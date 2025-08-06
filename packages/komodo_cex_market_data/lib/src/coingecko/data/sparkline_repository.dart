// ignore_for_file: strict_raw_type

import 'dart:async';

import 'package:hive/hive.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

// Global CoinGecko repository instance for backward compatibility
final CoinGeckoRepository _coinGeckoRepository = CoinGeckoRepository(
  coinGeckoProvider: CoinGeckoCexProvider(),
);
final BinanceRepository _binanceRepository = BinanceRepository(
  binanceProvider: BinanceProvider(),
);

SparklineRepository sparklineRepository = SparklineRepository();

class SparklineRepository {
  /// Creates a new SparklineRepository with optional repositories.
  ///
  /// If repositories are not provided, defaults to Binance and CoinGecko.
  SparklineRepository({List<CexRepository>? repositories})
    : _repositories =
          repositories ?? [_binanceRepository, _coinGeckoRepository];

  final Logger _log = Logger('SparklineRepository');
  final List<CexRepository> _repositories;
  bool isInitialized = false;
  final Duration cacheExpiry = const Duration(hours: 1);
  Box<Map<dynamic, dynamic>>? _box;

  /// Initialize the Hive box
  Future<void> init() async {
    if (isInitialized) {
      return;
    }

    // Check if the Hive box is already open
    if (!Hive.isBoxOpen('sparkline_data')) {
      try {
        _box = await Hive.openBox<Map>('sparkline_data');
      } catch (e) {
        _box = null;
        throw Exception('Failed to open Hive box: $e');
      }

      isInitialized = true;
    }
  }

  /// Fetches sparkline data for the given symbol with fallback support
  ///
  /// Tries repositories in order: Binance first, then CoinGecko
  /// Returns cached data if available and not expired
  Future<List<double>?> fetchSparkline(String symbol) async {
    if (!isInitialized) {
      throw Exception('SparklineRepository is not initialized');
    }
    if (_box == null) {
      throw Exception('Hive box is not initialized');
    }

    // Check if data is cached and not expired
    if (_box!.containsKey(symbol)) {
      final cachedData = _box!.get(symbol)?.cast<String, dynamic>();
      if (cachedData != null) {
        final cachedTime = DateTime.parse(cachedData['timestamp'] as String);
        if (DateTime.now().difference(cachedTime) < cacheExpiry) {
          final data = cachedData['data'];
          return data != null ? (data as List).cast<double>() : null;
        }
      }
    }

    // Try repositories in priority order (Binance first, then CoinGecko)
    final sortedRepos = RepositoryPriorityManager.sortBySparklinePriority(
      _repositories,
    );

    for (final repo in sortedRepos) {
      try {
        // Check if repository supports this asset
        if (!await _supportsAsset(repo, symbol)) {
          _log.finer('Repository ${repo.runtimeType} does not support $symbol');
          continue;
        }

        final sparklineData = await _fetchSparklineFromRepository(repo, symbol);
        if (sparklineData != null) {
          // Cache the successful result
          await _box!.put(symbol, {
            'data': sparklineData,
            'timestamp': DateTime.now().toIso8601String(),
          });
          return sparklineData;
        }
      } catch (e) {
        // Continue to next repository
        _log.warning(
          'Failed to fetch sparkline from ${repo.runtimeType} for $symbol: $e',
        );
        continue;
      }
    }

    // If all repositories failed, cache null result to avoid repeated attempts
    await _box!.put(symbol, {
      'data': null,
      'timestamp': DateTime.now().toIso8601String(),
    });
    return null;
  }

  /// Attempts to fetch sparkline data from a specific repository
  Future<List<double>?> _fetchSparklineFromRepository(
    CexRepository repo,
    String symbol,
  ) async {
    final startAt = DateTime.now().subtract(const Duration(days: 7));
    final endAt = DateTime.now();

    CoinOhlc ohlcData;

    // Handle USDT special case (constant price)
    if (symbol.split('-').firstOrNull?.toUpperCase() == 'USDT') {
      final interval = endAt.difference(startAt).inSeconds ~/ 500;
      ohlcData = CoinOhlc.fromConstantPrice(
        startAt: startAt,
        endAt: endAt,
        intervalSeconds: interval,
      );
    } else {
      ohlcData = await repo.getCoinOhlc(
        CexCoinPair(baseCoinTicker: symbol, relCoinTicker: 'USDT'),
        GraphInterval.oneDay,
        startAt: startAt,
        endAt: endAt,
      );
    }

    final sparklineData = ohlcData.ohlc.map((e) => e.close).toList();
    return sparklineData.isNotEmpty ? sparklineData : null;
  }

  /// Check if repository supports the given asset
  Future<bool> _supportsAsset(CexRepository repo, String symbol) async {
    try {
      final assetId = AssetId(
        id: symbol,
        name: symbol,
        symbol: AssetSymbol(assetConfigId: symbol),
        chainId: AssetChainId(chainId: 0),
        derivationPath: null,
        subClass: CoinSubClass.utxo,
      );
      final fiatAssetId = AssetId.fromFiatTicker('USDT');
      return await repo.supports(
        assetId,
        fiatAssetId,
        PriceRequestType.priceHistory,
      );
    } catch (e) {
      // If we can't check support, assume it might be supported
      return true;
    }
  }
}
