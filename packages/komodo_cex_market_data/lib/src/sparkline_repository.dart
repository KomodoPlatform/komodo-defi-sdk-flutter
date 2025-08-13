import 'dart:async';

import 'package:hive/hive.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

// TODO: create higher-level abstraction and move to SDK to avoid duplicating
// repositories and creating global variables like these
// Global CoinGecko repository instance for backward compatibility
final CoinGeckoRepository _coinGeckoRepository = CoinGeckoRepository(
  coinGeckoProvider: CoinGeckoCexProvider(),
);
final BinanceRepository _binanceRepository = BinanceRepository(
  binanceProvider: const BinanceProvider(),
);

SparklineRepository sparklineRepository = SparklineRepository();

class SparklineRepository with RepositoryFallbackMixin {
  /// Creates a new SparklineRepository with the given repositories.
  ///
  /// If repositories are not provided, defaults to Binance and CoinGecko.
  SparklineRepository({
    List<CexRepository>? repositories,
    RepositorySelectionStrategy? selectionStrategy,
  }) : _repositories =
           repositories ?? [_binanceRepository, _coinGeckoRepository],
       _selectionStrategy =
           selectionStrategy ?? DefaultRepositorySelectionStrategy();
  static final Logger _logger = Logger('SparklineRepository');

  final List<CexRepository> _repositories;
  final RepositorySelectionStrategy _selectionStrategy;
  bool isInitialized = false;
  final Duration cacheExpiry = const Duration(hours: 1);
  Box<Map<String, dynamic>>? _box;

  @override
  List<CexRepository> get priceRepositories => _repositories;

  @override
  RepositorySelectionStrategy get selectionStrategy => _selectionStrategy;

  /// Initialize the Hive box
  Future<void> init() async {
    if (isInitialized) {
      _logger.fine('init() called but already initialized');
      return;
    }

    // Check if the Hive box is already open
    if (!Hive.isBoxOpen('sparkline_data')) {
      try {
        _box = await Hive.openBox<Map<String, dynamic>>('sparkline_data');
        _logger.info('SparklineRepository initialized and Hive box opened');
      } catch (e, st) {
        _box = null;
        _logger.severe('Failed to open Hive box sparkline_data', e, st);
        throw Exception('Failed to open Hive box: $e');
      }

      isInitialized = true;
    }
  }

  /// Fetches sparkline data for the given symbol with fallback support
  ///
  /// Uses RepositoryFallbackMixin to select a supporting repository and
  /// automatically retry with backoff. Returns cached data if available and
  /// not expired.
  Future<List<double>?> fetchSparkline(AssetId assetId) async {
    final symbol = assetId.symbol.configSymbol;

    if (!isInitialized) {
      _logger.severe('fetchSparkline called before init for $symbol');
      throw Exception('SparklineRepository is not initialized');
    }
    if (_box == null) {
      _logger.severe('Hive box is null during fetchSparkline for $symbol');
      throw Exception('Hive box is not initialized');
    }

    // Check if data is cached and not expired
    if (_box!.containsKey(symbol)) {
      final cachedData = _box!.get(symbol)?.cast<String, dynamic>();
      if (cachedData != null) {
        final cachedTime = DateTime.parse(cachedData['timestamp'] as String);
        if (DateTime.now().difference(cachedTime) < cacheExpiry) {
          final data = cachedData['data'];
          final result = data != null ? (data as List).cast<double>() : null;
          _logger.fine(
            'Cache hit for $symbol; returning ${result?.length ?? 0} points',
          );
          return result;
        }
        _logger.fine('Cache expired for $symbol; refetching');
      }
    }

    // USDT special case (constant price)
    if (symbol.split('-').firstOrNull?.toUpperCase() == 'USDT') {
      _logger.fine('Using straightline stablecoin sparkline for $symbol');
      return _createStraightlineStableCoinSparkline(symbol);
    }

    // Build request context
    final startAt = DateTime.now().subtract(const Duration(days: 7));
    final endAt = DateTime.now();
    const quoteCurrency = Stablecoin.usdt;

    // Use fallback mixin to pick a supporting repo and retry if needed
    _logger.fine('Fetching OHLC for $symbol with fallback across repositories');
    final sparklineData = await tryRepositoriesInOrderMaybe<
      List<double>
    >(assetId, quoteCurrency, PriceRequestType.priceHistory, (repo) async {
      // Preflight support check to avoid making unsupported requests
      if (!await repo.supports(
        assetId,
        quoteCurrency,
        PriceRequestType.priceHistory,
      )) {
        _logger.fine(
          'Repository ${repo.runtimeType} does not support $symbol/$quoteCurrency',
        );
        throw StateError(
          'Repository ${repo.runtimeType} does not support $symbol/$quoteCurrency',
        );
      }
      final ohlcData = await repo.getCoinOhlc(
        assetId,
        quoteCurrency,
        GraphInterval.oneDay,
        startAt: startAt,
        endAt: endAt,
      );
      final data = ohlcData.ohlc.map((e) => e.close).toList();
      if (data.isEmpty) {
        _logger.fine('Empty OHLC data for $symbol from ${repo.runtimeType}');
        throw StateError(
          'Empty OHLC data for $symbol from ${repo.runtimeType}',
        );
      }
      _logger.fine(
        'Fetched ${data.length} close prices for $symbol from ${repo.runtimeType}',
      );
      return data;
    }, 'sparklineFetch');

    if (sparklineData != null && sparklineData.isNotEmpty) {
      await _box!.put(symbol, {
        'data': sparklineData,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _logger.fine(
        'Cached sparkline for $symbol with ${sparklineData.length} points',
      );
      return sparklineData;
    }

    // If all repositories failed, cache null result to avoid repeated attempts
    await _box!.put(symbol, {
      'data': null,
      'timestamp': DateTime.now().toIso8601String(),
    });
    _logger.warning(
      'All repositories failed fetching sparkline for $symbol; cached null',
    );
    return null;
  }

  Future<List<double>> _createStraightlineStableCoinSparkline(
    String symbol,
  ) async {
    final startAt = DateTime.now().subtract(const Duration(days: 7));
    final endAt = DateTime.now();
    final interval = endAt.difference(startAt).inSeconds ~/ 500;
    _logger.fine('Generating constant-price sparkline for $symbol');
    final ohlcData = CoinOhlc.fromConstantPrice(
      startAt: startAt,
      endAt: endAt,
      intervalSeconds: interval,
    );
    final constantData = ohlcData.ohlc.map((e) => e.close).toList();
    await _box!.put(symbol, {
      'data': constantData,
      'timestamp': DateTime.now().toIso8601String(),
    });
    _logger.fine(
      'Cached constant-price sparkline for $symbol with ${constantData.length} points',
    );
    return constantData;
  }
}
