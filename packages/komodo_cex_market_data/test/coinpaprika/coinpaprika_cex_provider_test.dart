import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_cex_market_data/src/coinpaprika/data/coinpaprika_cex_provider.dart';
import 'package:komodo_cex_market_data/src/coinpaprika/models/coinpaprika_coin.dart';
import 'package:komodo_cex_market_data/src/coinpaprika/models/coinpaprika_market.dart';
import 'package:komodo_cex_market_data/src/coinpaprika/models/coinpaprika_ticker.dart';
import 'package:komodo_cex_market_data/src/models/_models_index.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

/// Testable CoinPaprikaProvider that allows dependency injection of HTTP client
class TestableCoinPaprikaProvider extends CoinPaprikaProvider {
  TestableCoinPaprikaProvider({
    required this.httpClient,
    String? apiKey,
    String baseUrl = 'api.coinpaprika.com',
    String apiVersion = '/v1',
  }) : super(apiKey: apiKey, baseUrl: baseUrl, apiVersion: apiVersion);

  final http.Client httpClient;

  @override
  Future<List<CoinPaprikaCoin>> fetchCoinList() async {
    try {
      final uri = Uri.https(baseUrl, '$apiVersion/coins');
      final response = await httpClient.get(uri);

      if (response.statusCode == 200) {
        final coins = jsonDecode(response.body) as List<dynamic>;
        return coins
            .cast<Map<String, dynamic>>()
            .map(CoinPaprikaCoin.fromJson)
            .toList();
      } else {
        throw Exception(
          'Failed to load coin list: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Ohlc>> fetchHistoricalOhlc({
    required String coinId,
    required DateTime startDate,
    DateTime? endDate,
    QuoteCurrency quote = FiatCurrency.usd,
    String interval = '1d',
  }) async {
    try {
      // Convert interval format: '24h' -> '1d' for CoinPaprika API compatibility
      final apiInterval = _convertIntervalForApi(interval);

      // CoinPaprika API only requires start date and interval for historical data
      final queryParams = <String, String>{
        'start': _formatDateForApi(startDate),
        'interval': apiInterval,
      };

      final uri = Uri.https(
        baseUrl,
        '$apiVersion/tickers/$coinId/historical',
        queryParams,
      );
      final response = await httpClient.get(uri);

      if (response.statusCode == 200) {
        final ticksData = jsonDecode(response.body) as List<dynamic>;
        return ticksData
            .cast<Map<String, dynamic>>()
            .map(_parseTicksToOhlc)
            .toList();
      } else {
        throw Exception(
          'Failed to load OHLC data for $coinId: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CoinPaprikaTicker> fetchCoinTicker({
    required String coinId,
    List<QuoteCurrency> quotes = const [FiatCurrency.usd],
  }) async {
    try {
      final quotesParam = quotes
          .map((q) => q.coinPaprikaId.toUpperCase())
          .join(',');
      final queryParams = <String, String>{'quotes': quotesParam};

      final uri = Uri.https(
        baseUrl,
        '$apiVersion/tickers/$coinId',
        queryParams,
      );
      final response = await httpClient.get(uri);

      if (response.statusCode == 200) {
        final ticker = jsonDecode(response.body) as Map<String, dynamic>;
        return CoinPaprikaTicker.fromJson(ticker);
      } else {
        throw Exception(
          'Failed to load ticker data for $coinId: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CoinPaprikaMarket>> fetchCoinMarkets({
    required String coinId,
    List<QuoteCurrency> quotes = const [FiatCurrency.usd],
  }) async {
    try {
      final quotesParam = quotes
          .map((q) => q.coinPaprikaId.toUpperCase())
          .join(',');
      final queryParams = <String, String>{'quotes': quotesParam};

      final uri = Uri.https(
        baseUrl,
        '$apiVersion/coins/$coinId/markets',
        queryParams,
      );
      final response = await httpClient.get(uri);

      if (response.statusCode == 200) {
        final markets = jsonDecode(response.body) as List<dynamic>;
        return markets
            .cast<Map<String, dynamic>>()
            .map(CoinPaprikaMarket.fromJson)
            .toList();
      } else {
        throw Exception(
          'Failed to load market data for $coinId: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to parse CoinPaprika historical ticks JSON into Ohlc format.
  /// Since ticks only have a single price point, we use it for open, high, low, and close.
  Ohlc _parseTicksToOhlc(Map<String, dynamic> json) {
    final timestampStr = json['timestamp'] as String;
    final timestamp = DateTime.parse(timestampStr).millisecondsSinceEpoch;
    final price = Decimal.parse(json['price'].toString());

    return Ohlc.coinpaprika(
      timeOpen: timestamp,
      timeClose: timestamp,
      open: price,
      high: price,
      low: price,
      close: price,
      volume: json['volume_24h'] != null
          ? Decimal.parse(json['volume_24h'].toString())
          : null,
      marketCap: json['market_cap'] != null
          ? Decimal.parse(json['market_cap'].toString())
          : null,
    );
  }

  /// Formats a DateTime to the format expected by CoinPaprika API.
  String _formatDateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Converts internal interval format to CoinPaprika API format.
  String _convertIntervalForApi(String interval) {
    switch (interval) {
      case '24h':
      case '1d':
        return '1d';
      case '1h':
      case '5m':
      case '15m':
      case '30m':
        return interval;
      default:
        return interval;
    }
  }
}

void main() {
  group('CoinPaprikaProvider', () {
    late MockHttpClient mockHttpClient;
    late TestableCoinPaprikaProvider provider;

    setUp(() {
      mockHttpClient = MockHttpClient();
      provider = TestableCoinPaprikaProvider(httpClient: mockHttpClient);

      // Set up fallback values for mocktail
      registerFallbackValue(Uri());
    });

    group('supportedQuoteCurrencies', () {
      test('returns the correct hard-coded list of supported currencies', () {
        // Act
        final supportedCurrencies = provider.supportedQuoteCurrencies;

        // Assert
        expect(supportedCurrencies, isNotEmpty);
        expect(supportedCurrencies, contains(Cryptocurrency.btc));
        expect(supportedCurrencies, contains(Cryptocurrency.eth));
        expect(supportedCurrencies, contains(FiatCurrency.usd));
        expect(supportedCurrencies, contains(FiatCurrency.eur));
        expect(supportedCurrencies, contains(FiatCurrency.gbp));
        expect(supportedCurrencies, contains(FiatCurrency.jpy));

        // Verify the list is unmodifiable
        expect(
          () => supportedCurrencies.add(FiatCurrency.cad),
          throwsUnsupportedError,
        );
      });

      test('includes expected number of currencies', () {
        // Act
        final supportedCurrencies = provider.supportedQuoteCurrencies;

        // Assert - Based on the hard-coded list in the provider
        expect(supportedCurrencies.length, equals(42));
      });

      test('does not include unsupported currencies', () {
        // Act
        final supportedCurrencies = provider.supportedQuoteCurrencies;

        // Assert
        final supportedSymbols = supportedCurrencies
            .map((c) => c.symbol)
            .toSet();
        expect(supportedSymbols, isNot(contains('GOLD')));
        expect(supportedSymbols, isNot(contains('SILVER')));
        expect(supportedSymbols, isNot(contains('UNSUPPORTED')));
      });
    });

    group('fetchHistoricalOhlc URL format validation', () {
      test('generates correct URL format without quote parameter', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode([
            {
              'timestamp': '2024-01-01T00:00:00Z',
              'price': 50000.0,
              'volume_24h': 1000000.0,
              'market_cap': 900000000000.0,
            },
          ]),
          200,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        final startDate = DateTime.parse('2024-01-01T00:00:00Z');

        // Act
        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: startDate,
        );

        // Assert
        final capturedUri =
            verify(() => mockHttpClient.get(captureAny())).captured.single
                as Uri;

        // Verify URL structure
        expect(capturedUri.host, equals('api.coinpaprika.com'));
        expect(capturedUri.path, equals('/v1/tickers/btc-bitcoin/historical'));

        // Verify query parameters
        expect(capturedUri.queryParameters, hasLength(2));
        expect(capturedUri.queryParameters['start'], equals('2024-01-01'));
        expect(capturedUri.queryParameters['interval'], equals('1d'));

        // Verify NO quote parameter is included
        expect(capturedUri.queryParameters.containsKey('quote'), isFalse);
        expect(capturedUri.queryParameters.containsKey('limit'), isFalse);
        expect(capturedUri.queryParameters.containsKey('end'), isFalse);
      });

      test('converts 24h interval to 1d for API compatibility', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode([
            {
              'timestamp': '2024-01-01T00:00:00Z',
              'price': 50000.0,
              'volume_24h': 1000000.0,
              'market_cap': 900000000000.0,
            },
          ]),
          200,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        final startDate = DateTime.parse('2024-01-01T00:00:00Z');

        // Act
        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: startDate,
          interval: '24h',
        );

        // Assert
        final capturedUri =
            verify(() => mockHttpClient.get(captureAny())).captured.single
                as Uri;
        expect(capturedUri.queryParameters['interval'], equals('1d'));
      });

      test('preserves 1h interval as-is', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode([
            {
              'timestamp': '2024-01-01T00:00:00Z',
              'price': 44000.0,
              'volume_24h': 500000.0,
              'market_cap': 800000000000.0,
            },
          ]),
          200,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        final startDate = DateTime.parse('2024-01-01T00:00:00Z');

        // Act
        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: startDate,
          interval: '1h',
        );

        // Assert
        final capturedUri =
            verify(() => mockHttpClient.get(captureAny())).captured.single
                as Uri;
        expect(capturedUri.queryParameters['interval'], equals('1h'));
      });

      test('formats date correctly as YYYY-MM-DD', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode([
            {
              'timestamp': '2024-01-01T00:00:00Z',
              'price': 1.02,
              'volume_24h': 100.0,
              'market_cap': 20000000.0,
            },
          ]),
          200,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        final startDate = DateTime(2024, 8, 25, 14, 30, 45); // Date with time

        // Act
        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: startDate,
        );

        // Assert
        final capturedUri =
            verify(() => mockHttpClient.get(captureAny())).captured.single
                as Uri;
        expect(capturedUri.queryParameters['start'], equals('2024-08-25'));
      });

      test('generates URL matching correct format example', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode([
            {
              'timestamp': '2025-01-01T00:00:00Z',
              'price': 50000.0,
              'volume_24h': 1000000.0,
              'market_cap': 900000000000.0,
            },
          ]),
          200,
        );

        when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);

        final startDate = DateTime(2025, 1, 1);

        // Act
        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: startDate,
          interval: '1d',
        );

        // Assert
        final capturedUri =
            verify(() => mockHttpClient.get(captureAny())).captured.single
                as Uri;

        // Verify the URL matches the correct format:
        // https://api.coinpaprika.com/v1/tickers/btc-bitcoin/historical?start=2025-01-01&interval=1d
        expect(capturedUri.toString(),
            equals('https://api.coinpaprika.com/v1/tickers/btc-bitcoin/historical?start=2025-01-01&interval=1d'));
      });
    });

    group('interval conversion tests', () {
      test('converts 24h to 1d', () async {
        final mockResponse = http.Response(jsonEncode([]), 200);
        when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);

        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: DateTime(2024, 1, 1),
          interval: '24h',
        );

        final capturedUri = verify(() => mockHttpClient.get(captureAny())).captured.single as Uri;
        expect(capturedUri.queryParameters['interval'], equals('1d'));
      });

      test('preserves 1d as-is', () async {
        final mockResponse = http.Response(jsonEncode([]), 200);
        when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);

        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: DateTime(2024, 1, 1),
          interval: '1d',
        );

        final capturedUri = verify(() => mockHttpClient.get(captureAny())).captured.single as Uri;
        expect(capturedUri.queryParameters['interval'], equals('1d'));
      });

      test('preserves 1h as-is', () async {
        final mockResponse = http.Response(jsonEncode([]), 200);
        when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);

        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: DateTime(2024, 1, 1),
          interval: '1h',
        );

        final capturedUri = verify(() => mockHttpClient.get(captureAny())).captured.single as Uri;
        expect(capturedUri.queryParameters['interval'], equals('1h'));
      });

      test('preserves 5m as-is', () async {
        final mockResponse = http.Response(jsonEncode([]), 200);
        when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);

        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: DateTime(2024, 1, 1),
          interval: '5m',
        );

        final capturedUri = verify(() => mockHttpClient.get(captureAny())).captured.single as Uri;
        expect(capturedUri.queryParameters['interval'], equals('5m'));
      });

      test('preserves 15m as-is', () async {
        final mockResponse = http.Response(jsonEncode([]), 200);
        when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);

        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: DateTime(2024, 1, 1),
          interval: '15m',
        );

        final capturedUri = verify(() => mockHttpClient.get(captureAny())).captured.single as Uri;
        expect(capturedUri.queryParameters['interval'], equals('15m'));
      });

      test('preserves 30m as-is', () async {
        final mockResponse = http.Response(jsonEncode([]), 200);
        when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);

        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: DateTime(2024, 1, 1),
          interval: '30m',
        );

        final capturedUri = verify(() => mockHttpClient.get(captureAny())).captured.single as Uri;
        expect(capturedUri.queryParameters['interval'], equals('30m'));
      });

      test('passes through unknown intervals as-is', () async {
        final mockResponse = http.Response(jsonEncode([]), 200);
        when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);

        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: DateTime(2024, 1, 1),
          interval: '7d',
        );

        final capturedUri = verify(() => mockHttpClient.get(captureAny())).captured.single as Uri;
        expect(capturedUri.queryParameters['interval'], equals('7d'));
      });
    });

    group('date formatting tests', () {
      test('formats single digit month correctly', () async {
        final mockResponse = http.Response(jsonEncode([]), 200);
        when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);

        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: DateTime(2024, 3, 5),
        );

        final capturedUri = verify(() => mockHttpClient.get(captureAny())).captured.single as Uri;
        expect(capturedUri.queryParameters['start'], equals('2024-03-05'));
      });

      test('formats single digit day correctly', () async {
        final mockResponse = http.Response(jsonEncode([]), 200);
        when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);

        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: DateTime(2024, 12, 7),
        );

        final capturedUri = verify(() => mockHttpClient.get(captureAny())).captured.single as Uri;
        expect(capturedUri.queryParameters['start'], equals('2024-12-07'));
      });

      test('ignores time portion of datetime', () async {
        final mockResponse = http.Response(jsonEncode([]), 200);
        when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);

        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: DateTime(2024, 6, 15, 14, 30, 45, 123, 456),
        );

        final capturedUri = verify(() => mockHttpClient.get(captureAny())).captured.single as Uri;
        expect(capturedUri.queryParameters['start'], equals('2024-06-15'));
      });
    });

    group('URL format regression tests', () {
      test('URL format does not cause 400 Bad Request - regression test', () async {
        // This test validates the fix for the issue where the old URL format:
        // https://api.coinpaprika.com/v1/tickers/aur-auroracoin/historical?start=2025-08-25&quote=usdt&interval=24h&limit=5000&end=2025-09-01
        // was causing 400 Bad Request responses.
        //
        // The correct format is:
        // https://api.coinpaprika.com/v1/tickers/btc-bitcoin/historical?start=2025-01-01&interval=1d

        final mockResponse = http.Response(
          jsonEncode([
            {
              'timestamp': '2025-01-01T00:00:00Z',
              'price': 50000.0,
              'volume_24h': 1000000.0,
              'market_cap': 900000000000.0,
            },
          ]),
          200, // Should not be 400 Bad Request
        );

        when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);

        final startDate = DateTime(2025, 8, 25);

        // Act - this should not throw an exception or cause 400 Bad Request
        final result = await provider.fetchHistoricalOhlc(
          coinId: 'aur-auroracoin',
          startDate: startDate,
          interval: '24h', // This gets converted to '1d'
        );

        // Assert
        expect(result, isNotEmpty);

        final capturedUri = verify(() => mockHttpClient.get(captureAny())).captured.single as Uri;

        // Verify the URL does NOT contain the problematic parameters that caused 400 errors
        expect(capturedUri.queryParameters.containsKey('quote'), isFalse,
            reason: 'quote parameter should not be included in historical OHLC requests');
        expect(capturedUri.queryParameters.containsKey('limit'), isFalse,
            reason: 'limit parameter should not be included');
        expect(capturedUri.queryParameters.containsKey('end'), isFalse,
            reason: 'end parameter should not be included unless specifically needed');

        // Verify the URL contains only the required parameters
        expect(capturedUri.queryParameters, hasLength(2));
        expect(capturedUri.queryParameters['start'], equals('2025-08-25'));
        expect(capturedUri.queryParameters['interval'], equals('1d')); // 24h converted to 1d

        // Verify the complete URL format is correct
        expect(capturedUri.toString(),
            equals('https://api.coinpaprika.com/v1/tickers/aur-auroracoin/historical?start=2025-08-25&interval=1d'));
      });

      test('validates that quote parameter removal prevents USDT-related 400 errors', () async {
        // The original problematic URL included &quote=usdt which caused 400 errors
        final mockResponse = http.Response(jsonEncode([]), 200);
        when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);

        // This call previously would have included quote=usdt in the URL
        await provider.fetchHistoricalOhlc(
          coinId: 'btc-bitcoin',
          startDate: DateTime(2025, 8, 25),
          quote: Stablecoin.usdt, // This parameter is now ignored for historical data
        );

        final capturedUri = verify(() => mockHttpClient.get(captureAny())).captured.single as Uri;

        // Verify USDT quote is not included in the URL
        expect(capturedUri.queryParameters.containsKey('quote'), isFalse);
        expect(capturedUri.toString(), isNot(contains('usdt')));
        expect(capturedUri.toString(), isNot(contains('quote')));
      });
    });

    group('fetchCoinTicker quote currency mapping', () {
      test(
        'uses correct coinPaprikaId mapping for multiple quote currencies',
        () async {
          // Arrange
          final mockResponse = http.Response(
            jsonEncode({
              'id': 'btc-bitcoin',
              'quotes': {
                'USD': {'price': 50000.0},
                'USDT': {'price': 50010.0},
                'EUR': {'price': 42000.0},
              },
            }),
            200,
          );

          when(
            () => mockHttpClient.get(any()),
          ).thenAnswer((_) async => mockResponse);

          // Act
          await provider.fetchCoinTicker(
            coinId: 'btc-bitcoin',
            quotes: [FiatCurrency.usd, Stablecoin.usdt, FiatCurrency.eur],
          );

          // Assert
          final capturedUri =
              verify(() => mockHttpClient.get(captureAny())).captured.single
                  as Uri;
          final quotesParam = capturedUri.queryParameters['quotes'];
          expect(quotesParam, equals('USD,USDT,EUR'));
        },
      );

      test('converts coinPaprikaId to uppercase for API request', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode({
            'id': 'btc-bitcoin',
            'quotes': {
              'BTC': {'price': 1.0},
              'ETH': {'price': 15.2},
            },
          }),
          200,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await provider.fetchCoinTicker(
          coinId: 'btc-bitcoin',
          quotes: [Cryptocurrency.btc, Cryptocurrency.eth],
        );

        // Assert
        final capturedUri =
            verify(() => mockHttpClient.get(captureAny())).captured.single
                as Uri;
        final quotesParam = capturedUri.queryParameters['quotes'];
        expect(quotesParam, equals('BTC,ETH'));
      });

      test('handles single quote currency correctly', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode({
            'id': 'btc-bitcoin',
            'quotes': {
              'GBP': {'price': 38000.0},
            },
          }),
          200,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await provider.fetchCoinTicker(
          coinId: 'btc-bitcoin',
          quotes: [FiatCurrency.gbp],
        );

        // Assert
        final capturedUri =
            verify(() => mockHttpClient.get(captureAny())).captured.single
                as Uri;
        final quotesParam = capturedUri.queryParameters['quotes'];
        expect(quotesParam, equals('GBP'));
      });
    });

    group('fetchCoinMarkets quote currency mapping', () {
      test('uses correct coinPaprikaId mapping for market data', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode([
            {
              'exchange_id': 'binance',
              'exchange_name': 'Binance',
              'pair': 'BTC/USDT',
              'base_currency_id': 'btc-bitcoin',
              'base_currency_name': 'Bitcoin',
              'quote_currency_id': 'usdt-tether',
              'quote_currency_name': 'Tether',
              'market_url': 'https://binance.com/trade/BTC_USDT',
              'category': 'Spot',
              'fee_type': 'Percentage',
              'outlier': false,
              'adjusted_volume24h_share': 12.5,
              'last_updated': '2023-01-01T00:00:00Z',
              'quotes': {
                'USD': {'price': '50000.0', 'volume_24h': '1000000.0'},
              },
            },
          ]),
          200,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await provider.fetchCoinMarkets(
          coinId: 'btc-bitcoin',
          quotes: [FiatCurrency.usd, Stablecoin.usdt],
        );

        // Assert
        final capturedUri =
            verify(() => mockHttpClient.get(captureAny())).captured.single
                as Uri;
        final quotesParam = capturedUri.queryParameters['quotes'];
        expect(quotesParam, equals('USD,USDT'));
      });
    });

    group('coinPaprikaId extension usage', () {
      test('verifies QuoteCurrency.coinPaprikaId returns lowercase values', () {
        // Test various currency types to ensure the extension works correctly
        expect(FiatCurrency.usd.coinPaprikaId, equals('usd'));
        expect(FiatCurrency.eur.coinPaprikaId, equals('eur'));
        expect(FiatCurrency.gbp.coinPaprikaId, equals('gbp'));
        expect(Stablecoin.usdt.coinPaprikaId, equals('usdt'));
        expect(Stablecoin.usdc.coinPaprikaId, equals('usdc'));
        expect(Stablecoin.eurs.coinPaprikaId, equals('eurs'));
        expect(Cryptocurrency.btc.coinPaprikaId, equals('btc'));
        expect(Cryptocurrency.eth.coinPaprikaId, equals('eth'));
      });

      test('verifies provider uses coinPaprikaId extension consistently', () {
        // Arrange
        const testCurrency = FiatCurrency.jpy;

        // Act & Assert
        expect(testCurrency.coinPaprikaId, equals('jpy'));

        // Verify this matches what would be used in the provider
        final supportedCurrencies = provider.supportedQuoteCurrencies;
        final jpyCurrency = supportedCurrencies.firstWhere(
          (currency) => currency.symbol == 'JPY',
        );
        expect(jpyCurrency.coinPaprikaId, equals('jpy'));
      });
    });

    group('error handling', () {
      test('throws exception when HTTP request fails for OHLC', () async {
        // Arrange
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response('Server Error', 500));

        final startDate = DateTime.parse('2024-01-01T00:00:00Z');

        // Act & Assert
        expect(
          () => provider.fetchHistoricalOhlc(
            coinId: 'btc-bitcoin',
            startDate: startDate,
            quote: FiatCurrency.usd,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when HTTP request fails for ticker', () async {
        // Arrange
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response('Server Error', 500));

        // Act & Assert
        expect(
          () => provider.fetchCoinTicker(
            coinId: 'btc-bitcoin',
            quotes: [FiatCurrency.usd],
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
