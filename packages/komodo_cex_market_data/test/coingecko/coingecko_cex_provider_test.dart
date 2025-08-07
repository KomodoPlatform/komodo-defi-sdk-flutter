import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:test/test.dart';

void main() {
  group('Coingecko CEX provider tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('fetchCoinList test', () async {
      // Arrange
      final provider = CoinGeckoCexProvider();

      // Act
      final result = await provider.fetchCoinList();

      // Assert
      expect(result, isA<List<CexCoin>>());
      expect(result.length, greaterThan(0));
    });

    test('fetchCoinMarketData test', () async {
      // Arrange
      final provider = CoinGeckoCexProvider();

      // Act
      final result = await provider.fetchCoinMarketData();

      // Assert
      expect(result, isA<List<CoinMarketData>>());
      expect(result.length, greaterThan(0));
    });

    test('fetchCoinMarketChart test', () async {
      // Arrange
      final provider = CoinGeckoCexProvider();

      // Use timestamps from 7 days ago to 3 days ago (within 365-day limit)
      final now = DateTime.now();
      final fromDate = now.subtract(const Duration(days: 7));
      final toDate = now.subtract(const Duration(days: 3));
      final fromUnixTimestamp = fromDate.millisecondsSinceEpoch ~/ 1000;
      final toUnixTimestamp = toDate.millisecondsSinceEpoch ~/ 1000;

      // Act
      final result = await provider.fetchCoinMarketChart(
        id: 'bitcoin',
        vsCurrency: 'usd',
        fromUnixTimestamp: fromUnixTimestamp,
        toUnixTimestamp: toUnixTimestamp,
      );

      // Assert
      expect(result, isA<CoinMarketChart>());
      expect(result.prices, isA<List<List<num>>>());
      expect(result.prices.length, greaterThan(0));
      expect(result.marketCaps, isA<List<List<num>>>());
      expect(result.marketCaps.length, greaterThan(0));
      expect(result.totalVolumes, isA<List<List<num>>>());
      expect(result.totalVolumes.length, greaterThan(0));
    });

    test(
      'fetchCoinMarketChart handles large time ranges within constraints',
      () async {
        // Arrange
        final provider = CoinGeckoCexProvider();

        // Use timestamps that are close to the maximum allowed range but within constraints
        // This tests the splitting functionality without exceeding API limits
        final now = DateTime.now();
        final fromDate = now.subtract(const Duration(days: 350));
        final toDate = now.subtract(const Duration(days: 7));
        final fromUnixTimestamp = fromDate.millisecondsSinceEpoch ~/ 1000;
        final toUnixTimestamp = toDate.millisecondsSinceEpoch ~/ 1000;

        // Act
        final result = await provider.fetchCoinMarketChart(
          id: 'bitcoin',
          vsCurrency: 'usd',
          fromUnixTimestamp: fromUnixTimestamp,
          toUnixTimestamp: toUnixTimestamp,
        );

        // Assert
        expect(result, isA<CoinMarketChart>());
        expect(result.prices, isA<List<List<num>>>());
        expect(result.prices.length, greaterThan(0));
        expect(result.marketCaps, isA<List<List<num>>>());
        expect(result.marketCaps.length, greaterThan(0));
        expect(result.totalVolumes, isA<List<List<num>>>());
        expect(result.totalVolumes.length, greaterThan(0));
      },
    );

    test(
      'fetchCoinMarketChart validates historical data access limit',
      () async {
        // Arrange
        final provider = CoinGeckoCexProvider();

        // Use timestamps that exceed the 365-day historical limit
        final now = DateTime.now();
        final fromDate = now.subtract(const Duration(days: 400));
        final toDate = now.subtract(const Duration(days: 390));
        final fromUnixTimestamp = fromDate.millisecondsSinceEpoch ~/ 1000;
        final toUnixTimestamp = toDate.millisecondsSinceEpoch ~/ 1000;

        // Act & Assert
        expect(
          () => provider.fetchCoinMarketChart(
            id: 'bitcoin',
            vsCurrency: 'usd',
            fromUnixTimestamp: fromUnixTimestamp,
            toUnixTimestamp: toUnixTimestamp,
          ),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('fetchCoinOhlc validates 365-day limit', () async {
      // Arrange
      final provider = CoinGeckoCexProvider();

      // Act & Assert
      expect(
        () => provider.fetchCoinOhlc('bitcoin', 'usd', 400),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // test('fetchCoinHistoricalData test', () async {
  //   // Arrange
  //   final CoinGeckoCexProvider provider = CoinGeckoCexProvider();
  //   const String id = 'bitcoin';
  //   const String date = '2023-04-20';

  //   // Act
  //   final CoinHistoricalData result = await provider.fetchCoinHistoricalData(
  //     id: id,
  //     date: date,
  //   );

  //   // Assert
  //   expect(result, isA<CoinHistoricalData>());
  //   expect(result.marketData, isA<CoinMarketData>());
  //   expect(result.marketData?.currentPrice, isNotNull);
  //   expect(result.marketData?.currentPrice?.usd, isA<num>());
  // });
}
