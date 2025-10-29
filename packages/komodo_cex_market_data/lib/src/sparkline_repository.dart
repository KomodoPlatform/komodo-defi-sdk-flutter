import 'dart:async';

import 'package:hive_ce/hive.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// Repository for fetching sparkline data
// TODO: create higher-level abstraction and move to SDK
class SparklineRepository with RepositoryFallbackMixin {
  /// Creates a new SparklineRepository with the given repositories.
  ///
  /// If repositories are not provided, defaults to Binance and CoinGecko.
  SparklineRepository(
    this._repositories, {
    RepositorySelectionStrategy? selectionStrategy,
  }) : _selectionStrategy =
           selectionStrategy ?? DefaultRepositorySelectionStrategy();

  /// Creates a new SparklineRepository with the default repositories.
  ///
  /// Default repositories are Binance, CoinGecko, and CoinPaprika.
  factory SparklineRepository.defaultInstance() {
    return SparklineRepository([
      BinanceRepository(binanceProvider: const BinanceProvider()),
      CoinPaprikaRepository(
        coinPaprikaProvider: CoinPaprikaProvider(),
        ownsProvider: true,
      ),
      CoinGeckoRepository(coinGeckoProvider: CoinGeckoCexProvider()),
    ], selectionStrategy: DefaultRepositorySelectionStrategy());
  }

  static final Logger _logger = Logger('SparklineRepository');
  final List<CexRepository> _repositories;
  final RepositorySelectionStrategy _selectionStrategy;

  /// Indicates whether the repository has been initialized
  bool isInitialized = false;

  /// Duration for which the cache is valid
  final Duration cacheExpiry = const Duration(hours: 1);
  Box<SparklineData>? _box;

  /// Map to track ongoing requests and prevent duplicate requests for the
  /// same symbol
  final Map<String, Future<List<double>?>> _inFlightRequests = {};

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

    await _initializeHiveBox();
    isInitialized = true;
  }

  /// Initializes the Hive box with error recovery
  Future<void> _initializeHiveBox() async {
    const boxName = 'sparkline_data';

    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<SparklineData>(boxName);
      _logger.fine('Hive box $boxName was already open');
      return;
    }

    // Register adapters before opening box
    registerHiveAdapters();

    try {
      _box = await _openHiveBox(boxName);
      _logger.info(
        'SparklineRepository initialized and Hive box opened successfully',
      );
    } catch (e, st) {
      _logger.warning(
        'Initial attempt to open Hive box failed, attempting recovery',
        e,
        st,
      );
      await _recoverCorruptedHiveBox(boxName);
      _box = await _openHiveBox(boxName);
      _logger.info('SparklineRepository initialized after Hive box recovery');
    }
  }

  /// Opens the Hive box
  Future<Box<SparklineData>> _openHiveBox(String boxName) async {
    try {
      return await Hive.openBox<SparklineData>(boxName);
    } catch (e, st) {
      _logger.severe('Failed to open Hive box $boxName', e, st);
      rethrow;
    }
  }

  /// Recovers from a corrupted Hive box by deleting and recreating it
  Future<void> _recoverCorruptedHiveBox(String boxName) async {
    try {
      _logger.info('Attempting to recover corrupted Hive box: $boxName');

      // Try to delete the corrupted box
      await Hive.deleteBoxFromDisk(boxName);
      _logger.info('Successfully deleted corrupted Hive box: $boxName');
    } catch (deleteError, deleteSt) {
      _logger.severe(
        'Failed to delete corrupted Hive box $boxName during recovery',
        deleteError,
        deleteSt,
      );

      // If deletion fails, we still want to try opening a new box
      // The error will be handled by the caller
      throw Exception(
        'Failed to recover corrupted Hive box $boxName. '
        'Manual intervention may be required. Error: $deleteError',
      );
    }
  }

  /// Fetches sparkline data for the given symbol with request deduplication
  ///
  /// Uses RepositoryFallbackMixin to select a supporting repository and
  /// automatically retry with backoff. Returns cached data if available and
  /// not expired. Prevents duplicate concurrent requests for the same symbol.
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
    final cachedResult = _getCachedSparkline(symbol);
    if (cachedResult != null) {
      return cachedResult;
    }

    // Check if a request is already in flight for this symbol
    final existingRequest = _inFlightRequests[symbol];
    if (existingRequest != null) {
      _logger.fine(
        'Request already in flight for $symbol, returning existing future',
      );
      return existingRequest;
    }

    // Start new request and track it
    _logger.fine('Starting new request for $symbol');
    final future = _performSparklineFetch(assetId);
    _inFlightRequests[symbol] = future;

    // Clean up the in-flight map when request completes (success or failure)
    // Don't await this - let cleanup happen asynchronously so we can return
    // the future immediately for request deduplication
    unawaited(
      future.whenComplete(() {
        _inFlightRequests.remove(symbol);
        _logger.fine('Cleaned up in-flight request for $symbol');
      }),
    );

    return future;
  }

  /// Releases held resources such as HTTP clients and Hive boxes.
  Future<void> dispose() async {
    for (final repository in _repositories) {
      try {
        repository.dispose();
      } catch (e, st) {
        _logger.severe('Error disposing repository: $repository', e, st);
      }
    }

    final box = _box;
    if (box != null && box.isOpen) {
      try {
        await box.close();
      } catch (e, st) {
        _logger.severe('Error closing Hive box', e, st);
      }
    }
    _box = null;
    isInitialized = false;
  }

  /// Internal method to perform the actual sparkline fetch
  ///
  /// This is separated from fetchSparkline to enable proper request
  /// deduplication
  Future<List<double>?> _performSparklineFetch(AssetId assetId) async {
    final symbol = assetId.symbol.configSymbol;

    // Use quote currency utilities instead of hardcoded USDT check
    const quoteCurrency = Stablecoin.usdt;
    final assetAsQuote = QuoteCurrency.fromString(symbol);
    if (assetAsQuote != null && assetAsQuote == quoteCurrency) {
      _logger.fine('Using straightline stablecoin sparkline for $symbol');
      return _createStraightlineStableCoinSparkline(symbol);
    }

    // Build request context
    final startAt = DateTime.now().subtract(const Duration(days: 7));
    final endAt = DateTime.now();

    // Use fallback mixin to pick a supporting repo and retry if needed
    _logger.fine('Fetching OHLC for $symbol with fallback across repositories');
    final sparklineData = await tryRepositoriesInOrderMaybe<List<double>>(
      assetId,
      quoteCurrency,
      PriceRequestType.priceHistory,
      (repo) async {
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
        final data = ohlcData.ohlc
            .map((e) => e.closeDecimal.toDouble())
            .toList();
        if (data.isEmpty) {
          _logger.fine('Empty OHLC data for $symbol from ${repo.runtimeType}');
          throw StateError(
            'Empty OHLC data for $symbol from ${repo.runtimeType}',
          );
        }
        _logger.fine(
          'Fetched ${data.length} close prices for $symbol from '
          '${repo.runtimeType}',
        );
        return data;
      },
      'sparklineFetch',
    );

    if (sparklineData != null && sparklineData.isNotEmpty) {
      final cacheData = SparklineData.success(sparklineData);
      await _box!.put(symbol, cacheData);
      _logger.fine(
        'Cached sparkline for $symbol with ${sparklineData.length} points',
      );
      return sparklineData;
    }

    // If all repositories failed, cache null result to avoid repeated attempts
    final failedCacheData = SparklineData.failed();
    await _box!.put(symbol, failedCacheData);
    _logger.fine(
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
    final constantData = ohlcData.ohlc
        .map((e) => e.closeDecimal.toDouble())
        .toList();
    final cacheData = SparklineData.success(constantData);
    await _box!.put(symbol, cacheData);
    _logger.fine(
      'Cached constant-price sparkline for $symbol with '
      '${constantData.length} points',
    );
    return constantData;
  }

  List<double>? _getCachedSparkline(String symbol) {
    if (!_box!.containsKey(symbol)) {
      return null;
    }

    try {
      final raw = _box!.get(symbol);
      if (raw is! SparklineData) {
        _logger.fine(
          'Cache entry for $symbol has unexpected type: ${raw.runtimeType}; '
          'Clearing entry and skipping',
        );
        _box!.delete(symbol);
        return null;
      }

      if (raw.isExpired(cacheExpiry)) {
        _box!.delete(symbol);
        return null;
      }
      final data = raw.data;
      if (data != null) {
        _logger.fine(
          'Cache hit (typed) for $symbol; returning ${data.length} points',
        );
        return List<double>.unmodifiable(data);
      }
    } catch (e, s) {
      _logger.warning('Error reading cache for $symbol', e, s);
    }

    _logger.fine('Cache hit (typed) for $symbol but data null (failed)');
    return null;
  }
}
