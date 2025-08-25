import 'dart:async';
import 'dart:io';

import 'package:decimal/decimal.dart' show Decimal;
import 'package:hive_ce/hive.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock classes
class MockCexRepository extends Mock implements CexRepository {}

class MockRepositorySelectionStrategy extends Mock
    implements RepositorySelectionStrategy {}

void main() {
  group('Integration Tests - Core Functionality', () {
    late SparklineRepository sparklineRepo;
    late MockCexRepository primaryRepo;
    late MockCexRepository fallbackRepo;
    late MockRepositorySelectionStrategy mockStrategy;
    late AssetId testAsset;
    late Directory tempDir;

    setUpAll(() {
      tempDir = Directory.systemTemp.createTempSync('integration_test_');
      Hive.init(tempDir.path);

      testAsset = AssetId(
        id: 'BTC',
        name: 'Bitcoin',
        symbol: AssetSymbol(assetConfigId: 'BTC'),
        chainId: AssetChainId(chainId: 0),
        derivationPath: null,
        subClass: CoinSubClass.utxo,
      );

      registerFallbackValue(testAsset);
      registerFallbackValue(Stablecoin.usdt);
      registerFallbackValue(PriceRequestType.priceHistory);
      registerFallbackValue(GraphInterval.oneDay);
      registerFallbackValue(<CexRepository>[]);
      registerFallbackValue(DateTime.now());
    });

    setUp(() async {
      primaryRepo = MockCexRepository();
      fallbackRepo = MockCexRepository();
      mockStrategy = MockRepositorySelectionStrategy();

      sparklineRepo = SparklineRepository(
        repositories: [primaryRepo, fallbackRepo],
        selectionStrategy: mockStrategy,
      );

      // Setup default supports behavior
      when(
        () => primaryRepo.supports(any(), any(), any()),
      ).thenAnswer((_) async => true);
      when(
        () => fallbackRepo.supports(any(), any(), any()),
      ).thenAnswer((_) async => true);

      // Setup realistic strategy behavior
      when(
        () => mockStrategy.selectRepository(
          assetId: any(named: 'assetId'),
          fiatCurrency: any(named: 'fiatCurrency'),
          requestType: any(named: 'requestType'),
          availableRepositories: any(named: 'availableRepositories'),
        ),
      ).thenAnswer((invocation) async {
        final repos =
            invocation.namedArguments[#availableRepositories]
                as List<CexRepository>;
        return repos.isNotEmpty ? repos.first : null;
      });

      await sparklineRepo.init();
    });

    tearDown(() async {
      try {
        await Hive.deleteBoxFromDisk('sparkline_data');
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    tearDownAll(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('request deduplication prevents concurrent calls', () async {
      // Setup: Primary repo returns after a delay
      final completer = Completer<CoinOhlc>();
      when(
        () => primaryRepo.getCoinOhlc(
          testAsset,
          Stablecoin.usdt,
          GraphInterval.oneDay,
          startAt: any(named: 'startAt'),
          endAt: any(named: 'endAt'),
        ),
      ).thenAnswer((_) => completer.future);

      // Start 3 concurrent requests
      final futures = List.generate(
        3,
        (index) => sparklineRepo.fetchSparkline(testAsset),
      );

      // Wait a bit then complete the request
      await Future.delayed(const Duration(milliseconds: 10));

      final mockOhlc = CoinOhlc(
        ohlc: List.generate(
          5,
          (i) => Ohlc.binance(
            openTime: DateTime.now()
                .subtract(Duration(days: 4 - i))
                .millisecondsSinceEpoch,
            open: Decimal.fromInt(50000 + i),
            high: Decimal.fromInt(51000 + i),
            low: Decimal.fromInt(49000 + i),
            close: Decimal.fromInt(50500 + i),
            closeTime: DateTime.now()
                .subtract(Duration(days: 4 - i))
                .millisecondsSinceEpoch,
          ),
        ),
      );

      completer.complete(mockOhlc);

      // Wait for all requests to complete
      final results = await Future.wait(futures);

      // Verify: All requests return the same data
      expect(results.length, equals(3));
      for (final result in results) {
        expect(result, isNotNull);
        expect(result!.length, equals(5));
        expect(result, equals(results.first));
      }

      // Verify: Only one actual API call was made
      verify(
        () => primaryRepo.getCoinOhlc(
          testAsset,
          Stablecoin.usdt,
          GraphInterval.oneDay,
          startAt: any(named: 'startAt'),
          endAt: any(named: 'endAt'),
        ),
      ).called(1);
    });

    test('basic error handling with fallback', () async {
      // Setup: Primary fails, fallback succeeds
      when(
        () => primaryRepo.getCoinOhlc(
          testAsset,
          Stablecoin.usdt,
          GraphInterval.oneDay,
          startAt: any(named: 'startAt'),
          endAt: any(named: 'endAt'),
        ),
      ).thenThrow(Exception('Primary repo failed'));

      final mockOhlc = CoinOhlc(
        ohlc: [
          Ohlc.binance(
            openTime: DateTime.now().millisecondsSinceEpoch,
            open: Decimal.fromInt(45000),
            high: Decimal.fromInt(46000),
            low: Decimal.fromInt(44000),
            close: Decimal.fromInt(45500),
            closeTime: DateTime.now().millisecondsSinceEpoch,
          ),
        ],
      );

      when(
        () => fallbackRepo.getCoinOhlc(
          testAsset,
          Stablecoin.usdt,
          GraphInterval.oneDay,
          startAt: any(named: 'startAt'),
          endAt: any(named: 'endAt'),
        ),
      ).thenAnswer((_) async => mockOhlc);

      // Request should succeed via fallback
      final result = await sparklineRepo.fetchSparkline(testAsset);
      expect(result, isNotNull);
      expect(result!.first, equals(45500.0));

      // Verify fallback was used
      verify(
        () => fallbackRepo.getCoinOhlc(
          testAsset,
          Stablecoin.usdt,
          GraphInterval.oneDay,
          startAt: any(named: 'startAt'),
          endAt: any(named: 'endAt'),
        ),
      ).called(1);
    });

    test('cache works with request deduplication', () async {
      // Setup successful response
      final mockOhlc = CoinOhlc(
        ohlc: [
          Ohlc.binance(
            openTime: DateTime.now().millisecondsSinceEpoch,
            open: Decimal.fromInt(52000),
            high: Decimal.fromInt(53000),
            low: Decimal.fromInt(51000),
            close: Decimal.fromInt(52500),
            closeTime: DateTime.now().millisecondsSinceEpoch,
          ),
        ],
      );

      when(
        () => primaryRepo.getCoinOhlc(
          testAsset,
          Stablecoin.usdt,
          GraphInterval.oneDay,
          startAt: any(named: 'startAt'),
          endAt: any(named: 'endAt'),
        ),
      ).thenAnswer((_) async => mockOhlc);

      // First request populates cache
      final result1 = await sparklineRepo.fetchSparkline(testAsset);
      expect(result1, isNotNull);
      expect(result1!.first, equals(52500.0));

      // Second request should use cache (no additional API call)
      final result2 = await sparklineRepo.fetchSparkline(testAsset);
      expect(result2, equals(result1));

      // Verify: Only one API call was made
      verify(
        () => primaryRepo.getCoinOhlc(
          testAsset,
          Stablecoin.usdt,
          GraphInterval.oneDay,
          startAt: any(named: 'startAt'),
          endAt: any(named: 'endAt'),
        ),
      ).called(1);
    });

    test('handles complete repository failure gracefully', () async {
      // Setup: Both repositories fail
      when(
        () => primaryRepo.getCoinOhlc(
          testAsset,
          Stablecoin.usdt,
          GraphInterval.oneDay,
          startAt: any(named: 'startAt'),
          endAt: any(named: 'endAt'),
        ),
      ).thenThrow(Exception('Primary failed'));

      when(
        () => fallbackRepo.getCoinOhlc(
          testAsset,
          Stablecoin.usdt,
          GraphInterval.oneDay,
          startAt: any(named: 'startAt'),
          endAt: any(named: 'endAt'),
        ),
      ).thenThrow(Exception('Fallback failed'));

      // Request should return null when all repositories fail
      final result = await sparklineRepo.fetchSparkline(testAsset);
      expect(result, isNull);

      // Verify both repositories were attempted
      verify(
        () => primaryRepo.getCoinOhlc(
          testAsset,
          Stablecoin.usdt,
          GraphInterval.oneDay,
          startAt: any(named: 'startAt'),
          endAt: any(named: 'endAt'),
        ),
      ).called(greaterThan(0));
    });
  });
}
