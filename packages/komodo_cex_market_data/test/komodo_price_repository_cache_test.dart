import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockKomodoPriceProvider extends Mock implements IKomodoPriceProvider {}

void main() {
  group('KomodoPriceRepository Cache Tests', () {
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

    test(
      'should cache prices and not call provider multiple times within cache lifetime',
      () async {
        final mockPrices = {
          'KMD': AssetMarketInformation(
            ticker: 'KMD',
            lastPrice: Decimal.fromInt(100),
            change24h: Decimal.fromInt(5),
          ),
        };

        when(
          () => provider.getKomodoPrices(),
        ).thenAnswer((_) async => mockPrices);

        // First call should hit the provider
        final price1 = await repository.getCoinFiatPrice(asset('KMD'));

        // Second call should use cache, not hit the provider again
        final price2 = await repository.getCoinFiatPrice(asset('KMD'));

        // Third call should also use cache
        final price3 = await repository.getCoin24hrPriceChange(asset('KMD'));

        expect(price1, equals(Decimal.fromInt(100)));
        expect(price2, equals(Decimal.fromInt(100)));
        expect(price3, equals(Decimal.fromInt(5)));

        // Verify the provider was only called once
        verify(() => provider.getKomodoPrices()).called(1);
      },
    );

    test(
      'should clear cache and fetch fresh data when clearCache is called',
      () async {
        final mockPrices1 = {
          'KMD': AssetMarketInformation(
            ticker: 'KMD',
            lastPrice: Decimal.fromInt(100),
          ),
        };

        final mockPrices2 = {
          'KMD': AssetMarketInformation(
            ticker: 'KMD',
            lastPrice: Decimal.fromInt(200),
          ),
        };

        // Set up sequential responses
        when(
          () => provider.getKomodoPrices(),
        ).thenAnswer((_) async => mockPrices1);

        // First call
        final price1 = await repository.getCoinFiatPrice(asset('KMD'));
        expect(price1, equals(Decimal.fromInt(100)));

        // Clear cache and update mock for second call
        repository.clearCache();
        when(
          () => provider.getKomodoPrices(),
        ).thenAnswer((_) async => mockPrices2);

        // Second call should fetch fresh data
        final price2 = await repository.getCoinFiatPrice(asset('KMD'));
        expect(price2, equals(Decimal.fromInt(200)));

        // Verify the provider was called twice
        verify(() => provider.getKomodoPrices()).called(2);
      },
    );

    test('should cache coin list and not call provider multiple times', () async {
      final mockPrices = {
        'KMD': AssetMarketInformation(ticker: 'KMD', lastPrice: Decimal.one),
        'BTC': AssetMarketInformation(
          ticker: 'BTC',
          lastPrice: Decimal.fromInt(50000),
        ),
      };

      when(
        () => provider.getKomodoPrices(),
      ).thenAnswer((_) async => mockPrices);

      // First call should hit the provider
      final coinList1 = await repository.getCoinList();

      // Second call should use cached data
      final coinList2 = await repository.getCoinList();

      expect(coinList1.length, equals(2));
      expect(coinList2.length, equals(2));
      expect(coinList1.map((c) => c.id).toSet(), equals({'KMD', 'BTC'}));

      // Verify the provider was only called once (for the first getCoinList call)
      verify(() => provider.getKomodoPrices()).called(1);
    });
  });
}
