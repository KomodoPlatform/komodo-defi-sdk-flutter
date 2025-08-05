import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockKomodoPriceProvider extends Mock implements IKomodoPriceProvider {}

void main() {
  group('KomodoPriceRepository', () {
    late MockKomodoPriceProvider provider;
    late KomodoPriceRepository repository;

    setUp(() {
      provider = MockKomodoPriceProvider();
      repository = KomodoPriceRepository(cexPriceProvider: provider);
    });

    AssetId asset(String id) => AssetId(
      id: id,
      name: id,
      symbol: AssetSymbol(assetConfigId: id),
      chainId: AssetChainId(chainId: 0),
      derivationPath: null,
      subClass: CoinSubClass.utxo,
    );

    test('supports returns true for supported asset and fiat', () async {
      when(
        () => provider.getKomodoPrices(),
      ).thenAnswer((_) async => {'KMD': CexPrice(ticker: 'KMD', price: 1.0)});

      final result = await repository.supports(
        asset('KMD'),
        AssetId.fromFiatTicker('usd'),
        PriceRequestType.currentPrice,
      );

      expect(result, isTrue);
    });

    test('supports returns false for unsupported asset', () async {
      when(
        () => provider.getKomodoPrices(),
      ).thenAnswer((_) async => {'BTC': CexPrice(ticker: 'BTC', price: 1.0)});

      final result = await repository.supports(
        asset('KMD'),
        AssetId.fromFiatTicker('usd'),
        PriceRequestType.currentPrice,
      );

      expect(result, isFalse);
    });
  });
}
