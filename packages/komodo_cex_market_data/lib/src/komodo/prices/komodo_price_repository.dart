import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/src/cex_repository.dart';
import 'package:komodo_cex_market_data/src/komodo/prices/komodo_price_provider.dart';
import 'package:komodo_cex_market_data/src/models/models.dart';
import 'package:komodo_cex_market_data/src/repository_selection_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A repository for fetching the prices of coins from the Komodo Defi API.
class KomodoPriceRepository extends CexRepository {
  /// Creates a new instance of [KomodoPriceRepository].
  KomodoPriceRepository({required IKomodoPriceProvider cexPriceProvider})
    : _cexPriceProvider = cexPriceProvider;

  /// The price provider to fetch the prices from.
  final IKomodoPriceProvider _cexPriceProvider;

  // Supported coins and vs currencies are not expected to change regularly,
  // so this in-memory cache is acceptable for now until a more complete and
  // robust caching strategy with cache invalidation is implemented.
  List<CexCoin>? _cachedCoinsList;
  Set<String>? _cachedFiatCurrencies;

  /// Cache for storing prices with timestamps
  Map<String, AssetMarketInformation>? _cachedPrices;
  DateTime? _cacheTimestamp;

  /// Future for pending cache refresh to prevent concurrent fetches
  Future<Map<String, AssetMarketInformation>>? _pendingFetch;

  /// Cache lifetime in minutes
  static const int _cacheLifetimeMinutes = 5;

  @override
  Future<CoinOhlc> getCoinOhlc(
    AssetId assetId,
    QuoteCurrency quoteCurrency,
    GraphInterval interval, {
    DateTime? startAt,
    DateTime? endAt,
    int? limit,
  }) async {
    throw UnsupportedError(
      'KomodoPriceRepository does not support OHLC data fetching',
    );
  }

  @override
  Future<Decimal> getCoinFiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
    final prices = await _getCachedKomodoPrices();
    final ticker = assetId.symbol.configSymbol.toUpperCase();

    final priceData = prices.values.firstWhere(
      (AssetMarketInformation element) =>
          element.ticker.toUpperCase() == ticker,
      orElse: () => throw Exception('Price not found for $ticker'),
    );

    return priceData.lastPrice;
  }

  /// Gets cached Komodo prices or fetches fresh data if cache is expired.
  /// Prevents concurrent cache refreshes by using a shared future.
  Future<Map<String, AssetMarketInformation>> _getCachedKomodoPrices() async {
    // Check if a fetch is already in progress
    if (_pendingFetch != null) {
      return _pendingFetch!;
    }

    // Check if cache is valid
    if (_cachedPrices != null && _cacheTimestamp != null) {
      final now = DateTime.now();
      final cacheAge = now.difference(_cacheTimestamp!);
      if (cacheAge.inMinutes < _cacheLifetimeMinutes) {
        return _cachedPrices!;
      }
    }

    // Start fetch and store the future
    _pendingFetch = _cexPriceProvider.getKomodoPrices();

    try {
      final prices = await _pendingFetch!;
      _cachedPrices = prices;
      _cacheTimestamp = DateTime.now();
      // Update coin list cache when prices are refreshed
      _updateCoinListCache(prices);
      return prices;
    } finally {
      _pendingFetch = null;
    }
  }

  void _updateCoinListCache(Map<String, AssetMarketInformation> prices) {
    _cachedCoinsList =
        prices.values
            .map(
              (e) => CexCoin(
                id: e.ticker,
                symbol: e.ticker,
                name: e.ticker,
                currencies: const <String>{'USD', 'USDT'},
                source: 'komodo',
              ),
            )
            .toList();
    _cachedFiatCurrencies = {'USD', 'USDT'};
  }

  @override
  Future<Map<DateTime, Decimal>> getCoinFiatPrices(
    AssetId assetId,
    List<DateTime> dates, {
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
    // Check if any dates are historical
    final now = DateTime.now();
    final hasHistoricalDates = dates.any(
      (date) => date.isBefore(now.subtract(const Duration(hours: 1))),
    );
    if (hasHistoricalDates) {
      throw UnsupportedError(
        'KomodoPriceRepository does not support historical price data',
      );
    }

    // Komodo API typically returns current prices, not historical
    final currentPrice = await getCoinFiatPrice(
      assetId,
      fiatCurrency: fiatCurrency,
    );
    return Map.fromEntries(dates.map((date) => MapEntry(date, currentPrice)));
  }

  @override
  Future<Decimal> getCoin24hrPriceChange(
    AssetId assetId, {
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
    final prices = await _getCachedKomodoPrices();
    final ticker = assetId.symbol.configSymbol.toUpperCase();

    final priceData = prices.values.firstWhere(
      (AssetMarketInformation element) =>
          element.ticker.toUpperCase() == ticker,
      orElse: () => throw Exception('Price change not found for $ticker'),
    );

    if (priceData.change24h == null) {
      throw Exception('24h price change not available for $ticker');
    }

    return priceData.change24h!;
  }

  @override
  String resolveTradingSymbol(AssetId assetId) {
    return assetId.symbol.configSymbol.toUpperCase();
  }

  /// Fetches the prices of the provided coin IDs at the given timestamps.
  ///
  /// The [coinId] is the ID of the coin to fetch the prices for.
  /// The [timestamps] are the timestamps to fetch the prices for.
  /// The [vsCurrency] is the currency to compare the prices to.
  ///
  /// Returns a map of timestamps to the prices of the coins.
  Future<Decimal> getCexFiatPrices(
    String coinId,
    List<String> timestamps, {
    String vsCurrency = 'usd',
  }) async {
    return (await _getCachedKomodoPrices()).values.firstWhere((
      AssetMarketInformation element,
    ) {
      if (element.ticker != coinId) {
        return false;
      }

      // return timestamps.contains(element.timestamp);
      return true;
    }).lastPrice;
  }

  @override
  Future<List<CexCoin>> getCoinList() async {
    // Ensure prices are cached first
    if (_cachedCoinsList == null) {
      await _getCachedKomodoPrices();
    }
    return _cachedCoinsList ?? [];
  }

  @override
  Future<bool> supports(
    AssetId assetId,
    QuoteCurrency fiatCurrency,
    PriceRequestType requestType,
  ) async {
    try {
      final coins = await getCoinList();
      final fiat = fiatCurrency.symbol.toUpperCase();
      final tradingSymbol = resolveTradingSymbol(assetId);
      final supportsAsset = coins.any(
        (c) => c.id.toUpperCase() == tradingSymbol.toUpperCase(),
      );
      final supportsFiat = _cachedFiatCurrencies?.contains(fiat) ?? false;
      final supportsRequestType =
          requestType == PriceRequestType.currentPrice ||
          requestType == PriceRequestType.priceChange;
      return supportsAsset && supportsFiat && supportsRequestType;
    } on ArgumentError {
      return false;
    }
  }

  @override
  bool canHandleAsset(AssetId assetId) {
    // If cache is null, trigger population but don't wait for it
    // This ensures subsequent calls will have the cache available
    if (_cachedCoinsList == null) {
      // Trigger cache population asynchronously without waiting
      getCoinList().catchError((error) {
        // Silently handle errors to prevent unhandled exceptions
        // The cache will remain null and subsequent calls will retry
        return <CexCoin>[];
      });
      return false;
    }

    final symbol = assetId.symbol.configSymbol.toUpperCase();
    return _cachedCoinsList!.any((c) => c.id.toUpperCase() == symbol);
  }

  /// Clears all cached data in the repository.
  ///
  /// This can be useful for testing or when you want to force a fresh fetch
  /// of data on the next call to any price-related methods.
  void clearCache() {
    _cachedPrices = null;
    _cacheTimestamp = null;
    _cachedCoinsList = null;
    _cachedFiatCurrencies = null;
    _pendingFetch = null;
  }
}
