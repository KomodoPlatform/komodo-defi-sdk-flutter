import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock classes for testing
class MockCexRepository extends Mock implements CexRepository {}

class MockPrimaryRepository extends Mock implements CexRepository {}

class MockFallbackRepository extends Mock implements CexRepository {}

class MockRepositorySelectionStrategy extends Mock
    implements RepositorySelectionStrategy {}

// Test class that mixes in the functionality
class TestRepositoryFallbackManager with RepositoryFallbackMixin {
  TestRepositoryFallbackManager({
    required this.mockRepositories,
    required this.mockSelectionStrategy,
  });

  final List<CexRepository> mockRepositories;
  final RepositorySelectionStrategy mockSelectionStrategy;

  @override
  List<CexRepository> get priceRepositories => mockRepositories;

  @override
  RepositorySelectionStrategy get selectionStrategy => mockSelectionStrategy;
}

void main() {
  group('RepositoryFallbackMixin', () {
    late TestRepositoryFallbackManager manager;
    late MockPrimaryRepository primaryRepo;
    late MockFallbackRepository fallbackRepo;
    late MockRepositorySelectionStrategy mockStrategy;
    late AssetId testAsset;

    setUp(() {
      primaryRepo = MockPrimaryRepository();
      fallbackRepo = MockFallbackRepository();
      mockStrategy = MockRepositorySelectionStrategy();
      testAsset = AssetId(
        id: 'BTC',
        name: 'Bitcoin',
        symbol: AssetSymbol(assetConfigId: 'BTC'),
        chainId: AssetChainId(chainId: 0),
        derivationPath: null,
        subClass: CoinSubClass.utxo,
      );

      manager = TestRepositoryFallbackManager(
        mockRepositories: [primaryRepo, fallbackRepo],
        mockSelectionStrategy: mockStrategy,
      );

      // Register fallbacks for mocktail
      registerFallbackValue(testAsset);
      registerFallbackValue(Stablecoin.usdt);
      registerFallbackValue(PriceRequestType.currentPrice);
      registerFallbackValue(<CexRepository>[]);

      // Setup default supports behavior for all repositories
      // (assuming they support all assets unless explicitly set otherwise)
      when(
        () => primaryRepo.supports(any(), any(), any()),
      ).thenAnswer((_) async => true);

      when(
        () => fallbackRepo.supports(any(), any(), any()),
      ).thenAnswer((_) async => true);
    });

    group('Repository Health Tracking', () {
      test('repository starts as healthy', () {
        expect(manager.isRepositoryHealthyForTest(primaryRepo), isTrue);
      });

      test('repository becomes unhealthy after max failures', () {
        // Record failures up to max count
        for (int i = 0; i < 3; i++) {
          manager.recordRepositoryFailureForTest(primaryRepo);
        }

        expect(manager.isRepositoryHealthyForTest(primaryRepo), isFalse);
      });

      test('repository health recovers after success recording', () {
        // Make repository unhealthy
        for (int i = 0; i < 3; i++) {
          manager.recordRepositoryFailureForTest(primaryRepo);
        }
        expect(manager.isRepositoryHealthyForTest(primaryRepo), isFalse);

        // Record success should reset health
        manager.recordRepositorySuccessForTest(primaryRepo);
        expect(manager.isRepositoryHealthyForTest(primaryRepo), isTrue);
      });

      test('repository stays healthy with failures below threshold', () {
        // Record failures below max count
        for (int i = 0; i < 2; i++) {
          manager.recordRepositoryFailureForTest(primaryRepo);
        }

        expect(manager.isRepositoryHealthyForTest(primaryRepo), isTrue);
      });
    });

    group('Repository Fallback Logic', () {
      test('uses primary repository when healthy', () async {
        // Setup: Primary repo returns successfully
        when(
          () => mockStrategy.selectRepository(
            assetId: any(named: 'assetId'),
            fiatCurrency: any(named: 'fiatCurrency'),
            requestType: any(named: 'requestType'),
            availableRepositories: any(named: 'availableRepositories'),
          ),
        ).thenAnswer((_) async => primaryRepo);

        when(
          () => primaryRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenAnswer((_) async => Decimal.parse('50000.0'));

        // Test
        final result = await manager.tryRepositoriesInOrder(
          testAsset,
          Stablecoin.usdt,
          PriceRequestType.currentPrice,
          (repo) => repo.getCoinFiatPrice(testAsset),
          'test',
        );

        // Verify
        expect(result, equals(Decimal.parse('50000.0')));
        verify(() => primaryRepo.getCoinFiatPrice(testAsset)).called(1);
        verifyNever(
          () => fallbackRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        );
      });

      test('falls back to secondary repository when primary fails', () async {
        // Setup: Primary repo is selected but fails, fallback succeeds
        when(
          () => mockStrategy.selectRepository(
            assetId: any(named: 'assetId'),
            fiatCurrency: any(named: 'fiatCurrency'),
            requestType: any(named: 'requestType'),
            availableRepositories: any(named: 'availableRepositories'),
          ),
        ).thenAnswer((_) async => primaryRepo);

        when(
          () => primaryRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenThrow(Exception('Primary repo failed'));

        when(
          () => fallbackRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenAnswer((_) async => Decimal.parse('49000.0'));

        // Test
        final result = await manager.tryRepositoriesInOrder(
          testAsset,
          Stablecoin.usdt,
          PriceRequestType.currentPrice,
          (repo) => repo.getCoinFiatPrice(testAsset),
          'test',
        );

        // Verify
        expect(result, equals(Decimal.parse('49000.0')));
        verify(
          () => primaryRepo.getCoinFiatPrice(testAsset),
        ).called(1); // Called once, then fallback is tried
        verify(() => fallbackRepo.getCoinFiatPrice(testAsset)).called(1);
      });

      test('throws when all repositories fail', () async {
        // Setup: All repos fail
        when(
          () => mockStrategy.selectRepository(
            assetId: any(named: 'assetId'),
            fiatCurrency: any(named: 'fiatCurrency'),
            requestType: any(named: 'requestType'),
            availableRepositories: any(named: 'availableRepositories'),
          ),
        ).thenAnswer((_) async => primaryRepo);

        when(
          () => primaryRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenThrow(Exception('Primary failed'));

        when(
          () => fallbackRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenThrow(Exception('Fallback failed'));

        // Test & Verify
        expect(
          () => manager.tryRepositoriesInOrder(
            testAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
            (repo) => repo.getCoinFiatPrice(testAsset),
            'test',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('tryRepositoriesInOrderMaybe returns null when all fail', () async {
        // Setup: All repos fail
        when(
          () => mockStrategy.selectRepository(
            assetId: any(named: 'assetId'),
            fiatCurrency: any(named: 'fiatCurrency'),
            requestType: any(named: 'requestType'),
            availableRepositories: any(named: 'availableRepositories'),
          ),
        ).thenAnswer((_) async => primaryRepo);

        when(
          () => primaryRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenThrow(Exception('Primary failed'));

        when(
          () => fallbackRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenThrow(Exception('Fallback failed'));

        // Test
        final result = await manager.tryRepositoriesInOrderMaybe(
          testAsset,
          Stablecoin.usdt,
          PriceRequestType.currentPrice,
          (repo) => repo.getCoinFiatPrice(testAsset),
          'test',
        );

        // Verify
        expect(result, isNull);
      });
    });

    group('Repository Ordering', () {
      test('prefers healthy repositories over unhealthy ones', () async {
        // Make primary repo unhealthy
        for (int i = 0; i < 3; i++) {
          manager.recordRepositoryFailureForTest(primaryRepo);
        }

        // Verify primary repo is unhealthy and fallback is healthy
        expect(manager.isRepositoryHealthyForTest(primaryRepo), isFalse);
        expect(manager.isRepositoryHealthyForTest(fallbackRepo), isTrue);

        // Setup: Strategy should return fallback repo when called with healthy repos
        when(
          () => mockStrategy.selectRepository(
            assetId: any(named: 'assetId'),
            fiatCurrency: any(named: 'fiatCurrency'),
            requestType: any(named: 'requestType'),
            availableRepositories: any(named: 'availableRepositories'),
          ),
        ).thenAnswer((_) async => fallbackRepo);

        when(
          () => fallbackRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenAnswer((_) async => Decimal.parse('48000.0'));

        // Test
        final result = await manager.tryRepositoriesInOrder(
          testAsset,
          Stablecoin.usdt,
          PriceRequestType.currentPrice,
          (repo) => repo.getCoinFiatPrice(testAsset),
          'test',
        );

        // Verify
        expect(result, equals(Decimal.parse('48000.0')));

        // The fallback repo should be called since it was selected and succeeded
        verify(() => fallbackRepo.getCoinFiatPrice(testAsset)).called(1);
      });

      test(
        'uses all repositories as fallback when no healthy ones available',
        () async {
          // Make all repos unhealthy
          for (int i = 0; i < 3; i++) {
            manager.recordRepositoryFailureForTest(primaryRepo);
            manager.recordRepositoryFailureForTest(fallbackRepo);
          }

          // Setup: Strategy should be called with all repos since none are healthy
          when(
            () => mockStrategy.selectRepository(
              assetId: any(named: 'assetId'),
              fiatCurrency: any(named: 'fiatCurrency'),
              requestType: any(named: 'requestType'),
              availableRepositories: [primaryRepo, fallbackRepo],
            ),
          ).thenAnswer((_) async => primaryRepo);

          when(
            () => primaryRepo.getCoinFiatPrice(
              any(),
              fiatCurrency: any(named: 'fiatCurrency'),
            ),
          ).thenAnswer((_) async => Decimal.parse('47000.0'));

          // Test
          final result = await manager.tryRepositoriesInOrder(
            testAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
            (repo) => repo.getCoinFiatPrice(testAsset),
            'test',
          );

          // Verify
          expect(result, equals(Decimal.parse('47000.0')));
        },
      );

      test('throws when no repositories support the request', () async {
        // Create a manager with no repositories
        final emptyManager = TestRepositoryFallbackManager(
          mockRepositories: [],
          mockSelectionStrategy: mockStrategy,
        );

        // Test & Verify
        expect(
          () => emptyManager.tryRepositoriesInOrder(
            testAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
            (repo) => repo.getCoinFiatPrice(testAsset),
            'test',
          ),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Health Data Management', () {
      test('clearRepositoryHealthData resets all health tracking', () {
        // Make repositories unhealthy
        manager
          ..recordRepositoryFailureForTest(primaryRepo)
          ..recordRepositoryFailureForTest(fallbackRepo);

        // Verify they are recorded as having failures
        expect(
          manager.isRepositoryHealthyForTest(primaryRepo),
          isTrue,
        ); // Still healthy, only 1 failure

        // Add more failures to make them unhealthy
        for (int i = 0; i < 2; i++) {
          manager
            ..recordRepositoryFailureForTest(primaryRepo)
            ..recordRepositoryFailureForTest(fallbackRepo);
        }
        expect(manager.isRepositoryHealthyForTest(primaryRepo), isFalse);
        expect(manager.isRepositoryHealthyForTest(fallbackRepo), isFalse);

        // Clear health data
        manager.clearRepositoryHealthData();

        // Verify both are healthy again
        expect(manager.isRepositoryHealthyForTest(primaryRepo), isTrue);
        expect(manager.isRepositoryHealthyForTest(fallbackRepo), isTrue);
      });
    });

    group('Custom Operation Support', () {
      test(
        'supports different operation types with custom functions',
        () async {
          // Setup for price change operation
          when(
            () => mockStrategy.selectRepository(
              assetId: any(named: 'assetId'),
              fiatCurrency: any(named: 'fiatCurrency'),
              requestType: PriceRequestType.priceChange,
              availableRepositories: any(named: 'availableRepositories'),
            ),
          ).thenAnswer((_) async => primaryRepo);

          when(
            () => primaryRepo.getCoin24hrPriceChange(
              any(),
              fiatCurrency: any(named: 'fiatCurrency'),
            ),
          ).thenAnswer((_) async => Decimal.parse('0.05'));

          // Test custom operation
          final result = await manager.tryRepositoriesInOrder(
            testAsset,
            Stablecoin.usdt,
            PriceRequestType.priceChange,
            (repo) => repo.getCoin24hrPriceChange(testAsset),
            'priceChange24h',
          );

          // Verify
          expect(result, equals(Decimal.parse('0.05')));
          verify(() => primaryRepo.getCoin24hrPriceChange(testAsset)).called(1);
        },
      );

      test('respects maxTotalAttempts parameter', () async {
        // Setup: Primary repo always fails
        when(
          () => mockStrategy.selectRepository(
            assetId: any(named: 'assetId'),
            fiatCurrency: any(named: 'fiatCurrency'),
            requestType: any(named: 'requestType'),
            availableRepositories: any(named: 'availableRepositories'),
          ),
        ).thenAnswer((_) async => primaryRepo);

        when(
          () => primaryRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenThrow(Exception('Always fails'));

        when(
          () => fallbackRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenAnswer((_) async => Decimal.parse('50000.0'));

        // Test with maxTotalAttempts = 1 should fail since primary fails
        expect(
          () => manager.tryRepositoriesInOrder(
            testAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
            (repo) => repo.getCoinFiatPrice(testAsset),
            'test',
            maxTotalAttempts: 1,
          ),
          throwsA(isA<Exception>()),
        );

        // Test with maxTotalAttempts = 2 should succeed with fallback
        final result = await manager.tryRepositoriesInOrder(
          testAsset,
          Stablecoin.usdt,
          PriceRequestType.currentPrice,
          (repo) => repo.getCoinFiatPrice(testAsset),
          'test',
          maxTotalAttempts: 2,
        );

        // Verify fallback was used
        expect(result, equals(Decimal.parse('50000.0')));
        verify(
          () => primaryRepo.getCoinFiatPrice(testAsset),
        ).called(2); // Called once for each test
        verify(
          () => fallbackRepo.getCoinFiatPrice(testAsset),
        ).called(1); // Called once in second test
      });
    });
  });
}
