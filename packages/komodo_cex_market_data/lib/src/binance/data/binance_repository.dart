// Using relative imports in this "package" to make it easier to track external
// dependencies when moving or copying this "package" to another project.
import 'dart:developer';

import 'package:async/async.dart';
import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_cex_market_data/src/binance/models/binance_exchange_info_reduced.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart'
    show BackoffStrategy, ExponentialBackoff, retry;
import 'package:komodo_defi_types/komodo_defi_types.dart';

// Declaring constants here to make this easier to copy & move around
/// The base URL for the Binance API.
List<String> get binanceApiEndpoint => [
  'https://api.binance.com/api/v3',
  'https://api.binance.us/api/v3',
];

/// A repository class for interacting with the Binance API.
/// This class provides methods to fetch legacy tickers and OHLC candle data.
class BinanceRepository implements CexRepository {
  /// Creates a new [BinanceRepository] instance.
  BinanceRepository({
    required IBinanceProvider binanceProvider,
    BackoffStrategy? defaultBackoffStrategy,
    bool enableMemoization = true,
  }) : _binanceProvider = binanceProvider,
       _defaultBackoffStrategy =
           defaultBackoffStrategy ??
           ExponentialBackoff(maxDelay: const Duration(seconds: 5)),
       _idResolutionStrategy = BinanceIdResolutionStrategy(),
       _enableMemoization = enableMemoization;

  final IBinanceProvider _binanceProvider;
  final BackoffStrategy _defaultBackoffStrategy;
  final IdResolutionStrategy _idResolutionStrategy;
  final bool _enableMemoization;

  final AsyncMemoizer<List<CexCoin>> _coinListMemoizer = AsyncMemoizer();
  Set<String>? _cachedFiatCurrencies;

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
    try {
      return await retry(
        () async {
          // Try primary endpoint first, fallback to secondary on failure
          Exception? lastException;
          for (final baseUrl in binanceApiEndpoint) {
            try {
              final exchangeInfo = await _binanceProvider
                  .fetchExchangeInfoReduced(baseUrl: baseUrl);
              final coinsList = _convertSymbolsToCoins(exchangeInfo);
              _cachedFiatCurrencies =
                  exchangeInfo.symbols
                      .map((s) => s.quoteAsset.toUpperCase())
                      .toSet();
              return coinsList;
            } catch (e) {
              lastException = e is Exception ? e : Exception(e.toString());
            }
          }
          throw lastException ?? Exception('All endpoints failed');
        },
        maxAttempts: maxAttempts,
        backoffStrategy: backoffStrategy ?? _defaultBackoffStrategy,
      );
    } catch (e) {
      _cachedFiatCurrencies = <String>{};
      return List.empty();
    }
  }

  CexCoin _binanceCoin(String baseCoinAbbr, String quoteCoinAbbr) {
    return CexCoin(
      id: baseCoinAbbr,
      symbol: baseCoinAbbr,
      name: baseCoinAbbr,
      currencies: <String>{quoteCoinAbbr},
      source: 'binance',
    );
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
  }) async {
    if (symbol.baseCoinTicker.toUpperCase() ==
        symbol.relCoinTicker.toUpperCase()) {
      throw ArgumentError('Base and rel coin tickers cannot be the same');
    }

    final startUnixTimestamp = startAt?.millisecondsSinceEpoch;
    final endUnixTimestamp = endAt?.millisecondsSinceEpoch;
    final intervalAbbreviation = interval.toAbbreviation();

    return await retry(
      () async {
        // Try primary endpoint first, fallback to secondary on failure
        Exception? lastException;
        for (final baseUrl in binanceApiEndpoint) {
          try {
            return await _binanceProvider.fetchKlines(
              symbol.toString(),
              intervalAbbreviation,
              startUnixTimestampMilliseconds: startUnixTimestamp,
              endUnixTimestampMilliseconds: endUnixTimestamp,
              limit: limit,
              baseUrl: baseUrl,
            );
          } catch (e) {
            lastException = e is Exception ? e : Exception(e.toString());
          }
        }
        throw lastException ?? Exception('All endpoints failed');
      },
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
  Future<Decimal> getCoinFiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
    int maxAttempts = 5,
    BackoffStrategy? backoffStrategy,
  }) async {
    final tradingSymbol = resolveTradingSymbol(assetId);
    final fiatCurrencyId = fiatCurrency.binanceId.toLowerCase();

    if (tradingSymbol.toUpperCase() == fiatCurrencyId.toUpperCase()) {
      throw ArgumentError('Coin and fiat coin cannot be the same');
    }

    final trimmedCoinId = tradingSymbol.replaceAll(RegExp('-segwit'), '');

    final endAt = priceDate ?? DateTime.now();
    final startAt = endAt.subtract(const Duration(days: 1));

    final ohlcData = await getCoinOhlc(
      CexCoinPair(baseCoinTicker: trimmedCoinId, relCoinTicker: fiatCurrencyId),
      GraphInterval.oneDay,
      startAt: startAt,
      endAt: endAt,
      limit: 1,
      maxAttempts: maxAttempts,
      backoffStrategy: backoffStrategy,
    );
    return Decimal.parse(ohlcData.ohlc.first.close.toString());
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
    final fiatCurrencyId = fiatCurrency.binanceId.toLowerCase();

    if (tradingSymbol.toUpperCase() == fiatCurrencyId.toUpperCase()) {
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

    for (var i = 0; i <= daysDiff; i += 500) {
      final batchStartDate = startDate.add(Duration(days: i));
      final batchEndDate =
          i + 500 > daysDiff ? endDate : startDate.add(Duration(days: i + 500));

      final ohlcData = await getCoinOhlc(
        CexCoinPair(
          baseCoinTicker: trimmedCoinId,
          relCoinTicker: fiatCurrencyId,
        ),
        GraphInterval.oneDay,
        startAt: batchStartDate,
        endAt: batchEndDate,
        maxAttempts: maxAttempts,
        backoffStrategy: backoffStrategy,
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
    final fiatCurrencyId = fiatCurrency.binanceId.toLowerCase();

    if (tradingSymbol.toUpperCase() == fiatCurrencyId.toUpperCase()) {
      throw ArgumentError('Coin and fiat coin cannot be the same');
    }

    final trimmedCoinId = tradingSymbol.replaceAll(RegExp('-segwit'), '');
    final symbol =
        '${trimmedCoinId.toUpperCase()}${fiatCurrencyId.toUpperCase()}';

    return await retry(
      () async {
        // Try primary endpoint first, fallback to secondary on failure
        Exception? lastException;
        for (final baseUrl in binanceApiEndpoint) {
          try {
            final tickerData = await _binanceProvider.fetch24hrTicker(
              symbol,
              baseUrl: baseUrl,
            );
            return tickerData.priceChangePercent;
          } catch (e) {
            lastException = e is Exception ? e : Exception(e.toString());
          }
        }
        throw lastException ?? Exception('All endpoints failed');
      },
      maxAttempts: maxAttempts,
      backoffStrategy: backoffStrategy ?? _defaultBackoffStrategy,
    );
  }

  List<CexCoin> _convertSymbolsToCoins(
    BinanceExchangeInfoResponseReduced exchangeInfo,
  ) {
    final coins = <String, CexCoin>{};
    for (final symbol in exchangeInfo.symbols) {
      final baseAsset = symbol.baseAsset;
      final quoteAsset = symbol.quoteAsset;

      // TODO(Anon): Decide if this belongs at the repository level considering
      // that the repository should provide and transform data as required
      // without implementing business logic (or make it an optional parameter).
      if (!symbol.isSpotTradingAllowed) {
        continue;
      }

      if (!coins.containsKey(baseAsset)) {
        coins[baseAsset] = _binanceCoin(baseAsset, quoteAsset);
      } else {
        coins[baseAsset] = coins[baseAsset]!.copyWith(
          currencies: {...coins[baseAsset]!.currencies, quoteAsset},
        );
      }
    }
    return coins.values.toList();
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
    debugger(
      when: !supportsAsset || !supportsFiat,
      message:
          'BinanceRepository does not support asset $assetId or fiat $fiat',
    );
    return supportsAsset && supportsFiat;
  }
}
