import 'package:komodo_cex_market_data/src/cex_repository.dart';
import 'package:komodo_cex_market_data/src/komodo/prices/komodo_price_provider.dart';
import 'package:komodo_cex_market_data/src/models/models.dart';
import 'package:komodo_cex_market_data/src/repository_selection_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A repository for fetching the prices of coins from the Komodo Defi API.
class KomodoPriceRepository extends CexRepository {
  /// Creates a new instance of [KomodoPriceRepository].
  KomodoPriceRepository({
    required KomodoPriceProvider cexPriceProvider,
  }) : _cexPriceProvider = cexPriceProvider;

  /// The price provider to fetch the prices from.
  final KomodoPriceProvider _cexPriceProvider;

  // Supported coins and vs currencies are not expected to change regularly,
  // so this in-memory cache is acceptable for now until a more complete and
  // robust caching strategy with cache invalidation is implemented.
  List<CexCoin>? _cachedCoinsList;
  Set<String>? _cachedFiatCurrencies;

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
  Future<double> getCoinFiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCoinId = 'usdt',
  }) async {
    final prices = await _cexPriceProvider.getKomodoPrices();
    final ticker = assetId.symbol.configSymbol.toUpperCase();

    final priceData = prices.values.firstWhere(
      (CexPrice element) => element.ticker.toUpperCase() == ticker,
      orElse: () => throw Exception('Price not found for $ticker'),
    );

    return priceData.price;
  }

  @override
  Future<Map<DateTime, double>> getCoinFiatPrices(
    AssetId assetId,
    List<DateTime> dates, {
    String fiatCoinId = 'usdt',
  }) async {
    // Komodo API typically returns current prices, not historical
    // For simplicity, return the same current price for all requested dates
    final currentPrice =
        await getCoinFiatPrice(assetId, fiatCoinId: fiatCoinId);
    return Map.fromEntries(
      dates.map((date) => MapEntry(date, currentPrice)),
    );
  }

  @override
  String resolveTradingSymbol(AssetId assetId) {
    return assetId.symbol.configSymbol.toUpperCase();
  }

  @override
  bool canHandleAsset(AssetId assetId) {
    // We'll need to check if the asset is supported by fetching the coin list
    // For now, return true and let the actual method calls handle unsupported assets
    return true;
  }

  /// Fetches the prices of the provided coin IDs at the given timestamps.
  ///
  /// The [coinId] is the ID of the coin to fetch the prices for.
  /// The [timestamps] are the timestamps to fetch the prices for.
  /// The [vsCurrency] is the currency to compare the prices to.
  ///
  /// Returns a map of timestamps to the prices of the coins.
  Future<double> getCexFiatPrices(
    String coinId,
    List<String> timestamps, {
    String vsCurrency = 'usd',
  }) async {
    return (await _cexPriceProvider.getKomodoPrices())
        .values
        .firstWhere((CexPrice element) {
      if (element.ticker != coinId) {
        return false;
      }

      // return timestamps.contains(element.timestamp);
      return true;
    }).price;
  }

  /// Fetches the prices of the provided coin IDs.
  ///
  /// Returns a map of coin IDs to their prices.
  Future<Map<String, CexPrice>> getKomodoPrices() async {
    return _cexPriceProvider.getKomodoPrices();
  }

  @override
  Future<List<CexCoin>> getCoinList() async {
    if (_cachedCoinsList != null) {
      return _cachedCoinsList!;
    }
    final prices = await getKomodoPrices();
    _cachedCoinsList = prices.values
        .map(
          (e) => CexCoin(
            id: e.ticker,
            symbol: e.ticker,
            name: e.ticker,
            currencies: <String>{'USD', 'USDT'},
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
    AssetId fiatAssetId,
    PriceRequestType requestType,
  ) async {
    final coins = await getCoinList();
    final fiat = fiatAssetId.symbol.configSymbol.toUpperCase();
    final supportsAsset = coins.any(
      (c) => c.id.toUpperCase() == assetId.symbol.configSymbol.toUpperCase(),
    );
    final supportsFiat = _cachedFiatCurrencies?.contains(fiat) ?? false;
    final supportsRequestType = requestType == PriceRequestType.currentPrice ||
        requestType == PriceRequestType.priceChange;
    return supportsAsset && supportsFiat && supportsRequestType;
  }
}
