import 'package:komodo_cex_market_data/src/komodo/prices/komodo_price_provider.dart';
import 'package:komodo_cex_market_data/src/komodo/prices/komodo_price_repository.dart';
import 'package:test/test.dart';

void main() {
  late KomodoPriceRepository cexPriceRepository;
  setUp(() {
    cexPriceRepository = KomodoPriceRepository(
      cexPriceProvider: KomodoPriceProvider(),
    );
  });

  group('getCoinList', () {
    test('should return coin list', () async {
      // Arrange

      // Act
      final result = await cexPriceRepository.getCoinList();

      // Assert
      expect(result.length, greaterThan(0));
      expect(result.any((coin) => coin.id == 'KMD'), isTrue);
    });
  });
}
