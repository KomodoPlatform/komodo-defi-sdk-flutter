import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_cex_market_data/src/binance/models/binance_24hr_ticker.dart';
import 'package:komodo_cex_market_data/src/binance/models/binance_exchange_info_reduced.dart';
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
            Stablecoin.frax, // FRAX
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
            Ohlc(
              open: 50000,
              high: 51000,
              low: 49000,
              close: 50500,
              openTime:
                  DateTime.now()
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
          openTime:
              DateTime.now()
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
  });
}
