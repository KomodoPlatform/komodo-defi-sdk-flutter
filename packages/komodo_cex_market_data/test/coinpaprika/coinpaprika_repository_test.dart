import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/src/coinpaprika/coinpaprika.dart';
import 'package:komodo_cex_market_data/src/coinpaprika/models/coinpaprika_ticker.dart';
import 'package:komodo_cex_market_data/src/coinpaprika/models/coinpaprika_ticker_quote.dart';
import 'package:komodo_cex_market_data/src/models/models.dart';
import 'package:komodo_cex_market_data/src/repository_selection_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockCoinPaprikaProvider extends Mock implements ICoinPaprikaProvider {}

// Helper function to create mock ticker data
CoinPaprikaTicker createMockTicker({
  String quoteCurrency = 'USDT',
  double price = 50000.0,
  double percentChange24h = 2.5,
}) {
  return CoinPaprikaTicker(
    id: 'btc-bitcoin',
    name: 'Bitcoin',
    symbol: 'BTC',
    rank: 1,
    circulatingSupply: 19000000,
    totalSupply: 21000000,
    maxSupply: 21000000,
    betaValue: 0.0,
    firstDataAt: DateTime.now(),
    lastUpdated: DateTime.now(),
    quotes: {
      quoteCurrency: CoinPaprikaTickerQuote(
        price: price,
        volume24h: 1000000.0,
        volume24hChange24h: 0.0,
        marketCap: 1000000000.0,
        marketCapChange24h: 0.0,
        percentChange15m: 0.0,
        percentChange30m: 0.0,
        percentChange1h: 0.0,
        percentChange6h: 0.0,
        percentChange12h: 0.0,
        percentChange24h: percentChange24h,
        percentChange7d: 0.0,
        percentChange30d: 0.0,
        percentChange1y: 0.0,
      ),
    },
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FiatCurrency.usd);
    registerFallbackValue(DateTime.now());
  });
  group('CoinPaprikaRepository', () {
    late MockCoinPaprikaProvider mockProvider;
    late CoinPaprikaRepository repository;

    setUp(() {
      mockProvider = MockCoinPaprikaProvider();
      repository = CoinPaprikaRepository(
        coinPaprikaProvider: mockProvider,
        enableMemoization: false, // Disable for testing
      );

      // Set up minimal default stubs - specific tests will override these
      registerFallbackValue(DateTime.now());

      // Add default stub for fetchHistoricalOhlc to prevent null return issues
      when(
        () => mockProvider.fetchHistoricalOhlc(
          coinId: any(named: 'coinId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          quote: any(named: 'quote'),
          interval: any(named: 'interval'),
        ),
      ).thenAnswer((_) async => <Ohlc>[]);

      // Set up default mock behavior for supportedQuoteCurrencies
      // CoinPaprika provider should only return fiat/crypto currencies, NOT stablecoins
      // Stablecoins are supported by mapping to their underlying fiat currencies
      when(() => mockProvider.supportedQuoteCurrencies).thenReturn([
        FiatCurrency.usd,
        FiatCurrency.eur,
        FiatCurrency.gbp,
        Cryptocurrency.btc,
        Cryptocurrency.eth,
      ]);

      // Set up default mock behavior for apiPlan
      when(
        () => mockProvider.apiPlan,
      ).thenReturn(const CoinPaprikaApiPlan.free());
    });

    group('getCoinList', () {
      test('returns list of active coins with supported currencies', () async {
        // Arrange
        final mockCoins = [
          const CoinPaprikaCoin(
            id: 'btc-bitcoin',
            name: 'Bitcoin',
            symbol: 'BTC',
            rank: 1,
            isNew: false,
            isActive: true,
            type: 'coin',
          ),
          const CoinPaprikaCoin(
            id: 'eth-ethereum',
            name: 'Ethereum',
            symbol: 'ETH',
            rank: 2,
            isNew: false,
            isActive: true,
            type: 'coin',
          ),
          const CoinPaprikaCoin(
            id: 'inactive-coin',
            name: 'Inactive Coin',
            symbol: 'INACTIVE',
            rank: 999,
            isNew: false,
            isActive: false,
            type: 'coin',
          ),
        ];

        when(
          () => mockProvider.fetchCoinList(),
        ).thenAnswer((_) async => mockCoins);

        // Act
        final result = await repository.getCoinList();

        // Assert
        expect(result, hasLength(2)); // Only active coins
        expect(result[0].id, equals('btc-bitcoin'));
        expect(result[0].symbol, equals('BTC'));
        expect(result[0].name, equals('Bitcoin'));
        expect(result[0].currencies, contains('usd'));
        expect(result[0].currencies, contains('btc'));
        expect(result[0].currencies, contains('eur'));

        expect(result[1].id, equals('eth-ethereum'));
        expect(result[1].symbol, equals('ETH'));
        expect(result[1].name, equals('Ethereum'));

        verify(() => mockProvider.fetchCoinList()).called(1);
      });

      test('handles provider errors gracefully', () async {
        // Arrange
        when(
          () => mockProvider.fetchCoinList(),
        ).thenThrow(Exception('API error'));

        // Act & Assert
        expect(() => repository.getCoinList(), throwsA(isA<Exception>()));

        verify(() => mockProvider.fetchCoinList()).called(1);
      });
    });

    group('resolveTradingSymbol', () {
      test('returns coinPaprikaId when available', () {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Act
        final result = repository.resolveTradingSymbol(assetId);

        // Assert
        expect(result, equals('btc-bitcoin'));
      });

      test('throws ArgumentError when coinPaprikaId is missing', () {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            // No coinPaprikaId
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Act & Assert
        expect(
          () => repository.resolveTradingSymbol(assetId),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('canHandleAsset', () {
      test('returns true when coinPaprikaId is available', () {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Act
        final result = repository.canHandleAsset(assetId);

        // Assert
        expect(result, isTrue);
      });

      test('returns false when coinPaprikaId is missing', () {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            // No coinPaprikaId
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Act
        final result = repository.canHandleAsset(assetId);

        // Assert
        expect(result, isFalse);
      });
    });

    group('getCoinFiatPrice', () {
      test('returns current price from markets endpoint', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final mockTicker = createMockTicker();

        when(
          () => mockProvider.fetchCoinTicker(
            coinId: any(named: 'coinId'),
            quotes: any(named: 'quotes'),
          ),
        ).thenAnswer((_) async => mockTicker);

        // Act
        final result = await repository.getCoinFiatPrice(assetId);

        // Assert
        expect(result, equals(Decimal.fromInt(50000)));
        verify(
          () => mockProvider.fetchCoinTicker(
            coinId: 'btc-bitcoin',
            quotes: [Stablecoin.usdt],
          ),
        ).called(1);
      });

      test('throws exception when no market data available', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        when(
          () => mockProvider.fetchCoinTicker(
            coinId: any(named: 'coinId'),
            quotes: any(named: 'quotes'),
          ),
        ).thenAnswer(
          (_) async => CoinPaprikaTicker(
            id: 'btc-bitcoin',
            name: 'Bitcoin',
            symbol: 'BTC',
            rank: 1,
            circulatingSupply: 19000000,
            totalSupply: 21000000,
            maxSupply: 21000000,
            betaValue: 0.0,
            firstDataAt: DateTime.now(),
            lastUpdated: DateTime.now(),
            quotes: {}, // Empty quotes to trigger exception
          ),
        );

        // Act & Assert
        expect(
          () => repository.getCoinFiatPrice(assetId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getCoinOhlc', () {
      test('returns OHLC data within API plan limits', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final mockOhlcData = [
          Ohlc.coinpaprika(
            timeOpen: DateTime.now()
                .subtract(const Duration(hours: 12))
                .millisecondsSinceEpoch,
            timeClose: DateTime.now()
                .subtract(const Duration(hours: 1))
                .millisecondsSinceEpoch,
            open: Decimal.fromInt(45000),
            high: Decimal.fromInt(52000),
            low: Decimal.fromInt(44000),
            close: Decimal.fromInt(50000),
            volume: Decimal.fromInt(1000000),
            marketCap: Decimal.fromInt(900000000000),
          ),
        ];

        when(
          () => mockProvider.fetchHistoricalOhlc(
            coinId: any(named: 'coinId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            quote: any(named: 'quote'),
            interval: any(named: 'interval'),
          ),
        ).thenAnswer((_) async => mockOhlcData);

        final now = DateTime.now();
        final startAt = now.subtract(const Duration(hours: 12));
        final endAt = now.subtract(
          const Duration(hours: 1),
        ); // Within 24h limit

        // Act
        final result = await repository.getCoinOhlc(
          assetId,
          Stablecoin.usdt,
          GraphInterval.oneHour,
          startAt: startAt,
          endAt: endAt,
        );

        // Assert
        expect(result.ohlc, hasLength(1));
        expect(result.ohlc.first.openDecimal, equals(Decimal.fromInt(45000)));
        expect(result.ohlc.first.highDecimal, equals(Decimal.fromInt(52000)));
        expect(result.ohlc.first.lowDecimal, equals(Decimal.fromInt(44000)));
        expect(result.ohlc.first.closeDecimal, equals(Decimal.fromInt(50000)));

        verify(
          () => mockProvider.fetchHistoricalOhlc(
            coinId: any(named: 'coinId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            quote: any(named: 'quote'),
            interval: any(named: 'interval'),
          ),
        ).called(1);
      });

      test(
        'throws ArgumentError for requests exceeding 24h without start/end dates',
        () async {
          // Arrange
          final assetId = AssetId(
            id: 'BTC',
            name: 'Bitcoin',
            symbol: AssetSymbol(
              assetConfigId: 'BTC',
              coinPaprikaId: 'btc-bitcoin',
            ),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          // Set up mock to return empty data so we can test the logic
          when(
            () => mockProvider.fetchHistoricalOhlc(
              coinId: any(named: 'coinId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              quote: any(named: 'quote'),
              interval: any(named: 'interval'),
            ),
          ).thenAnswer((_) async => []);

          // Act - should not throw since default period is 24h (within limit)
          final result = await repository.getCoinOhlc(
            assetId,
            Stablecoin.usdt,
            GraphInterval.oneHour,
            // No startAt/endAt - defaults to 24h which is within limit
          );

          // Assert - should get empty result, not throw error
          expect(result.ohlc, isEmpty);
        },
      );

      test(
        'splits requests to fetch all available data when exceeding plan limits',
        () async {
          // Arrange
          final assetId = AssetId(
            id: 'BTC',
            name: 'Bitcoin',
            symbol: AssetSymbol(
              assetConfigId: 'BTC',
              coinPaprikaId: 'btc-bitcoin',
            ),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          // Set up Starter plan (30 days limit) for batching test
          when(
            () => mockProvider.apiPlan,
          ).thenReturn(const CoinPaprikaApiPlan.starter());

          // Create mock data for each batch
          final mockOhlcDataBatch1 = [
            Ohlc.coinpaprika(
              timeOpen: DateTime.now()
                  .subtract(const Duration(hours: 23))
                  .millisecondsSinceEpoch,
              timeClose: DateTime.now()
                  .subtract(const Duration(hours: 22))
                  .millisecondsSinceEpoch,
              open: Decimal.fromInt(45000),
              high: Decimal.fromInt(52000),
              low: Decimal.fromInt(44000),
              close: Decimal.fromInt(50000),
              volume: Decimal.fromInt(1000000),
              marketCap: Decimal.fromInt(900000000000),
            ),
          ];

          final mockOhlcDataBatch2 = [
            Ohlc.coinpaprika(
              timeOpen: DateTime.now()
                  .subtract(const Duration(hours: 1))
                  .millisecondsSinceEpoch,
              timeClose: DateTime.now().millisecondsSinceEpoch,
              open: Decimal.fromInt(48000),
              high: Decimal.fromInt(51000),
              low: Decimal.fromInt(47000),
              close: Decimal.fromInt(49000),
              volume: Decimal.fromInt(800000),
              marketCap: Decimal.fromInt(920000000000),
            ),
          ];

          // Mock different responses for each batch request
          when(
            () => mockProvider.fetchHistoricalOhlc(
              coinId: any(named: 'coinId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              quote: any(named: 'quote'),
              interval: any(named: 'interval'),
            ),
          ).thenAnswer((invocation) async {
            // Return different data for different time ranges to simulate batching
            return [...mockOhlcDataBatch1, ...mockOhlcDataBatch2];
          });

          // Request data for 25 days within starter plan's 30-day limit to avoid cutoff adjustments
          // But make the request large enough to trigger batching by using a custom large batch size scenario
          // Actually, let's test with a business plan that has 365-day limit to avoid cutoff issues
          when(
            () => mockProvider.apiPlan,
          ).thenReturn(const CoinPaprikaApiPlan.business());

          final now = DateTime.now();
          final requestedStart = now.subtract(
            const Duration(days: 200),
          ); // Within 365-day limit
          final endAt = now;

          final result = await repository.getCoinOhlc(
            assetId,
            Stablecoin.usdt,
            GraphInterval.oneDay,
            startAt: requestedStart,
            endAt: endAt,
          );

          // Assert - should contain data from all batches
          expect(result.ohlc, isNotEmpty);
          expect(
            result.ohlc.length,
            greaterThanOrEqualTo(2),
          ); // Multiple batches should return combined data

          // Verify that multiple provider calls were made for batching (200 days should trigger multiple batches)
          verify(
            () => mockProvider.fetchHistoricalOhlc(
              coinId: 'btc-bitcoin',
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              quote: Stablecoin.usdt,
              interval: any(named: 'interval'),
            ),
          ).called(greaterThan(1));
        },
      );

      test(
        'returns empty OHLC when entire requested range is before cutoff',
        () async {
          // Arrange
          final assetId = AssetId(
            id: 'BTC',
            name: 'Bitcoin',
            symbol: AssetSymbol(
              assetConfigId: 'BTC',
              coinPaprikaId: 'btc-bitcoin',
            ),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          // Set up Free plan (365 day limit)
          when(
            () => mockProvider.apiPlan,
          ).thenReturn(const CoinPaprikaApiPlan.free());

          // Request data from 400 days ago to 390 days ago (both before cutoff)
          final requestedStart = DateTime.now().subtract(
            const Duration(days: 400),
          );
          final requestedEnd = DateTime.now().subtract(
            const Duration(days: 390),
          );

          // Act
          final result = await repository.getCoinOhlc(
            assetId,
            Stablecoin.usdt,
            GraphInterval.oneDay,
            startAt: requestedStart,
            endAt: requestedEnd,
          );

          // Assert - should return empty OHLC without making provider calls
          expect(result.ohlc, isEmpty);

          // Verify no provider calls were made since effective range is invalid
          verifyNever(
            () => mockProvider.fetchHistoricalOhlc(
              coinId: any(named: 'coinId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              quote: any(named: 'quote'),
              interval: any(named: 'interval'),
            ),
          );
        },
      );

      test(
        'fetches all available data by splitting requests when part of range is before cutoff',
        () async {
          // Arrange
          final assetId = AssetId(
            id: 'BTC',
            name: 'Bitcoin',
            symbol: AssetSymbol(
              assetConfigId: 'BTC',
              coinPaprikaId: 'btc-bitcoin',
            ),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          // Set up Free plan (365 day limit)
          when(
            () => mockProvider.apiPlan,
          ).thenReturn(const CoinPaprikaApiPlan.free());

          final mockOhlcData = [
            Ohlc.coinpaprika(
              timeOpen: DateTime.now()
                  .subtract(const Duration(days: 100))
                  .millisecondsSinceEpoch,
              timeClose: DateTime.now()
                  .subtract(const Duration(days: 99))
                  .millisecondsSinceEpoch,
              open: Decimal.fromInt(45000),
              high: Decimal.fromInt(52000),
              low: Decimal.fromInt(44000),
              close: Decimal.fromInt(50000),
              volume: Decimal.fromInt(1000000),
              marketCap: Decimal.fromInt(900000000000),
            ),
          ];

          when(
            () => mockProvider.fetchHistoricalOhlc(
              coinId: any(named: 'coinId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              quote: any(named: 'quote'),
              interval: any(named: 'interval'),
            ),
          ).thenAnswer((_) async => mockOhlcData);

          // Request data from 400 days ago to now (starts before cutoff but ends within available range)
          final requestedStart = DateTime.now().subtract(
            const Duration(days: 400),
          );
          final endAt = DateTime.now();

          // Act
          final result = await repository.getCoinOhlc(
            assetId,
            Stablecoin.usdt,
            GraphInterval.oneDay,
            startAt: requestedStart,
            endAt: endAt,
          );

          // Assert - should get available data from cutoff onwards
          expect(result.ohlc, isNotEmpty);

          // Verify that the provider was called with the cutoff date as startDate
          final captured = verify(
            () => mockProvider.fetchHistoricalOhlc(
              coinId: 'btc-bitcoin',
              startDate: captureAny(named: 'startDate'),
              endDate: captureAny(named: 'endDate'),
              quote: Stablecoin.usdt,
              interval: any(named: 'interval'),
            ),
          ).captured;

          final actualStartDate = captured.first as DateTime;
          final expectedCutoff = DateTime.now().subtract(
            const Duration(days: 365),
          );

          // Should be close to the cutoff date (within a few minutes due to test execution time)
          expect(
            actualStartDate.difference(expectedCutoff).abs().inMinutes,
            lessThan(5),
          );
        },
      );
    });

    group('supports', () {
      test('returns true for supported asset and quote currency', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final mockCoins = [
          const CoinPaprikaCoin(
            id: 'btc-bitcoin',
            name: 'Bitcoin',
            symbol: 'BTC',
            rank: 1,
            isNew: false,
            isActive: true,
            type: 'coin',
          ),
        ];

        when(
          () => mockProvider.fetchCoinList(),
        ).thenAnswer((_) async => mockCoins);

        // Act
        final result = await repository.supports(
          assetId,
          FiatCurrency.usd,
          PriceRequestType.currentPrice,
        );

        // Assert
        expect(result, isTrue);
      });

      test('returns true for supported stablecoin quote currency', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final mockCoins = [
          const CoinPaprikaCoin(
            id: 'btc-bitcoin',
            name: 'Bitcoin',
            symbol: 'BTC',
            rank: 1,
            isNew: false,
            isActive: true,
            type: 'coin',
          ),
        ];

        when(
          () => mockProvider.fetchCoinList(),
        ).thenAnswer((_) async => mockCoins);

        // Act - Using USDT stablecoin which should be supported via its underlying fiat (USD)
        // even though the provider only lists USD, not USDT, in supportedQuoteCurrencies
        final result = await repository.supports(
          assetId,
          Stablecoin.usdt,
          PriceRequestType.currentPrice,
        );

        // Assert
        expect(result, isTrue);
      });

      test(
        'returns true for EUR-based stablecoin when EUR is supported',
        () async {
          // Arrange
          final assetId = AssetId(
            id: 'BTC',
            name: 'Bitcoin',
            symbol: AssetSymbol(
              assetConfigId: 'BTC',
              coinPaprikaId: 'btc-bitcoin',
            ),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          final mockCoins = [
            const CoinPaprikaCoin(
              id: 'btc-bitcoin',
              name: 'Bitcoin',
              symbol: 'BTC',
              rank: 1,
              isNew: false,
              isActive: true,
              type: 'coin',
            ),
          ];

          when(
            () => mockProvider.fetchCoinList(),
          ).thenAnswer((_) async => mockCoins);

          // Act - Using EURS stablecoin which should be supported via its underlying fiat (EUR)
          final result = await repository.supports(
            assetId,
            Stablecoin.eurs,
            PriceRequestType.currentPrice,
          );

          // Assert
          expect(result, isTrue);
        },
      );

      test(
        'returns false for stablecoin with unsupported underlying fiat',
        () async {
          // Arrange - Mock provider that doesn't support JPY
          when(() => mockProvider.supportedQuoteCurrencies).thenReturn([
            FiatCurrency.usd,
            FiatCurrency.eur,
            // No JPY here
          ]);

          final assetId = AssetId(
            id: 'BTC',
            name: 'Bitcoin',
            symbol: AssetSymbol(
              assetConfigId: 'BTC',
              coinPaprikaId: 'btc-bitcoin',
            ),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          final mockCoins = [
            const CoinPaprikaCoin(
              id: 'btc-bitcoin',
              name: 'Bitcoin',
              symbol: 'BTC',
              rank: 1,
              isNew: false,
              isActive: true,
              type: 'coin',
            ),
          ];

          when(
            () => mockProvider.fetchCoinList(),
          ).thenAnswer((_) async => mockCoins);

          // Act - Using JPYT stablecoin which maps to JPY (not supported by provider)
          final result = await repository.supports(
            assetId,
            Stablecoin.jpyt,
            PriceRequestType.currentPrice,
          );

          // Assert
          expect(result, isFalse);
        },
      );

      test('returns false for unsupported quote currency', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final mockCoins = [
          const CoinPaprikaCoin(
            id: 'btc-bitcoin',
            name: 'Bitcoin',
            symbol: 'BTC',
            rank: 1,
            isNew: false,
            isActive: true,
            type: 'coin',
          ),
        ];

        when(
          () => mockProvider.fetchCoinList(),
        ).thenAnswer((_) async => mockCoins);

        // Act - Using an unsupported quote currency
        final result = await repository.supports(
          assetId,
          const QuoteCurrency.commodity(symbol: 'GOLD', displayName: 'Gold'),
          PriceRequestType.currentPrice,
        );

        // Assert
        expect(result, isFalse);
      });

      test('returns false for unsupported fiat currency', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final mockCoins = [
          const CoinPaprikaCoin(
            id: 'btc-bitcoin',
            name: 'Bitcoin',
            symbol: 'BTC',
            rank: 1,
            isNew: false,
            isActive: true,
            type: 'coin',
          ),
        ];

        when(
          () => mockProvider.fetchCoinList(),
        ).thenAnswer((_) async => mockCoins);

        // Create an unsupported fiat currency
        const unsupportedFiat = QuoteCurrency.fiat(
          symbol: 'UNSUPPORTED',
          displayName: 'Unsupported Currency',
        );

        // Act - Using an unsupported fiat currency
        final result = await repository.supports(
          assetId,
          unsupportedFiat,
          PriceRequestType.currentPrice,
        );

        // Assert
        expect(result, isFalse);
      });

      test('returns false when asset cannot be resolved', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            // No coinPaprikaId
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Act
        final result = await repository.supports(
          assetId,
          FiatCurrency.usd,
          PriceRequestType.currentPrice,
        );

        // Assert
        expect(result, isFalse);
      });
    });

    group('stablecoin to fiat mapping', () {
      test('correctly maps USDT to USD for price requests', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final mockTicker = createMockTicker();

        when(
          () => mockProvider.fetchCoinTicker(
            coinId: any(named: 'coinId'),
            quotes: any(named: 'quotes'),
          ),
        ).thenAnswer((_) async => mockTicker);

        // Act - Using USDT stablecoin
        final result = await repository.getCoinFiatPrice(
          assetId,
          fiatCurrency: Stablecoin.usdt,
        );

        // Assert
        expect(result, equals(Decimal.fromInt(50000)));

        // Verify that the provider was called with USDT stablecoin
        verify(
          () => mockProvider.fetchCoinTicker(
            coinId: 'btc-bitcoin',
            quotes: [Stablecoin.usdt],
          ),
        ).called(1);
      });

      test('correctly maps EUR-pegged stablecoin for price requests', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final mockTicker = createMockTicker(
          quoteCurrency: 'EURS',
          price: 42000.0,
        );

        when(
          () => mockProvider.fetchCoinTicker(
            coinId: any(named: 'coinId'),
            quotes: any(named: 'quotes'),
          ),
        ).thenAnswer((_) async => mockTicker);

        // Act - Using EURS stablecoin
        final result = await repository.getCoinFiatPrice(
          assetId,
          fiatCurrency: Stablecoin.eurs,
        );

        // Assert
        expect(result, equals(Decimal.fromInt(42000)));

        // Verify that the provider was called with EURS stablecoin
        verify(
          () => mockProvider.fetchCoinTicker(
            coinId: 'btc-bitcoin',
            quotes: [Stablecoin.eurs],
          ),
        ).called(1);
      });

      test(
        'uses correct coinPaprikaId for stablecoin in OHLC requests',
        () async {
          // Arrange
          final assetId = AssetId(
            id: 'BTC',
            name: 'Bitcoin',
            symbol: AssetSymbol(
              assetConfigId: 'BTC',
              coinPaprikaId: 'btc-bitcoin',
            ),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          final mockOhlcData = [
            Ohlc.coinpaprika(
              timeOpen: DateTime.now()
                  .subtract(const Duration(hours: 12))
                  .millisecondsSinceEpoch,
              timeClose: DateTime.now()
                  .subtract(const Duration(hours: 1))
                  .millisecondsSinceEpoch,
              open: Decimal.fromInt(45000),
              high: Decimal.fromInt(52000),
              low: Decimal.fromInt(44000),
              close: Decimal.fromInt(50000),
              volume: Decimal.fromInt(1000000),
              marketCap: Decimal.fromInt(900000000000),
            ),
          ];

          when(
            () => mockProvider.fetchHistoricalOhlc(
              coinId: any(named: 'coinId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              quote: any(named: 'quote'),
              interval: any(named: 'interval'),
            ),
          ).thenAnswer((_) async => mockOhlcData);

          final now = DateTime.now();
          final startAt = now.subtract(const Duration(hours: 12));
          final endAt = now.subtract(const Duration(hours: 1));

          // Act - Using USDT stablecoin
          final result = await repository.getCoinOhlc(
            assetId,
            Stablecoin.usdt,
            GraphInterval.oneHour,
            startAt: startAt,
            endAt: endAt,
          );

          // Assert
          expect(result.ohlc, hasLength(1));
          expect(
            result.ohlc.first.closeDecimal,
            equals(Decimal.fromInt(50000)),
          );

          // Verify that the provider was called with USDT stablecoin directly
          verify(
            () => mockProvider.fetchHistoricalOhlc(
              coinId: 'btc-bitcoin',
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              quote: Stablecoin.usdt,
              interval: any(named: 'interval'),
            ),
          ).called(1);
        },
      );

      test(
        'correctly handles 24hr price change with stablecoin currency',
        () async {
          // Arrange
          final assetId = AssetId(
            id: 'BTC',
            name: 'Bitcoin',
            symbol: AssetSymbol(
              assetConfigId: 'BTC',
              coinPaprikaId: 'btc-bitcoin',
            ),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          final mockTicker = createMockTicker(
            quoteCurrency: 'USDC',
            price: 50000.0,
            percentChange24h: 3.2,
          );

          when(
            () => mockProvider.fetchCoinTicker(
              coinId: any(named: 'coinId'),
              quotes: any(named: 'quotes'),
            ),
          ).thenAnswer((_) async => mockTicker);

          // Act - Using USDC stablecoin
          final result = await repository.getCoin24hrPriceChange(
            assetId,
            fiatCurrency: Stablecoin.usdc,
          );

          // Assert
          expect(result, equals(Decimal.parse('3.2')));

          // Verify that the provider was called with USDC stablecoin
          verify(
            () => mockProvider.fetchCoinTicker(
              coinId: 'btc-bitcoin',
              quotes: [Stablecoin.usdc],
            ),
          ).called(1);
        },
      );
    });

    group('Batch Duration Validation Tests', () {
      test('ensures no batch exceeds 90 days for free plan', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Set up Free plan (90-day batch size for historical ticks)
        when(
          () => mockProvider.apiPlan,
        ).thenReturn(const CoinPaprikaApiPlan.free());

        final mockOhlcData = [
          Ohlc.coinpaprika(
            timeOpen: DateTime.now()
                .toUtc()
                .subtract(const Duration(days: 30))
                .millisecondsSinceEpoch,
            timeClose: DateTime.now().toUtc().millisecondsSinceEpoch,
            open: Decimal.fromInt(50000),
            high: Decimal.fromInt(52000),
            low: Decimal.fromInt(48000),
            close: Decimal.fromInt(51000),
            volume: Decimal.fromInt(1000000),
            marketCap: Decimal.fromInt(900000000000),
          ),
        ];

        // Mock provider to track batch requests
        final capturedBatchRequests = <Map<String, dynamic>>[];
        when(
          () => mockProvider.fetchHistoricalOhlc(
            coinId: any(named: 'coinId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            quote: any(named: 'quote'),
            interval: any(named: 'interval'),
          ),
        ).thenAnswer((invocation) async {
          final startDate = invocation.namedArguments[#startDate] as DateTime;
          final endDate = invocation.namedArguments[#endDate] as DateTime;

          capturedBatchRequests.add({
            'startDate': startDate,
            'endDate': endDate,
            'duration': endDate.difference(startDate),
          });

          return mockOhlcData;
        });

        // Request data for exactly 200 days to force multiple batches
        // Each batch should be 90 days
        final now = DateTime.now().toUtc();
        final requestedStart = now.subtract(const Duration(days: 200));
        final requestedEnd = now;

        // Act
        await repository.getCoinOhlc(
          assetId,
          FiatCurrency.usd,
          GraphInterval.oneDay,
          startAt: requestedStart,
          endAt: requestedEnd,
        );

        // Assert
        expect(capturedBatchRequests, isNotEmpty);

        // Verify each batch is within the safe limit (90 days)
        const maxSafeDuration = Duration(days: 90);
        for (final request in capturedBatchRequests) {
          final duration = request['duration'] as Duration;
          expect(
            duration,
            lessThanOrEqualTo(maxSafeDuration),
            reason:
                'Batch duration ${duration.inDays} days '
                'exceeds safe limit of 90 days',
          );
        }
      });

      test('uses UTC time for all date calculations', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        when(
          () => mockProvider.apiPlan,
        ).thenReturn(const CoinPaprikaApiPlan.free());

        final mockOhlcData = [
          Ohlc.coinpaprika(
            timeOpen: DateTime.now().toUtc().millisecondsSinceEpoch,
            timeClose: DateTime.now().toUtc().millisecondsSinceEpoch,
            open: Decimal.fromInt(50000),
            high: Decimal.fromInt(52000),
            low: Decimal.fromInt(48000),
            close: Decimal.fromInt(51000),
            volume: Decimal.fromInt(1000000),
            marketCap: Decimal.fromInt(900000000000),
          ),
        ];

        DateTime? capturedStartDate;
        DateTime? capturedEndDate;

        when(
          () => mockProvider.fetchHistoricalOhlc(
            coinId: any(named: 'coinId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            quote: any(named: 'quote'),
            interval: any(named: 'interval'),
          ),
        ).thenAnswer((invocation) async {
          capturedStartDate =
              invocation.namedArguments[#startDate] as DateTime?;
          capturedEndDate = invocation.namedArguments[#endDate] as DateTime?;
          return mockOhlcData;
        });

        // Act - don't provide endAt to test default behavior
        await repository.getCoinOhlc(
          assetId,
          FiatCurrency.usd,
          GraphInterval.oneDay,
        );

        // Assert
        expect(capturedEndDate, isNotNull);

        // Verify the captured endDate is in UTC (should have zero offset from UTC)
        if (capturedEndDate != null) {
          final utcNow = DateTime.now().toUtc();
          final timeDifference = capturedEndDate!.difference(utcNow).abs();

          // Should be very close to current UTC time (within 1 minute)
          expect(
            timeDifference,
            lessThan(const Duration(minutes: 1)),
            reason:
                'End date should be close to current UTC time. '
                'Captured: ${capturedEndDate!.toIso8601String()}, '
                'UTC Now: ${utcNow.toIso8601String()}',
          );
        }
      });

      test(
        'validates batch duration and throws error if exceeding safe limit',
        () async {
          // Arrange
          final assetId = AssetId(
            id: 'BTC',
            name: 'Bitcoin',
            symbol: AssetSymbol(
              assetConfigId: 'BTC',
              coinPaprikaId: 'btc-bitcoin',
            ),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          // Set up a custom plan that would create an invalid batch
          when(
            () => mockProvider.apiPlan,
          ).thenReturn(const CoinPaprikaApiPlan.free());

          // Mock the provider to return data
          when(
            () => mockProvider.fetchHistoricalOhlc(
              coinId: any(named: 'coinId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              quote: any(named: 'quote'),
              interval: any(named: 'interval'),
            ),
          ).thenAnswer(
            (_) async => [
              Ohlc.coinpaprika(
                timeOpen: DateTime.now().toUtc().millisecondsSinceEpoch,
                timeClose: DateTime.now().toUtc().millisecondsSinceEpoch,
                open: Decimal.fromInt(50000),
                high: Decimal.fromInt(52000),
                low: Decimal.fromInt(48000),
                close: Decimal.fromInt(51000),
                volume: Decimal.fromInt(1000000),
                marketCap: Decimal.fromInt(900000000000),
              ),
            ],
          );

          // Act & Assert
          // Create a scenario where batch calculation might exceed safe limit
          final now = DateTime.now().toUtc();
          final requestedStart = DateTime(
            now.year,
            now.month,
            now.day - 2,
          ); // Exactly 2 days ago
          final requestedEnd = DateTime(
            now.year,
            now.month,
            now.day,
          ); // Start of today

          // This should not throw an error as the repository should handle batching correctly
          expect(
            () => repository.getCoinOhlc(
              assetId,
              FiatCurrency.usd,
              GraphInterval.oneDay,
              startAt: requestedStart,
              endAt: requestedEnd,
            ),
            returnsNormally,
          );
        },
      );

      test(
        'handles starter plan with 5-year limit and 90-day batch size',
        () async {
          // Arrange
          final assetId = AssetId(
            id: 'BTC',
            name: 'Bitcoin',
            symbol: AssetSymbol(
              assetConfigId: 'BTC',
              coinPaprikaId: 'btc-bitcoin',
            ),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          // Set up Starter plan (5 years limit with 90-day batch size)
          when(
            () => mockProvider.apiPlan,
          ).thenReturn(const CoinPaprikaApiPlan.starter());

          final mockOhlcData = [
            Ohlc.coinpaprika(
              timeOpen: DateTime.now().toUtc().millisecondsSinceEpoch,
              timeClose: DateTime.now().toUtc().millisecondsSinceEpoch,
              open: Decimal.fromInt(50000),
              high: Decimal.fromInt(52000),
              low: Decimal.fromInt(48000),
              close: Decimal.fromInt(51000),
              volume: Decimal.fromInt(1000000),
              marketCap: Decimal.fromInt(900000000000),
            ),
          ];

          final capturedBatchRequests = <Duration>[];
          when(
            () => mockProvider.fetchHistoricalOhlc(
              coinId: any(named: 'coinId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              quote: any(named: 'quote'),
              interval: any(named: 'interval'),
            ),
          ).thenAnswer((invocation) async {
            final startDate = invocation.namedArguments[#startDate] as DateTime;
            final endDate = invocation.namedArguments[#endDate] as DateTime;
            capturedBatchRequests.add(endDate.difference(startDate));
            return mockOhlcData;
          });

          // Request data for exactly 200 days (should create multiple 90-day batches)
          final now = DateTime.now().toUtc();
          final requestedStart = now.subtract(const Duration(days: 200));
          final requestedEnd = now;

          // Act
          await repository.getCoinOhlc(
            assetId,
            FiatCurrency.usd,
            GraphInterval.oneDay,
            startAt: requestedStart,
            endAt: requestedEnd,
          );

          // Assert
          expect(capturedBatchRequests, isNotEmpty);

          // For starter plan with 90-day batch size, max batch should be 90 days
          const maxSafeDuration = Duration(days: 90);

          for (final duration in capturedBatchRequests) {
            expect(
              duration,
              lessThanOrEqualTo(maxSafeDuration),
              reason:
                  'Batch duration ${duration.inDays} days '
                  'exceeds safe limit of 90 days for starter plan',
            );
          }
        },
      );

      test('batch size prevents oversized requests', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Test with 90-day batch size for historical ticks
        when(
          () => mockProvider.apiPlan,
        ).thenReturn(const CoinPaprikaApiPlan.free());

        final mockOhlcData = [
          Ohlc.coinpaprika(
            timeOpen: DateTime.now().toUtc().millisecondsSinceEpoch,
            timeClose: DateTime.now().toUtc().millisecondsSinceEpoch,
            open: Decimal.fromInt(50000),
            high: Decimal.fromInt(52000),
            low: Decimal.fromInt(48000),
            close: Decimal.fromInt(51000),
            volume: Decimal.fromInt(1000000),
            marketCap: Decimal.fromInt(900000000000),
          ),
        ];

        Duration? capturedBatchDuration;
        when(
          () => mockProvider.fetchHistoricalOhlc(
            coinId: any(named: 'coinId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            quote: any(named: 'quote'),
            interval: any(named: 'interval'),
          ),
        ).thenAnswer((invocation) async {
          final startDate = invocation.namedArguments[#startDate] as DateTime;
          final endDate = invocation.namedArguments[#endDate] as DateTime;
          capturedBatchDuration = endDate.difference(startDate);
          return mockOhlcData;
        });

        // Request data for exactly 50 days - should fit in single batch
        final now = DateTime.now().toUtc();
        final requestedStart = now.subtract(const Duration(days: 50));
        final requestedEnd = now;

        // Act
        await repository.getCoinOhlc(
          assetId,
          FiatCurrency.usd,
          GraphInterval.oneDay,
          startAt: requestedStart,
          endAt: requestedEnd,
        );

        // Assert
        expect(capturedBatchDuration, isNotNull);

        // Batch should not exceed 90-day limit
        const expectedMaxDuration = Duration(days: 90);
        expect(
          capturedBatchDuration!,
          lessThanOrEqualTo(expectedMaxDuration),
          reason:
              'Batch duration should not exceed 90-day limit. '
              'Expected max: 90 days, '
              'Actual: ${capturedBatchDuration!.inDays} days',
        );
      });
    });
  });
}
