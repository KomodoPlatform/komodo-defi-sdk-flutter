import 'dart:convert';

import 'package:decimal/decimal.dart' show Decimal;
import 'package:http/http.dart' as http;
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_cex_market_data/src/coingecko/models/coin_historical_data/coin_historical_data.dart';
import 'package:logging/logging.dart';

/// Interface for fetching data from CoinGecko API.
abstract class ICoinGeckoProvider {
  Future<List<CexCoin>> fetchCoinList({bool includePlatforms = false});

  Future<List<String>> fetchSupportedVsCurrencies();

  Future<List<CoinMarketData>> fetchCoinMarketData({
    String vsCurrency = 'usd',
    List<String>? ids,
    String? category,
    String order = 'market_cap_asc',
    int perPage = 100,
    int page = 1,
    bool sparkline = false,
    String? priceChangePercentage,
    String locale = 'en',
    String? precision,
  });

  Future<CoinMarketChart> fetchCoinMarketChart({
    required String id,
    required String vsCurrency,
    required int fromUnixTimestamp,
    required int toUnixTimestamp,
    String? precision,
  });

  Future<CoinOhlc> fetchCoinOhlc(
    String id,
    String vsCurrency,
    int days, {
    int? precision,
  });

  Future<CoinHistoricalData> fetchCoinHistoricalMarketData({
    required String id,
    required DateTime date,
    String vsCurrency = 'usd',
    bool localization = false,
  });

  Future<Map<String, AssetMarketInformation>> fetchCoinPrices(
    List<String> coinGeckoIds, {
    List<String> vsCurrencies = const <String>['usd'],
  });
}

/// A class for fetching data from CoinGecko API.
class CoinGeckoCexProvider implements ICoinGeckoProvider {
  /// Creates a new instance of [CoinGeckoCexProvider].
  CoinGeckoCexProvider({
    this.baseUrl = 'api.coingecko.com',
    this.apiVersion = '/api/v3',
  });

  /// The base URL for the CoinGecko API.
  final String baseUrl;

  /// The API version for the CoinGecko API.
  final String apiVersion;

  static final Logger _logger = Logger('CoinGeckoCexProvider');

  /// Fetches the list of coins supported by CoinGecko.
  ///
  /// [includePlatforms] Include platform contract addresses.
  @override
  Future<List<CexCoin>> fetchCoinList({bool includePlatforms = false}) async {
    final queryParameters = <String, String>{
      'include_platform': includePlatforms.toString(),
    };
    final uri = Uri.https(baseUrl, '$apiVersion/coins/list', queryParameters);

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final coins = jsonDecode(response.body) as List<dynamic>;
      return coins
          .map(
            (dynamic element) =>
                CexCoin.fromJson(element as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception(
        'Failed to load coin list: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Fetches the list of supported vs currencies.
  @override
  Future<List<String>> fetchSupportedVsCurrencies() async {
    final uri = Uri.https(
      baseUrl,
      '$apiVersion/simple/supported_vs_currencies',
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final currencies = jsonDecode(response.body) as List<dynamic>;
      return currencies.map((dynamic currency) => currency as String).toList();
    } else {
      throw Exception(
        'Failed to load supported vs currencies: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Fetches the market data for a specific currency.
  ///
  /// [vsCurrency] The target currency of market data (usd, eur, jpy, etc.).
  /// [ids] The ids of the coins, comma separated.
  /// [category] The category of the coins.
  /// [order] The order of the coins.
  /// [perPage] Total results per page.
  /// [page] Page through results.
  /// [sparkline] Include sparkline 7 days data.
  /// [priceChangePercentage] Comma-sepa
  /// [locale] The localization of the market data.
  /// [precision] The price's precision.
  @override
  Future<List<CoinMarketData>> fetchCoinMarketData({
    String vsCurrency = 'usd',
    List<String>? ids,
    String? category,
    String order = 'market_cap_asc',
    int perPage = 100,
    int page = 1,
    bool sparkline = false,
    String? priceChangePercentage,
    String locale = 'en',
    String? precision,
  }) {
    final queryParameters = <String, String>{
      'vs_currency': vsCurrency,
      if (ids != null) 'ids': ids.join(','),
      if (category != null) 'category': category,
      'order': order,
      'per_page': perPage.toString(),
      'page': page.toString(),
      'sparkline': sparkline.toString(),
      if (priceChangePercentage != null)
        'price_change_percentage': priceChangePercentage,
      'locale': locale,
      if (precision != null) 'price_change_percentage': precision,
    };
    final uri = Uri.https(
      baseUrl,
      '$apiVersion/coins/markets',
      queryParameters,
    );

    return http.get(uri).then((http.Response response) {
      if (response.statusCode == 200) {
        final coins = jsonDecode(response.body) as List<dynamic>;
        return coins
            .map(
              (dynamic element) =>
                  CoinMarketData.fromJson(element as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load coin market data: ${response.statusCode} ${response.body}',
        );
      }
    });
  }

  /// Fetches the market chart data for a specific currency.
  ///
  /// [id] The id of the coin.
  /// [vsCurrency] The target currency of market data (usd, eur, jpy, etc.).
  /// [fromUnixTimestamp] From date in UNIX Timestamp.
  /// [toUnixTimestamp] To date in UNIX Timestamp.
  /// [precision] The price's precision.
  @override
  Future<CoinMarketChart> fetchCoinMarketChart({
    required String id,
    required String vsCurrency,
    required int fromUnixTimestamp,
    required int toUnixTimestamp,
    String? precision,
  }) async {
    // Validate that dates are within CoinGecko's historical data limit
    _validateHistoricalDataAccess(fromUnixTimestamp, toUnixTimestamp);

    const maxDaysPerRequest = 365;
    const secondsPerDay = 86400;
    const maxSecondsPerRequest = maxDaysPerRequest * secondsPerDay;

    final totalDuration = toUnixTimestamp - fromUnixTimestamp;

    // If the range is within 365 days, make a single request
    if (totalDuration <= maxSecondsPerRequest) {
      return _fetchCoinMarketChartSingle(
        id: id,
        vsCurrency: vsCurrency,
        fromUnixTimestamp: fromUnixTimestamp,
        toUnixTimestamp: toUnixTimestamp,
        precision: precision,
      );
    }

    // Split into multiple requests and combine results
    final List<CoinMarketChart> charts = [];
    int currentFrom = fromUnixTimestamp;

    while (currentFrom < toUnixTimestamp) {
      final currentTo =
          (currentFrom + maxSecondsPerRequest) > toUnixTimestamp
              ? toUnixTimestamp
              : currentFrom + maxSecondsPerRequest;

      final chart = await _fetchCoinMarketChartSingle(
        id: id,
        vsCurrency: vsCurrency,
        fromUnixTimestamp: currentFrom,
        toUnixTimestamp: currentTo,
        precision: precision,
      );

      charts.add(chart);
      currentFrom = currentTo;
    }

    // Combine all charts into one
    return _combineCoinMarketCharts(charts);
  }

  /// Makes a single API request for coin market chart data.
  Future<CoinMarketChart> _fetchCoinMarketChartSingle({
    required String id,
    required String vsCurrency,
    required int fromUnixTimestamp,
    required int toUnixTimestamp,
    String? precision,
  }) {
    final queryParameters = <String, String>{
      'vs_currency': vsCurrency,
      'from': fromUnixTimestamp.toString(),
      'to': toUnixTimestamp.toString(),
      if (precision != null) 'precision': precision,
    };
    final uri = Uri.https(
      baseUrl,
      '$apiVersion/coins/$id/market_chart/range',
      queryParameters,
    );

    return http.get(uri).then((http.Response response) {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CoinMarketChart.fromJson(data);
      } else {
        throw Exception(
          'Failed to load coin market chart: ${response.statusCode} ${response.body}',
        );
      }
    });
  }

  /// Combines multiple CoinMarketChart objects into a single one.
  CoinMarketChart _combineCoinMarketCharts(List<CoinMarketChart> charts) {
    if (charts.isEmpty) {
      throw ArgumentError('Cannot combine empty list of charts');
    }

    if (charts.length == 1) {
      return charts.first;
    }

    final List<List<num>> combinedPrices = [];
    final List<List<num>> combinedMarketCaps = [];
    final List<List<num>> combinedTotalVolumes = [];

    for (final chart in charts) {
      combinedPrices.addAll(chart.prices);
      combinedMarketCaps.addAll(chart.marketCaps);
      combinedTotalVolumes.addAll(chart.totalVolumes);
    }

    // Remove potential duplicate data points at boundaries
    final uniquePrices = _removeDuplicateDataPoints(combinedPrices);
    final uniqueMarketCaps = _removeDuplicateDataPoints(combinedMarketCaps);
    final uniqueTotalVolumes = _removeDuplicateDataPoints(combinedTotalVolumes);

    return CoinMarketChart(
      prices: uniquePrices,
      marketCaps: uniqueMarketCaps,
      totalVolumes: uniqueTotalVolumes,
    );
  }

  /// Removes duplicate data points based on timestamp (first element).
  List<List<num>> _removeDuplicateDataPoints(List<List<num>> dataPoints) {
    if (dataPoints.isEmpty) return dataPoints;

    final Map<num, List<num>> uniquePoints = {};
    for (final point in dataPoints) {
      if (point.isNotEmpty) {
        final timestamp = point[0];
        uniquePoints[timestamp] = point;
      }
    }

    final sortedKeys = uniquePoints.keys.toList()..sort();
    return sortedKeys.map((key) => uniquePoints[key]!).toList();
  }

  /// Validates that the requested time range is within CoinGecko's historical data limits.
  /// Public API users are limited to querying historical data within the past 365 days.
  void _validateHistoricalDataAccess(
    int fromUnixTimestamp,
    int toUnixTimestamp,
  ) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const maxDaysBack = 365;
    const secondsPerDay = 86400;
    const maxSecondsBack = maxDaysBack * secondsPerDay;

    // Check if the from date is more than 365 days in the past
    final daysFromNow = (now - fromUnixTimestamp) / secondsPerDay;
    if (daysFromNow > maxDaysBack) {
      throw ArgumentError(
        'From date cannot be more than 365 days in the past for CoinGecko public API. '
        'From date is ${daysFromNow.ceil()} days ago. Maximum allowed: $maxDaysBack days.',
      );
    }

    // Check if the to date is more than 365 days in the past
    final toDaysFromNow = (now - toUnixTimestamp) / secondsPerDay;
    if (toDaysFromNow > maxDaysBack) {
      throw ArgumentError(
        'To date cannot be more than 365 days in the past for CoinGecko public API. '
        'To date is ${toDaysFromNow.ceil()} days ago. Maximum allowed: $maxDaysBack days.',
      );
    }
  }

  /// Fetches the market chart data for a specific currency.
  ///
  /// [id] The id of the coin.
  /// [vsCurrency] The target currency of market data (usd, eur, jpy, etc.).
  /// [date] The date of the market data to fetch.
  /// [localization] Include all the localized languages in response. Defaults to false.
  @override
  Future<CoinHistoricalData> fetchCoinHistoricalMarketData({
    required String id,
    required DateTime date,
    String vsCurrency = 'usd',
    bool localization = false,
  }) {
    final queryParameters = <String, String>{
      'date': _formatDate(date),
      'localization': localization.toString(),
    };
    final uri = Uri.https(
      baseUrl,
      '$apiVersion/coins/$id/history',
      queryParameters,
    );

    return http.get(uri).then((http.Response response) {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CoinHistoricalData.fromJson(data);
      } else {
        throw Exception(
          'Failed to load coin market chart: ${response.statusCode} ${response.body}',
        );
      }
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  /// Fetches prices from CoinGecko API.
  /// The CoinGecko API is used as a fallback when the Komodo API is down.
  ///
  /// The [coinGeckoIds] are the CoinGecko IDs of the coins to fetch prices for.
  /// The [vsCurrencies] is a comma-separated list of currencies to compare to.
  ///
  /// Returns a map of coingecko IDs to their [AssetMarketInformation]s.
  ///
  /// Throws an error if the request fails.
  ///
  /// Example:
  /// ```dart
  /// final prices = await cexPriceProvider.getCoinGeckoPrices(
  ///  ['bitcoin', 'ethereum'],
  /// );
  @override
  Future<Map<String, AssetMarketInformation>> fetchCoinPrices(
    List<String> coinGeckoIds, {
    List<String> vsCurrencies = const <String>['usd'],
  }) async {
    final currencies = vsCurrencies.join(',');
    coinGeckoIds.removeWhere((String id) => id.isEmpty);

    final tickersUrl = Uri.https(baseUrl, '$apiVersion/simple/price', {
      'ids': coinGeckoIds.join(','),
      'vs_currencies': currencies,
    });

    final res = await http.get(tickersUrl);
    final body = res.body;

    final json = jsonDecode(body) as Map<String, dynamic>?;
    if (json == null) {
      throw Exception('Invalid response from CoinGecko API: empty JSON');
    }

    final prices = <String, AssetMarketInformation>{};
    json.forEach((String coingeckoId, dynamic pricesData) {
      if (coingeckoId == 'test-coin') {
        return;
      }

      // TODO(Francois): map to multiple currencies, or only allow 1 vs currency
      final price = (pricesData as Map<String, dynamic>)['usd'] as num?;

      // Parse price with explicit error handling
      Decimal parsedPrice;
      final priceString = price?.toString() ?? '';

      if (price == null || priceString.isEmpty) {
        _logger.warning(
          'CoinGecko API returned null or empty price for $coingeckoId',
        );
        throw Exception(
          'Invalid price data for $coingeckoId: received null or empty value',
        );
      }

      final tempPrice = Decimal.tryParse(priceString);
      if (tempPrice == null) {
        _logger.warning(
          'Failed to parse price "$priceString" for $coingeckoId as Decimal',
        );
        throw Exception(
          'Invalid price data for $coingeckoId: could not parse "$priceString" as decimal',
        );
      }

      parsedPrice = tempPrice;

      prices[coingeckoId] = AssetMarketInformation(
        ticker: coingeckoId,
        lastPrice: parsedPrice,
      );
    });

    return prices;
  }

  /// Fetches the ohlc data for a specific currency.
  ///
  /// [id] The id of the coin.
  /// [vsCurrency] The target currency of market data (usd, eur, jpy, etc.).
  /// [days] Data up to number of days ago.
  /// [precision] The price's precision.
  @override
  Future<CoinOhlc> fetchCoinOhlc(
    String id,
    String vsCurrency,
    int days, {
    int? precision,
  }) {
    // Validate days constraint for CoinGecko public API
    if (days > 365) {
      throw ArgumentError(
        'Days parameter cannot exceed 365 for CoinGecko public API. '
        'Requested: $days days. Maximum allowed: 365 days.',
      );
    }
    final queryParameters = <String, String>{
      'id': id,
      'vs_currency': vsCurrency,
      'days': days.toString(),
      if (precision != null) 'precision': precision.toString(),
    };

    final uri = Uri.https(
      baseUrl,
      '$apiVersion/coins/$id/ohlc',
      queryParameters,
    );

    return http.get(uri).then((http.Response response) {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return CoinOhlc.fromJson(data, source: OhlcSource.coingecko);
      } else {
        throw Exception(
          'Failed to load coin ohlc data: ${response.statusCode} ${response.body}',
        );
      }
    });
  }
}
