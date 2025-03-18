import 'dart:async';
import 'dart:collection';

import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

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
    required CexRepository priceRepository,
    required KomodoPriceRepository komodoPriceRepository,
  }) : _priceRepository = priceRepository,
       _komodoPriceRepository = komodoPriceRepository;

  static const _cacheClearInterval = Duration(minutes: 5);
  Timer? _cacheTimer;

  @override
  Future<void> init() async {
    // Initialize any resources if needed
    _knownTickers = UnmodifiableSetView(
      (await _priceRepository.getCoinList()).map((e) => e.id).toSet(),
    );

    // Start cache clearing timer
    _cacheTimer = Timer.periodic(_cacheClearInterval, (_) => _clearCaches());
  }

  Set<String>? _knownTickers;

  final CexRepository _priceRepository;
  final KomodoPriceRepository _komodoPriceRepository;
  bool _isDisposed = false;

  // Cache to store asset prices
  final Map<String, Decimal> _priceCache = {};

  // Cache to store 24h price changes
  final Map<String, Decimal> _priceChangeCache = {};

  /// Clears all cached data to ensure fresh values are fetched
  void _clearCaches() {
    if (_isDisposed) return;
    _priceCache.clear();
    _priceChangeCache.clear();
  }

  // Helper method to generate cache keys
  String _getCacheKey(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  }) {
    return '${assetId.id}_${fiatCurrency}_${priceDate?.millisecondsSinceEpoch ?? 'current'}';
  }

  // Helper method to generate change cache keys
  String _getChangeCacheKey(AssetId assetId, {String fiatCurrency = 'usdt'}) {
    return '${assetId.id}_${fiatCurrency}_change24h';
  }

  

  @override
  Decimal? priceIfKnown(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  }) {
    if (_isDisposed) {
      throw StateError('PriceManager has been disposed');
    }

    final cacheKey = _getCacheKey(
      assetId,
      priceDate: priceDate,
      fiatCurrency: fiatCurrency,
    );

    return _priceCache[cacheKey];
  }

  @override
  Future<Decimal> fiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCurrency = 'usdt',
  }) async {
    if (_isDisposed) {
      throw StateError('PriceManager has been disposed');
    }
    _assertInitialized();

    final cacheKey = _getCacheKey(
      assetId,
      priceDate: priceDate,
      fiatCurrency: fiatCurrency,
    );

    // Check cache first
    final cachedPrice = _priceCache[cacheKey];
    if (cachedPrice != null) {
      return cachedPrice;
    }

    try {
      final priceDouble = await _priceRepository.getCoinFiatPrice(
        assetId.id,
        priceDate: priceDate,
        fiatCoinId: fiatCurrency,
      );

      // Convert double to Decimal via string
      final price = Decimal.parse(priceDouble.toString());

      // Cache the result
      _priceCache[cacheKey] = price;

      return price;
    } catch (e) {
      throw StateError('Failed to get price for ${assetId.name}: $e');
    }
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
    final cachedPrice = _priceCache[cacheKey];
    if (cachedPrice != null) {
      return cachedPrice;
    }

    final maybeKnownTicker =
        assetId.symbol.binanceId ?? assetId.symbol.configSymbol;

    final isKnownTicker = _knownTickers?.contains(maybeKnownTicker) ?? false;

    if (!isKnownTicker) {
      return null;
    }

    try {
      final price = await fiatPrice(
        assetId,
        priceDate: priceDate,
        fiatCurrency: fiatCurrency,
      );
      return price;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Decimal?> priceChange24h(
    AssetId assetId, {
    String fiatCurrency = 'usdt',
  }) async {
    if (_isDisposed) {
      throw StateError('PriceManager has been disposed');
    }
    _assertInitialized();

    final cacheKey = _getChangeCacheKey(assetId, fiatCurrency: fiatCurrency);

    // Check cache first
    final cachedChange = _priceChangeCache[cacheKey];
    if (cachedChange != null) {
      return cachedChange;
    }

    try {
      // Get Komodo prices data which contains 24h change info
      final prices = await _komodoPriceRepository.getKomodoPrices();

      // Find the price for the requested asset
      final priceData = prices[assetId.id];

      if (priceData == null || priceData.change24h == null) {
        return null;
      }

      // Convert to Decimal
      final change = Decimal.parse(priceData.change24h.toString());

      // Cache the result
      _priceChangeCache[cacheKey] = change;

      return change;
    } catch (e) {
      // If there's an error, return null instead of throwing
      return null;
    }
  }

  @override
  Future<Map<DateTime, Decimal>> fiatPriceHistory(
    AssetId assetId,
    List<DateTime> dates, {
    String fiatCurrency = 'usdt',
  }) async {
    if (_isDisposed) {
      throw StateError('PriceManager has been disposed');
    }

    _assertInitialized();

    try {
      final priceDoubleMap = await _priceRepository.getCoinFiatPrices(
        assetId.id,
        dates,
        fiatCoinId: fiatCurrency,
      );

      // Convert double values to Decimal via string
      final priceMap = priceDoubleMap.map(
        (key, value) => MapEntry(key, Decimal.parse(value.toString())),
      );

      // Cache the historical prices
      for (final entry in priceMap.entries) {
        final cacheKey = _getCacheKey(
          assetId,
          priceDate: entry.key,
          fiatCurrency: fiatCurrency,
        );
        _priceCache[cacheKey] = entry.value;
      }

      return priceMap;
    } catch (e) {
      throw StateError(
        'Failed to get historical prices for ${assetId.name}: $e',
      );
    }
  }

  void _assertInitialized() {
    if (_knownTickers == null) {
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
  }
}
