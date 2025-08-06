import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
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
    QuoteCurrency quoteCurrency = Stablecoin.usdt,
  });

  /// Gets the current fiat price for an asset if the CEX data is available
  Future<Decimal?> maybeFiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    QuoteCurrency quoteCurrency = Stablecoin.usdt,
  });

  /// Gets the price for an asset if it's cached, returns null otherwise
  Decimal? priceIfKnown(
    AssetId assetId, {
    DateTime? priceDate,
    QuoteCurrency quoteCurrency = Stablecoin.usdt,
  });

  /// Gets historical fiat prices for an asset at specified dates
  ///
  /// Returns a map of dates to prices
  Future<Map<DateTime, Decimal>> fiatPriceHistory(
    AssetId assetId,
    List<DateTime> dates, {
    QuoteCurrency quoteCurrency = Stablecoin.usdt,
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
    QuoteCurrency quoteCurrency = Stablecoin.usdt,
  });

  /// Disposes of all resources
  Future<void> dispose();
}

/// Implementation of the [MarketDataManager] interface for managing asset prices
class CexMarketDataManager implements MarketDataManager {
  /// Creates a new instance of [CexMarketDataManager]
  CexMarketDataManager({
    required List<CexRepository> priceRepositories,
    RepositorySelectionStrategy? selectionStrategy,
  }) : _priceRepositories = priceRepositories,
       _selectionStrategy =
           selectionStrategy ?? DefaultRepositorySelectionStrategy();

  static final _logger = Logger('CexMarketDataManager');
  static const _cacheClearInterval = Duration(minutes: 5);
  Timer? _cacheTimer;

  @override
  Future<void> init() async {
    for (final repo in _priceRepositories) {
      try {
        final coins = await repo.getCoinList();
        _logger.finer(
          'Loaded ${coins.length} coins from repository: ${repo.runtimeType}',
        );
      } catch (e, s) {
        // Log error but continue with other repositories
        _logger
          ..info('Failed to get coin list from repository: $e')
          ..finest('Stack trace: $s');
      }
    }

    // Start cache clearing timer
    _cacheTimer = Timer.periodic(_cacheClearInterval, (_) => _clearCaches);
    _logger.finer(
      'Started cache clearing timer with interval $_cacheClearInterval',
    );

    _isInitialized = true;
  }

  final List<CexRepository> _priceRepositories;
  final RepositorySelectionStrategy _selectionStrategy;
  bool _isDisposed = false;
  bool _isInitialized = false;

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
    QuoteCurrency quoteCurrency = Stablecoin.usdt,
  }) {
    return '${assetId.symbol.configSymbol}_${quoteCurrency}_'
        '${priceDate?.millisecondsSinceEpoch ?? 'current'}';
  }

  // Helper method to generate change cache keys
  String _getChangeCacheKey(
    AssetId assetId, {
    QuoteCurrency quoteCurrency = Stablecoin.usdt,
  }) {
    return '${assetId.symbol.configSymbol}_${quoteCurrency}_change24h';
  }

  /// Validates that the manager hasn't been disposed
  void _checkNotDisposed() {
    if (_isDisposed) {
      _logger.warning('Attempted to use manager after dispose');
      throw StateError('PriceManager has been disposed');
    }
  }

  /// Validates that the manager has been initialized
  void _assertInitialized() {
    if (!_isInitialized) {
      _logger.warning('Attempted to use manager before initialization');
      throw StateError('MarketDataManager must be initialized before use');
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

  /// Fetches price from repository and caches the result
  Future<Decimal> _fetchAndCachePrice(
    CexRepository repo,
    AssetId assetId,
    String cacheKey, {
    DateTime? priceDate,
    QuoteCurrency quoteCurrency = Stablecoin.usdt,
  }) async {
    final priceDouble = await retry(
      () => repo.getCoinFiatPrice(
        assetId,
        priceDate: priceDate,
        fiatCurrency: quoteCurrency,
      ),
      maxAttempts: 3,
    );
    final price = Decimal.parse(priceDouble.toString());
    _priceCache[cacheKey] = price;
    _logger.finer(
      'Fetched price from ${repo.runtimeType} for '
      '${assetId.symbol.configSymbol}: $price',
    );
    return price;
  }

  @override
  Decimal? priceIfKnown(
    AssetId assetId, {
    DateTime? priceDate,
    QuoteCurrency quoteCurrency = Stablecoin.usdt,
  }) {
    _checkNotDisposed();

    final cacheKey = _getCacheKey(
      assetId,
      priceDate: priceDate,
      quoteCurrency: quoteCurrency,
    );

    return _getCachedPrice(cacheKey);
  }

  @override
  Future<Decimal> fiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    QuoteCurrency quoteCurrency = Stablecoin.usdt,
  }) async {
    _checkNotDisposed();
    _assertInitialized();

    final cacheKey = _getCacheKey(
      assetId,
      priceDate: priceDate,
      quoteCurrency: quoteCurrency,
    );

    // Check cache first
    final cachedPrice = _getCachedPrice(cacheKey);
    if (cachedPrice != null) {
      return cachedPrice;
    }

    // Select repository
    final repo = await _selectionStrategy.selectRepository(
      assetId: assetId,
      fiatCurrency: quoteCurrency,
      requestType: PriceRequestType.currentPrice,
      availableRepositories: _priceRepositories,
    );
    if (repo == null) {
      _logger.shout(
        'No repository supports ${assetId.symbol.configSymbol}/$quoteCurrency for current price',
      );
      throw StateError(
        'No repository supports ${assetId.symbol.configSymbol}/$quoteCurrency for current price',
      );
    }

    return _fetchAndCachePrice(
      repo,
      assetId,
      cacheKey,
      priceDate: priceDate,
      quoteCurrency: quoteCurrency,
    );
  }

  @override
  Future<Decimal?> maybeFiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    QuoteCurrency quoteCurrency = Stablecoin.usdt,
  }) async {
    _assertInitialized();

    final cacheKey = _getCacheKey(
      assetId,
      priceDate: priceDate,
      quoteCurrency: quoteCurrency,
    );

    // Check cache first
    final cachedPrice = _getCachedPrice(cacheKey);
    if (cachedPrice != null) {
      return cachedPrice;
    }

    // Select repository
    final repo = await _selectionStrategy.selectRepository(
      assetId: assetId,
      fiatCurrency: quoteCurrency,
      requestType: PriceRequestType.currentPrice,
      availableRepositories: _priceRepositories,
    );
    if (repo == null) {
      _logger.finer(
        'No repository supports ${assetId.symbol.configSymbol}/$quoteCurrency for maybeFiatPrice',
      );
      return null;
    }

    try {
      return await _fetchAndCachePrice(
        repo,
        assetId,
        cacheKey,
        priceDate: priceDate,
        quoteCurrency: quoteCurrency,
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
    QuoteCurrency quoteCurrency = Stablecoin.usdt,
  }) async {
    _checkNotDisposed();
    _assertInitialized();

    final cacheKey = _getChangeCacheKey(assetId, quoteCurrency: quoteCurrency);
    final cached = _priceChangeCache[cacheKey];
    if (cached != null) {
      _logger.finer('Cache hit for $cacheKey');
      return cached;
    }

    // Select repository
    final repo = await _selectionStrategy.selectRepository(
      assetId: assetId,
      fiatCurrency: quoteCurrency,
      requestType: PriceRequestType.priceChange,
      availableRepositories: _priceRepositories,
    );
    if (repo == null) {
      _logger.finer(
        'No repository supports ${assetId.symbol.configSymbol}/$quoteCurrency for maybeFiatPrice',
      );
      return null;
    }

    try {
      final priceChange = await retry(
        () => repo.getCoin24hrPriceChange(assetId, fiatCurrency: quoteCurrency),
        maxAttempts: 3,
      );

      _priceChangeCache[cacheKey] = priceChange;
      _logger.finer(
        'Fetched 24h price change from ${repo.runtimeType} for '
        '${assetId.symbol.configSymbol}: $priceChange',
      );
      return priceChange;
    } catch (e, s) {
      _logger
        ..fine('maybeFiatPrice failed for ${assetId.symbol.configSymbol}: $e')
        ..finest('Stack trace: $s');
      return null;
    }
  }

  @override
  Future<Map<DateTime, Decimal>> fiatPriceHistory(
    AssetId assetId,
    List<DateTime> dates, {
    QuoteCurrency quoteCurrency = Stablecoin.usdt,
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
        quoteCurrency: quoteCurrency,
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
    final repo = await _selectionStrategy.selectRepository(
      assetId: assetId,
      fiatCurrency: quoteCurrency,
      requestType: PriceRequestType.priceHistory,
      availableRepositories: _priceRepositories,
    );
    if (repo == null) {
      _logger.shout(
        'No repository supports ${assetId.symbol.configSymbol}/$quoteCurrency for price history',
      );
      throw StateError(
        'No repository supports ${assetId.symbol.configSymbol}/$quoteCurrency for price history',
      );
    }

    // Fetch missing prices
    final priceDoubleMap = await retry(
      () => repo.getCoinFiatPrices(
        assetId,
        missingDates,
        fiatCurrency: quoteCurrency,
      ),
      maxAttempts: 3,
    );

    // Convert to Decimal, cache, and merge with cached
    final priceMap = priceDoubleMap.map((date, value) {
      final dec = Decimal.parse(value.toString());
      final cacheKey = _getCacheKey(
        assetId,
        priceDate: date,
        quoteCurrency: quoteCurrency,
      );
      _priceCache[cacheKey] = dec;
      return MapEntry(date, dec);
    });

    return {...cached, ...priceMap};
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _isInitialized = false;
    _cacheTimer?.cancel();
    _cacheTimer = null;
    _priceCache.clear();
    _priceChangeCache.clear();
    _logger.fine('Disposed CexMarketDataManager');
  }
}
