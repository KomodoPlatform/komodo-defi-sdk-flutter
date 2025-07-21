import 'package:komodo_cex_market_data/src/komodo/prices/komodo_price_provider.dart';
import 'package:komodo_cex_market_data/src/models/models.dart';
import 'package:komodo_cex_market_data/src/repository_selection_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A repository for fetching the prices of coins from the Komodo Defi API.
class KomodoPriceRepository {
  /// Creates a new instance of [KomodoPriceRepository].
  KomodoPriceRepository({
    required KomodoPriceProvider cexPriceProvider,
  }) : _cexPriceProvider = cexPriceProvider;

  /// The price provider to fetch the prices from.
  final KomodoPriceProvider _cexPriceProvider;

  List<CexCoin>? _cachedCoinsList;
  Set<String>? _cachedFiatCurrencies;

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
    // For now, assume all request types are supported if asset/fiat are supported
    return supportsAsset && supportsFiat;
  }
}
