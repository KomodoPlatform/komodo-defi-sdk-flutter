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

import 'fixtures/mock_helpers.dart';
import 'fixtures/test_constants.dart';
import 'fixtures/test_fixtures.dart';
import 'fixtures/verification_helpers.dart';

/// Testable CoinPaprikaProvider that allows dependency injection of HTTP client
class TestableCoinPaprikaProvider extends CoinPaprikaProvider {
  TestableCoinPaprikaProvider({
    required this.httpClient,
    super.apiKey,
    super.baseUrl,
    super.apiVersion,
  });

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
      MockHelpers.registerFallbackValues();
      mockHttpClient = MockHttpClient();
      provider = TestableCoinPaprikaProvider(httpClient: mockHttpClient);
    });

    group('supportedQuoteCurrencies', () {
      test('returns the correct hard-coded list of supported currencies', () {
        // Act
        final supportedCurrencies = provider.supportedQuoteCurrencies;

        // Assert
        expect(supportedCurrencies, isNotEmpty);
        for (final currency in TestConstants.defaultSupportedCurrencies) {
          expect(supportedCurrencies, contains(currency));
        }

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
        final mockResponse = TestFixtures.createHistoricalOhlcResponse();

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        final startDate = TestData.pastDate;

        // Act
        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: startDate,
        );

        // Assert
        VerificationHelpers.verifyHistoricalOhlcUrl(
          mockHttpClient,
          TestConstants.bitcoinCoinId,
          expectedStartDate: TestConstants.dateFormat,
          expectedInterval: TestConstants.interval1d,
          excludedParams: ['quote', 'limit', 'end'],
        );
      });

      test('converts 24h interval to 1d for API compatibility', () async {
        // Arrange
        final mockResponse = TestFixtures.createHistoricalOhlcResponse();

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: TestData.pastDate,
          interval: TestConstants.interval24h,
        );

        // Assert
        VerificationHelpers.verifyIntervalConversion(
          mockHttpClient,
          TestConstants.interval24h,
          TestConstants.interval1d,
        );
      });

      test('preserves 1h interval as-is', () async {
        // Arrange
        final mockResponse = TestFixtures.createHistoricalOhlcResponse(
          price: 44000,
          volume24h: TestConstants.mediumVolume,
          marketCap: 800000000000,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: TestData.pastDate,
          interval: TestConstants.interval1h,
        );

        // Assert
        VerificationHelpers.verifyIntervalConversion(
          mockHttpClient,
          TestConstants.interval1h,
          TestConstants.interval1h,
        );
      });

      test('formats date correctly as YYYY-MM-DD', () async {
        // Arrange
        final mockResponse = TestFixtures.createHistoricalOhlcResponse(
          price: 1.02,
          volume24h: TestConstants.lowVolume,
          marketCap: TestConstants.smallMarketCap,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        final startDate = DateTime(2024, 8, 25, 14, 30, 45); // Date with time

        // Act
        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: startDate,
        );

        // Assert
        VerificationHelpers.verifyDateFormatting(
          mockHttpClient,
          startDate,
          '2024-08-25',
        );
      });

      test('generates URL matching correct format example', () async {
        // Arrange
        final mockResponse = TestFixtures.createHistoricalOhlcResponse(
          timestamp: '2025-01-01T00:00:00Z',
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        final startDate = DateTime(2025);

        // Act
        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: startDate,
        );

        // Assert
        VerificationHelpers.verifyHttpGetCall(
          mockHttpClient,
          'https://api.coinpaprika.com/v1/tickers/btc-bitcoin/historical?start=2025-01-01&interval=1d',
        );
      });
    });

    group('interval conversion tests', () {
      final emptyResponse = TestFixtures.createHistoricalOhlcResponse(
        ticks: [],
      );
      final testDate = DateTime(2024);

      test('converts 24h to 1d', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => emptyResponse);

        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: testDate,
          interval: TestConstants.interval24h,
        );

        VerificationHelpers.verifyIntervalConversion(
          mockHttpClient,
          TestConstants.interval24h,
          TestConstants.interval1d,
        );
      });

      test('preserves 1d as-is', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => emptyResponse);

        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: testDate,
        );

        VerificationHelpers.verifyIntervalConversion(
          mockHttpClient,
          TestConstants.interval1d,
          TestConstants.interval1d,
        );
      });

      test('preserves 1h as-is', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => emptyResponse);

        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: testDate,
          interval: TestConstants.interval1h,
        );

        VerificationHelpers.verifyIntervalConversion(
          mockHttpClient,
          TestConstants.interval1h,
          TestConstants.interval1h,
        );
      });

      test('preserves 5m as-is', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => emptyResponse);

        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: testDate,
          interval: TestConstants.interval5m,
        );

        VerificationHelpers.verifyIntervalConversion(
          mockHttpClient,
          TestConstants.interval5m,
          TestConstants.interval5m,
        );
      });

      test('preserves 15m as-is', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => emptyResponse);

        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: testDate,
          interval: TestConstants.interval15m,
        );

        VerificationHelpers.verifyIntervalConversion(
          mockHttpClient,
          TestConstants.interval15m,
          TestConstants.interval15m,
        );
      });

      test('preserves 30m as-is', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => emptyResponse);

        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: testDate,
          interval: TestConstants.interval30m,
        );

        VerificationHelpers.verifyIntervalConversion(
          mockHttpClient,
          TestConstants.interval30m,
          TestConstants.interval30m,
        );
      });

      test('passes through unknown intervals as-is', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => emptyResponse);

        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: testDate,
          interval: '7d',
        );

        VerificationHelpers.verifyIntervalConversion(
          mockHttpClient,
          '7d',
          '7d',
        );
      });
    });

    group('date formatting tests', () {
      final emptyResponse = TestFixtures.createHistoricalOhlcResponse(
        ticks: [],
      );

      test('formats single digit month correctly', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => emptyResponse);

        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: DateTime(2024, 3, 5),
        );

        VerificationHelpers.verifyDateFormatting(
          mockHttpClient,
          DateTime(2024, 3, 5),
          TestConstants.dateFormatWithSingleDigits,
        );
      });

      test('formats single digit day correctly', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => emptyResponse);

        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: DateTime(2024, 12, 7),
        );

        VerificationHelpers.verifyDateFormatting(
          mockHttpClient,
          DateTime(2024, 12, 7),
          '2024-12-07',
        );
      });

      test('ignores time portion of datetime', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => emptyResponse);

        await provider.fetchHistoricalOhlc(
          coinId: TestConstants.bitcoinCoinId,
          startDate: DateTime(2024, 6, 15, 14, 30, 45, 123, 456),
        );

        VerificationHelpers.verifyDateFormatting(
          mockHttpClient,
          DateTime(2024, 6, 15, 14, 30, 45, 123, 456),
          '2024-06-15',
        );
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

        final mockResponse = TestFixtures.createHistoricalOhlcResponse(
          timestamp: '2025-01-01T00:00:00Z',
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        final startDate = DateTime(2025, 8, 25);

        // Act - this should not throw an exception or cause 400 Bad Request
        final result = await provider.fetchHistoricalOhlc(
          coinId: 'aur-auroracoin',
          startDate: startDate,
          interval: TestConstants.interval24h, // This gets converted to '1d'
        );

        // Assert
        expect(result, isNotEmpty);

        VerificationHelpers.verifyHttpGetCallMultiple(
          mockHttpClient,
          expectedUrl: 'https://api.coinpaprika.com/v1/tickers/aur-auroracoin/historical?start=2025-08-25&interval=1d',
          expectedHost: TestConstants.baseUrl,
          expectedPath: '${TestConstants.apiVersion}/tickers/aur-auroracoin/historical',
          expectedQueryParamKeys: ['start', 'interval'],
          excludedParams: ['quote', 'limit', 'end'],
        );
      });

      test(
        'validates that quote parameter removal prevents USDT-related 400 errors',
        () async {
          // The original problematic URL included &quote=usdt which caused 400 errors
          final mockResponse = TestFixtures.createHistoricalOhlcResponse(
            ticks: [],
          );
          when(
            () => mockHttpClient.get(any()),
          ).thenAnswer((_) async => mockResponse);

          // This call previously would have included quote=usdt in the URL
          await provider.fetchHistoricalOhlc(
            coinId: TestConstants.bitcoinCoinId,
            startDate: DateTime(2025, 8, 25),
            quote: Stablecoin
                .usdt, // This parameter is now ignored for historical data
          );

          final capturedUri =
              verify(() => mockHttpClient.get(captureAny())).captured.single
                  as Uri;
          expect(capturedUri.queryParameters.containsKey('quote'), isFalse,
              reason: 'Quote parameter should not be included in historical OHLC requests');
          expect(capturedUri.toString(), isNot(contains('usdt')));
          expect(capturedUri.toString(), isNot(contains('quote')));
        },
      );
    });

    group('fetchCoinTicker quote currency mapping', () {
      test(
        'uses correct coinPaprikaId mapping for multiple quote currencies',
        () async {
          // Arrange
          final mockResponse = TestFixtures.createTickerResponse(
            quotes: TestFixtures.createMultipleQuotes(
              currencies: [
                TestConstants.usdQuote,
                TestConstants.usdtQuote,
                TestConstants.eurQuote,
              ],
              prices: [
                TestConstants.bitcoinPrice,
                TestConstants.bitcoinPrice + 10,
                42000.0,
              ],
            ),
          );

          when(
            () => mockHttpClient.get(any()),
          ).thenAnswer((_) async => mockResponse);

          // Act
          await provider.fetchCoinTicker(
            coinId: TestConstants.bitcoinCoinId,
            quotes: [FiatCurrency.usd, Stablecoin.usdt, FiatCurrency.eur],
          );

          // Assert
          VerificationHelpers.verifyTickerUrl(
            mockHttpClient,
            TestConstants.bitcoinCoinId,
            expectedQuotes: 'USD,USDT,EUR',
          );
        },
      );

      test('converts coinPaprikaId to uppercase for API request', () async {
        // Arrange
        final mockResponse = TestFixtures.createTickerResponse(
          quotes: TestFixtures.createMultipleQuotes(
            currencies: [TestConstants.btcQuote, TestConstants.ethQuote],
            prices: [1.0, 15.2],
          ),
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await provider.fetchCoinTicker(
          coinId: TestConstants.bitcoinCoinId,
          quotes: [Cryptocurrency.btc, Cryptocurrency.eth],
        );

        // Assert
        VerificationHelpers.verifyTickerUrl(
          mockHttpClient,
          TestConstants.bitcoinCoinId,
          expectedQuotes: 'BTC,ETH',
        );
      });

      test('handles single quote currency correctly', () async {
        // Arrange
        final mockResponse = TestFixtures.createTickerResponse(
          quotes: {
            TestConstants.gbpQuote: {
              'price': 38000.0,
              'volume_24h': TestConstants.highVolume,
              'volume_24h_change_24h': 0.0,
              'market_cap': TestConstants.bitcoinMarketCap,
              'market_cap_change_24h': 0.0,
              'percent_change_15m': 0.0,
              'percent_change_30m': 0.0,
              'percent_change_1h': 0.0,
              'percent_change_6h': 0.0,
              'percent_change_12h': 0.0,
              'percent_change_24h': TestConstants.positiveChange,
              'percent_change_7d': 0.0,
              'percent_change_30d': 0.0,
              'percent_change_1y': 0.0,
            },
          },
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await provider.fetchCoinTicker(
          coinId: TestConstants.bitcoinCoinId,
          quotes: [FiatCurrency.gbp],
        );

        // Assert
        VerificationHelpers.verifyTickerUrl(
          mockHttpClient,
          TestConstants.bitcoinCoinId,
          expectedQuotes: TestConstants.gbpQuote,
        );
      });
    });

    group('fetchCoinMarkets quote currency mapping', () {
      test('uses correct coinPaprikaId mapping for market data', () async {
        // Arrange
        final mockResponse = TestFixtures.createMarketsResponse();

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await provider.fetchCoinMarkets(
          coinId: TestConstants.bitcoinCoinId,
          quotes: [FiatCurrency.usd, Stablecoin.usdt],
        );

        // Assert
        VerificationHelpers.verifyMarketsUrl(
          mockHttpClient,
          TestConstants.bitcoinCoinId,
          expectedQuotes: 'USD,USDT',
        );
      });
    });

    group('coinPaprikaId extension usage', () {
      test('verifies QuoteCurrency.coinPaprikaId returns lowercase values', () {
        // Test various currency types to ensure the extension works correctly
        final expectedMappings = {
          FiatCurrency.usd: 'usd',
          FiatCurrency.eur: 'eur',
          FiatCurrency.gbp: 'gbp',
          Stablecoin.usdt: 'usdt',
          Stablecoin.usdc: 'usdc',
          Stablecoin.eurs: 'eurs',
          Cryptocurrency.btc: 'btc',
          Cryptocurrency.eth: 'eth',
        };

        expectedMappings.forEach((currency, expectedId) {
          expect(currency.coinPaprikaId, equals(expectedId));
        });
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
        MockHelpers.setupErrorResponses(mockHttpClient);

        // Act & Assert
        expect(
          () => provider.fetchHistoricalOhlc(
            coinId: TestConstants.bitcoinCoinId,
            startDate: TestData.pastDate,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when HTTP request fails for ticker', () async {
        // Arrange
        MockHelpers.setupErrorResponses(mockHttpClient);

        // Act & Assert
        expect(
          () => provider.fetchCoinTicker(
            coinId: TestConstants.bitcoinCoinId,
            quotes: [FiatCurrency.usd],
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
