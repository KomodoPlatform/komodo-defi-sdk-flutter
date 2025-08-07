import 'package:komodo_cex_market_data/src/coingecko/coingecko.dart';
import 'package:komodo_cex_market_data/src/models/models.dart';
import 'package:komodo_cex_market_data/src/repository_selection_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockICoinGeckoProvider extends Mock implements ICoinGeckoProvider {}

void main() {
  group('CoinGeckoRepository', () {
    late CoinGeckoRepository repository;
    late MockICoinGeckoProvider mockProvider;

    setUp(() {
      mockProvider = MockICoinGeckoProvider();
      repository = CoinGeckoRepository(
        coinGeckoProvider: mockProvider,
        enableMemoization: false, // Disable for testing
      );
    });

    group('getCoinOhlc 365-day limit handling', () {
      test('should make single request when within 365-day limit', () async {
        final startAt = DateTime(2023);
        final endAt = DateTime(2023, 12, 31); // 364 days
        final mockOhlc = CoinOhlc(
          ohlc: [
            Ohlc(
              open: 100,
              high: 110,
              low: 90,
              close: 105,
              openTime: startAt.millisecondsSinceEpoch,
              closeTime: endAt.millisecondsSinceEpoch,
            ),
          ],
        );

        when(
          () => mockProvider.fetchCoinOhlc(any(), any(), any()),
        ).thenAnswer((_) async => mockOhlc);

        final result = await repository.getCoinOhlc(
          const CexCoinPair(baseCoinTicker: 'bitcoin', relCoinTicker: 'usd'),
          GraphInterval.oneDay,
          startAt: startAt,
          endAt: endAt,
        );

        expect(result.ohlc.length, equals(1));
        // Verify only one call was made
        verify(
          () => mockProvider.fetchCoinOhlc('bitcoin', 'usd', any()),
        ).called(1);
      });

      test('should split requests when exceeding 365-day limit', () async {
        final startAt = DateTime(2022);
        final endAt = DateTime(2024); // More than 365 days
        final mockOhlc = CoinOhlc(
          ohlc: [
            Ohlc(
              open: 100,
              high: 110,
              low: 90,
              close: 105,
              openTime: startAt.millisecondsSinceEpoch,
              closeTime: endAt.millisecondsSinceEpoch,
            ),
          ],
        );

        when(
          () => mockProvider.fetchCoinOhlc(any(), any(), any()),
        ).thenAnswer((_) async => mockOhlc);

        final result = await repository.getCoinOhlc(
          const CexCoinPair(baseCoinTicker: 'bitcoin', relCoinTicker: 'usd'),
          GraphInterval.oneDay,
          startAt: startAt,
          endAt: endAt,
        );

        // Should have made multiple calls and combined the results
        expect(result.ohlc.length, greaterThan(1));

        // Verify multiple calls were made (should be at least 2 for 2+ years)
        verify(
          () => mockProvider.fetchCoinOhlc('bitcoin', 'usd', any()),
        ).called(greaterThan(1));
      });

      test('should handle requests exactly at 365-day limit', () async {
        final startAt = DateTime(2023);
        final endAt = DateTime(2024); // Exactly 365 days
        final mockOhlc = CoinOhlc(
          ohlc: [
            Ohlc(
              open: 100,
              high: 110,
              low: 90,
              close: 105,
              openTime: startAt.millisecondsSinceEpoch,
              closeTime: endAt.millisecondsSinceEpoch,
            ),
          ],
        );

        when(
          () => mockProvider.fetchCoinOhlc(any(), any(), any()),
        ).thenAnswer((_) async => mockOhlc);

        final result = await repository.getCoinOhlc(
          const CexCoinPair(baseCoinTicker: 'bitcoin', relCoinTicker: 'usd'),
          GraphInterval.oneDay,
          startAt: startAt,
          endAt: endAt,
        );

        expect(result.ohlc.length, equals(1));
        // Should make only one call at the limit
        verify(
          () => mockProvider.fetchCoinOhlc('bitcoin', 'usd', 365),
        ).called(1);
      });
    });

    group('USD equivalent currency support', () {
      setUp(() {
        // Mock the coin list response
        when(() => mockProvider.fetchCoinList()).thenAnswer(
          (_) async => [
            const CexCoin(
              id: 'bitcoin',
              symbol: 'btc',
              name: 'Bitcoin',
              currencies: {},
            ),
            const CexCoin(
              id: 'ethereum',
              symbol: 'eth',
              name: 'Ethereum',
              currencies: {},
            ),
          ],
        );

        // Mock supported currencies including USD
        when(
          () => mockProvider.fetchSupportedVsCurrencies(),
        ).thenAnswer((_) async => ['usd', 'eur', 'gbp', 'jpy', 'btc', 'eth']);
      });

      test('should support USD fiat currency', () async {
        final assetId = AssetId(
          id: 'bitcoin',
          name: 'Bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC', coinGeckoId: 'bitcoin'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );
        final supports = await repository.supports(
          assetId,
          FiatCurrency.usd,
          PriceRequestType.currentPrice,
        );

        expect(supports, isTrue);
      });

      test(
        'should support all USD-pegged stablecoins via USD mapping',
        () async {
          final assetId = AssetId(
            id: 'bitcoin',
            name: 'Bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC', coinGeckoId: 'bitcoin'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          final usdStablecoins = [
            Stablecoin.usdt,
            Stablecoin.usdc,
            Stablecoin.busd,
            Stablecoin.dai,
            Stablecoin.tusd,
            Stablecoin.frax,
            Stablecoin.lusd,
            Stablecoin.gusd,
            Stablecoin.usdp,
            Stablecoin.susd,
            Stablecoin.fei,
            Stablecoin.tribe,
            Stablecoin.ust,
            Stablecoin.ustc,
          ];

          for (final stablecoin in usdStablecoins) {
            final supports = await repository.supports(
              assetId,
              stablecoin,
              PriceRequestType.currentPrice,
            );

            expect(
              supports,
              isTrue,
              reason:
                  '${stablecoin.symbol} should be supported via USD mapping',
            );
          }
        },
      );

      test('should support EUR-pegged stablecoins via EUR mapping', () async {
        final assetId = AssetId(
          id: 'bitcoin',
          name: 'Bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC', coinGeckoId: 'bitcoin'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final eurStablecoins = [
          Stablecoin.eurs,
          Stablecoin.eurt,
          Stablecoin.jeur,
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
            reason: '${stablecoin.symbol} should be supported via EUR mapping',
          );
        }
      });

      test('should support GBP-pegged stablecoins via GBP mapping', () async {
        final assetId = AssetId(
          id: 'bitcoin',
          name: 'Bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC', coinGeckoId: 'bitcoin'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final supports = await repository.supports(
          assetId,
          Stablecoin.gbpt,
          PriceRequestType.currentPrice,
        );

        expect(
          supports,
          isTrue,
          reason: 'GBPT should be supported via GBP mapping',
        );
      });

      test(
        'should not support currency when underlying fiat is not supported',
        () async {
          // Mock supported currencies without JPY and without USD to prevent fallback
          when(
            () => mockProvider.fetchSupportedVsCurrencies(),
          ).thenAnswer((_) async => ['eur', 'gbp']);

          final repository = CoinGeckoRepository(
            coinGeckoProvider: mockProvider,
            enableMemoization: false,
          );

          final assetId = AssetId(
            id: 'bitcoin',
            name: 'Bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC', coinGeckoId: 'bitcoin'),
            chainId: AssetChainId(chainId: 0),
            derivationPath: null,
            subClass: CoinSubClass.utxo,
          );

          final supports = await repository.supports(
            assetId,
            Stablecoin.jpyt,
            PriceRequestType.currentPrice,
          );

          expect(
            supports,
            isFalse,
            reason: 'JPYT should not be supported when JPY is not supported',
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
          FiatCurrency.usd,
          PriceRequestType.currentPrice,
        );

        expect(
          supports,
          isFalse,
          reason: 'Unknown asset should not be supported',
        );
      });

      test('should handle cryptocurrency quote currencies', () async {
        final assetId = AssetId(
          id: 'ethereum',
          name: 'Ethereum',
          symbol: AssetSymbol(assetConfigId: 'ETH', coinGeckoId: 'ethereum'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.erc20,
        );

        final supports = await repository.supports(
          assetId,
          Cryptocurrency.btc,
          PriceRequestType.currentPrice,
        );

        expect(
          supports,
          isTrue,
          reason: 'BTC should be supported as quote currency',
        );
      });
    });

    group('_mapFiatCurrencyToCoingecko mapping verification', () {
      test('should map USD stablecoins to usd', () {
        // This verifies the mapping indirectly through coinGeckoId
        expect(Stablecoin.usdt.coinGeckoId, equals('usd'));
        expect(Stablecoin.usdc.coinGeckoId, equals('usd'));
        expect(Stablecoin.busd.coinGeckoId, equals('usd'));
        expect(Stablecoin.dai.coinGeckoId, equals('usd'));
        expect(Stablecoin.tusd.coinGeckoId, equals('usd'));
        expect(Stablecoin.frax.coinGeckoId, equals('usd'));
        expect(Stablecoin.lusd.coinGeckoId, equals('usd'));
        expect(Stablecoin.gusd.coinGeckoId, equals('usd'));
        expect(Stablecoin.usdp.coinGeckoId, equals('usd'));
        expect(Stablecoin.susd.coinGeckoId, equals('usd'));
        expect(Stablecoin.fei.coinGeckoId, equals('usd'));
        expect(Stablecoin.tribe.coinGeckoId, equals('usd'));
        expect(Stablecoin.ust.coinGeckoId, equals('usd'));
        expect(Stablecoin.ustc.coinGeckoId, equals('usd'));
      });

      test('should map EUR stablecoins to eur', () {
        expect(Stablecoin.eurs.coinGeckoId, equals('eur'));
        expect(Stablecoin.eurt.coinGeckoId, equals('eur'));
        expect(Stablecoin.jeur.coinGeckoId, equals('eur'));
      });

      test('should map fiat currencies to lowercase symbols', () {
        expect(FiatCurrency.usd.coinGeckoId, equals('usd'));
        expect(FiatCurrency.eur.coinGeckoId, equals('eur'));
        expect(FiatCurrency.gbp.coinGeckoId, equals('gbp'));
      });

      test('should handle Turkish Lira special case', () {
        expect(FiatCurrency.tryLira.coinGeckoId, equals('try'));
      });
    });
  });
}
