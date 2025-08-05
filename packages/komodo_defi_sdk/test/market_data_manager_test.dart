import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_sdk/src/market_data/market_data_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockKomodoPriceRepository extends Mock
    implements IKomodoPriceRepository {}

class MockCexRepository extends Mock implements CexRepository {}

void main() {
  group('CexMarketDataManager', () {
    AssetId asset(String id) => AssetId(
      id: id,
      name: id,
      symbol: AssetSymbol(assetConfigId: id),
      chainId: AssetChainId(chainId: 0),
      derivationPath: null,
      subClass: CoinSubClass.utxo,
    );

    test('prefers KomodoPriceRepository when supported', () async {
      final komodo = MockKomodoPriceRepository();
      final fallback = MockCexRepository();
      final manager = CexMarketDataManager(
        priceRepositories: [fallback],
        komodoPriceRepository: komodo,
        selectionStrategy: DefaultRepositorySelectionStrategy(),
        timerFactory: (d, cb) => Timer(d, cb),
      );

      when(() => komodo.getCoinList()).thenAnswer(
        (_) async => [
          CexCoin(
            id: 'BTC',
            symbol: 'BTC',
            name: 'BTC',
            currencies: {'USDT'},
            source: 'komodo',
          ),
        ],
      );
      when(
        () => komodo.getCoinFiatPrice(
          asset('BTC'),
          priceDate: null,
          fiatCoinId: 'usdt',
        ),
      ).thenAnswer((_) async => 2.0);
      when(() => fallback.getCoinList()).thenAnswer(
        (_) async => [
          CexCoin(
            id: 'BTC',
            symbol: 'BTC',
            name: 'BTC',
            currencies: {'USDT'},
            source: 'fallback',
          ),
        ],
      );
      when(
        () => fallback.getCoinFiatPrice(
          asset('BTC'),
          priceDate: null,
          fiatCoinId: 'usdt',
        ),
      ).thenAnswer((_) async => 3.0);

      await manager.init();
      final price = await manager.fiatPrice(asset('BTC'));
      expect(price, Decimal.parse('2.0'));
      verify(
        () => komodo.getCoinFiatPrice(
          asset('BTC'),
          priceDate: null,
          fiatCoinId: 'usdt',
        ),
      ).called(1);
      verifyNever(
        () => fallback.getCoinFiatPrice(
          asset('BTC'),
          priceDate: null,
          fiatCoinId: 'usdt',
        ),
      );
    });

    test(
      'falls back when Komodo repository unsupported and caches results',
      () async {
        final komodo = MockKomodoPriceRepository();
        final fallback = MockCexRepository();
        final manager = CexMarketDataManager(
          priceRepositories: [fallback],
          komodoPriceRepository: komodo,
          selectionStrategy: DefaultRepositorySelectionStrategy(),
          timerFactory: (d, cb) => Timer(d, cb),
        );

        when(() => komodo.getCoinList()).thenAnswer((_) async => []);
        when(() => fallback.getCoinList()).thenAnswer(
          (_) async => [
            CexCoin(
              id: 'BTC',
              symbol: 'BTC',
              name: 'BTC',
              currencies: {'USDT'},
              source: 'fallback',
            ),
          ],
        );
        when(
          () => fallback.getCoinFiatPrice(
            asset('BTC'),
            priceDate: null,
            fiatCoinId: 'usdt',
          ),
        ).thenAnswer((_) async => 3.0);

        await manager.init();
        final first = await manager.fiatPrice(asset('BTC'));
        final second = await manager.fiatPrice(asset('BTC'));

        expect(first, Decimal.parse('3.0'));
        expect(second, Decimal.parse('3.0'));
        verify(
          () => fallback.getCoinFiatPrice(
            asset('BTC'),
            priceDate: null,
            fiatCoinId: 'usdt',
          ),
        ).called(1);

        await manager.dispose();
        expect(() => manager.priceIfKnown(asset('BTC')), throwsStateError);
      },
    );
  });
}
