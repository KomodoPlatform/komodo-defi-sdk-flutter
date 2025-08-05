import 'dart:async';
import 'dart:collection';

import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart' show retry;
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

// TODO: Add streaming support for price updates. The challenges share a lot
// of similarities with the balance manager. Investigate if we can create a
// generic manager class for such cases.

/// Interface defining the contract for price management operations
abstract class MarketDataManager {
  Future<void> init();

  /// Gets the current fiat price for an asset
  ///
  /// Throws [ArgumentError] if asset is not found
  /// May throw [TimeoutException] if price fetch times out
  Future<Decimal> fiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  });

  /// Gets the current fiat price for an asset if the CEX data is available
  Future<Decimal?> maybeFiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  });

  /// Gets the price for an asset if it's cached, returns null otherwise
  Decimal? priceIfKnown(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  });

  /// Gets historical fiat prices for an asset at specified dates
  ///
  /// Returns a map of dates to prices
  Future<Map<DateTime, Decimal>> fiatPriceHistory(
    AssetId assetId,
    List<DateTime> dates, {
    String fiatCurrency = 'usdt',
  });

  /// Gets the 24-hour price change percentage for an asset
  ///
  /// Returns the percentage change as a decimal value (e.g., 0.05 for 5% increase)
  /// Returns null if the change data is not available
  ///
  /// Note: This method will likely be deprecated in the future in favor of a
  /// more flexible method that provides data for various time periods.
  ///
  /// Throws [ArgumentError] if asset is not found
  /// May throw [TimeoutException] if price fetch times out
  Future<Decimal?> priceChange24h(
    AssetId assetId, {
    String fiatCurrency = 'usdt',
  });

  /// Disposes of all resources
  Future<void> dispose();
}

/// Implementation of the [MarketDataManager] interface for managing asset prices
class CexMarketDataManager implements MarketDataManager {
  /// Creates a new instance of [CexMarketDataManager]
  CexMarketDataManager({
    required List<CexRepository> priceRepositories,
    required KomodoPriceRepository komodoPriceRepository,
    RepositorySelectionStrategy? selectionStrategy,
  }) : _priceRepositories = priceRepositories,
       _komodoPriceRepository = komodoPriceRepository,
       _selectionStrategy = selectionStrategy ?? RepositorySelectionStrategy();
  static final _logger = Logger('CexMarketDataManager');

  static const _cacheClearInterval = Duration(minutes: 5);
  Timer? _cacheTimer;

  @override
  Future<void> init() async {
    // Initialize known tickers from all repositories
    final allTickers = <String>{};
    for (final repo in _priceRepositories) {
      try {
        final coins = await repo.getCoinList();
        allTickers.addAll(coins.map((e) => e.symbol));
        _logger.finer(
          'Loaded ${coins.length} coins from repository: ${repo.runtimeType}',
        );
      } catch (e, s) {
        // Log error but continue with other repositories
        _logger.info('Failed to get coin list from repository: $e');
        _logger.finest('Stack trace: $s');
      }
    }
    _knownTickers = UnmodifiableSetView(allTickers);
    _logger.fine('Initialized known tickers: ${_knownTickers?.length ?? 0}');
    // Start cache clearing timer
    _cacheTimer = Timer.periodic(_cacheClearInterval, (_) => _clearCaches());
    _logger.finer(
      'Started cache clearing timer with interval $_cacheClearInterval',
    );
  }

  Set<String>? _knownTickers;

  final List<CexRepository> _priceRepositories;
  final KomodoPriceRepository _komodoPriceRepository;
  final RepositorySelectionStrategy _selectionStrategy;
  bool _isDisposed = false;

  // Cache to store asset prices
  final Map<String, Decimal> _priceCache = {};

  // Cache to store 24h price changes
  final Map<String, Decimal> _priceChangeCache = {};

  /// Clears all cached data to ensure fresh values are fetched
  void _clearCaches() {
    if (_isDisposed) return;
    _logger.finer('Clearing price and price change caches');
    _priceCache.clear();
    _priceChangeCache.clear();
  }

  // Helper method to generate cache keys
  String _getCacheKey(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  }) {
    return '${assetId.symbol.configSymbol}_${fiatCurrency}_${priceDate?.millisecondsSinceEpoch ?? 'current'}';
  }

  // Helper method to generate change cache keys
  String _getChangeCacheKey(AssetId assetId, {String fiatCurrency = 'usdt'}) {
    return '${assetId.symbol.configSymbol}_${fiatCurrency}_change24h';
  }

  /// Validates that the manager hasn't been disposed
  void _checkNotDisposed() {
    if (_isDisposed) {
      _logger.warning('Attempted to use manager after dispose');
      throw StateError('PriceManager has been disposed');
    }
  }

  /// Gets cached price if available, returns null otherwise
  Decimal? _getCachedPrice(String cacheKey) {
    final cachedPrice = _priceCache[cacheKey];
    if (cachedPrice != null) {
      _logger.finer('Cache hit for $cacheKey');
    }
    return cachedPrice;
  }

  /// Selects appropriate repository for price requests
  Future<CexRepository?> _selectRepositoryForRequest(
    AssetId assetId,
    String fiatCurrency,
    PriceRequestType requestType,
  ) async {
    final fiatAssetId = AssetId.fromFiatTicker(fiatCurrency);
    return _selectionStrategy.selectRepository(
      assetId: assetId,
      fiatAssetId: fiatAssetId,
      requestType: requestType,
      availableRepositories: _priceRepositories,
    );
  }

  /// Fetches price from repository and caches the result
  Future<Decimal> _fetchAndCachePrice(
    CexRepository repo,
    AssetId assetId,
    String cacheKey, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  }) async {
    final priceDouble = await retry(
      () => repo.getCoinFiatPrice(
        assetId,
        priceDate: priceDate,
        fiatCoinId: fiatCurrency,
      ),
      maxAttempts: 3,
    );
    final price = Decimal.parse(priceDouble.toString());
    _priceCache[cacheKey] = price;
    _logger.finer(
      'Fetched price from ${repo.runtimeType} for ${assetId.symbol.configSymbol}: $price',
    );
    return price;
  }

  /// Generic method for cache-first execution pattern
  Future<T> _executeWithCache<T>(
    String cacheKey,
    Future<T> Function() fetcher,
    Map<String, T> cache,
  ) async {
    // Check cache first
    final cached = cache[cacheKey];
    if (cached != null) {
      _logger.finer('Cache hit for $cacheKey');
      return cached;
    }

    // Fetch and cache
    final result = await fetcher();
    cache[cacheKey] = result;
    return result;
  }

  @override
  Decimal? priceIfKnown(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  }) {
    _checkNotDisposed();

    final cacheKey = _getCacheKey(
      assetId,
      priceDate: priceDate,
      fiatCurrency: fiatCurrency,
    );

    return _getCachedPrice(cacheKey);
  }

  @override
  Future<Decimal> fiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  }) async {
    _checkNotDisposed();
    _assertInitialized();

    final cacheKey = _getCacheKey(
      assetId,
      priceDate: priceDate,
      fiatCurrency: fiatCurrency,
    );

    // Check cache first
    final cachedPrice = _getCachedPrice(cacheKey);
    if (cachedPrice != null) {
      return cachedPrice;
    }

    // Select repository
    final repo = await _selectRepositoryForRequest(
      assetId,
      fiatCurrency,
      PriceRequestType.currentPrice,
    );
    if (repo == null) {
      _logger.shout(
        'No repository supports ${assetId.symbol.configSymbol}/$fiatCurrency for current price',
      );
      throw StateError(
        'No repository supports ${assetId.symbol.configSymbol}/$fiatCurrency for current price',
      );
    }

    return _fetchAndCachePrice(
      repo,
      assetId,
      cacheKey,
      priceDate: priceDate,
      fiatCurrency: fiatCurrency,
    );
  }

  @override
  Future<Decimal?> maybeFiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  }) async {
    _assertInitialized();

    final cacheKey = _getCacheKey(
      assetId,
      priceDate: priceDate,
      fiatCurrency: fiatCurrency,
    );

    // Check cache first
    final cachedPrice = _getCachedPrice(cacheKey);
    if (cachedPrice != null) {
      return cachedPrice;
    }

    // Select repository
    final repo = await _selectRepositoryForRequest(
      assetId,
      fiatCurrency,
      PriceRequestType.currentPrice,
    );
    if (repo == null) {
      _logger.finer(
        'No repository supports ${assetId.symbol.configSymbol}/$fiatCurrency for maybeFiatPrice',
      );
      return null;
    }

    try {
      return await _fetchAndCachePrice(
        repo,
        assetId,
        cacheKey,
        priceDate: priceDate,
        fiatCurrency: fiatCurrency,
      );
    } catch (e, s) {
      _logger
        ..fine('maybeFiatPrice failed for ${assetId.symbol.configSymbol}: $e')
        ..finest('Stack trace: $s');
      return null;
    }
  }

  @override
  Future<Decimal?> priceChange24h(
    AssetId assetId, {
    String fiatCurrency = 'usdt',
  }) async {
    _checkNotDisposed();
    _assertInitialized();

    final cacheKey = _getChangeCacheKey(assetId, fiatCurrency: fiatCurrency);

    return _executeWithCache(cacheKey, () async {
      try {
        // Get Komodo prices data which contains 24h change info
        final prices = await _komodoPriceRepository.getKomodoPrices();

        // Find the price for the requested asset
        final priceData = prices[assetId.symbol.configSymbol];

        if (priceData == null || priceData.change24h == null) {
          _logger.finer(
            'No 24h change data for ${assetId.symbol.configSymbol}',
          );
          return null;
        }

        // Convert to Decimal
        final change = Decimal.parse(priceData.change24h.toString());
        _logger.finer(
          'Fetched 24h change for ${assetId.symbol.configSymbol}: $change',
        );
        return change;
      } catch (e, s) {
        // If there's an error, return null instead of throwing
        _logger
          ..fine(
            'Failed to get 24h change for ${assetId.symbol.configSymbol}: $e',
          )
          ..finest('Stack trace: $s');
        return null;
      }
    }, _priceChangeCache);
  }

  @override
  Future<Map<DateTime, Decimal>> fiatPriceHistory(
    AssetId assetId,
    List<DateTime> dates, {
    String fiatCurrency = 'usdt',
  }) async {
    _checkNotDisposed();
    _assertInitialized();

    final cached = <DateTime, Decimal>{};
    final missingDates = <DateTime>[];

    // Check cache for each date
    for (final date in dates) {
      final cacheKey = _getCacheKey(
        assetId,
        priceDate: date,
        fiatCurrency: fiatCurrency,
      );
      final cachedPrice = _getCachedPrice(cacheKey);
      if (cachedPrice != null) {
        cached[date] = cachedPrice;
      } else {
        missingDates.add(date);
      }
    }

    if (missingDates.isEmpty) {
      return cached;
    }

    // Select repository for missing dates
    final repo = await _selectRepositoryForRequest(
      assetId,
      fiatCurrency,
      PriceRequestType.priceHistory,
    );
    if (repo == null) {
      _logger.shout(
        'No repository supports ${assetId.symbol.configSymbol}/$fiatCurrency for price history',
      );
      throw StateError(
        'No repository supports ${assetId.symbol.configSymbol}/$fiatCurrency for price history',
      );
    }

    // Fetch missing prices
    final priceDoubleMap = await retry(
      () => repo.getCoinFiatPrices(
        assetId,
        missingDates,
        fiatCoinId: fiatCurrency,
      ),
      maxAttempts: 3,
    );

    // Convert to Decimal, cache, and merge with cached
    final priceMap = priceDoubleMap.map((date, value) {
      final dec = Decimal.parse(value.toString());
      final cacheKey = _getCacheKey(
        assetId,
        priceDate: date,
        fiatCurrency: fiatCurrency,
      );
      _priceCache[cacheKey] = dec;
      return MapEntry(date, dec);
    });

    return {...cached, ...priceMap};
  }

  void _assertInitialized() {
    if (_knownTickers == null) {
      _logger.shout('CexMarketDataManager used before initialization');
      throw StateError('PriceManager has not been initialized');
    }
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _cacheTimer?.cancel();
    _cacheTimer = null;
    _priceCache.clear();
    _priceChangeCache.clear();
    _logger.fine('Disposed CexMarketDataManager');
  }
}
