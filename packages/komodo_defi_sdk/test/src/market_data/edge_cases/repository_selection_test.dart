import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_cex_market_data/src/binance/models/binance_24hr_ticker.dart';
import 'package:komodo_cex_market_data/src/binance/models/binance_exchange_info_reduced.dart';
import 'package:komodo_cex_market_data/src/coingecko/models/coin_historical_data/coin_historical_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockCexRepository extends Mock implements CexRepository {}

// Lightweight stub providers to create real repository instances for
// priority-based selection tests without hitting the network.
class _TestBinanceProvider implements IBinanceProvider {
  @override
  Future<CoinOhlc> fetchKlines(
    String symbol,
    String interval, {
    int? startUnixTimestampMilliseconds,
    int? endUnixTimestampMilliseconds,
    int? limit,
    String? baseUrl,
  }) async {
    return const CoinOhlc(ohlc: []);
  }

  @override
  Future<Binance24hrTicker> fetch24hrTicker(String symbol, {String? baseUrl}) {
    throw UnimplementedError();
  }

  @override
  Future<BinanceExchangeInfoResponse> fetchExchangeInfo({String? baseUrl}) {
    throw UnimplementedError();
  }

  @override
  Future<BinanceExchangeInfoResponseReduced> fetchExchangeInfoReduced({
    String? baseUrl,
  }) async {
    return BinanceExchangeInfoResponseReduced(
      timezone: '',
      serverTime: 0,
      symbols: [
        SymbolReduced(
          symbol: 'BTCUSDT',
          status: 'TRADING',
          baseAsset: 'BTC',
          baseAssetPrecision: 8,
          quoteAsset: 'USDT',
          quotePrecision: 8,
          quoteAssetPrecision: 8,
          isSpotTradingAllowed: true,
        ),
      ],
    );
  }
}

class _TestCoinGeckoProvider implements ICoinGeckoProvider {
  @override
  Future<List<CexCoin>> fetchCoinList({bool includePlatforms = false}) async {
    return const [
      CexCoin(
        id: 'BTC',
        symbol: 'BTC',
        name: 'Bitcoin',
        currencies: <String>{},
      ),
    ];
  }

  @override
  Future<List<String>> fetchSupportedVsCurrencies() async {
    return ['usdt'];
  }

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
    throw UnimplementedError();
  }

  @override
  Future<CoinMarketChart> fetchCoinMarketChart({
    required String id,
    required String vsCurrency,
    required int fromUnixTimestamp,
    required int toUnixTimestamp,
    String? precision,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CoinOhlc> fetchCoinOhlc(
    String id,
    String vsCurrency,
    int days, {
    int? precision,
  }) async {
    return const CoinOhlc(ohlc: []);
  }

  @override
  Future<CoinHistoricalData> fetchCoinHistoricalMarketData({
    required String id,
    required DateTime date,
    String vsCurrency = 'usd',
    bool localization = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, AssetMarketInformation>> fetchCoinPrices(
    List<String> coinGeckoIds, {
    List<String> vsCurrencies = const <String>['usd'],
  }) {
    throw UnimplementedError();
  }
}

void main() {
  group('Repository Selection Strategy Edge Cases', () {
    late DefaultRepositorySelectionStrategy strategy;
    late MockCexRepository mockBinanceRepo;
    late MockCexRepository mockCoinGeckoRepo;
    late MockCexRepository mockKomodoRepo;

    setUp(() {
      strategy = DefaultRepositorySelectionStrategy();
      mockBinanceRepo = MockCexRepository();
      mockCoinGeckoRepo = MockCexRepository();
      mockKomodoRepo = MockCexRepository();
    });

    group('Unsupported Asset Handling', () {
      test(
        'selectRepository returns null when no repository supports the asset',
        () async {
          // Setup repositories with limited coin lists that don't include MARTY or DOC
          final binanceCoins = [
            const CexCoin(
              id: 'BTC',
              symbol: 'BTC',
              name: 'Bitcoin',
              currencies: {'USDT', 'BUSD'},
              source: 'binance',
            ),
            const CexCoin(
              id: 'ETH',
              symbol: 'ETH',
              name: 'Ethereum',
              currencies: {'USDT', 'BUSD'},
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

          final komodoCoins = [
            const CexCoin(
              id: 'KMD',
              symbol: 'KMD',
              name: 'Komodo',
              currencies: {'USD'},
              source: 'komodo',
            ),
          ];

          when(
            () => mockBinanceRepo.getCoinList(),
          ).thenAnswer((_) async => binanceCoins);
          when(
            () => mockCoinGeckoRepo.getCoinList(),
          ).thenAnswer((_) async => coinGeckoCoins);
          when(
            () => mockKomodoRepo.getCoinList(),
          ).thenAnswer((_) async => komodoCoins);

          final repositories = [
            mockBinanceRepo,
            mockCoinGeckoRepo,
            mockKomodoRepo,
          ];

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
          final randomAsset = AssetId(
            id: 'test-random',
            symbol: AssetSymbol(assetConfigId: 'RANDOMCOIN'),
            name: 'RANDOMCOIN',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );

          // All of these should return null since no repository supports them
          final martyResult = await strategy.selectRepository(
            assetId: martyAsset,
            fiatCurrency: Stablecoin.usdt,
            requestType: PriceRequestType.currentPrice,
            availableRepositories: repositories,
          );
          expect(martyResult, isNull);

          final docResult = await strategy.selectRepository(
            assetId: docAsset,
            fiatCurrency: Stablecoin.usdt,
            requestType: PriceRequestType.currentPrice,
            availableRepositories: repositories,
          );
          expect(docResult, isNull);

          final randomResult = await strategy.selectRepository(
            assetId: randomAsset,
            fiatCurrency: Stablecoin.usdt,
            requestType: PriceRequestType.currentPrice,
            availableRepositories: repositories,
          );
          expect(randomResult, isNull);
        },
      );

      test(
        'selectRepository returns null when asset is supported but fiat currency is not',
        () async {
          // Setup repository that supports BTC but only with limited fiat currencies
          final limitedCoins = [
            const CexCoin(
              id: 'BTC',
              symbol: 'BTC',
              name: 'Bitcoin',
              currencies: {'EUR'}, // Only EUR, not USD or USDT
              source: 'limited',
            ),
          ];

          when(
            () => mockBinanceRepo.getCoinList(),
          ).thenAnswer((_) async => limitedCoins);

          final btcAsset = AssetId(
            id: 'bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC'),
            name: 'Bitcoin',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );

          // Should return null because BTC/USDT is not supported (only BTC/EUR)
          final result = await strategy.selectRepository(
            assetId: btcAsset,
            fiatCurrency: Stablecoin.usdt,
            requestType: PriceRequestType.currentPrice,
            availableRepositories: [mockBinanceRepo],
          );
          expect(result, isNull);
        },
      );

      test(
        'selectRepository returns null when fiat currency is supported but asset is not',
        () async {
          // Setup repository that supports USDT but only with limited assets
          final limitedCoins = [
            const CexCoin(
              id: 'ETH',
              symbol: 'ETH',
              name: 'Ethereum',
              currencies: {'USDT'}, // Supports USDT but not BTC
              source: 'limited',
            ),
          ];

          when(
            () => mockBinanceRepo.getCoinList(),
          ).thenAnswer((_) async => limitedCoins);

          final btcAsset = AssetId(
            id: 'bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC'),
            name: 'Bitcoin',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );

          // Should return null because BTC is not supported (only ETH)
          final result = await strategy.selectRepository(
            assetId: btcAsset,
            fiatCurrency: Stablecoin.usdt,
            requestType: PriceRequestType.currentPrice,
            availableRepositories: [mockBinanceRepo],
          );
          expect(result, isNull);
        },
      );
    });

    group('Case Sensitivity Tests', () {
      test('asset matching is case-insensitive', () async {
        final mixedCaseCoins = [
          const CexCoin(
            id: 'btc', // lowercase id
            symbol: 'BTC', // uppercase symbol
            name: 'Bitcoin',
            currencies: {'USDT'},
            source: 'test',
          ),
        ];

        when(
          () => mockBinanceRepo.getCoinList(),
        ).thenAnswer((_) async => mixedCaseCoins);

        // Test with different cases
        final btcUpperAsset = AssetId(
          id: 'bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          name: 'Bitcoin',
          chainId: AssetChainId(chainId: 1),
          derivationPath: '1234',
          subClass: CoinSubClass.utxo,
        );
        final btcLowerAsset = AssetId(
          id: 'bitcoin',
          symbol: AssetSymbol(assetConfigId: 'btc'),
          name: 'Bitcoin',
          chainId: AssetChainId(chainId: 1),
          derivationPath: '1234',
          subClass: CoinSubClass.utxo,
        );

        final upperResult = await strategy.selectRepository(
          assetId: btcUpperAsset,
          fiatCurrency: Stablecoin.usdt,
          requestType: PriceRequestType.currentPrice,
          availableRepositories: [mockBinanceRepo],
        );
        expect(upperResult, equals(mockBinanceRepo));

        final lowerResult = await strategy.selectRepository(
          assetId: btcLowerAsset,
          fiatCurrency: Stablecoin.usdt,
          requestType: PriceRequestType.currentPrice,
          availableRepositories: [mockBinanceRepo],
        );
        expect(lowerResult, equals(mockBinanceRepo));
      });

      test('fiat currency matching is case-insensitive', () async {
        final mixedCaseCoins = [
          const CexCoin(
            id: 'BTC',
            symbol: 'BTC',
            name: 'Bitcoin',
            currencies: {'usdt'}, // lowercase currency
            source: 'test',
          ),
        ];

        when(
          () => mockBinanceRepo.getCoinList(),
        ).thenAnswer((_) async => mixedCaseCoins);

        final btcAsset = AssetId(
          id: 'bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          name: 'Bitcoin',
          chainId: AssetChainId(chainId: 1),
          derivationPath: '1234',
          subClass: CoinSubClass.utxo,
        );

        final result = await strategy.selectRepository(
          assetId: btcAsset,
          fiatCurrency: Stablecoin.usdt, // This has uppercase symbol
          requestType: PriceRequestType.currentPrice,
          availableRepositories: [mockBinanceRepo],
        );
        expect(result, equals(mockBinanceRepo));
      });
    });

    group('Empty Repository List Handling', () {
      test(
        'selectRepository returns null when no repositories are available',
        () async {
          final btcAsset = AssetId(
            id: 'bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC'),
            name: 'Bitcoin',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );

          final result = await strategy.selectRepository(
            assetId: btcAsset,
            fiatCurrency: Stablecoin.usdt,
            requestType: PriceRequestType.currentPrice,
            availableRepositories: [], // Empty list
          );
          expect(result, isNull);
        },
      );

      test(
        'selectRepository handles repositories with empty coin lists',
        () async {
          when(() => mockBinanceRepo.getCoinList()).thenAnswer((_) async => []);
          when(
            () => mockCoinGeckoRepo.getCoinList(),
          ).thenAnswer((_) async => []);

          final btcAsset = AssetId(
            id: 'bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC'),
            name: 'Bitcoin',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );

          final result = await strategy.selectRepository(
            assetId: btcAsset,
            fiatCurrency: Stablecoin.usdt,
            requestType: PriceRequestType.currentPrice,
            availableRepositories: [mockBinanceRepo, mockCoinGeckoRepo],
          );
          expect(result, isNull);
        },
      );
    });

    group('Repository Priority Tests', () {
      test(
        'selectRepository returns highest priority repository when multiple support the asset',
        () async {
          // Use real repository types with stub providers so priority mapping applies
          final binanceRepo = BinanceRepository(
            binanceProvider: _TestBinanceProvider(),
            enableMemoization: false,
          );
          final coinGeckoRepo = CoinGeckoRepository(
            coinGeckoProvider: _TestCoinGeckoProvider(),
            enableMemoization: false,
          );

          final btcAsset = AssetId(
            id: 'bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC'),
            name: 'Bitcoin',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );

          final result = await strategy.selectRepository(
            assetId: btcAsset,
            fiatCurrency: Stablecoin.usdt,
            requestType: PriceRequestType.currentPrice,
            availableRepositories: [
              coinGeckoRepo,
              binanceRepo,
            ], // Order shouldn't matter
          );

          // According to RepositoryPriorityManager: Binance(2) > CoinGecko(3)
          expect(result, equals(binanceRepo));
        },
      );
    });

    group('Caching Behavior Tests', () {
      test(
        'ensureCacheInitialized handles repository failures gracefully',
        () async {
          // Setup one repository to fail
          when(
            () => mockBinanceRepo.getCoinList(),
          ).thenThrow(Exception('API Error'));
          when(() => mockCoinGeckoRepo.getCoinList()).thenAnswer(
            (_) async => [
              const CexCoin(
                id: 'BTC',
                symbol: 'BTC',
                name: 'Bitcoin',
                currencies: {'USDT'},
                source: 'coingecko',
              ),
            ],
          );

          // Should not throw, just handle the failure
          expect(
            () => strategy.ensureCacheInitialized([
              mockBinanceRepo,
              mockCoinGeckoRepo,
            ]),
            returnsNormally,
          );

          // The working repository should still be usable
          final btcAsset = AssetId(
            id: 'bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC'),
            name: 'Bitcoin',
            chainId: AssetChainId(chainId: 1),
            derivationPath: '1234',
            subClass: CoinSubClass.utxo,
          );

          final result = await strategy.selectRepository(
            assetId: btcAsset,
            fiatCurrency: Stablecoin.usdt,
            requestType: PriceRequestType.currentPrice,
            availableRepositories: [mockBinanceRepo, mockCoinGeckoRepo],
          );

          // Should return the working repository
          expect(result, equals(mockCoinGeckoRepo));
        },
      );

      test('cache is built correctly from coin list data', () async {
        final testCoins = [
          const CexCoin(
            id: 'BTC',
            symbol: 'BTC',
            name: 'Bitcoin',
            currencies: {'USDT', 'BUSD', 'EUR'},
            source: 'test',
          ),
          const CexCoin(
            id: 'ETH',
            symbol: 'ETH',
            name: 'Ethereum',
            currencies: {'USDT', 'BUSD'},
            source: 'test',
          ),
        ];

        when(
          () => mockBinanceRepo.getCoinList(),
        ).thenAnswer((_) async => testCoins);

        await strategy.ensureCacheInitialized([mockBinanceRepo]);

        // Test that all supported combinations work
        final btcAsset = AssetId(
          id: 'bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          name: 'Bitcoin',
          chainId: AssetChainId(chainId: 1),
          derivationPath: '1234',
          subClass: CoinSubClass.utxo,
        );
        final ethAsset = AssetId(
          id: 'ethereum',
          symbol: AssetSymbol(assetConfigId: 'ETH'),
          name: 'Ethereum',
          chainId: AssetChainId(chainId: 1),
          derivationPath: '1234',
          subClass: CoinSubClass.utxo,
        );

        // BTC with various fiat currencies
        expect(
          await strategy.selectRepository(
            assetId: btcAsset,
            fiatCurrency: Stablecoin.usdt,
            requestType: PriceRequestType.currentPrice,
            availableRepositories: [mockBinanceRepo],
          ),
          equals(mockBinanceRepo),
        );

        expect(
          await strategy.selectRepository(
            assetId: btcAsset,
            fiatCurrency: Stablecoin.busd,
            requestType: PriceRequestType.currentPrice,
            availableRepositories: [mockBinanceRepo],
          ),
          equals(mockBinanceRepo),
        );

        // ETH should work with USDT
        expect(
          await strategy.selectRepository(
            assetId: ethAsset,
            fiatCurrency: Stablecoin.usdt,
            requestType: PriceRequestType.currentPrice,
            availableRepositories: [mockBinanceRepo],
          ),
          equals(mockBinanceRepo),
        );
      });
    });
  });
}
