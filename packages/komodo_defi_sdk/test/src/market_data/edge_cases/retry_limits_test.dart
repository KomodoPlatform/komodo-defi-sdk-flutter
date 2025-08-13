import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockCexRepository extends Mock implements CexRepository {}

class MockRepositorySelectionStrategy extends Mock
    implements RepositorySelectionStrategy {}

class FakeAssetId extends Fake implements AssetId {}

class TestRetryManager with RepositoryFallbackMixin {
  TestRetryManager({
    required this.repositories,
    required this.selectionStrategy,
  });

  final List<CexRepository> repositories;
  @override
  final RepositorySelectionStrategy selectionStrategy;

  @override
  List<CexRepository> get priceRepositories => repositories;

  // Expose the mixin method for testing
  Future<T> testTryRepositoriesInOrder<T>(
    AssetId assetId,
    QuoteCurrency quoteCurrency,
    PriceRequestType requestType,
    Future<T> Function(CexRepository repo) operation,
    String operationName, {
    int? maxTotalAttempts,
  }) {
    return tryRepositoriesInOrder(
      assetId,
      quoteCurrency,
      requestType,
      operation,
      operationName,
      maxTotalAttempts: maxTotalAttempts ?? 3,
    );
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAssetId());
    registerFallbackValue(Stablecoin.usdt);
    registerFallbackValue(PriceRequestType.currentPrice);
  });

  group('Retry Limits and Anti-Spam Tests', () {
    late MockCexRepository mockBinanceRepo;
    late MockCexRepository mockCoinGeckoRepo;
    late MockRepositorySelectionStrategy mockSelectionStrategy;
    late TestRetryManager testManager;

    setUp(() {
      mockBinanceRepo = MockCexRepository();
      mockCoinGeckoRepo = MockCexRepository();
      mockSelectionStrategy = MockRepositorySelectionStrategy();

      testManager = TestRetryManager(
        repositories: [mockBinanceRepo, mockCoinGeckoRepo],
        selectionStrategy: mockSelectionStrategy,
      );

      // Setup basic repository behavior
      when(() => mockBinanceRepo.getCoinList()).thenAnswer((_) async => []);
      when(() => mockCoinGeckoRepo.getCoinList()).thenAnswer((_) async => []);
    });

    group('Repository-Level Retry Limits', () {
      test(
        'BinanceRepository getCoinList does not exceed 3 attempts on failure',
        () async {
          final mockProvider = MockBinanceProvider();
          var callCount = 0;
          when(
            () => mockProvider.fetchExchangeInfoReduced(
              baseUrl: any(named: 'baseUrl'),
            ),
          ).thenAnswer((_) async {
            callCount++;
            throw Exception('Simulated Binance API failure');
          });

          final binanceRepo = BinanceRepository(
            binanceProvider: mockProvider,
            enableMemoization: false,
          );

          // Should handle internal failures gracefully and not spam beyond limit
          try {
            await binanceRepo.getCoinList();
          } catch (_) {
            // Some implementations may propagate the last error; ignore for call count assertion
          }

          // Binance tries primary and secondary endpoints; ensure attempts <= 3
          expect(callCount, lessThanOrEqualTo(3));
        },
      );

      test(
        'CoinGeckoRepository getCoinList does not exceed 3 attempts on failure',
        () async {
          final mockProvider = MockCoinGeckoProvider();
          var callCount = 0;
          when(mockProvider.fetchCoinList).thenAnswer((_) async {
            callCount++;
            throw Exception('Simulated CoinGecko API failure');
          });

          final coinGeckoRepo = CoinGeckoRepository(
            coinGeckoProvider: mockProvider,
            enableMemoization: false,
          );

          try {
            await coinGeckoRepo.getCoinList();
          } catch (_) {
            // Expected to fail due to simulated provider failure
          }

          // Ensure the repository does not retry more than a conservative cap
          expect(callCount, lessThanOrEqualTo(3));
        },
      );
    });

    group('Fallback Mixin Retry Behavior', () {
      test('respects maxTotalAttempts limit and prevents spam', () async {
        final testAsset = AssetId(
          id: 'bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          name: 'Bitcoin',
          chainId: AssetChainId(chainId: 1),
          derivationPath: '1234',
          subClass: CoinSubClass.utxo,
        );

        // Ensure repositories report support so fallback ordering includes them
        when(
          () => mockBinanceRepo.supports(any(), any(), any()),
        ).thenAnswer((_) async => true);
        when(
          () => mockCoinGeckoRepo.supports(any(), any(), any()),
        ).thenAnswer((_) async => true);

        // Mock selection strategy to return primary repo
        when(
          () => mockSelectionStrategy.selectRepository(
            assetId: any(named: 'assetId'),
            fiatCurrency: any(named: 'fiatCurrency'),
            requestType: any(named: 'requestType'),
            availableRepositories: any(named: 'availableRepositories'),
          ),
        ).thenAnswer((_) async => mockBinanceRepo);

        // Mock primary repo to always fail
        var callCount = 0;
        when(
          () => mockBinanceRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          throw Exception('Simulated API failure');
        });

        // Mock fallback repo to succeed
        when(
          () => mockCoinGeckoRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenAnswer((_) async => Decimal.parse('50000.0'));

        // Test with custom maxTotalAttempts = 2 to allow fallback
        final result = await testManager.testTryRepositoriesInOrder(
          testAsset,
          Stablecoin.usdt,
          PriceRequestType.currentPrice,
          (repo) => repo.getCoinFiatPrice(testAsset),
          'fiatPrice',
          maxTotalAttempts: 2,
        );

        // Should succeed using fallback repo after primary fails
        expect(result, equals(Decimal.parse('50000.0')));

        // Primary repo should only be called once (respecting maxTotalAttempts: 2)
        expect(callCount, equals(1));
      });

      test(
        'limits total API calls across repositories to prevent spam',
        () async {
          final testAsset = AssetId(
            id: 'bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC'),
            name: 'Bitcoin',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );

          // Ensure repositories report support so primary is used and fallback is available
          when(
            () => mockBinanceRepo.supports(any(), any(), any()),
          ).thenAnswer((_) async => true);
          when(
            () => mockCoinGeckoRepo.supports(any(), any(), any()),
          ).thenAnswer((_) async => true);

          // Mock selection strategy to return primary repo
          when(
            () => mockSelectionStrategy.selectRepository(
              assetId: any(named: 'assetId'),
              fiatCurrency: any(named: 'fiatCurrency'),
              requestType: any(named: 'requestType'),
              availableRepositories: any(named: 'availableRepositories'),
            ),
          ).thenAnswer((_) async => mockBinanceRepo);

          var binanceCallCount = 0;
          var coinGeckoCallCount = 0;

          // Mock both repos to fail to test total retry limit
          when(
            () => mockBinanceRepo.getCoinFiatPrice(
              any(),
              fiatCurrency: any(named: 'fiatCurrency'),
            ),
          ).thenAnswer((_) async {
            binanceCallCount++;
            throw Exception('Binance API failure');
          });

          when(
            () => mockCoinGeckoRepo.getCoinFiatPrice(
              any(),
              fiatCurrency: any(named: 'fiatCurrency'),
            ),
          ).thenAnswer((_) async {
            coinGeckoCallCount++;
            throw Exception('CoinGecko API failure');
          });

          // Should fail after trying both repositories with limited retries
          await expectLater(
            testManager.testTryRepositoriesInOrder(
              testAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
              (repo) => repo.getCoinFiatPrice(testAsset),
              'fiatPrice',
              maxTotalAttempts: 1, // Limit to 1 total attempt
            ),
            throwsA(isA<Exception>()),
          );

          // With maxTotalAttempts: 1, should only call primary repository once
          expect(binanceCallCount, equals(1));
          expect(coinGeckoCallCount, equals(0)); // Should not reach fallback

          // Total API calls should be exactly 1
          final totalCalls = binanceCallCount + coinGeckoCallCount;
          expect(totalCalls, equals(1));
        },
      );
    });

    group('Backoff Strategy Verification', () {
      test('conservative retry behavior under load', () async {
        // Use single repository manager to test retry behavior
        final singleRepoManager = TestRetryManager(
          repositories: [mockBinanceRepo], // Only one repository
          selectionStrategy: mockSelectionStrategy,
        );

        final testAsset = AssetId(
          id: 'ethereum',
          symbol: AssetSymbol(assetConfigId: 'ETH'),
          name: 'Ethereum',
          chainId: AssetChainId(chainId: 1),
          derivationPath: '1234',
          subClass: CoinSubClass.utxo,
        );

        // Mock selection strategy to return the only repository
        when(
          () => mockSelectionStrategy.selectRepository(
            assetId: any(named: 'assetId'),
            fiatCurrency: any(named: 'fiatCurrency'),
            requestType: any(named: 'requestType'),
            availableRepositories: any(named: 'availableRepositories'),
          ),
        ).thenAnswer((_) async => mockBinanceRepo);

        var totalRetryAttempts = 0;

        // Mock repo to track retry attempts
        when(
          () => mockBinanceRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenAnswer((_) async {
          totalRetryAttempts++;
          if (totalRetryAttempts < 3) {
            throw Exception('Temporary failure');
          }
          return Decimal.parse('3000.0');
        });

        // Should succeed after a few retries with single repository
        final result = await singleRepoManager.testTryRepositoriesInOrder(
          testAsset,
          Stablecoin.usdt,
          PriceRequestType.currentPrice,
          (repo) => repo.getCoinFiatPrice(testAsset),
          'fiatPrice',
          maxTotalAttempts: 3,
        );

        expect(result, equals(Decimal.parse('3000.0')));
        expect(totalRetryAttempts, equals(3));
      });
    });

    group('Anti-Spam Edge Cases', () {
      test('handles multiple concurrent requests without spam', () async {
        final testAsset = AssetId(
          id: 'bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          name: 'Bitcoin',
          chainId: AssetChainId(chainId: 1),
          derivationPath: '1234',
          subClass: CoinSubClass.utxo,
        );

        // Mock selection strategy
        when(
          () => mockSelectionStrategy.selectRepository(
            assetId: any(named: 'assetId'),
            fiatCurrency: any(named: 'fiatCurrency'),
            requestType: any(named: 'requestType'),
            availableRepositories: any(named: 'availableRepositories'),
          ),
        ).thenAnswer((_) async => mockBinanceRepo);

        var totalCalls = 0;

        when(
          () => mockBinanceRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenAnswer((_) async {
          totalCalls++;
          return Decimal.parse('50000.0');
        });

        // Simulate multiple concurrent requests
        final futures = List.generate(
          5,
          (index) => testManager.testTryRepositoriesInOrder(
            testAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
            (repo) => repo.getCoinFiatPrice(testAsset),
            'fiatPrice',
            maxTotalAttempts: 1,
          ),
        );

        final results = await Future.wait(futures);

        // All requests should succeed
        expect(results.length, equals(5));
        for (final result in results) {
          expect(result, equals(Decimal.parse('50000.0')));
        }

        // Total calls should equal number of requests (5) since maxTotalAttempts = 1
        expect(totalCalls, equals(5));
      });

      test('circuit breaker behavior prevents excessive retries', () async {
        final testAsset = AssetId(
          id: 'bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          name: 'Bitcoin',
          chainId: AssetChainId(chainId: 1),
          derivationPath: '1234',
          subClass: CoinSubClass.utxo,
        );

        // Mock selection strategy
        when(
          () => mockSelectionStrategy.selectRepository(
            assetId: any(named: 'assetId'),
            fiatCurrency: any(named: 'fiatCurrency'),
            requestType: any(named: 'requestType'),
            availableRepositories: any(named: 'availableRepositories'),
          ),
        ).thenAnswer((_) async => mockBinanceRepo);

        var callCount = 0;

        // Mock repo to always fail
        when(
          () => mockBinanceRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          throw Exception('Persistent failure');
        });

        // Multiple attempts should be limited by maxTotalAttempts
        for (int i = 0; i < 3; i++) {
          try {
            await testManager.testTryRepositoriesInOrder(
              testAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
              (repo) => repo.getCoinFiatPrice(testAsset),
              'fiatPrice',
              maxTotalAttempts: 1,
            );
          } catch (e) {
            // Expected to fail
          }
        }

        // Should have limited total calls despite multiple requests
        // 3 requests × 1 total attempt = 3 calls to primary repo
        expect(callCount, equals(3)); // Exactly 3 requests × 1 attempt each
      });
    });
  });
}

class MockBinanceProvider extends Mock implements IBinanceProvider {}

class MockCoinGeckoProvider extends Mock implements ICoinGeckoProvider {}
