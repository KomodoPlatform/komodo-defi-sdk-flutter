import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'binance_test_helpers.dart';

class MockIBinanceProvider extends Mock implements IBinanceProvider {}

void main() {
  group('BinanceRepository', () {
    late BinanceRepository repository;
    late MockIBinanceProvider mockProvider;

    setUp(() {
      mockProvider = MockIBinanceProvider();
      repository = BinanceRepository(
        binanceProvider: mockProvider,
        enableMemoization: false, // Disable for testing
      );
    });

    group('USD equivalent currency mapping', () {
      setUp(() {
        // Mock the exchange info response with typical Binance quote assets
        final mockExchangeInfo = buildComprehensiveExchangeInfo();

        when(
          () => mockProvider.fetchExchangeInfoReduced(
            baseUrl: any(named: 'baseUrl'),
          ),
        ).thenAnswer((_) async => mockExchangeInfo);
      });

      test('should map USD fiat to USDT when USD is not supported', () async {
        final assetId = AssetId(
          id: 'bitcoin',
          name: 'Bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final supports = await repository.supports(
          assetId,
          FiatCurrency.usd,
          PriceRequestType.currentPrice,
        );

        expect(
          supports,
          isTrue,
          reason: 'USD should be supported by mapping to USDT',
        );
      });

      test(
        'should support all USD-pegged stablecoins by mapping to USDT',
        () async {
          final assetId = AssetId(
            id: 'bitcoin',
            name: 'Bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          // Stablecoins directly supported by Binance
          final directlySupported = [
            Stablecoin.usdt, // USDT
            Stablecoin.usdc, // USDC
            Stablecoin.busd, // BUSD
            Stablecoin.tusd, // TUSD
            Stablecoin.usdp, // USDP
            Stablecoin.dai, // DAI
            Stablecoin.lusd, // LUSD
            Stablecoin.gusd, // GUSD
            Stablecoin.susd, // SUSD
            Stablecoin.fei, // FEI
          ];

          // Stablecoins that map to USDT (not directly supported by Binance)
          final mappedToUsdt = [
            Stablecoin.tribe, // Maps to USDT
            Stablecoin.ust, // Maps to USDT
            Stablecoin.ustc, // Maps to USDT
          ];

          // Test directly supported stablecoins
          for (final stablecoin in directlySupported) {
            final supports = await repository.supports(
              assetId,
              stablecoin,
              PriceRequestType.currentPrice,
            );

            expect(
              supports,
              isTrue,
              reason:
                  '${stablecoin.symbol} should be directly supported by Binance',
            );
          }

          // Test stablecoins that map to USDT
          for (final stablecoin in mappedToUsdt) {
            final supports = await repository.supports(
              assetId,
              stablecoin,
              PriceRequestType.currentPrice,
            );

            expect(
              supports,
              isTrue,
              reason:
                  '${stablecoin.symbol} should be supported via USDT mapping',
            );
          }
        },
      );

      test('should support EUR-pegged stablecoins when EUR is supported', () async {
        final assetId = AssetId(
          id: 'bitcoin',
          name: 'Bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Test EUR stablecoins - should work because EUR is in our mock exchange info
        // Note: Only EURS and EURT are directly supported by Binance
        final eurStablecoins = [
          Stablecoin.eurs, // Directly supported
          Stablecoin.eurt, // Directly supported
          // Stablecoin.jeur, // Not directly supported by Binance, maps to EUR
        ];

        for (final stablecoin in eurStablecoins) {
          final supports = await repository.supports(
            assetId,
            stablecoin,
            PriceRequestType.currentPrice,
          );

          expect(
            supports,
            isTrue,
            reason:
                '${stablecoin.symbol} should be supported (directly or via EUR mapping)',
          );
        }
      });

      test(
        'should not support currency when neither original nor fallback is available',
        () async {
          // Create a mock exchange info without GBP or USDT
          final mockExchangeInfoNoFallback = buildMinimalExchangeInfo();

          when(
            () => mockProvider.fetchExchangeInfoReduced(
              baseUrl: any(named: 'baseUrl'),
            ),
          ).thenAnswer((_) async => mockExchangeInfoNoFallback);

          final repositoryNoFallback = BinanceRepository(
            binanceProvider: mockProvider,
            enableMemoization: false,
          );

          final assetId = AssetId(
            id: 'bitcoin',
            name: 'Bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          final supports = await repositoryNoFallback.supports(
            assetId,
            Stablecoin.gbpt,
            PriceRequestType.currentPrice,
          );

          expect(
            supports,
            isFalse,
            reason:
                'GBPT should not be supported when neither GBP nor USDT are available',
          );
        },
      );

      test('should not support asset when asset is not in coin list', () async {
        final assetId = AssetId(
          id: 'unknown',
          name: 'Unknown',
          symbol: AssetSymbol(assetConfigId: 'UNKNOWN'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final supports = await repository.supports(
          assetId,
          Stablecoin.usdt,
          PriceRequestType.currentPrice,
        );

        expect(
          supports,
          isFalse,
          reason: 'Unknown asset should not be supported',
        );
      });

      test(
        'should not support USD fiat when coin exists but USDT pair does not',
        () async {
          final viaAssetId = AssetId(
            id: 'viacoin',
            name: 'Viacoin',
            symbol: AssetSymbol(assetConfigId: 'VIA'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          // VIA coin should be supported (it has BNB and ETH pairs)
          final supportsViaBnb = await repository.supports(
            viaAssetId,
            Cryptocurrency.bnb,
            PriceRequestType.currentPrice,
          );

          expect(supportsViaBnb, isTrue, reason: 'VIA should support BNB pair');

          // But USD (which maps to USDT) should not be supported since VIA-USDT pair doesn't exist
          final supportsViaUsd = await repository.supports(
            viaAssetId,
            FiatCurrency.usd,
            PriceRequestType.currentPrice,
          );

          expect(
            supportsViaUsd,
            isFalse,
            reason:
                'VIA should not support USD because VIA-USDT pair does not exist',
          );
        },
      );

      test('should handle coin with limited fiat support correctly', () async {
        final viaAssetId = AssetId(
          id: 'viacoin',
          name: 'Viacoin',
          symbol: AssetSymbol(assetConfigId: 'VIA'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // VIA should support cryptocurrencies it has pairs for
        final supportsViaEth = await repository.supports(
          viaAssetId,
          Cryptocurrency.eth,
          PriceRequestType.currentPrice,
        );

        expect(supportsViaEth, isTrue, reason: 'VIA should support ETH pair');

        // But should not support any stablecoin that maps to USDT
        final supportsTribeStablecoin = await repository.supports(
          viaAssetId,
          Stablecoin.tribe, // This maps to USDT
          PriceRequestType.currentPrice,
        );

        expect(
          supportsTribeStablecoin,
          isFalse,
          reason:
              'VIA should not support TRIBE stablecoin (maps to USDT) since VIA-USDT pair does not exist',
        );
      });
    });

    group('Price fetching with mapping', () {
      setUp(() {
        // Mock exchange info for price fetching tests
        final mockExchangeInfo = BinanceExchangeInfoResponseReduced(
          timezone: 'UTC',
          serverTime: DateTime.now().millisecondsSinceEpoch,
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

        when(
          () => mockProvider.fetchExchangeInfoReduced(
            baseUrl: any(named: 'baseUrl'),
          ),
        ).thenAnswer((_) async => mockExchangeInfo);
      });

      test('should use mapped currency in getCoinFiatPrice', () async {
        final mockOhlc = CoinOhlc(
          ohlc: [
            Ohlc.binance(
              open: Decimal.fromInt(50000),
              high: Decimal.fromInt(51000),
              low: Decimal.fromInt(49000),
              close: Decimal.fromInt(50500),
              openTime: DateTime.now()
                  .subtract(const Duration(days: 1))
                  .millisecondsSinceEpoch,
              closeTime: DateTime.now().millisecondsSinceEpoch,
            ),
          ],
        );

        when(
          () => mockProvider.fetchKlines(
            'BTCUSDT',
            any(),
            startUnixTimestampMilliseconds: any(
              named: 'startUnixTimestampMilliseconds',
            ),
            endUnixTimestampMilliseconds: any(
              named: 'endUnixTimestampMilliseconds',
            ),
            limit: any(named: 'limit'),
            baseUrl: any(named: 'baseUrl'),
          ),
        ).thenAnswer((_) async => mockOhlc);

        final assetId = AssetId(
          id: 'bitcoin',
          name: 'Bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Test with USD (should map to USDT)
        final price = await repository.getCoinFiatPrice(
          assetId,
          fiatCurrency: FiatCurrency.usd,
        );

        expect(price, equals(Decimal.parse('50500')));

        // Verify the correct symbol was used (BTC/USDT, not BTC/USD)
        verify(
          () => mockProvider.fetchKlines(
            'BTCUSDT',
            any(),
            startUnixTimestampMilliseconds: any(
              named: 'startUnixTimestampMilliseconds',
            ),
            endUnixTimestampMilliseconds: any(
              named: 'endUnixTimestampMilliseconds',
            ),
            limit: 1,
            baseUrl: any(named: 'baseUrl'),
          ),
        ).called(1);
      });

      test('should use mapped currency in getCoin24hrPriceChange', () async {
        final mockTicker = Binance24hrTicker(
          symbol: 'BTCUSDT',
          priceChange: Decimal.parse('1000'),
          priceChangePercent: Decimal.parse('2.0'),
          weightedAvgPrice: Decimal.parse('50250'),
          prevClosePrice: Decimal.parse('50000'),
          lastPrice: Decimal.parse('51000'),
          lastQty: Decimal.parse('0.1'),
          bidPrice: Decimal.parse('50900'),
          bidQty: Decimal.parse('0.1'),
          askPrice: Decimal.parse('51100'),
          askQty: Decimal.parse('0.1'),
          openPrice: Decimal.parse('50000'),
          highPrice: Decimal.parse('52000'),
          lowPrice: Decimal.parse('49000'),
          volume: Decimal.parse('1000'),
          quoteVolume: Decimal.parse('50500000'),
          openTime: DateTime.now()
              .subtract(const Duration(hours: 24))
              .millisecondsSinceEpoch,
          closeTime: DateTime.now().millisecondsSinceEpoch,
          firstId: 1,
          lastId: 10000,
          count: 10000,
        );

        when(
          () => mockProvider.fetch24hrTicker(
            'BTCUSDT',
            baseUrl: any(named: 'baseUrl'),
          ),
        ).thenAnswer((_) async => mockTicker);

        final assetId = AssetId(
          id: 'bitcoin',
          name: 'Bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Test with USD (should map to USDT)
        final priceChange = await repository.getCoin24hrPriceChange(
          assetId,
          fiatCurrency: FiatCurrency.usd,
        );

        expect(priceChange, equals(Decimal.parse('2.0')));

        // Verify the correct symbol was used (BTCUSDT, not BTCUSD)
        verify(
          () => mockProvider.fetch24hrTicker(
            'BTCUSDT',
            baseUrl: any(named: 'baseUrl'),
          ),
        ).called(1);
      });
    });

    group('_mapFiatCurrencyToBinance method behavior', () {
      setUp(() {
        when(
          () => mockProvider.fetchExchangeInfoReduced(
            baseUrl: any(named: 'baseUrl'),
          ),
        ).thenAnswer((_) async => buildComprehensiveExchangeInfo());
      });

      test('should preserve directly supported currencies', () async {
        // Initialize the repository to populate cached currencies
        await repository.getCoinList();

        // Test that currencies directly supported by Binance are preserved
        expect(Stablecoin.usdt.binanceId, equals('USDT'));
        expect(Stablecoin.usdc.binanceId, equals('USDC'));
        expect(Stablecoin.busd.binanceId, equals('BUSD'));
      });

      test('should map USD to USDT', () async {
        // Initialize the repository to populate cached currencies
        await repository.getCoinList();

        // USD should be mapped to USDT since Binance doesn't support base USD
        expect(FiatCurrency.usd.binanceId, equals('USDT'));
      });

      test('should handle stablecoin fallback logic', () async {
        // Initialize the repository to populate cached currencies
        await repository.getCoinList();

        // Stablecoins directly supported by Binance should return their own symbol
        expect(Stablecoin.usdt.binanceId, equals('USDT'));
        expect(Stablecoin.usdc.binanceId, equals('USDC'));
        expect(Stablecoin.busd.binanceId, equals('BUSD'));
        expect(Stablecoin.tusd.binanceId, equals('TUSD'));
        expect(Stablecoin.usdp.binanceId, equals('USDP'));
        expect(Stablecoin.dai.binanceId, equals('DAI'));
        expect(Stablecoin.frax.binanceId, equals('FRAX'));
        expect(Stablecoin.lusd.binanceId, equals('LUSD'));
        expect(Stablecoin.gusd.binanceId, equals('GUSD'));
        expect(Stablecoin.susd.binanceId, equals('SUSD'));
        expect(Stablecoin.fei.binanceId, equals('FEI'));

        // Stablecoins not directly supported should fall back to USDT (for USD-pegged)
        expect(Stablecoin.tribe.binanceId, equals('USDT'));
        expect(Stablecoin.ust.binanceId, equals('USDT'));
        expect(Stablecoin.ustc.binanceId, equals('USDT'));

        // EUR stablecoins that are directly supported
        expect(Stablecoin.eurs.binanceId, equals('EURS'));
        expect(Stablecoin.eurt.binanceId, equals('EURT'));
      });
    });

    group('Bug reproduction: coin supported but fiat mapping fails', () {
      test(
        'getCoinFiatPrice should fail for VIA-USD when only VIA-BNB/ETH pairs exist',
        () async {
          final viaAssetId = AssetId(
            id: 'viacoin',
            name: 'Viacoin',
            symbol: AssetSymbol(assetConfigId: 'VIA'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          // This should fail because VIA-USDT pair doesn't exist
          expect(
            () async => await repository.getCoinFiatPrice(
              viaAssetId,
              fiatCurrency: FiatCurrency.usd,
            ),
            throwsA(isA<Exception>()),
            reason:
                'Should fail when trying to get VIA price in USD (which maps to USDT) when VIA-USDT pair does not exist',
          );
        },
      );
    });

    group('USD stablecoin fallback functionality', () {
      late BinanceRepository repositoryWithFallbacks;
      late MockIBinanceProvider mockProviderWithFallbacks;

      setUp(() {
        mockProviderWithFallbacks = MockIBinanceProvider();
        repositoryWithFallbacks = BinanceRepository(
          binanceProvider: mockProviderWithFallbacks,
          enableMemoization: false,
        );

        // Mock exchange info with fallback scenarios
        final mockExchangeInfoWithFallbacks =
            buildExchangeInfoWithFallbackStablecoins();

        when(
          () => mockProviderWithFallbacks.fetchExchangeInfoReduced(
            baseUrl: any(named: 'baseUrl'),
          ),
        ).thenAnswer((_) async => mockExchangeInfoWithFallbacks);
      });

      test('should support USD when coin has BUSD but not USDT', () async {
        final fallbackAssetId = AssetId(
          id: 'fallbackcoin',
          name: 'Fallback Coin',
          symbol: AssetSymbol(assetConfigId: 'FALLBACK'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final supportsUsd = await repositoryWithFallbacks.supports(
          fallbackAssetId,
          FiatCurrency.usd,
          PriceRequestType.currentPrice,
        );

        expect(
          supportsUsd,
          isTrue,
          reason: 'FALLBACK should support USD via BUSD fallback',
        );
      });

      test('should support USDT when coin has USDC but not USDT', () async {
        final onlyUsdcAssetId = AssetId(
          id: 'onlyusdccoin',
          name: 'Only USDC Coin',
          symbol: AssetSymbol(assetConfigId: 'ONLYUSDC'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final supportsUsdt = await repositoryWithFallbacks.supports(
          onlyUsdcAssetId,
          Stablecoin.usdt,
          PriceRequestType.currentPrice,
        );

        expect(
          supportsUsdt,
          isTrue,
          reason: 'ONLYUSDC should support USDT via USDC fallback',
        );
      });

      test('should not support USD when coin has no USD stablecoins', () async {
        final noUsdAssetId = AssetId(
          id: 'nousdcoin',
          name: 'No USD Coin',
          symbol: AssetSymbol(assetConfigId: 'NOUSD'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final supportsUsd = await repositoryWithFallbacks.supports(
          noUsdAssetId,
          FiatCurrency.usd,
          PriceRequestType.currentPrice,
        );

        expect(
          supportsUsd,
          isFalse,
          reason: 'NOUSD should not support USD as it has no USD stablecoins',
        );
      });

      test('should fetch price using BUSD when USDT not available', () async {
        // Mock OHLC data for FALLBACKBUSD pair
        final mockOhlc = CoinOhlc(
          ohlc: [
            Ohlc.binance(
              open: Decimal.fromInt(100),
              high: Decimal.fromInt(105),
              low: Decimal.fromInt(98),
              close: Decimal.fromInt(102),
              openTime: DateTime.now()
                  .subtract(const Duration(days: 1))
                  .millisecondsSinceEpoch,
              closeTime: DateTime.now().millisecondsSinceEpoch,
            ),
          ],
        );

        when(
          () => mockProviderWithFallbacks.fetchKlines(
            'FALLBACKBUSD',
            any(),
            startUnixTimestampMilliseconds: any(
              named: 'startUnixTimestampMilliseconds',
            ),
            endUnixTimestampMilliseconds: any(
              named: 'endUnixTimestampMilliseconds',
            ),
            limit: any(named: 'limit'),
            baseUrl: any(named: 'baseUrl'),
          ),
        ).thenAnswer((_) async => mockOhlc);

        final fallbackAssetId = AssetId(
          id: 'fallbackcoin',
          name: 'Fallback Coin',
          symbol: AssetSymbol(assetConfigId: 'FALLBACK'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final price = await repositoryWithFallbacks.getCoinFiatPrice(
          fallbackAssetId,
          fiatCurrency: FiatCurrency.usd,
        );

        expect(price, equals(Decimal.fromInt(102)));

        // Verify that BUSD pair was used instead of USDT
        verify(
          () => mockProviderWithFallbacks.fetchKlines(
            'FALLBACKBUSD',
            any(),
            startUnixTimestampMilliseconds: any(
              named: 'startUnixTimestampMilliseconds',
            ),
            endUnixTimestampMilliseconds: any(
              named: 'endUnixTimestampMilliseconds',
            ),
            limit: 1,
            baseUrl: any(named: 'baseUrl'),
          ),
        ).called(1);
      });

      test(
        'should fetch 24hr price change using USDC when USDT not available',
        () async {
          final mockTicker = Binance24hrTicker(
            symbol: 'ONLYUSDCUSDC',
            priceChange: Decimal.parse('5.0'),
            priceChangePercent: Decimal.parse('5.0'),
            weightedAvgPrice: Decimal.parse('105'),
            prevClosePrice: Decimal.parse('100'),
            lastPrice: Decimal.parse('105'),
            lastQty: Decimal.parse('0.1'),
            bidPrice: Decimal.parse('104.5'),
            bidQty: Decimal.parse('0.1'),
            askPrice: Decimal.parse('105.5'),
            askQty: Decimal.parse('0.1'),
            openPrice: Decimal.parse('100'),
            highPrice: Decimal.parse('106'),
            lowPrice: Decimal.parse('99'),
            volume: Decimal.parse('1000'),
            quoteVolume: Decimal.parse('105000'),
            openTime: DateTime.now()
                .subtract(const Duration(hours: 24))
                .millisecondsSinceEpoch,
            closeTime: DateTime.now().millisecondsSinceEpoch,
            firstId: 1,
            lastId: 10000,
            count: 10000,
          );

          when(
            () => mockProviderWithFallbacks.fetch24hrTicker(
              'ONLYUSDCUSDC',
              baseUrl: any(named: 'baseUrl'),
            ),
          ).thenAnswer((_) async => mockTicker);

          final onlyUsdcAssetId = AssetId(
            id: 'onlyusdccoin',
            name: 'Only USDC Coin',
            symbol: AssetSymbol(assetConfigId: 'ONLYUSDC'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          final priceChange = await repositoryWithFallbacks
              .getCoin24hrPriceChange(
                onlyUsdcAssetId,
                fiatCurrency:
                    Stablecoin.usdt, // Request USDT but should use USDC
              );

          expect(priceChange, equals(Decimal.parse('5.0')));

          // Verify that USDC pair was used instead of USDT
          verify(
            () => mockProviderWithFallbacks.fetch24hrTicker(
              'ONLYUSDCUSDC',
              baseUrl: any(named: 'baseUrl'),
            ),
          ).called(1);
        },
      );

      test(
        'should prefer USDT over other stablecoins when available',
        () async {
          final btcAssetId = AssetId(
            id: 'bitcoin',
            name: 'Bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          // Mock OHLC data for BTCUSDT pair
          final mockOhlc = CoinOhlc(
            ohlc: [
              Ohlc.binance(
                open: Decimal.fromInt(50000),
                high: Decimal.fromInt(51000),
                low: Decimal.fromInt(49000),
                close: Decimal.fromInt(50500),
                openTime: DateTime.now()
                    .subtract(const Duration(days: 1))
                    .millisecondsSinceEpoch,
                closeTime: DateTime.now().millisecondsSinceEpoch,
              ),
            ],
          );

          when(
            () => mockProviderWithFallbacks.fetchKlines(
              'BTCUSDT',
              any(),
              startUnixTimestampMilliseconds: any(
                named: 'startUnixTimestampMilliseconds',
              ),
              endUnixTimestampMilliseconds: any(
                named: 'endUnixTimestampMilliseconds',
              ),
              limit: any(named: 'limit'),
              baseUrl: any(named: 'baseUrl'),
            ),
          ).thenAnswer((_) async => mockOhlc);

          final price = await repositoryWithFallbacks.getCoinFiatPrice(
            btcAssetId,
            fiatCurrency: FiatCurrency.usd,
          );

          expect(price, equals(Decimal.fromInt(50500)));

          // Verify that USDT pair was used (preferred over USDC/BUSD)
          verify(
            () => mockProviderWithFallbacks.fetchKlines(
              'BTCUSDT',
              any(),
              startUnixTimestampMilliseconds: any(
                named: 'startUnixTimestampMilliseconds',
              ),
              endUnixTimestampMilliseconds: any(
                named: 'endUnixTimestampMilliseconds',
              ),
              limit: 1,
              baseUrl: any(named: 'baseUrl'),
            ),
          ).called(1);
        },
      );

      test(
        'should throw error when no suitable USD stablecoin available',
        () async {
          final noUsdAssetId = AssetId(
            id: 'nousdcoin',
            name: 'No USD Coin',
            symbol: AssetSymbol(assetConfigId: 'NOUSD'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          expect(
            () async => await repositoryWithFallbacks.getCoinFiatPrice(
              noUsdAssetId,
              fiatCurrency: FiatCurrency.usd,
            ),
            throwsA(isA<ArgumentError>()),
            reason:
                'Should throw error when no USD stablecoins are available for the coin',
          );
        },
      );
    });

    group('Real-world USD stablecoin priority examples', () {
      late BinanceRepository realWorldRepository;
      late MockIBinanceProvider mockRealWorldProvider;

      setUp(() {
        mockRealWorldProvider = MockIBinanceProvider();
        realWorldRepository = BinanceRepository(
          binanceProvider: mockRealWorldProvider,
          enableMemoization: false,
        );

        // Mock exchange info with real-world example scenarios
        final mockRealWorldExchangeInfo = buildRealWorldExampleExchangeInfo();

        when(
          () => mockRealWorldProvider.fetchExchangeInfoReduced(
            baseUrl: any(named: 'baseUrl'),
          ),
        ).thenAnswer((_) async => mockRealWorldExchangeInfo);
      });

      test(
        'BTC should prefer USDT when available (highest priority)',
        () async {
          final btcAssetId = AssetId(
            id: 'bitcoin',
            name: 'Bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          final supportsUsd = await realWorldRepository.supports(
            btcAssetId,
            FiatCurrency.usd,
            PriceRequestType.currentPrice,
          );

          expect(supportsUsd, isTrue);

          // Mock OHLC for BTCUSDT
          final mockOhlc = CoinOhlc(
            ohlc: [
              Ohlc.binance(
                open: Decimal.fromInt(50000),
                high: Decimal.fromInt(51000),
                low: Decimal.fromInt(49000),
                close: Decimal.fromInt(50500),
                openTime: DateTime.now()
                    .subtract(const Duration(days: 1))
                    .millisecondsSinceEpoch,
                closeTime: DateTime.now().millisecondsSinceEpoch,
              ),
            ],
          );

          when(
            () => mockRealWorldProvider.fetchKlines(
              'BTCUSDT',
              any(),
              startUnixTimestampMilliseconds: any(
                named: 'startUnixTimestampMilliseconds',
              ),
              endUnixTimestampMilliseconds: any(
                named: 'endUnixTimestampMilliseconds',
              ),
              limit: any(named: 'limit'),
              baseUrl: any(named: 'baseUrl'),
            ),
          ).thenAnswer((_) async => mockOhlc);

          final price = await realWorldRepository.getCoinFiatPrice(
            btcAssetId,
            fiatCurrency: FiatCurrency.usd,
          );

          expect(price, equals(Decimal.fromInt(50500)));

          // Verify USDT was chosen over other available stablecoins
          verify(
            () => mockRealWorldProvider.fetchKlines(
              'BTCUSDT',
              any(),
              startUnixTimestampMilliseconds: any(
                named: 'startUnixTimestampMilliseconds',
              ),
              endUnixTimestampMilliseconds: any(
                named: 'endUnixTimestampMilliseconds',
              ),
              limit: 1,
              baseUrl: any(named: 'baseUrl'),
            ),
          ).called(1);
        },
      );

      test('ETH should fallback to USDC when USDT not available', () async {
        final ethAssetId = AssetId(
          id: 'ethereum',
          name: 'Ethereum',
          symbol: AssetSymbol(assetConfigId: 'ETH'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final supportsUsd = await realWorldRepository.supports(
          ethAssetId,
          FiatCurrency.usd,
          PriceRequestType.currentPrice,
        );

        expect(supportsUsd, isTrue);

        // Mock OHLC for ETHUSDC (fallback since ETHUSDT doesn't exist)
        final mockOhlc = CoinOhlc(
          ohlc: [
            Ohlc.binance(
              open: Decimal.fromInt(3000),
              high: Decimal.fromInt(3100),
              low: Decimal.fromInt(2950),
              close: Decimal.fromInt(3050),
              openTime: DateTime.now()
                  .subtract(const Duration(days: 1))
                  .millisecondsSinceEpoch,
              closeTime: DateTime.now().millisecondsSinceEpoch,
            ),
          ],
        );

        when(
          () => mockRealWorldProvider.fetchKlines(
            'ETHUSDC',
            any(),
            startUnixTimestampMilliseconds: any(
              named: 'startUnixTimestampMilliseconds',
            ),
            endUnixTimestampMilliseconds: any(
              named: 'endUnixTimestampMilliseconds',
            ),
            limit: any(named: 'limit'),
            baseUrl: any(named: 'baseUrl'),
          ),
        ).thenAnswer((_) async => mockOhlc);

        final price = await realWorldRepository.getCoinFiatPrice(
          ethAssetId,
          fiatCurrency: FiatCurrency.usd,
        );

        expect(price, equals(Decimal.fromInt(3050)));

        // Verify USDC was chosen as fallback
        verify(
          () => mockRealWorldProvider.fetchKlines(
            'ETHUSDC',
            any(),
            startUnixTimestampMilliseconds: any(
              named: 'startUnixTimestampMilliseconds',
            ),
            endUnixTimestampMilliseconds: any(
              named: 'endUnixTimestampMilliseconds',
            ),
            limit: 1,
            baseUrl: any(named: 'baseUrl'),
          ),
        ).called(1);
      });

      test(
        'BNB should fallback to BUSD when USDT and USDC not available',
        () async {
          final bnbAssetId = AssetId(
            id: 'binancecoin',
            name: 'Binance Coin',
            symbol: AssetSymbol(assetConfigId: 'BNB'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          final supportsUsd = await realWorldRepository.supports(
            bnbAssetId,
            FiatCurrency.usd,
            PriceRequestType.currentPrice,
          );

          expect(supportsUsd, isTrue);

          // Mock OHLC for BNBBUSD (fallback since BNBUSDT and BNBUSDC don't exist)
          final mockOhlc = CoinOhlc(
            ohlc: [
              Ohlc.binance(
                open: Decimal.fromInt(300),
                high: Decimal.fromInt(310),
                low: Decimal.fromInt(295),
                close: Decimal.fromInt(305),
                openTime: DateTime.now()
                    .subtract(const Duration(days: 1))
                    .millisecondsSinceEpoch,
                closeTime: DateTime.now().millisecondsSinceEpoch,
              ),
            ],
          );

          when(
            () => mockRealWorldProvider.fetchKlines(
              'BNBBUSD',
              any(),
              startUnixTimestampMilliseconds: any(
                named: 'startUnixTimestampMilliseconds',
              ),
              endUnixTimestampMilliseconds: any(
                named: 'endUnixTimestampMilliseconds',
              ),
              limit: any(named: 'limit'),
              baseUrl: any(named: 'baseUrl'),
            ),
          ).thenAnswer((_) async => mockOhlc);

          final price = await realWorldRepository.getCoinFiatPrice(
            bnbAssetId,
            fiatCurrency: FiatCurrency.usd,
          );

          expect(price, equals(Decimal.fromInt(305)));

          // Verify BUSD was chosen as fallback
          verify(
            () => mockRealWorldProvider.fetchKlines(
              'BNBBUSD',
              any(),
              startUnixTimestampMilliseconds: any(
                named: 'startUnixTimestampMilliseconds',
              ),
              endUnixTimestampMilliseconds: any(
                named: 'endUnixTimestampMilliseconds',
              ),
              limit: 1,
              baseUrl: any(named: 'baseUrl'),
            ),
          ).called(1);
        },
      );

      test(
        'NOUSDC should not support USD when no USD stablecoins available',
        () async {
          final noUsdAssetId = AssetId(
            id: 'nousdccoin',
            name: 'No USDC Coin',
            symbol: AssetSymbol(assetConfigId: 'NOUSDC'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          final supportsUsd = await realWorldRepository.supports(
            noUsdAssetId,
            FiatCurrency.usd,
            PriceRequestType.currentPrice,
          );

          expect(
            supportsUsd,
            isFalse,
            reason:
                'NOUSDC should not support USD as it has no USD stablecoins (only EUR, GBP, JPY)',
          );
        },
      );

      test(
        'should maintain existing behavior for non-USD currencies (EUR exact match required)',
        () async {
          final bnbAssetId = AssetId(
            id: 'binancecoin',
            name: 'Binance Coin',
            symbol: AssetSymbol(assetConfigId: 'BNB'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          // BNB doesn't have EUR pair in our test data
          final supportsEur = await realWorldRepository.supports(
            bnbAssetId,
            FiatCurrency.eur,
            PriceRequestType.currentPrice,
          );

          expect(
            supportsEur,
            isFalse,
            reason:
                'BNB should not support EUR as exact match is required for non-USD currencies',
          );

          // But NOUSDC does have EUR pair
          final noUsdAssetId = AssetId(
            id: 'nousdccoin',
            name: 'No USDC Coin',
            symbol: AssetSymbol(assetConfigId: 'NOUSDC'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          final noUsdSupportsEur = await realWorldRepository.supports(
            noUsdAssetId,
            FiatCurrency.eur,
            PriceRequestType.currentPrice,
          );

          expect(
            noUsdSupportsEur,
            isTrue,
            reason: 'NOUSDC should support EUR as it has direct EUR pair',
          );
        },
      );

      test(
        'should provide access to USD stablecoin priority configuration',
        () {
          final priority = BinanceRepository.usdStablecoinPriority;

          // Verify configuration is accessible
          expect(priority, isNotEmpty);

          // Verify expected top priorities are present and in correct order
          expect(priority.first, equals('USDT'));
          expect(priority[1], equals('USDC'));
          expect(priority[2], equals('BUSD'));

          // Verify the list is immutable
          expect(() => priority.add('TEST'), throwsA(isA<UnsupportedError>()));

          // Verify all expected stablecoins are present
          const expectedStablecoins = [
            'USDT',
            'USDC',
            'BUSD',
            'FDUSD',
            'TUSD',
            'USDP',
            'DAI',
            'LUSD',
            'GUSD',
            'SUSD',
            'FEI',
          ];

          for (final stablecoin in expectedStablecoins) {
            expect(
              priority.contains(stablecoin),
              isTrue,
              reason: 'Priority list should contain $stablecoin',
            );
          }
        },
      );

      test(
        'should provide detailed ArgumentError messages with value and name',
        () async {
          final invalidAssetId = AssetId(
            id: 'invalidcoin',
            name: 'Invalid Coin',
            symbol: AssetSymbol(assetConfigId: 'INVALID'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          try {
            await realWorldRepository.getCoinFiatPrice(
              invalidAssetId,
              fiatCurrency: FiatCurrency.usd,
            );
            fail('Should have thrown ArgumentError');
          } catch (e) {
            expect(e, isA<ArgumentError>());
            final error = e as ArgumentError;
            expect(error.name, equals('assetId'));
            expect(error.invalidValue, equals('INVALID'));
            expect(error.message, contains('Asset not found'));
          }
        },
      );
    });
  });
}
