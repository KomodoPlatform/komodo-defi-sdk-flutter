import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockBinanceRepository extends Mock implements BinanceRepository {}

class MockCoinGeckoRepository extends Mock implements CoinGeckoRepository {}

void main() {
  group('RepositorySelectionStrategy', () {
    late RepositorySelectionStrategy strategy;
    late MockBinanceRepository binance;
    late MockCoinGeckoRepository gecko;

    setUp(() {
      strategy = DefaultRepositorySelectionStrategy();
      binance = MockBinanceRepository();
      gecko = MockCoinGeckoRepository();
    });

    test('selects repository based on priority', () async {
      final asset = AssetId(
        id: 'BTC',
        name: 'BTC',
        symbol: AssetSymbol(assetConfigId: 'BTC'),
        chainId: AssetChainId(chainId: 0),
        derivationPath: null,
        subClass: CoinSubClass.utxo,
      );
      final fiat = FiatCurrency.usd;

      when(() => binance.getCoinList()).thenAnswer(
        (_) async => [
          CexCoin(
            id: 'BTC',
            symbol: 'BTC',
            name: 'BTC',
            currencies: {'USD'},
            source: 'binance',
          ),
        ],
      );
      when(() => gecko.getCoinList()).thenAnswer(
        (_) async => [
          CexCoin(
            id: 'BTC',
            symbol: 'BTC',
            name: 'BTC',
            currencies: {'USD'},
            source: 'gecko',
          ),
        ],
      );

      final repo = await strategy.selectRepository(
        assetId: asset,
        fiatCurrency: fiat,
        requestType: PriceRequestType.currentPrice,
        availableRepositories: [gecko, binance],
      );

      expect(repo, equals(binance));
    });
  });
}
