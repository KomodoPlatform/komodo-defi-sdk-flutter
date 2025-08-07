import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_sdk/src/market_data/market_data_manager.dart';
import 'package:komodo_defi_sdk/src/market_data/repository_fallback_mixin.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockCexRepository extends Mock implements CexRepository {}

class MockRepositorySelectionStrategy extends Mock
    implements RepositorySelectionStrategy {}

class FakeAssetId extends Fake implements AssetId {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAssetId());
    registerFallbackValue(Stablecoin.usdt);
    registerFallbackValue(PriceRequestType.currentPrice);
  });
  group('Unsupported Asset Edge Cases', () {
    late MockCexRepository mockBinanceRepo;
    late MockCexRepository mockCoinGeckoRepo;
    late MockRepositorySelectionStrategy mockSelectionStrategy;
    late TestManager testManager;

    setUp(() {
      mockBinanceRepo = MockCexRepository();
      mockCoinGeckoRepo = MockCexRepository();
      mockSelectionStrategy = MockRepositorySelectionStrategy();

      testManager = TestManager(
        repositories: [mockBinanceRepo, mockCoinGeckoRepo],
        selectionStrategy: mockSelectionStrategy,
      );

      // Setup basic repository behavior - both repos claim empty coin lists
      when(() => mockBinanceRepo.getCoinList()).thenAnswer((_) async => []);
      when(() => mockCoinGeckoRepo.getCoinList()).thenAnswer((_) async => []);
    });

    group('Repository Fallback Mixin Bug Tests', () {
      test(
        'should not try any repositories when selection strategy returns null',
        () async {
          // Arrange: Create an unsupported asset
          final unsupportedAsset = AssetId(
            id: 'test-marty',
            symbol: AssetSymbol(assetConfigId: 'MARTY'),
            name: 'MARTY',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );

          // Mock selection strategy to return null (no repository supports this asset)
          when(
            () => mockSelectionStrategy.selectRepository(
              assetId: any(named: 'assetId'),
              fiatCurrency: any(named: 'fiatCurrency'),
              requestType: any(named: 'requestType'),
              availableRepositories: any(named: 'availableRepositories'),
            ),
          ).thenAnswer((_) async => null);

          // Mock repository supports method to return false
          when(
            () => mockBinanceRepo.supports(any(), any(), any()),
          ).thenAnswer((_) async => false);
          when(
            () => mockCoinGeckoRepo.supports(any(), any(), any()),
          ).thenAnswer((_) async => false);

          // Act & Assert: Should throw StateError, not try to call repositories
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
                contains('No repository supports MARTY/USDT'),
              ),
            ),
          );

          // Verify that getCoinFiatPrice was never called on any repository
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
        },
      );

      test(
        'correctly throws StateError when no repository supports asset (after fix)',
        () async {
          // This test verifies the correct behavior after the bug fix
          final unsupportedAsset = AssetId(
            id: 'test-doc',
            symbol: AssetSymbol(assetConfigId: 'DOC'),
            name: 'DOC',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );

          // Selection strategy returns null (correct behavior)
          when(
            () => mockSelectionStrategy.selectRepository(
              assetId: any(named: 'assetId'),
              fiatCurrency: any(named: 'fiatCurrency'),
              requestType: any(named: 'requestType'),
              availableRepositories: any(named: 'availableRepositories'),
            ),
          ).thenAnswer((_) async => null);

          // After the fix, should throw StateError without calling repositories
          expect(
            () => testManager.testTryRepositoriesInOrder(
              unsupportedAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
              (repo) => repo.getCoinFiatPrice(
                unsupportedAsset,
                fiatCurrency: Stablecoin.usdt,
              ),
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

          // Verify that repositories are never called (correct behavior)
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
        },
      );
    });

    group('ID Resolution Strategy Edge Cases', () {
      test(
        'ID resolution strategies are too permissive for unsupported assets',
        () {
          final binanceStrategy = BinanceIdResolutionStrategy();
          final coinGeckoStrategy = CoinGeckoIdResolutionStrategy();

          // Test with clearly unsupported assets
          final martyAsset = AssetId(
            id: 'test-marty',
            symbol: AssetSymbol(assetConfigId: 'MARTY'),
            name: 'MARTY',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );
          final docAsset = AssetId(
            id: 'test-doc',
            symbol: AssetSymbol(assetConfigId: 'DOC'),
            name: 'DOC',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );

          // Both strategies will claim they can resolve these assets
          // because they have configSymbol values
          expect(binanceStrategy.canResolve(martyAsset), isTrue);
          expect(binanceStrategy.canResolve(docAsset), isTrue);
          expect(coinGeckoStrategy.canResolve(martyAsset), isTrue);
          expect(coinGeckoStrategy.canResolve(docAsset), isTrue);

          // They will return the configSymbol as trading symbol
          expect(
            binanceStrategy.resolveTradingSymbol(martyAsset),
            equals('MARTY'),
          );
          expect(binanceStrategy.resolveTradingSymbol(docAsset), equals('DOC'));
          expect(
            coinGeckoStrategy.resolveTradingSymbol(martyAsset),
            equals('MARTY'),
          );
          expect(
            coinGeckoStrategy.resolveTradingSymbol(docAsset),
            equals('DOC'),
          );
        },
      );

      test('ID resolution with empty/null fields should fail', () {
        final binanceStrategy = BinanceIdResolutionStrategy();

        final emptyAsset = AssetId(
          id: 'test-empty',
          symbol: AssetSymbol(assetConfigId: ''),
          name: '',
          chainId: AssetChainId(chainId: 1),
          derivationPath: '1234',
          subClass: CoinSubClass.utxo,
        );

        // Should not be able to resolve empty symbols
        expect(binanceStrategy.canResolve(emptyAsset), isFalse);
        expect(
          () => binanceStrategy.resolveTradingSymbol(emptyAsset),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Repository Support Method Tests', () {
      test(
        'repository supports method correctly identifies unsupported assets',
        () async {
          // Setup repositories with known coin lists
          final binanceCoins = [
            const CexCoin(
              id: 'BTC',
              symbol: 'BTC',
              name: 'Bitcoin',
              currencies: {'USDT'},
              source: 'binance',
            ),
            const CexCoin(
              id: 'ETH',
              symbol: 'ETH',
              name: 'Ethereum',
              currencies: {'USDT'},
              source: 'binance',
            ),
          ];
          final coinGeckoCoins = [
            const CexCoin(
              id: 'bitcoin',
              symbol: 'btc',
              name: 'Bitcoin',
              currencies: {'usd', 'usdt'},
              source: 'coingecko',
            ),
            const CexCoin(
              id: 'ethereum',
              symbol: 'eth',
              name: 'Ethereum',
              currencies: {'usd', 'usdt'},
              source: 'coingecko',
            ),
          ];

          when(
            () => mockBinanceRepo.getCoinList(),
          ).thenAnswer((_) async => binanceCoins);
          when(
            () => mockCoinGeckoRepo.getCoinList(),
          ).thenAnswer((_) async => coinGeckoCoins);

          // Mock the supports method to behave like real repositories
          when(() => mockBinanceRepo.supports(any(), any(), any())).thenAnswer((
            invocation,
          ) async {
            final assetId = invocation.positionalArguments[0] as AssetId;
            final quoteCurrency =
                invocation.positionalArguments[1] as QuoteCurrency;

            final supportsAsset = binanceCoins.any(
              (c) =>
                  c.id.toUpperCase() ==
                  assetId.symbol.assetConfigId.toUpperCase(),
            );
            final supportsFiat = binanceCoins.any(
              (c) => c.currencies.contains(quoteCurrency.symbol.toUpperCase()),
            );
            return supportsAsset && supportsFiat;
          });

          when(
            () => mockCoinGeckoRepo.supports(any(), any(), any()),
          ).thenAnswer((invocation) async {
            final assetId = invocation.positionalArguments[0] as AssetId;
            final quoteCurrency =
                invocation.positionalArguments[1] as QuoteCurrency;

            final supportsAsset = coinGeckoCoins.any(
              (c) =>
                  c.id.toLowerCase() ==
                      assetId.symbol.assetConfigId.toLowerCase() ||
                  c.symbol.toLowerCase() ==
                      assetId.symbol.assetConfigId.toLowerCase(),
            );
            final supportsFiat = coinGeckoCoins.any(
              (c) => c.currencies.contains(
                quoteCurrency.coinGeckoId.toLowerCase(),
              ),
            );
            return supportsAsset && supportsFiat;
          });

          // Test supported assets
          final btcAsset = AssetId(
            id: 'bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC'),
            name: 'Bitcoin',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );
          expect(
            await mockBinanceRepo.supports(
              btcAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
            isTrue,
          );
          expect(
            await mockCoinGeckoRepo.supports(
              btcAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
            isTrue,
          );

          // Test unsupported assets
          final martyAsset = AssetId(
            id: 'test-marty',
            symbol: AssetSymbol(assetConfigId: 'MARTY'),
            name: 'MARTY',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );
          final docAsset = AssetId(
            id: 'test-doc',
            symbol: AssetSymbol(assetConfigId: 'DOC'),
            name: 'DOC',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );

          expect(
            await mockBinanceRepo.supports(
              martyAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
            isFalse,
          );
          expect(
            await mockBinanceRepo.supports(
              docAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
            isFalse,
          );
          expect(
            await mockCoinGeckoRepo.supports(
              martyAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
            isFalse,
          );
          expect(
            await mockCoinGeckoRepo.supports(
              docAsset,
              Stablecoin.usdt,
              PriceRequestType.currentPrice,
            ),
            isFalse,
          );
        },
      );
    });

    group('Integration Tests - MarketDataManager', () {
      late CexMarketDataManager marketDataManager;

      setUp(() {
        marketDataManager = CexMarketDataManager(
          priceRepositories: [mockBinanceRepo, mockCoinGeckoRepo],
          selectionStrategy: mockSelectionStrategy,
        );
      });

      test(
        'maybeFiatPrice returns null for completely unsupported assets',
        () async {
          await marketDataManager.init();

          // Mock selection strategy to return null for unsupported asset
          when(
            () => mockSelectionStrategy.selectRepository(
              assetId: any(named: 'assetId'),
              fiatCurrency: any(named: 'fiatCurrency'),
              requestType: any(named: 'requestType'),
              availableRepositories: any(named: 'availableRepositories'),
            ),
          ).thenAnswer((_) async => null);

          final unsupportedAsset = AssetId(
            id: 'test-unsupported',
            symbol: AssetSymbol(assetConfigId: 'UNSUPPORTED'),
            name: 'UNSUPPORTED',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );

          final result = await marketDataManager.maybeFiatPrice(
            unsupportedAsset,
          );
          expect(result, isNull);
        },
      );

      test(
        'fiatPrice throws appropriate error for unsupported assets',
        () async {
          await marketDataManager.init();

          // Mock selection strategy to return null
          when(
            () => mockSelectionStrategy.selectRepository(
              assetId: any(named: 'assetId'),
              fiatCurrency: any(named: 'fiatCurrency'),
              requestType: any(named: 'requestType'),
              availableRepositories: any(named: 'availableRepositories'),
            ),
          ).thenAnswer((_) async => null);

          final unsupportedAsset = AssetId(
            id: 'test-unsupported',
            symbol: AssetSymbol(assetConfigId: 'UNSUPPORTED'),
            name: 'UNSUPPORTED',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );

          expect(
            () => marketDataManager.fiatPrice(unsupportedAsset),
            throwsA(isA<StateError>()),
          );
        },
      );

      tearDown(() async {
        await marketDataManager.dispose();
      });
    });
  });
}

/// Test helper class that exposes the mixin methods for testing
class TestManager with RepositoryFallbackMixin {
  TestManager({required this.repositories, required this.selectionStrategy});

  final List<CexRepository> repositories;
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

  // Expose the maybe version for testing
  Future<T?> testTryRepositoriesInOrderMaybe<T>(
    AssetId assetId,
    QuoteCurrency quoteCurrency,
    PriceRequestType requestType,
    Future<T> Function(CexRepository repo) operation,
    String operationName, {
    int? maxTotalAttempts,
  }) {
    return tryRepositoriesInOrderMaybe(
      assetId,
      quoteCurrency,
      requestType,
      operation,
      operationName,
      maxTotalAttempts: maxTotalAttempts ?? 3,
    );
  }
}
