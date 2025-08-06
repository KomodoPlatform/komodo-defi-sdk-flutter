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

  /// Cache lifetime in minutes
  static const int _cacheLifetimeMinutes = 5;

  @override
  Future<CoinOhlc> getCoinOhlc(
    CexCoinPair symbol,
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
  Future<Map<String, AssetMarketInformation>> _getCachedKomodoPrices() async {
    // Check if cache is valid
    if (_cachedPrices != null && _cacheTimestamp != null) {
      final now = DateTime.now();
      final cacheAge = now.difference(_cacheTimestamp!);
      if (cacheAge.inMinutes < _cacheLifetimeMinutes) {
        return _cachedPrices!;
      }
    }

    // Fetch fresh data
    final prices = await _cexPriceProvider.getKomodoPrices();

    // Update cache
    _cachedPrices = prices;
    _cacheTimestamp = DateTime.now();

    return prices;
  }

  @override
  Future<Map<DateTime, Decimal>> getCoinFiatPrices(
    AssetId assetId,
    List<DateTime> dates, {
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
    // Komodo API typically returns current prices, not historical
    // For simplicity, return the same current price for all requested dates
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
    if (_cachedCoinsList != null) {
      return _cachedCoinsList!;
    }
    final prices = await _getCachedKomodoPrices();
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
    return _cachedCoinsList!;
  }

  @override
  Future<bool> supports(
    AssetId assetId,
    QuoteCurrency fiatCurrency,
    PriceRequestType requestType,
  ) async {
    final coins = await getCoinList();
    final fiat = fiatCurrency.symbol.toUpperCase();
    final supportsAsset = coins.any(
      (c) => c.id.toUpperCase() == assetId.symbol.configSymbol.toUpperCase(),
    );
    final supportsFiat = _cachedFiatCurrencies?.contains(fiat) ?? false;
    final supportsRequestType =
        requestType == PriceRequestType.currentPrice ||
        requestType == PriceRequestType.priceChange;
    return supportsAsset && supportsFiat && supportsRequestType;
  }

  @override
  bool canHandleAsset(AssetId assetId) {
    final symbol = assetId.symbol.configSymbol.toUpperCase();
    return _cachedCoinsList?.any((c) => c.id.toUpperCase() == symbol) ?? false;
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
  }
}
