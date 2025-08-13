// Using relative imports in this "package" to make it easier to track external
// dependencies when moving or copying this "package" to another project.

// TODO: look into custom exception types or justifying the current approach.
// ignore_for_file: avoid_catches_without_on_clauses

import 'package:async/async.dart';
import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_cex_market_data/src/binance/models/binance_exchange_info_reduced.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

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
    bool enableMemoization = true,
  }) : _binanceProvider = binanceProvider,
       _idResolutionStrategy = BinanceIdResolutionStrategy(),
       _enableMemoization = enableMemoization;

  final IBinanceProvider _binanceProvider;
  final IdResolutionStrategy _idResolutionStrategy;
  final bool _enableMemoization;

  static final Logger _logger = Logger('BinanceRepository');

  final AsyncMemoizer<List<CexCoin>> _coinListMemoizer = AsyncMemoizer();
  Set<String>? _cachedFiatCurrencies;

  @override
  Future<List<CexCoin>> getCoinList() async {
    if (_enableMemoization) {
      return _coinListMemoizer.runOnce(_fetchCoinListInternal);
    } else {
      // Warning: Direct API calls without memoization can lead to API
      // rate limiting and unnecessary network requests. Use this mode sparingly
      return _fetchCoinListInternal();
    }
  }

  /// Internal method to fetch coin list data from the API.
  Future<List<CexCoin>> _fetchCoinListInternal() async {
    try {
      // Try primary endpoint first, fallback to secondary on failure
      Exception? lastException;
      for (final baseUrl in binanceApiEndpoint) {
        try {
          final exchangeInfo = await _binanceProvider.fetchExchangeInfoReduced(
            baseUrl: baseUrl,
          );
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
    } catch (e, s) {
      _logger.severe('Failed to fetch coin list from Binance API: $e', e, s);
      rethrow;
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
    AssetId assetId,
    QuoteCurrency quoteCurrency,
    GraphInterval interval, {
    DateTime? startAt,
    DateTime? endAt,
    int? limit,
  }) async {
    final baseTicker = resolveTradingSymbol(assetId);
    final relTicker = quoteCurrency.binanceId;

    if (baseTicker.toUpperCase() == relTicker.toUpperCase()) {
      throw ArgumentError('Base and rel coin tickers cannot be the same');
    }

    final startUnixTimestamp = startAt?.millisecondsSinceEpoch;
    final endUnixTimestamp = endAt?.millisecondsSinceEpoch;
    final intervalAbbreviation = interval.toAbbreviation();

    // Try primary endpoint first, fallback to secondary on failure
    Exception? lastException;
    for (final baseUrl in binanceApiEndpoint) {
      try {
        final symbolString =
            '${baseTicker.toUpperCase()}${relTicker.toUpperCase()}';
        return await _binanceProvider.fetchKlines(
          symbolString,
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
    final fiatCurrencyId = fiatCurrency.binanceId.toLowerCase();

    if (tradingSymbol.toUpperCase() == fiatCurrencyId.toUpperCase()) {
      throw ArgumentError('Coin and fiat coin cannot be the same');
    }

    final endAt = priceDate ?? DateTime.now();
    final startAt = endAt.subtract(const Duration(days: 1));

    final ohlcData = await getCoinOhlc(
      assetId,
      fiatCurrency,
      GraphInterval.oneDay,
      startAt: startAt,
      endAt: endAt,
      limit: 1,
    );
    return Decimal.parse(ohlcData.ohlc.first.close.toString());
  }

  @override
  Future<Map<DateTime, Decimal>> getCoinFiatPrices(
    AssetId assetId,
    List<DateTime> dates, {
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
    final tradingSymbol = resolveTradingSymbol(assetId).toLowerCase();
    final fiatCurrencyId = fiatCurrency.binanceId.toLowerCase();

    if (tradingSymbol == fiatCurrencyId) {
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

    for (var i = 0; i <= daysDiff; i += 500) {
      final batchStartDate = startDate.add(Duration(days: i));
      final batchEndDate =
          i + 500 > daysDiff ? endDate : startDate.add(Duration(days: i + 500));

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
  }) async {
    final tradingSymbol = resolveTradingSymbol(assetId);
    final fiatCurrencyId = fiatCurrency.binanceId.toLowerCase();

    if (tradingSymbol.toUpperCase() == fiatCurrencyId.toUpperCase()) {
      throw ArgumentError('Coin and fiat coin cannot be the same');
    }

    final trimmedCoinId = tradingSymbol.replaceAll(RegExp('-segwit'), '');
    final symbol =
        '${trimmedCoinId.toUpperCase()}${fiatCurrencyId.toUpperCase()}';

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
    try {
      final coins = await getCoinList();
      final fiat = fiatCurrency.binanceId;
      // If resolveTradingSymbol throws, treat as unsupported
      final tradingSymbol = resolveTradingSymbol(assetId);
      final supportsAsset = coins.any(
        (c) => c.id.toUpperCase() == tradingSymbol.toUpperCase(),
      );
      final supportsFiat =
          _cachedFiatCurrencies?.contains(fiat.toUpperCase()) ?? false;
      return supportsAsset && supportsFiat;
    } on ArgumentError {
      return false;
    }
  }
}
