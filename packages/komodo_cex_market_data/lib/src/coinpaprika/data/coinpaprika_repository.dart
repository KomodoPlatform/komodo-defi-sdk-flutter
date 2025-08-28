import 'package:async/async.dart';
import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/src/cex_repository.dart';
import 'package:komodo_cex_market_data/src/coinpaprika/data/coinpaprika_cex_provider.dart';
import 'package:komodo_cex_market_data/src/id_resolution_strategy.dart';
import 'package:komodo_cex_market_data/src/models/models.dart';
import 'package:komodo_cex_market_data/src/repository_selection_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// The maximum number of hours that CoinPaprika free tier supports for historical data.
const int maxCoinPaprikaFreeHours = 24;

/// A repository class for interacting with the CoinPaprika API.
class CoinPaprikaRepository implements CexRepository {
  /// Creates a new instance of [CoinPaprikaRepository].
  CoinPaprikaRepository({
    required this.coinPaprikaProvider,
    bool enableMemoization = true,
  }) : _idResolutionStrategy = CoinPaprikaIdResolutionStrategy(),
       _enableMemoization = enableMemoization;

  /// The CoinPaprika provider to use for fetching data.
  final ICoinPaprikaProvider coinPaprikaProvider;
  final IdResolutionStrategy _idResolutionStrategy;
  final bool _enableMemoization;

  final AsyncMemoizer<List<CexCoin>> _coinListMemoizer = AsyncMemoizer();
  Set<String>? _cachedQuoteCurrencies;

  static final Logger _logger = Logger('CoinPaprikaRepository');

  @override
  Future<List<CexCoin>> getCoinList() async {
    if (_enableMemoization) {
      return _coinListMemoizer.runOnce(_fetchCoinListInternal);
    } else {
      return _fetchCoinListInternal();
    }
  }

  /// Internal method to fetch coin list data from the API.
  Future<List<CexCoin>> _fetchCoinListInternal() async {
    try {
      final coins = await coinPaprikaProvider.fetchCoinList();

      // CoinPaprika supports a standard set of quote currencies
      final supportedCurrencies = {
        'usd',
        'eur',
        'gbp',
        'jpy',
        'krw',
        'pln',
        'cad',
        'aud',
        'nzd',
        'chf',
        'btc',
        'eth',
      };

      final result = coins
          .where((coin) => coin.isActive) // Only include active coins
          .map(
            (coin) => CexCoin(
              id: coin.id,
              symbol: coin.symbol,
              name: coin.name,
              currencies: supportedCurrencies,
            ),
          )
          .toList();

      _cachedQuoteCurrencies = supportedCurrencies
          .map((s) => s.toUpperCase())
          .toSet();

      _logger.info(
        'Successfully processed ${result.length} active coins from CoinPaprika',
      );
      return result;
    } catch (e, stackTrace) {
      _logger.severe(
        'Failed to fetch coin list from CoinPaprika',
        e,
        stackTrace,
      );
      rethrow;
    }
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
    try {
      final tradingSymbol = resolveTradingSymbol(assetId);
      final quoteCurrencyId = quoteCurrency.coinPaprikaId;

      // Calculate the time span
      var hours = maxCoinPaprikaFreeHours;
      if (startAt != null && endAt != null) {
        final timeDelta = endAt.difference(startAt);
        hours = (timeDelta.inSeconds.toDouble() / 3600).ceil();
      }

      // If the request is within the free tier limit, make a single request
      if (hours <= maxCoinPaprikaFreeHours) {
        return _fetchSingleOhlcRequest(
          tradingSymbol,
          quoteCurrencyId,
          startAt,
          endAt,
        );
      }

      // If the request exceeds the limit, we need startAt and endAt to split requests
      if (startAt == null || endAt == null) {
        throw ArgumentError(
          'startAt and endAt must be provided for requests exceeding $maxCoinPaprikaFreeHours hours',
        );
      }

      // Split the request into multiple sequential requests
      return _fetchMultipleOhlcRequests(
        tradingSymbol,
        quoteCurrencyId,
        startAt,
        endAt,
      );
    } catch (e, stackTrace) {
      _logger.severe(
        'Failed to fetch OHLC data for ${assetId.id}',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Fetches OHLC data in a single request (within free tier limits).
  Future<CoinOhlc> _fetchSingleOhlcRequest(
    String tradingSymbol,
    String quoteCurrencyId,
    DateTime? startAt,
    DateTime? endAt,
  ) async {
    final ohlcData = await coinPaprikaProvider.fetchHistoricalOhlc(
      coinId: tradingSymbol,
      startDate:
          startAt ??
          DateTime.now().subtract(
            const Duration(hours: maxCoinPaprikaFreeHours),
          ),
      endDate: endAt,
      quote: quoteCurrencyId,
    );

    return CoinOhlc(ohlc: ohlcData);
  }

  /// Fetches OHLC data in multiple requests to handle free tier limitations.
  Future<CoinOhlc> _fetchMultipleOhlcRequests(
    String tradingSymbol,
    String quoteCurrencyId,
    DateTime startAt,
    DateTime endAt,
  ) async {
    final allOhlcData = <Ohlc>[];
    var currentStart = startAt;

    _logger.info(
      'Splitting OHLC request for $tradingSymbol into multiple ${maxCoinPaprikaFreeHours}h batches',
    );

    while (currentStart.isBefore(endAt)) {
      final batchEnd = currentStart.add(
        const Duration(hours: maxCoinPaprikaFreeHours),
      );
      final actualEnd = batchEnd.isAfter(endAt) ? endAt : batchEnd;

      final batchHours = actualEnd.difference(currentStart).inHours;
      if (batchHours <= 0) break;

      _logger.fine(
        'Fetching batch: ${currentStart.toIso8601String()} to ${actualEnd.toIso8601String()}',
      );

      final batchOhlc = await _fetchSingleOhlcRequest(
        tradingSymbol,
        quoteCurrencyId,
        currentStart,
        actualEnd,
      );

      allOhlcData.addAll(batchOhlc.ohlc);
      currentStart = actualEnd;

      // Add delay between requests to avoid rate limiting
      if (currentStart.isBefore(endAt)) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    _logger.info(
      'Successfully fetched ${allOhlcData.length} OHLC data points across multiple batches',
    );
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
    try {
      final tradingSymbol = resolveTradingSymbol(assetId);
      final quoteCurrencyId = fiatCurrency.coinPaprikaId.toUpperCase();

      if (priceDate != null) {
        // For historical prices, use OHLC data
        final endDate = priceDate.add(const Duration(hours: 1));
        final ohlcData = await getCoinOhlc(
          assetId,
          fiatCurrency,
          GraphInterval.oneHour,
          startAt: priceDate,
          endAt: endDate,
        );

        if (ohlcData.ohlc.isEmpty) {
          throw Exception(
            'No price data available for ${assetId.id} at $priceDate',
          );
        }

        return ohlcData.ohlc.first.closeDecimal;
      }

      // For current prices, use ticker endpoint
      final ticker = await coinPaprikaProvider.fetchCoinTicker(
        coinId: tradingSymbol,
        quotes: quoteCurrencyId,
      );

      final quotes = ticker['quotes'] as Map<String, dynamic>?;
      if (quotes == null) {
        throw Exception('No quotes data available for ${assetId.id}');
      }

      final quoteData = quotes[quoteCurrencyId] as Map<String, dynamic>?;
      if (quoteData == null) {
        throw Exception(
          'No price data found for ${assetId.id} in $quoteCurrencyId',
        );
      }

      final price = quoteData['price'];
      if (price == null) {
        throw Exception(
          'Price field not found for ${assetId.id} in $quoteCurrencyId',
        );
      }

      return Decimal.parse(price.toString());
    } catch (e, stackTrace) {
      _logger.severe('Failed to get price for ${assetId.id}', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Map<DateTime, Decimal>> getCoinFiatPrices(
    AssetId assetId,
    List<DateTime> dates, {
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
    try {
      if (dates.isEmpty) {
        return {};
      }

      final sortedDates = List<DateTime>.from(dates)..sort();
      final startDate = sortedDates.first.subtract(const Duration(hours: 1));
      final endDate = sortedDates.last.add(const Duration(hours: 1));

      final ohlcData = await getCoinOhlc(
        assetId,
        fiatCurrency,
        GraphInterval.oneDay,
        startAt: startDate,
        endAt: endDate,
      );

      final result = <DateTime, Decimal>{};

      // Match OHLC data to requested dates
      for (final date in dates) {
        final dayStart = DateTime(date.year, date.month, date.day);
        final dayEnd = dayStart.add(const Duration(days: 1));

        // Find the closest OHLC data point
        final closestOhlc = ohlcData.ohlc
            .where((ohlc) {
              final ohlcDate = DateTime.fromMillisecondsSinceEpoch(
                ohlc.closeTimeMs,
              );
              return ohlcDate.isAfter(dayStart) && ohlcDate.isBefore(dayEnd);
            })
            .cast<Ohlc?>()
            .firstWhere((ohlc) => ohlc != null, orElse: () => null);

        if (closestOhlc != null) {
          result[date] = closestOhlc.closeDecimal;
        }
      }

      return result;
    } catch (e, stackTrace) {
      _logger.severe('Failed to get prices for ${assetId.id}', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Decimal> getCoin24hrPriceChange(
    AssetId assetId, {
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
    try {
      final tradingSymbol = resolveTradingSymbol(assetId);
      final quoteCurrencyId = fiatCurrency.coinPaprikaId.toUpperCase();

      // Use ticker endpoint for 24hr price change
      final ticker = await coinPaprikaProvider.fetchCoinTicker(
        coinId: tradingSymbol,
        quotes: quoteCurrencyId,
      );

      final quotes = ticker['quotes'] as Map<String, dynamic>?;
      if (quotes == null) {
        throw Exception('No quotes data available for ${assetId.id}');
      }

      final quoteData = quotes[quoteCurrencyId] as Map<String, dynamic>?;
      if (quoteData == null) {
        throw Exception(
          'No price change data found for ${assetId.id} in $quoteCurrencyId',
        );
      }

      final percentChange24h = quoteData['percent_change_24h'];
      if (percentChange24h == null) {
        throw Exception(
          '24h percent change field not found for ${assetId.id} in $quoteCurrencyId',
        );
      }

      return Decimal.parse(percentChange24h.toString());
    } catch (e, stackTrace) {
      _logger.severe(
        'Failed to get 24hr price change for ${assetId.id}',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<bool> supports(
    AssetId assetId,
    QuoteCurrency fiatCurrency,
    PriceRequestType requestType,
  ) async {
    try {
      // Check if we can resolve the trading symbol
      if (!canHandleAsset(assetId)) {
        return false;
      }

      // Check if quote currency is supported
      final quoteCurrencyId = fiatCurrency.coinPaprikaId.toLowerCase();
      final supportedQuotes =
          _cachedQuoteCurrencies ??
          {
            'USD',
            'EUR',
            'GBP',
            'JPY',
            'KRW',
            'PLN',
            'CAD',
            'AUD',
            'NZD',
            'CHF',
            'BTC',
            'ETH',
          };

      if (!supportedQuotes.contains(quoteCurrencyId.toUpperCase())) {
        return false;
      }

      // Ensure coin list is loaded to verify coin existence
      final coins = await getCoinList();
      final tradingSymbol = resolveTradingSymbol(assetId);

      final coinExists = coins.any(
        (coin) => coin.id.toLowerCase() == tradingSymbol.toLowerCase(),
      );

      return coinExists;
    } catch (e) {
      // If we can't resolve or verify support, assume unsupported
      _logger.warning('Failed to check support for ${assetId.id}: $e');
      return false;
    }
  }
}
