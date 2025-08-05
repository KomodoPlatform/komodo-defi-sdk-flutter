import 'package:komodo_cex_market_data/src/cex_repository.dart';
import 'package:komodo_cex_market_data/src/coingecko/coingecko.dart';
import 'package:komodo_cex_market_data/src/id_resolution_strategy.dart';
import 'package:komodo_cex_market_data/src/models/models.dart';
import 'package:komodo_cex_market_data/src/repository_selection_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart'
    show BackoffStrategy, ExponentialBackoff, retry;
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// The number of seconds in a day.
const int secondsInDay = 86400;

/// A repository class for interacting with the CoinGecko API.
class CoinGeckoRepository implements CexRepository {
  /// Creates a new instance of [CoinGeckoRepository].
  CoinGeckoRepository({
    required this.coinGeckoProvider,
    BackoffStrategy? defaultBackoffStrategy,
  })  : _defaultBackoffStrategy = defaultBackoffStrategy ??
            ExponentialBackoff(
              maxDelay: const Duration(seconds: 5),
            ),
        _idResolutionStrategy = CoinGeckoIdResolutionStrategy();

  /// The CoinGecko provider to use for fetching data.
  final ICoinGeckoProvider coinGeckoProvider;
  final BackoffStrategy _defaultBackoffStrategy;
  final IdResolutionStrategy _idResolutionStrategy;

  List<CexCoin>? _cachedCoinsList;
  Set<String>? _cachedFiatCurrencies;

  /// Fetches the CoinGecko market data.
  ///
  /// Returns a list of [CoinMarketData] objects containing the market data.
  ///
  /// Throws an [Exception] if the API request fails.
  ///
  /// Example usage:
  /// ```dart
  /// final List<CoinMarketData> marketData = await getCoinGeckoMarketData();
  /// ```
  Future<List<CoinMarketData>> getCoinGeckoMarketData({
    int maxAttempts = 5,
    BackoffStrategy? backoffStrategy,
  }) async {
    return await retry(
      () => coinGeckoProvider.fetchCoinMarketData(),
      maxAttempts: maxAttempts,
      backoffStrategy: backoffStrategy ?? _defaultBackoffStrategy,
    );
  }

  @override
  Future<List<CexCoin>> getCoinList({
    int maxAttempts = 5,
    BackoffStrategy? backoffStrategy,
  }) async {
    if (_cachedCoinsList != null) {
      return _cachedCoinsList!;
    }

    final effectiveBackoffStrategy = backoffStrategy ?? _defaultBackoffStrategy;

    final coins = await retry(
      () => coinGeckoProvider.fetchCoinList(),
      maxAttempts: maxAttempts,
      backoffStrategy: effectiveBackoffStrategy,
    );
    final supportedCurrencies = await retry(
      () => coinGeckoProvider.fetchSupportedVsCurrencies(),
      maxAttempts: maxAttempts,
      backoffStrategy: effectiveBackoffStrategy,
    );

    _cachedCoinsList = coins
        .map((CexCoin e) => e.copyWith(currencies: supportedCurrencies.toSet()))
        .toList();
    _cachedFiatCurrencies =
        supportedCurrencies.map((s) => s.toUpperCase()).toSet();

    return _cachedCoinsList!;
  }

  @override
  Future<CoinOhlc> getCoinOhlc(
    CexCoinPair symbol,
    GraphInterval interval, {
    DateTime? startAt,
    DateTime? endAt,
    int? limit,
    int maxAttempts = 5,
    BackoffStrategy? backoffStrategy,
  }) {
    var days = 1;
    if (startAt != null && endAt != null) {
      final timeDelta = endAt.difference(startAt);
      days = (timeDelta.inSeconds.toDouble() / secondsInDay).ceil();
    }

    return retry(
      () => coinGeckoProvider.fetchCoinOhlc(
        symbol.baseCoinTicker,
        symbol.relCoinTicker,
        days,
      ),
      maxAttempts: maxAttempts,
      backoffStrategy: backoffStrategy ?? _defaultBackoffStrategy,
    );
  }

  @override
  String resolveTradingSymbol(AssetId assetId) {
    return _idResolutionStrategy.resolveTradingSymbol(assetId);
  }

  @override
  bool canHandleAsset(AssetId assetId) {
    return _idResolutionStrategy.canResolve(assetId);
  }

  @override
  Future<double> getCoinFiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCoinId = 'usdt',
    int maxAttempts = 5,
    BackoffStrategy? backoffStrategy,
  }) async {
    final tradingSymbol = resolveTradingSymbol(assetId);

    final coinPrice = await retry(
      () => coinGeckoProvider.fetchCoinHistoricalMarketData(
        id: tradingSymbol,
        date: priceDate ?? DateTime.now(),
      ),
      maxAttempts: maxAttempts,
      backoffStrategy: backoffStrategy ?? _defaultBackoffStrategy,
    );
    return coinPrice.marketData?.currentPrice?.usd?.toDouble() ?? 0;
  }

  @override
  Future<Map<DateTime, double>> getCoinFiatPrices(
    AssetId assetId,
    List<DateTime> dates, {
    String fiatCoinId = 'usdt',
    int maxAttempts = 5,
    BackoffStrategy? backoffStrategy,
  }) async {
    final tradingSymbol = resolveTradingSymbol(assetId);

    if (tradingSymbol.toUpperCase() == fiatCoinId.toUpperCase()) {
      throw ArgumentError('Coin and fiat coin cannot be the same');
    }

    dates.sort();
    final trimmedCoinId = tradingSymbol.replaceAll(RegExp('-segwit'), '');

    if (dates.isEmpty) {
      return {};
    }

    final startDate = dates.first.add(const Duration(days: -2));
    final endDate = dates.last.add(const Duration(days: 2));
    final daysDiff = endDate.difference(startDate).inDays;

    final result = <DateTime, double>{};

    // Process in batches to avoid overwhelming the API
    for (var i = 0; i <= daysDiff; i += 365) {
      final batchStartDate = startDate.add(Duration(days: i));
      final batchEndDate =
          i + 365 > daysDiff ? endDate : startDate.add(Duration(days: i + 365));

      final ohlcData = await getCoinOhlc(
        CexCoinPair(baseCoinTicker: trimmedCoinId, relCoinTicker: fiatCoinId),
        GraphInterval.oneDay,
        startAt: batchStartDate,
        endAt: batchEndDate,
      );

      final batchResult =
          ohlcData.ohlc.fold<Map<DateTime, double>>({}, (map, ohlc) {
        final date = DateTime.fromMillisecondsSinceEpoch(
          ohlc.closeTime,
        );
        map[DateTime(date.year, date.month, date.day)] = ohlc.close;
        return map;
      });

      result.addAll(batchResult);
    }

    return result;
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
    // For now, assume all request types are supported if asset/fiat are supported
    return supportsAsset && supportsFiat;
  }
}
