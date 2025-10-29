import 'package:async/async.dart';
import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/src/cex_repository.dart';
import 'package:komodo_cex_market_data/src/coinpaprika/data/coinpaprika_cex_provider.dart';
import 'package:komodo_cex_market_data/src/coinpaprika/models/coinpaprika_api_plan.dart';
import 'package:komodo_cex_market_data/src/id_resolution_strategy.dart';
import 'package:komodo_cex_market_data/src/models/_models_index.dart';
import 'package:komodo_cex_market_data/src/repository_selection_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// A repository class for interacting with the CoinPaprika API.
///
/// ## API Plan Limitations
/// CoinPaprika has different API plans with varying limitations:
/// - Free: 1 day of OHLC historical data
/// - Starter: 1 month of OHLC historical data
/// - Pro: 3 months of OHLC historical data
/// - Business: 1 year of OHLC historical data
/// - Ultimate/Enterprise: No OHLC historical data limitations
///
/// The provider layer handles validation and will throw appropriate errors
/// for requests that exceed the current plan's limitations.
/// For older historical data or higher limits, upgrade to a higher plan.
class CoinPaprikaRepository implements CexRepository {
  /// Creates a new instance of [CoinPaprikaRepository].
  CoinPaprikaRepository({
    required this.coinPaprikaProvider,
    bool enableMemoization = true,
    bool ownsProvider = false,
  }) : _idResolutionStrategy = CoinPaprikaIdResolutionStrategy(),
       _enableMemoization = enableMemoization,
       _ownsProvider = ownsProvider;

  /// The CoinPaprika provider to use for fetching data.
  final ICoinPaprikaProvider coinPaprikaProvider;
  final IdResolutionStrategy _idResolutionStrategy;
  final bool _enableMemoization;
  final bool _ownsProvider;

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
    final coins = await coinPaprikaProvider.fetchCoinList();

    // Build supported quote currencies from provider (hard-coded in provider)
    final supportedCurrencies = coinPaprikaProvider.supportedQuoteCurrencies
        .map((q) => q.coinPaprikaId)
        .toSet();

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

    return result;
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
    final tradingSymbol = resolveTradingSymbol(assetId);
    final apiPlan = coinPaprikaProvider.apiPlan;

    // Determine the actual fetchable date range (using UTC)
    var effectiveStartAt = startAt?.toUtc();
    final effectiveEndAt = endAt ?? DateTime.now().toUtc();

    // If no startAt provided, use default based on plan limit or
    // reasonable default
    if (effectiveStartAt == null) {
      if (apiPlan.hasUnlimitedOhlcHistory) {
        effectiveStartAt = effectiveEndAt.subtract(
          const Duration(days: 365),
        ); // Default 1 year for unlimited
      } else {
        effectiveStartAt = effectiveEndAt.subtract(
          apiPlan.ohlcHistoricalDataLimit!,
        );
      }
    }

    // Check if the requested range is entirely before the cutoff date
    // (only for limited plans)
    if (!apiPlan.hasUnlimitedOhlcHistory) {
      final cutoffDate = apiPlan.getHistoricalDataCutoff();
      if (cutoffDate != null) {
        // If both start and end dates are before cutoff, return empty data
        if (effectiveEndAt.isBefore(cutoffDate)) {
          return const CoinOhlc(ohlc: []);
        }

        // If start date is before cutoff, adjust it to cutoff date
        if (effectiveStartAt.isBefore(cutoffDate)) {
          effectiveStartAt = cutoffDate;
        }
      }
    }

    // If effective start is after end, return empty data
    if (effectiveStartAt.isAfter(effectiveEndAt)) {
      return const CoinOhlc(ohlc: []);
    }

    // Determine reasonable batch size based on API plan
    final batchDuration = _getBatchDuration(apiPlan);
    final totalDuration = effectiveEndAt.difference(effectiveStartAt);

    // If the request is within the batch size, make a single request
    if (totalDuration <= batchDuration) {
      return _fetchSingleOhlcRequest(
        tradingSymbol,
        quoteCurrency,
        effectiveStartAt,
        effectiveEndAt,
      );
    }

    // Split the request into multiple sequential requests
    return _fetchMultipleOhlcRequests(
      tradingSymbol,
      quoteCurrency,
      effectiveStartAt,
      effectiveEndAt,
      batchDuration,
    );
  }

  /// Fetches OHLC data in a single request (within plan limits).
  Future<CoinOhlc> _fetchSingleOhlcRequest(
    String tradingSymbol,
    QuoteCurrency quoteCurrency,
    DateTime? startAt,
    DateTime? endAt,
  ) async {
    final apiPlan = coinPaprikaProvider.apiPlan;

    final ohlcData = await coinPaprikaProvider.fetchHistoricalOhlc(
      coinId: tradingSymbol,
      startDate:
          startAt ??
          DateTime.now().toUtc().subtract(
            apiPlan.hasUnlimitedOhlcHistory
                ? const Duration(days: 1)
                // "!" is safe because we checked hasUnlimitedOhlcHistory above
                : apiPlan.ohlcHistoricalDataLimit!,
          ),
      endDate: endAt,
      quote: quoteCurrency,
    );

    return CoinOhlc(ohlc: ohlcData);
  }

  /// Fetches OHLC data in multiple requests to handle API plan limitations.
  Future<CoinOhlc> _fetchMultipleOhlcRequests(
    String tradingSymbol,
    QuoteCurrency quoteCurrency,
    DateTime startAt,
    DateTime endAt,
    Duration batchDuration,
  ) async {
    final allOhlcData = <Ohlc>[];
    var currentStart = startAt;

    while (currentStart.isBefore(endAt)) {
      final batchEnd = currentStart.add(batchDuration);
      final actualEnd = batchEnd.isAfter(endAt) ? endAt : batchEnd;

      final actualBatchDuration = actualEnd.difference(currentStart);
      // Smallest interval is 5 minutes, so we can't have a resolution of
      // smaller than a minute
      if (actualBatchDuration.inMinutes <= 0) break;

      // Ensure batch duration doesn't exceed our chosen batch size
      if (actualBatchDuration > batchDuration) {
        throw ArgumentError.value(
          actualBatchDuration,
          'actualBatchDuration',
          'Batch duration ${actualBatchDuration.inDays} days '
              'exceeds safe limit of ${batchDuration.inDays} days',
        );
      }

      try {
        final batchOhlc = await _fetchSingleOhlcRequest(
          tradingSymbol,
          quoteCurrency,
          currentStart,
          actualEnd,
        );

        allOhlcData.addAll(batchOhlc.ohlc);
      } catch (e) {
        _logger.warning(
          'Failed to fetch batch ${currentStart.toIso8601String()} to '
          '${actualEnd.toIso8601String()}: $e',
        );
        // Continue with next batch instead of failing completely
      }

      currentStart = actualEnd;

      // Add delay between requests to avoid rate limiting
      if (currentStart.isBefore(endAt)) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    }

    return CoinOhlc(ohlc: allOhlcData);
  }

  /// Determines reasonable batch size based on API plan.
  Duration _getBatchDuration(CoinPaprikaApiPlan apiPlan) {
    if (apiPlan.hasUnlimitedOhlcHistory) {
      return const Duration(days: 90); // Reasonable default for unlimited plans
    } else {
      final planLimit = apiPlan.ohlcHistoricalDataLimit!;
      // Use smaller batches: max 90 days or plan limit minus buffer,
      // whichever is smaller
      const bufferDuration = Duration(minutes: 1);
      final maxPlanBatch = planLimit - bufferDuration;
      return maxPlanBatch.inDays > 90 ? const Duration(days: 90) : maxPlanBatch;
    }
  }

  /// Formats a DateTime to the format expected by logging and error messages.
  String _formatDateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
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
      quotes: [fiatCurrency],
    );

    final quoteData = ticker.quotes[quoteCurrencyId];
    if (quoteData == null) {
      throw Exception(
        'No price data found for ${assetId.id} in $quoteCurrencyId',
      );
    }

    return Decimal.parse(quoteData.price.toString());
  }

  @override
  Future<Map<DateTime, Decimal>> getCoinFiatPrices(
    AssetId assetId,
    List<DateTime> dates, {
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
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
      final dayStart = DateTime.utc(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1)).toUtc();

      // Find the closest OHLC data point
      Ohlc? closestOhlc;
      for (final ohlc in ohlcData.ohlc) {
        final ohlcDate = DateTime.fromMillisecondsSinceEpoch(
          ohlc.closeTimeMs,
          isUtc: true,
        );
        if (!ohlcDate.isBefore(dayStart) && ohlcDate.isBefore(dayEnd)) {
          closestOhlc = ohlc;
          break;
        }
      }

      if (closestOhlc != null) {
        result[date] = closestOhlc.closeDecimal;
      }
    }

    return result;
  }

  @override
  Future<Decimal> getCoin24hrPriceChange(
    AssetId assetId, {
    QuoteCurrency fiatCurrency = Stablecoin.usdt,
  }) async {
    final tradingSymbol = resolveTradingSymbol(assetId);
    final quoteCurrencyId = fiatCurrency.coinPaprikaId.toUpperCase();

    // Use ticker endpoint for 24hr price change
    final ticker = await coinPaprikaProvider.fetchCoinTicker(
      coinId: tradingSymbol,
      quotes: [fiatCurrency],
    );

    final quoteData = ticker.quotes[quoteCurrencyId];
    if (quoteData == null) {
      throw Exception(
        'No price change data found for ${assetId.id} in $quoteCurrencyId',
      );
    }

    return Decimal.parse(quoteData.percentChange24h.toString());
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
      // For stablecoins, we need to check if their underlying fiat currency is
      // supported since CoinPaprika treats stablecoins as their underlying
      // fiat currencies
      final currencyToCheck = fiatCurrency.when(
        fiat: (_, __) => fiatCurrency,
        stablecoin: (_, __, underlyingFiat) => underlyingFiat,
        crypto: (_, __) => fiatCurrency, // Use as-is for crypto
        commodity: (_, __) => fiatCurrency, // Use as-is for commodity
      );

      final supportedQuotes =
          _cachedQuoteCurrencies ??
          coinPaprikaProvider.supportedQuoteCurrencies
              .map((q) => q.coinPaprikaId.toUpperCase())
              .toSet();

      if (!supportedQuotes.contains(
        currencyToCheck.coinPaprikaId.toUpperCase(),
      )) {
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

  @override
  void dispose() {
    if (_ownsProvider) {
      coinPaprikaProvider.dispose();
    }
  }
}
