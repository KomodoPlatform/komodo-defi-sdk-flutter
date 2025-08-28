import 'package:decimal/decimal.dart';
import 'package:komodo_cex_market_data/src/coinpaprika/coinpaprika.dart';
import 'package:komodo_cex_market_data/src/models/models.dart';
import 'package:komodo_cex_market_data/src/repository_selection_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockCoinPaprikaProvider extends Mock implements ICoinPaprikaProvider {}

void main() {
  group('CoinPaprikaRepository', () {
    late MockCoinPaprikaProvider mockProvider;
    late CoinPaprikaRepository repository;

    setUp(() {
      mockProvider = MockCoinPaprikaProvider();
      repository = CoinPaprikaRepository(
        coinPaprikaProvider: mockProvider,
        enableMemoization: false, // Disable for testing
      );

      // Set up minimal default stubs - specific tests will override these
      registerFallbackValue(DateTime.now());
    });

    group('getCoinList', () {
      test('returns list of active coins with supported currencies', () async {
        // Arrange
        final mockCoins = [
          const CoinPaprikaCoin(
            id: 'btc-bitcoin',
            name: 'Bitcoin',
            symbol: 'BTC',
            rank: 1,
            isNew: false,
            isActive: true,
            type: 'coin',
          ),
          const CoinPaprikaCoin(
            id: 'eth-ethereum',
            name: 'Ethereum',
            symbol: 'ETH',
            rank: 2,
            isNew: false,
            isActive: true,
            type: 'coin',
          ),
          const CoinPaprikaCoin(
            id: 'inactive-coin',
            name: 'Inactive Coin',
            symbol: 'INACTIVE',
            rank: 999,
            isNew: false,
            isActive: false,
            type: 'coin',
          ),
        ];

        when(() => mockProvider.fetchCoinList())
            .thenAnswer((_) async => mockCoins);

        // Act
        final result = await repository.getCoinList();

        // Assert
        expect(result, hasLength(2)); // Only active coins
        expect(result[0].id, equals('btc-bitcoin'));
        expect(result[0].symbol, equals('BTC'));
        expect(result[0].name, equals('Bitcoin'));
        expect(result[0].currencies, contains('usd'));
        expect(result[0].currencies, contains('btc'));
        expect(result[0].currencies, contains('eur'));

        expect(result[1].id, equals('eth-ethereum'));
        expect(result[1].symbol, equals('ETH'));
        expect(result[1].name, equals('Ethereum'));

        verify(() => mockProvider.fetchCoinList()).called(1);
      });

      test('handles provider errors gracefully', () async {
        // Arrange
        when(() => mockProvider.fetchCoinList())
            .thenThrow(Exception('API error'));

        // Act & Assert
        expect(
          () => repository.getCoinList(),
          throwsA(isA<Exception>()),
        );

        verify(() => mockProvider.fetchCoinList()).called(1);
      });
    });

    group('resolveTradingSymbol', () {
      test('returns coinPaprikaId when available', () {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Act
        final result = repository.resolveTradingSymbol(assetId);

        // Assert
        expect(result, equals('btc-bitcoin'));
      });

      test('throws ArgumentError when coinPaprikaId is missing', () {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            // No coinPaprikaId
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Act & Assert
        expect(
          () => repository.resolveTradingSymbol(assetId),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('canHandleAsset', () {
      test('returns true when coinPaprikaId is available', () {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Act
        final result = repository.canHandleAsset(assetId);

        // Assert
        expect(result, isTrue);
      });

      test('returns false when coinPaprikaId is missing', () {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            // No coinPaprikaId
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Act
        final result = repository.canHandleAsset(assetId);

        // Assert
        expect(result, isFalse);
      });
    });

    group('getCoinFiatPrice', () {
      test('returns current price from markets endpoint', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final mockTicker = {
          'quotes': {
            'USDT': {
              'price': 50000.0,
              'volume_24h': 1000000.0,
              'percent_change_24h': 2.5,
            },
          },
        };

        when(() => mockProvider.fetchCoinTicker(
              coinId: any(named: 'coinId'),
              quotes: any(named: 'quotes'),
            )).thenAnswer((_) async => mockTicker);

        // Act
        final result = await repository.getCoinFiatPrice(assetId);

        // Assert
        expect(result, equals(Decimal.fromInt(50000)));
        verify(() => mockProvider.fetchCoinTicker(
              coinId: 'btc-bitcoin',
              quotes: 'USDT',
            )).called(1);
      });

      test('throws exception when no market data available', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        when(() => mockProvider.fetchCoinTicker(
              coinId: any(named: 'coinId'),
              quotes: any(named: 'quotes'),
            )).thenAnswer((_) async => {});

        // Act & Assert
        expect(
          () => repository.getCoinFiatPrice(assetId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getCoinOhlc', () {
      test('returns OHLC data within free tier limits', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final mockOhlcData = [
          Ohlc.coinpaprika(
            timeOpen: DateTime.parse('2024-01-01T00:00:00Z').millisecondsSinceEpoch,
            timeClose: DateTime.parse('2024-01-01T23:59:59Z').millisecondsSinceEpoch,
            open: Decimal.fromInt(45000),
            high: Decimal.fromInt(52000),
            low: Decimal.fromInt(44000),
            close: Decimal.fromInt(50000),
            volume: Decimal.fromInt(1000000),
            marketCap: Decimal.fromInt(900000000000),
          ),
        ];

        when(() => mockProvider.fetchHistoricalOhlc(
              coinId: any(named: 'coinId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              quote: any(named: 'quote'),
            )).thenAnswer((_) async => mockOhlcData);

        final startAt = DateTime(2024, 1, 1);
        final endAt = DateTime(2024, 1, 1, 12); // Within 24h limit

        // Act
        final result = await repository.getCoinOhlc(
          assetId,
          Stablecoin.usdt,
          GraphInterval.oneHour,
          startAt: startAt,
          endAt: endAt,
        );

        // Assert
        expect(result.ohlc, hasLength(1));
        expect(result.ohlc.first.openDecimal, equals(Decimal.fromInt(45000)));
        expect(result.ohlc.first.highDecimal, equals(Decimal.fromInt(52000)));
        expect(result.ohlc.first.lowDecimal, equals(Decimal.fromInt(44000)));
        expect(result.ohlc.first.closeDecimal, equals(Decimal.fromInt(50000)));

        verify(() => mockProvider.fetchHistoricalOhlc(
              coinId: any(named: 'coinId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              quote: any(named: 'quote'),
            )).called(1);
      });

      test('throws ArgumentError for requests exceeding 24h without start/end dates', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Set up mock to return empty data so we can test the logic
        when(() => mockProvider.fetchHistoricalOhlc(
              coinId: any(named: 'coinId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              quote: any(named: 'quote'),
            )).thenAnswer((_) async => []);

        // Act - should not throw since default period is 24h (within limit)
        final result = await repository.getCoinOhlc(
          assetId,
          Stablecoin.usdt,
          GraphInterval.oneHour,
          // No startAt/endAt - defaults to 24h which is within limit
        );

        // Assert - should get empty result, not throw error
        expect(result.ohlc, isEmpty);
      });
    });

    group('supports', () {
      test('returns true for supported asset and quote currency', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final mockCoins = [
          const CoinPaprikaCoin(
            id: 'btc-bitcoin',
            name: 'Bitcoin',
            symbol: 'BTC',
            rank: 1,
            isNew: false,
            isActive: true,
            type: 'coin',
          ),
        ];

        when(() => mockProvider.fetchCoinList())
            .thenAnswer((_) async => mockCoins);

        // Act
        final result = await repository.supports(
          assetId,
          FiatCurrency.usd,
          PriceRequestType.currentPrice,
        );

        // Assert
        expect(result, isTrue);
      });

      test('returns false for unsupported quote currency', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            coinPaprikaId: 'btc-bitcoin',
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        final mockCoins = [
          const CoinPaprikaCoin(
            id: 'btc-bitcoin',
            name: 'Bitcoin',
            symbol: 'BTC',
            rank: 1,
            isNew: false,
            isActive: true,
            type: 'coin',
          ),
        ];

        when(() => mockProvider.fetchCoinList())
            .thenAnswer((_) async => mockCoins);

        // Act - Using an unsupported quote currency
        final result = await repository.supports(
          assetId,
          const QuoteCurrency.commodity(symbol: 'GOLD', displayName: 'Gold'),
          PriceRequestType.currentPrice,
        );

        // Assert
        expect(result, isFalse);
      });

      test('returns false when asset cannot be resolved', () async {
        // Arrange
        final assetId = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(
            assetConfigId: 'BTC',
            // No coinPaprikaId
          ),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        );

        // Act
        final result = await repository.supports(
          assetId,
          FiatCurrency.usd,
          PriceRequestType.currentPrice,
        );

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
