import 'package:async/async.dart';
import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/src/cex_repository.dart';
import 'package:komodo_cex_market_data/src/coingecko/coingecko.dart';
import 'package:komodo_cex_market_data/src/coingecko/models/coin_historical_data/coin_historical_data.dart';
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
    bool enableMemoization = true,
  }) : _defaultBackoffStrategy =
           defaultBackoffStrategy ??
           ExponentialBackoff(maxDelay: const Duration(seconds: 5)),
       _idResolutionStrategy = CoinGeckoIdResolutionStrategy(),
       _enableMemoization = enableMemoization;

  /// The CoinGecko provider to use for fetching data.
  final ICoinGeckoProvider coinGeckoProvider;
  final BackoffStrategy _defaultBackoffStrategy;
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
  Future<List<CoinMarketData>> getCoinGeckoMarketData({
    int maxAttempts = 5,
    BackoffStrategy? backoffStrategy,
  }) async {
    return retry(
      coinGeckoProvider.fetchCoinMarketData,
      maxAttempts: maxAttempts,
      backoffStrategy: backoffStrategy ?? _defaultBackoffStrategy,
    );
  }

  @override
  Future<List<CexCoin>> getCoinList({
    int maxAttempts = 5,
    BackoffStrategy? backoffStrategy,
  }) async {
    if (_enableMemoization) {
      return _coinListMemoizer.runOnce(
        () => _fetchCoinListInternal(maxAttempts, backoffStrategy),
      );
    } else {
      // Warning: Direct API calls without memoization can lead to API rate limiting
      // and unnecessary network requests. Use this mode sparingly.
      return _fetchCoinListInternal(maxAttempts, backoffStrategy);
    }
  }

  /// Internal method to fetch coin list data from the API.
  Future<List<CexCoin>> _fetchCoinListInternal(
    int maxAttempts,
    BackoffStrategy? backoffStrategy,
  ) async {
    final effectiveBackoffStrategy = backoffStrategy ?? _defaultBackoffStrategy;

    final coins = await retry(
      coinGeckoProvider.fetchCoinList,
      maxAttempts: maxAttempts,
      backoffStrategy: effectiveBackoffStrategy,
    );
    final supportedCurrencies = await retry(
      coinGeckoProvider.fetchSupportedVsCurrencies,
      maxAttempts: maxAttempts,
      backoffStrategy: effectiveBackoffStrategy,
    );

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

  /// Maps any currency to the appropriate CoinGecko vs_currency
  /// Handles stablecoin -> fiat conversion and validates against supported currencies
  String _mapFiatCurrencyToCoingecko(QuoteCurrency fiatCurrency) {
    // Use the QuoteCurrency's coinGeckoId which handles all mappings
    final mappedCurrency = fiatCurrency.coinGeckoId;

    // Verify the mapped currency is actually supported by CoinGecko
    if (_cachedFiatCurrencies?.contains(mappedCurrency.toUpperCase()) == true) {
      return mappedCurrency;
    }

    // Fallback: Check if the original currency is directly supported
    final original = fiatCurrency.symbol.toLowerCase();
    if (_cachedFiatCurrencies?.contains(original.toUpperCase()) == true) {
      return original;
    }

    // Final fallback: Default to USD
    return 'usd';
  }

  @override
  Future<Decimal> getCoinFiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
    int maxAttempts = 5,
    BackoffStrategy? backoffStrategy,
  }) async {
    final tradingSymbol = resolveTradingSymbol(assetId);
    final mappedFiatId = _mapFiatCurrencyToCoingecko(fiatCurrency);

    final coinPrice = await retry(
      () => coinGeckoProvider.fetchCoinHistoricalMarketData(
        id: tradingSymbol,
        date: priceDate ?? DateTime.now(),
      ),
      maxAttempts: maxAttempts,
      backoffStrategy: backoffStrategy ?? _defaultBackoffStrategy,
    );

    return _extractPriceFromResponse(coinPrice, mappedFiatId);
  }

  Decimal _extractPriceFromResponse(
    CoinHistoricalData coinPrice,
    String mappedFiatId,
  ) {
    final price = coinPrice.marketData?.currentPrice?.usd;
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
    int maxAttempts = 5,
    BackoffStrategy? backoffStrategy,
  }) async {
    final tradingSymbol = resolveTradingSymbol(assetId);
    final mappedFiatId = _mapFiatCurrencyToCoingecko(fiatCurrency);

    if (tradingSymbol.toUpperCase() == mappedFiatId.toUpperCase()) {
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

    final result = <DateTime, Decimal>{};

    // Process in batches to avoid overwhelming the API
    for (var i = 0; i <= daysDiff; i += 365) {
      final batchStartDate = startDate.add(Duration(days: i));
      final batchEndDate =
          i + 365 > daysDiff ? endDate : startDate.add(Duration(days: i + 365));

      final ohlcData = await getCoinOhlc(
        CexCoinPair(baseCoinTicker: trimmedCoinId, relCoinTicker: mappedFiatId),
        GraphInterval.oneDay,
        startAt: batchStartDate,
        endAt: batchEndDate,
      );

      final batchResult = ohlcData.ohlc.fold<Map<DateTime, Decimal>>({}, (
        map,
        ohlc,
      ) {
        final date = DateTime.fromMillisecondsSinceEpoch(ohlc.closeTime);
        map[DateTime(date.year, date.month, date.day)] = Decimal.parse(
          ohlc.close.toString(),
        );
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
    int maxAttempts = 5,
    BackoffStrategy? backoffStrategy,
  }) async {
    final tradingSymbol = resolveTradingSymbol(assetId);
    final mappedFiatId = _mapFiatCurrencyToCoingecko(fiatCurrency);

    if (tradingSymbol.toUpperCase() == mappedFiatId.toUpperCase()) {
      throw ArgumentError('Coin and fiat coin cannot be the same');
    }

    return retry(
      () async {
        final priceData = await coinGeckoProvider.fetchCoinMarketData(
          ids: [tradingSymbol],
          vsCurrency: mappedFiatId, // Use mapped fiat currency
        );
        if (priceData.length != 1) {
          throw Exception('Invalid market data for $tradingSymbol');
        }

        final priceChange = priceData.first.priceChange24h;
        if (priceChange == null) {
          throw Exception('Price change data not available for $tradingSymbol');
        }
        return priceChange;
      },
      maxAttempts: maxAttempts,
      backoffStrategy: backoffStrategy ?? _defaultBackoffStrategy,
    );
  }

  @override
  Future<bool> supports(
    AssetId assetId,
    QuoteCurrency fiatCurrency,
    PriceRequestType requestType,
  ) async {
    final coins = await getCoinList();
    final mappedFiat = _mapFiatCurrencyToCoingecko(fiatCurrency);

    // Use the same logic as resolveTradingSymbol to find the coin
    final tradingSymbol = resolveTradingSymbol(assetId);
    final supportsAsset = coins.any(
      (c) =>
          c.id.toLowerCase() == tradingSymbol.toLowerCase() ||
          c.symbol.toLowerCase() == tradingSymbol.toLowerCase(),
    );
    final supportsFiat =
        _cachedFiatCurrencies?.contains(mappedFiat.toUpperCase()) ?? false;
    return supportsAsset && supportsFiat;
  }
}
