import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockCexRepository extends Mock implements CexRepository {}

class MockRepositorySelectionStrategy extends Mock
    implements RepositorySelectionStrategy {}

class FakeAssetId extends Fake implements AssetId {}

/// Test helper class that exposes the mixin methods for testing
class TestSupportFilteringManager with RepositoryFallbackMixin {
  TestSupportFilteringManager({
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

  group('Repository Supports Filtering Tests', () {
    late MockCexRepository mockBinanceRepo;
    late MockCexRepository mockCoinGeckoRepo;
    late MockCexRepository mockKomodoRepo;
    late MockRepositorySelectionStrategy mockSelectionStrategy;
    late TestSupportFilteringManager testManager;
    late AssetId supportedAsset;
    late AssetId unsupportedAsset;

    setUp(() {
      mockBinanceRepo = MockCexRepository();
      mockCoinGeckoRepo = MockCexRepository();
      mockKomodoRepo = MockCexRepository();
      mockSelectionStrategy = MockRepositorySelectionStrategy();

      testManager = TestSupportFilteringManager(
        repositories: [mockBinanceRepo, mockCoinGeckoRepo, mockKomodoRepo],
        selectionStrategy: mockSelectionStrategy,
      );

      // Create test assets
      supportedAsset = AssetId(
        id: 'bitcoin',
        symbol: AssetSymbol(assetConfigId: 'BTC'),
        name: 'Bitcoin',
        chainId: AssetChainId(chainId: 1),
        derivationPath: '1234',
        subClass: CoinSubClass.utxo,
      );

      unsupportedAsset = AssetId(
        id: 'test-doc',
        symbol: AssetSymbol(assetConfigId: 'DOC'),
        name: 'DOC',
        chainId: AssetChainId(chainId: 1),
        derivationPath: '1234',
        subClass: CoinSubClass.utxo,
      );
    });

    group('Repository Support Filtering Edge Cases', () {
      test('should only attempt repositories that support the asset', () async {
        // Setup: Binance supports BTC, CoinGecko does not, Komodo does
        when(
          () => mockBinanceRepo.supports(
            supportedAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
          ),
        ).thenAnswer((_) async => true);

        when(
          () => mockCoinGeckoRepo.supports(
            supportedAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
          ),
        ).thenAnswer((_) async => false);

        when(
          () => mockKomodoRepo.supports(
            supportedAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
          ),
        ).thenAnswer((_) async => true);

        // Setup selection strategy to return Binance as primary
        when(
          () => mockSelectionStrategy.selectRepository(
            assetId: any(named: 'assetId'),
            fiatCurrency: any(named: 'fiatCurrency'),
            requestType: any(named: 'requestType'),
            availableRepositories: any(named: 'availableRepositories'),
          ),
        ).thenAnswer((_) async => mockBinanceRepo);

        // Setup repository responses
        when(
          () => mockBinanceRepo.getCoinFiatPrice(supportedAsset),
        ).thenThrow(Exception('Binance failed'));

        when(
          () => mockKomodoRepo.getCoinFiatPrice(supportedAsset),
        ).thenAnswer((_) async => Decimal.parse('50000.0'));

        // CoinGecko should NOT be called since it doesn't support the asset
        when(
          () => mockCoinGeckoRepo.getCoinFiatPrice(supportedAsset),
        ).thenAnswer((_) async => Decimal.parse('49999.0')); // Act
        final result = await testManager.testTryRepositoriesInOrder(
          supportedAsset,
          Stablecoin.usdt,
          PriceRequestType.currentPrice,
          (repo) => repo.getCoinFiatPrice(supportedAsset),
          'fiatPrice',
        );

        // Assert
        expect(result, equals(Decimal.parse('50000.0')));

        // Verify that both supporting repositories were called
        // (Binance failed, then Komodo succeeded)
        verify(
          () => mockBinanceRepo.getCoinFiatPrice(supportedAsset),
        ).called(1);

        verify(() => mockKomodoRepo.getCoinFiatPrice(supportedAsset)).called(1);

        // CoinGecko should NEVER be called since it doesn't support the asset
        verifyNever(() => mockCoinGeckoRepo.getCoinFiatPrice(supportedAsset));

        // Verify supports was called for each repository
        verify(
          () => mockBinanceRepo.supports(
            supportedAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
          ),
        ).called(greaterThanOrEqualTo(1));

        verify(
          () => mockCoinGeckoRepo.supports(
            supportedAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
          ),
        ).called(greaterThanOrEqualTo(1));

        verify(
          () => mockKomodoRepo.supports(
            supportedAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
          ),
        ).called(greaterThanOrEqualTo(1));
      });

      test(
        'should not attempt any repositories when none support the asset',
        () async {
          // Setup: No repository supports DOC
          when(
            () => mockBinanceRepo.supports(
              unsupportedAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
          ).thenAnswer((_) async => false);

          when(
            () => mockCoinGeckoRepo.supports(
              unsupportedAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
          ).thenAnswer((_) async => false);

          when(
            () => mockKomodoRepo.supports(
              unsupportedAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
          ).thenAnswer((_) async => false);

          // Selection strategy should return null since no repo supports it
          when(
            () => mockSelectionStrategy.selectRepository(
              assetId: any(named: 'assetId'),
              fiatCurrency: any(named: 'fiatCurrency'),
              requestType: any(named: 'requestType'),
              availableRepositories: any(named: 'availableRepositories'),
            ),
          ).thenAnswer((_) async => null);

          // Act & Assert
          expect(
            () => testManager.testTryRepositoriesInOrder(
              unsupportedAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
              (repo) => repo.getCoinFiatPrice(unsupportedAsset),
              'fiatPrice',
            ),
            throwsA(
              isA<StateError>().having(
                (e) => e.message,
                'message',
                contains('No repository supports DOC/USDT'),
              ),
            ),
          );

          // Verify no repository operations were attempted
          verifyNever(
            () => mockBinanceRepo.getCoinFiatPrice(
              any(),
              fiatCurrency: any(named: 'fiatCurrency'),
            ),
          );
          verifyNever(
            () => mockCoinGeckoRepo.getCoinFiatPrice(
              any(),
              fiatCurrency: any(named: 'fiatCurrency'),
            ),
          );
          verifyNever(
            () => mockKomodoRepo.getCoinFiatPrice(
              any(),
              fiatCurrency: any(named: 'fiatCurrency'),
            ),
          );
        },
      );

      test(
        'should handle repositories with unhealthy status but supporting asset',
        () async {
          // Make Binance unhealthy
          for (int i = 0; i < 3; i++) {
            testManager.recordRepositoryFailureForTest(mockBinanceRepo);
          }

          // Setup: Only CoinGecko supports the asset (and is healthy)
          when(
            () => mockBinanceRepo.supports(
              supportedAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
          ).thenAnswer((_) async => true);

          when(
            () => mockCoinGeckoRepo.supports(
              supportedAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
          ).thenAnswer((_) async => true);

          when(
            () => mockKomodoRepo.supports(
              supportedAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
          ).thenAnswer((_) async => false);

          // Setup selection strategy to return CoinGecko from healthy repos
          when(
            () => mockSelectionStrategy.selectRepository(
              assetId: any(named: 'assetId'),
              fiatCurrency: any(named: 'fiatCurrency'),
              requestType: any(named: 'requestType'),
              availableRepositories: any(named: 'availableRepositories'),
            ),
          ).thenAnswer((_) async => mockCoinGeckoRepo);

          // Setup: CoinGecko fails, should fall back to unhealthy Binance
          when(
            () => mockCoinGeckoRepo.getCoinFiatPrice(supportedAsset),
          ).thenThrow(Exception('CoinGecko failed'));

          when(
            () => mockBinanceRepo.getCoinFiatPrice(supportedAsset),
          ).thenAnswer((_) async => Decimal.parse('50000.0'));

          // Act
          final result = await testManager.testTryRepositoriesInOrder(
            supportedAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
            (repo) => repo.getCoinFiatPrice(supportedAsset),
            'fiatPrice',
          );

          // Assert
          expect(result, equals(Decimal.parse('50000.0')));

          // Verify both supporting repositories were attempted
          verify(
            () => mockCoinGeckoRepo.getCoinFiatPrice(supportedAsset),
          ).called(1);

          verify(
            () => mockBinanceRepo.getCoinFiatPrice(supportedAsset),
          ).called(1);

          // Komodo should NOT be called since it doesn't support the asset
          verifyNever(() => mockKomodoRepo.getCoinFiatPrice(supportedAsset));
        },
      );

      test(
        'should handle repositories that throw on supports check gracefully',
        () async {
          // Setup: Binance supports the asset, CoinGecko throws on supports check
          when(
            () => mockBinanceRepo.supports(
              supportedAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
          ).thenAnswer((_) async => true);

          when(
            () => mockCoinGeckoRepo.supports(
              supportedAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
          ).thenThrow(Exception('CoinGecko supports check failed'));

          when(
            () => mockKomodoRepo.supports(
              supportedAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
          ).thenAnswer((_) async => false);

          // Setup selection strategy to return Binance
          when(
            () => mockSelectionStrategy.selectRepository(
              assetId: any(named: 'assetId'),
              fiatCurrency: any(named: 'fiatCurrency'),
              requestType: any(named: 'requestType'),
              availableRepositories: any(named: 'availableRepositories'),
            ),
          ).thenAnswer((_) async => mockBinanceRepo);

          when(
            () => mockBinanceRepo.getCoinFiatPrice(
              any(),
              fiatCurrency: any(named: 'fiatCurrency'),
            ),
          ).thenAnswer((_) async => Decimal.parse('50000.0'));

          // Act
          final result = await testManager.testTryRepositoriesInOrder(
            supportedAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
            (repo) => repo.getCoinFiatPrice(supportedAsset),
            'fiatPrice',
          );

          // Assert
          expect(result, equals(Decimal.parse('50000.0')));

          // Verify only Binance was called (CoinGecko should be skipped due to error)
          verify(
            () => mockBinanceRepo.getCoinFiatPrice(supportedAsset),
          ).called(1);

          verifyNever(
            () => mockCoinGeckoRepo.getCoinFiatPrice(
              any(),
              fiatCurrency: any(named: 'fiatCurrency'),
            ),
          );

          verifyNever(
            () => mockKomodoRepo.getCoinFiatPrice(
              any(),
              fiatCurrency: any(named: 'fiatCurrency'),
            ),
          );
        },
      );

      test('should filter supporting repositories when all are unhealthy', () async {
        // Make all repositories unhealthy
        for (int i = 0; i < 3; i++) {
          testManager
            ..recordRepositoryFailureForTest(mockBinanceRepo)
            ..recordRepositoryFailureForTest(mockCoinGeckoRepo)
            ..recordRepositoryFailureForTest(mockKomodoRepo);
        }

        // Setup: Only Binance supports the asset
        when(
          () => mockBinanceRepo.supports(
            supportedAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
          ),
        ).thenAnswer((_) async => true);

        when(
          () => mockCoinGeckoRepo.supports(
            supportedAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
          ),
        ).thenAnswer((_) async => false);

        when(
          () => mockKomodoRepo.supports(
            supportedAsset,
            Stablecoin.usdt,
            PriceRequestType.currentPrice,
          ),
        ).thenAnswer((_) async => false);

        // Since all repos are unhealthy, the selection strategy should be called
        // with all repos, but should still consider support
        when(
          () => mockSelectionStrategy.selectRepository(
            assetId: any(named: 'assetId'),
            fiatCurrency: any(named: 'fiatCurrency'),
            requestType: any(named: 'requestType'),
            availableRepositories: any(named: 'availableRepositories'),
          ),
        ).thenAnswer(
          (_) async => null,
        ); // No healthy repos supporting the asset

        when(
          () => mockBinanceRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        ).thenAnswer((_) async => Decimal.parse('50000.0'));

        // Act - this should still work as Binance supports it even though unhealthy
        final result = await testManager.testTryRepositoriesInOrder(
          supportedAsset,
          Stablecoin.usdt,
          PriceRequestType.currentPrice,
          (repo) => repo.getCoinFiatPrice(supportedAsset),
          'fiatPrice',
        );

        // Assert
        expect(result, equals(Decimal.parse('50000.0')));

        // Verify only Binance was called (it's the only one supporting the asset)
        verify(
          () => mockBinanceRepo.getCoinFiatPrice(supportedAsset),
        ).called(1);

        verifyNever(
          () => mockCoinGeckoRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        );

        verifyNever(
          () => mockKomodoRepo.getCoinFiatPrice(
            any(),
            fiatCurrency: any(named: 'fiatCurrency'),
          ),
        );
      });
    });
  });
}
