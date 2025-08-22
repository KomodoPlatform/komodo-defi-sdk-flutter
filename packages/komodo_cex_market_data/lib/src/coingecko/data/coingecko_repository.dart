import 'package:async/async.dart';
import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/src/cex_repository.dart';
import 'package:komodo_cex_market_data/src/coingecko/coingecko.dart';
import 'package:komodo_cex_market_data/src/coingecko/models/coin_historical_data/coin_historical_data.dart';
import 'package:komodo_cex_market_data/src/id_resolution_strategy.dart';
import 'package:komodo_cex_market_data/src/models/models.dart';
import 'package:komodo_cex_market_data/src/repository_selection_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// The number of seconds in a day.
const int secondsInDay = 86400;

/// The maximum number of days that CoinGecko API supports for historical data.
const int maxCoinGeckoDays = 365;

/// A repository class for interacting with the CoinGecko API.
class CoinGeckoRepository implements CexRepository {
  /// Creates a new instance of [CoinGeckoRepository].
  CoinGeckoRepository({
    required this.coinGeckoProvider,
    bool enableMemoization = true,
  }) : _idResolutionStrategy = CoinGeckoIdResolutionStrategy(),
       _enableMemoization = enableMemoization;

  /// The CoinGecko provider to use for fetching data.
  final ICoinGeckoProvider coinGeckoProvider;
  final IdResolutionStrategy _idResolutionStrategy;
  final bool _enableMemoization;

  final AsyncMemoizer<List<CexCoin>> _coinListMemoizer = AsyncMemoizer();
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
  Future<List<CoinMarketData>> getCoinGeckoMarketData() async {
    return coinGeckoProvider.fetchCoinMarketData();
  }

  @override
  Future<List<CexCoin>> getCoinList() async {
    if (_enableMemoization) {
      return _coinListMemoizer.runOnce(_fetchCoinListInternal);
    } else {
      // Warning: Direct API calls without memoization can lead to API rate limiting
      // and unnecessary network requests. Use this mode sparingly.
      return _fetchCoinListInternal();
    }
  }

  /// Internal method to fetch coin list data from the API.
  Future<List<CexCoin>> _fetchCoinListInternal() async {
    final coins = await coinGeckoProvider.fetchCoinList();
    final supportedCurrencies =
        await coinGeckoProvider.fetchSupportedVsCurrencies();

    final result =
        coins
            .map(
              (CexCoin e) =>
                  e.copyWith(currencies: supportedCurrencies.toSet()),
            )
            .toSet();

    _cachedFiatCurrencies =
        supportedCurrencies.map((s) => s.toUpperCase()).toSet();

    return result.toList();
  }

  @override
  Future<CoinOhlc> getCoinOhlc(
    AssetId assetId,
    QuoteCurrency quoteCurrency,
    GraphInterval interval, {
    DateTime? startAt,
    DateTime? endAt,
    int? limit,
  }) async {
    var days = 1;
    if (startAt != null && endAt != null) {
      final timeDelta = endAt.difference(startAt);
      days = (timeDelta.inSeconds.toDouble() / secondsInDay).ceil();
    }

    // Use the same ticker resolution as other methods
    final tradingSymbol = resolveTradingSymbol(assetId);

    // If the request is within the CoinGecko limit, make a single request
    if (days <= maxCoinGeckoDays) {
      return coinGeckoProvider.fetchCoinOhlc(
        tradingSymbol,
        quoteCurrency.coinGeckoId,
        days,
      );
    }

    // If the request exceeds the limit, we need startAt and endAt to split requests
    if (startAt == null || endAt == null) {
      throw ArgumentError(
        'startAt and endAt must be provided for requests exceeding $maxCoinGeckoDays days',
      );
    }

    // Split the request into multiple sequential requests
    final allOhlcData = <Ohlc>[];
    var currentStart = startAt;

    while (currentStart.isBefore(endAt)) {
      final currentEnd = currentStart.add(
        const Duration(days: maxCoinGeckoDays),
      );
      final batchEndDate = currentEnd.isAfter(endAt) ? endAt : currentEnd;

      final batchDays = batchEndDate.difference(currentStart).inDays;
      if (batchDays <= 0) break;

      final batchOhlc = await coinGeckoProvider.fetchCoinOhlc(
        tradingSymbol,
        quoteCurrency.coinGeckoId,
        batchDays,
      );

      allOhlcData.addAll(batchOhlc.ohlc);
      currentStart = batchEndDate;
    }

    return CoinOhlc(ohlc: allOhlcData);
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
  Future<Decimal> getCoinFiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
    final tradingSymbol = resolveTradingSymbol(assetId);
    final mappedFiatId = fiatCurrency.coinGeckoId;

    final coinPrice = await coinGeckoProvider.fetchCoinHistoricalMarketData(
      id: tradingSymbol,
      date: priceDate ?? DateTime.now(),
    );

    return _extractPriceFromResponse(coinPrice, mappedFiatId);
  }

  Decimal _extractPriceFromResponse(
    CoinHistoricalData coinPrice,
    String mappedFiatId,
  ) {
    final currentPriceMap = coinPrice.marketData?.currentPrice?.toJson();
    if (currentPriceMap == null) {
      throw Exception(
        'Market data or current price not found in response: $coinPrice',
      );
    }

    final price = currentPriceMap[mappedFiatId];
    if (price == null) {
      throw Exception(
        'Price data for $mappedFiatId not found in response: $coinPrice',
      );
    }
    return Decimal.parse(price.toString());
  }

  @override
  Future<Map<DateTime, Decimal>> getCoinFiatPrices(
    AssetId assetId,
    List<DateTime> dates, {
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
    final tradingSymbol = resolveTradingSymbol(assetId);
    final mappedFiatId = fiatCurrency.coinGeckoId;

    if (tradingSymbol.toUpperCase() == mappedFiatId.toUpperCase()) {
      throw ArgumentError('Coin and fiat coin cannot be the same');
    }

    dates.sort();

    if (dates.isEmpty) {
      return {};
    }

    final startDate = dates.first.add(const Duration(days: -2));
    final endDate = dates.last.add(const Duration(days: 2));
    final daysDiff = endDate.difference(startDate).inDays;

    final result = <DateTime, Decimal>{};

    // Process in batches to avoid overwhelming the API
    for (var i = 0; i <= daysDiff; i += maxCoinGeckoDays) {
      final batchStartDate = startDate.add(Duration(days: i));
      final batchEndDate =
          i + maxCoinGeckoDays > daysDiff
              ? endDate
              : startDate.add(Duration(days: i + maxCoinGeckoDays));

      final ohlcData = await getCoinOhlc(
        assetId,
        fiatCurrency,
        GraphInterval.oneDay,
        startAt: batchStartDate,
        endAt: batchEndDate,
      );

      final batchResult = ohlcData.ohlc.fold<Map<DateTime, Decimal>>({}, (
        map,
        ohlc,
      ) {
        final dateUtc = DateTime.fromMillisecondsSinceEpoch(
          ohlc.closeTimeMs,
          isUtc: true,
        );
        map[DateTime.utc(dateUtc.year, dateUtc.month, dateUtc.day)] =
            ohlc.closeDecimal;
        return map;
      });

      result.addAll(batchResult);
    }

    return result;
  }

  @override
  Future<Decimal> getCoin24hrPriceChange(
    AssetId assetId, {
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
    final tradingSymbol = resolveTradingSymbol(assetId);
    final mappedFiatId = fiatCurrency.coinGeckoId;

    if (tradingSymbol.toUpperCase() == mappedFiatId.toUpperCase()) {
      throw ArgumentError('Coin and fiat coin cannot be the same');
    }

    final priceData = await coinGeckoProvider.fetchCoinMarketData(
      ids: [tradingSymbol],
      vsCurrency: mappedFiatId, // Use mapped fiat currency
    );
    if (priceData.length != 1) {
      throw Exception('Invalid market data for $tradingSymbol');
    }

    final priceChange = priceData.first.priceChangePercentage24h;
    if (priceChange == null) {
      throw Exception('Price change data not available for $tradingSymbol');
    }
    return priceChange;
  }

  @override
  Future<bool> supports(
    AssetId assetId,
    QuoteCurrency fiatCurrency,
    PriceRequestType requestType,
  ) async {
    try {
      final coins = await getCoinList();
      final mappedFiat = fiatCurrency.coinGeckoId;

      // Use the same logic as resolveTradingSymbol to find the coin
      final tradingSymbol = resolveTradingSymbol(assetId);
      final supportsAsset = coins.any(
        (c) => c.id.toLowerCase() == tradingSymbol.toLowerCase(),
      );
      final supportsFiat =
          _cachedFiatCurrencies?.contains(mappedFiat.toUpperCase()) ?? false;
      return supportsAsset && supportsFiat;
    } on ArgumentError {
      // If we cannot resolve a trading symbol, treat as unsupported
      return false;
    }
  }
}
