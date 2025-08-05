// Using relative imports in this "package" to make it easier to track external
// dependencies when moving or copying this "package" to another project.
import 'package:komodo_cex_market_data/src/binance/data/binance_provider.dart';
import 'package:komodo_cex_market_data/src/binance/data/binance_provider_interface.dart';
import 'package:komodo_cex_market_data/src/binance/models/binance_exchange_info_reduced.dart';
import 'package:komodo_cex_market_data/src/cex_repository.dart';
import 'package:komodo_cex_market_data/src/id_resolution_strategy.dart';
import 'package:komodo_cex_market_data/src/models/models.dart';
import 'package:komodo_cex_market_data/src/repository_selection_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart'
    show retry, BackoffStrategy, ExponentialBackoff;
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
  }) : _binanceProvider = binanceProvider,
       _defaultBackoffStrategy =
           defaultBackoffStrategy ??
           ExponentialBackoff(maxDelay: const Duration(seconds: 5)),
       _idResolutionStrategy = BinanceIdResolutionStrategy();

  final IBinanceProvider _binanceProvider;
  final BackoffStrategy _defaultBackoffStrategy;
  final IdResolutionStrategy _idResolutionStrategy;

  List<CexCoin>? _cachedCoinsList;
  Set<String>? _cachedFiatCurrencies;

  @override
  Future<List<CexCoin>> getCoinList({
    int maxAttempts = 5,
    BackoffStrategy? backoffStrategy,
  }) async {
    if (_cachedCoinsList != null) {
      return _cachedCoinsList!;
    }

    try {
      return await retry(
        () async {
          // Try primary endpoint first, fallback to secondary on failure
          Exception? lastException;
          for (final baseUrl in binanceApiEndpoint) {
            try {
              final exchangeInfo = await _binanceProvider
                  .fetchExchangeInfoReduced(baseUrl: baseUrl);
              _cachedCoinsList = _convertSymbolsToCoins(exchangeInfo);
              return _cachedCoinsList!;
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
      _cachedCoinsList = List.empty();
      _cachedFiatCurrencies = <String>{};
    }
    return _cachedCoinsList!;
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
  Future<double> getCoinFiatPrice(
    AssetId assetId, {
    DateTime? priceDate,
    String fiatCoinId = 'usdt',
    int maxAttempts = 5,
    BackoffStrategy? backoffStrategy,
  }) async {
    final tradingSymbol = resolveTradingSymbol(assetId);

    if (tradingSymbol.toUpperCase() == fiatCoinId.toUpperCase()) {
      throw ArgumentError('Coin and fiat coin cannot be the same');
    }

    final trimmedCoinId = tradingSymbol.replaceAll(RegExp('-segwit'), '');

    final endAt = priceDate ?? DateTime.now();
    final startAt = endAt.subtract(const Duration(days: 1));

    final ohlcData = await getCoinOhlc(
      CexCoinPair(baseCoinTicker: trimmedCoinId, relCoinTicker: fiatCoinId),
      GraphInterval.oneDay,
      startAt: startAt,
      endAt: endAt,
      limit: 1,
      maxAttempts: maxAttempts,
      backoffStrategy: backoffStrategy,
    );
    return ohlcData.ohlc.first.close;
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

    for (var i = 0; i <= daysDiff; i += 500) {
      final batchStartDate = startDate.add(Duration(days: i));
      final batchEndDate =
          i + 500 > daysDiff ? endDate : startDate.add(Duration(days: i + 500));

      final ohlcData = await getCoinOhlc(
        CexCoinPair(baseCoinTicker: trimmedCoinId, relCoinTicker: fiatCoinId),
        GraphInterval.oneDay,
        startAt: batchStartDate,
        endAt: batchEndDate,
        maxAttempts: maxAttempts,
        backoffStrategy: backoffStrategy,
      );

      final batchResult = ohlcData.ohlc.fold<Map<DateTime, double>>({}, (
        map,
        ohlc,
      ) {
        final date = DateTime.fromMillisecondsSinceEpoch(ohlc.closeTime);
        map[DateTime(date.year, date.month, date.day)] = ohlc.close;
        return map;
      });

      result.addAll(batchResult);
    }

    return result;
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
