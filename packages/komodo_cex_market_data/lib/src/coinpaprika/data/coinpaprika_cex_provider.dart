import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_cex_market_data/src/coinpaprika/models/coinpaprika_coin.dart';
import 'package:komodo_cex_market_data/src/coinpaprika/models/coinpaprika_market.dart';
import 'package:komodo_cex_market_data/src/models/models.dart';
import 'package:logging/logging.dart';

/// Configuration constants for CoinPaprika API.
class CoinPaprikaConfig {
  /// Base URL for CoinPaprika API
  static const String baseUrl = 'https://api.coinpaprika.com/v1';

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 30);

  /// Maximum number of retries for failed requests
  static const int maxRetries = 3;

  /// Free tier daily limit in hours for OHLC data
  static const int freeTierDayLimit = 24;

  /// Rate limit: requests per month for free tier
  static const int freeRequestsPerMonth = 25000;
}

/// Abstract interface for CoinPaprika data provider.
abstract class ICoinPaprikaProvider {
  /// Fetches the list of all available coins.
  Future<List<CoinPaprikaCoin>> fetchCoinList();

  /// Fetches historical OHLC data for a specific coin.
  ///
  /// [coinId]: The CoinPaprika coin identifier (e.g., "btc-bitcoin")
  /// [startDate]: Start date for historical data
  /// [endDate]: End date for historical data (optional)
  /// [quote]: Quote currency (default: "usd")
  /// [interval]: Data interval (default: "24h")
  Future<List<Ohlc>> fetchHistoricalOhlc({
    required String coinId,
    required DateTime startDate,
    DateTime? endDate,
    String quote = 'usd',
    String interval = '24h',
  });

  /// Fetches current market data for a specific coin.
  ///
  /// [coinId]: The CoinPaprika coin identifier (e.g., "btc-bitcoin")
  /// [quotes]: Comma-separated list of quote currencies
  Future<List<CoinPaprikaMarket>> fetchCoinMarkets({
    required String coinId,
    String quotes = 'USD',
  });

  /// Fetches ticker data for a specific coin.
  ///
  /// [coinId]: The CoinPaprika coin identifier (e.g., "btc-bitcoin")
  /// [quotes]: Comma-separated list of quote currencies
  Future<Map<String, dynamic>> fetchCoinTicker({
    required String coinId,
    String quotes = 'USD',
  });
}

/// Implementation of CoinPaprika data provider using HTTP requests.
class CoinPaprikaProvider implements ICoinPaprikaProvider {
  /// Creates a new CoinPaprika provider instance.
  CoinPaprikaProvider({
    String? apiKey,
    this.baseUrl = 'api.coinpaprika.com',
    this.apiVersion = '/v1',
  }) : _apiKey = apiKey;

  /// The base URL for the CoinPaprika API.
  final String baseUrl;

  /// The API version for the CoinPaprika API.
  final String apiVersion;

  final String? _apiKey;

  static final Logger _logger = Logger('CoinPaprikaProvider');

  @override
  Future<List<CoinPaprikaCoin>> fetchCoinList() async {
    try {
      _logger.info('Fetching coin list from CoinPaprika');

      final uri = Uri.https(baseUrl, '$apiVersion/coins');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final coins = jsonDecode(response.body) as List<dynamic>;
        final result = coins
            .cast<Map<String, dynamic>>()
            .map(CoinPaprikaCoin.fromJson)
            .toList();

        _logger.info(
          'Successfully fetched ${result.length} coins from CoinPaprika',
        );
        return result;
      } else {
        throw Exception(
          'Failed to load coin list: ${response.statusCode} ${response.body}',
        );
      }
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
  Future<List<Ohlc>> fetchHistoricalOhlc({
    required String coinId,
    required DateTime startDate,
    DateTime? endDate,
    String quote = 'usd',
    String interval = '24h',
  }) async {
    try {
      _logger.info(
        'Fetching OHLC data for $coinId from ${startDate.toIso8601String()} to ${endDate?.toIso8601String() ?? 'now'}',
      );

      final queryParams = <String, String>{
        'start': startDate.toIso8601String(),
        'quote': quote,
        'interval': interval,
      };

      if (endDate != null) {
        queryParams['end'] = endDate.toIso8601String();
      }

      final uri = Uri.https(
        baseUrl,
        '$apiVersion/coins/$coinId/ohlcv/historical',
        queryParams,
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final ohlcData = jsonDecode(response.body) as List<dynamic>;
        final result = ohlcData
            .cast<Map<String, dynamic>>()
            .map(_parseOhlcFromJson)
            .toList();

        _logger.info(
          'Successfully fetched ${result.length} OHLC data points for $coinId',
        );
        return result;
      } else {
        throw Exception(
          'Failed to load OHLC data for $coinId: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      _logger.severe('Failed to fetch OHLC data for $coinId', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<CoinPaprikaMarket>> fetchCoinMarkets({
    required String coinId,
    String quotes = 'USD',
  }) async {
    try {
      _logger.info('Fetching market data for $coinId with quotes: $quotes');

      final queryParams = <String, String>{'quotes': quotes};

      final uri = Uri.https(
        baseUrl,
        '$apiVersion/coins/$coinId/markets',
        queryParams,
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final markets = jsonDecode(response.body) as List<dynamic>;
        final result = markets
            .cast<Map<String, dynamic>>()
            .map(CoinPaprikaMarket.fromJson)
            .toList();

        _logger.info(
          'Successfully fetched ${result.length} markets for $coinId',
        );
        return result;
      } else {
        throw Exception(
          'Failed to load market data for $coinId: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      _logger.severe('Failed to fetch markets for $coinId', e, stackTrace);
      rethrow;
    }
  }

  /// Fetches ticker data for a specific coin.
  ///
  /// [coinId]: The CoinPaprika coin identifier (e.g., "btc-bitcoin")
  /// [quotes]: Comma-separated list of quote currencies
  @override
  Future<Map<String, dynamic>> fetchCoinTicker({
    required String coinId,
    String quotes = 'USD',
  }) async {
    try {
      _logger.info('Fetching ticker data for $coinId with quotes: $quotes');

      final queryParams = <String, String>{'quotes': quotes};

      final uri = Uri.https(
        baseUrl,
        '$apiVersion/tickers/$coinId',
        queryParams,
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final ticker = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.info('Successfully fetched ticker data for $coinId');
        return ticker;
      } else {
        throw Exception(
          'Failed to load ticker data for $coinId: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      _logger.severe('Failed to fetch ticker data for $coinId', e, stackTrace);
      rethrow;
    }
  }

  /// Helper method to parse CoinPaprika OHLC JSON into Ohlc format.
  Ohlc _parseOhlcFromJson(Map<String, dynamic> json) {
    final timeOpenStr = json['time_open'] as String;
    final timeCloseStr = json['time_close'] as String;

    final timeOpen = DateTime.parse(timeOpenStr).millisecondsSinceEpoch;
    final timeClose = DateTime.parse(timeCloseStr).millisecondsSinceEpoch;

    return Ohlc.coinpaprika(
      timeOpen: timeOpen,
      timeClose: timeClose,
      open: Decimal.parse(json['open'].toString()),
      high: Decimal.parse(json['high'].toString()),
      low: Decimal.parse(json['low'].toString()),
      close: Decimal.parse(json['close'].toString()),
      volume: json['volume'] != null
          ? Decimal.parse(json['volume'].toString())
          : null,
      marketCap: json['market_cap'] != null
          ? Decimal.parse(json['market_cap'].toString())
          : null,
    );
  }
}
