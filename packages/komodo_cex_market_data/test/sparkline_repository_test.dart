import 'dart:async';
import 'dart:io';

import 'package:decimal/decimal.dart' show Decimal;
import 'package:hive_ce/hive.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_cex_market_data/src/models/sparkline_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock classes
class MockCexRepository extends Mock implements CexRepository {}

class MockRepositorySelectionStrategy extends Mock
    implements RepositorySelectionStrategy {}

class MockBox extends Mock implements Box<SparklineData> {}

void main() {
  group('SparklineRepository', () {
    late SparklineRepository sparklineRepo;
    late MockCexRepository primaryRepo;
    late MockCexRepository fallbackRepo;
    late MockRepositorySelectionStrategy mockStrategy;
    late AssetId testAsset;
    late Directory tempDir;

    setUpAll(() {
      // Setup Hive in a temporary directory
      tempDir = Directory.systemTemp.createTempSync('sparkline_test_');
      Hive.init(tempDir.path);

      // Register fallback values for mocktail
      registerFallbackValue(
        testAsset = AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        ),
      );
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

      // Setup realistic strategy behavior - return first available healthy repo
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
      // Clean up Hive box properly after each test
      if (sparklineRepo.isInitialized) {
        try {
          final box = Hive.box<SparklineData>('sparkline_data');
          if (box.isOpen) {
            await box.clear();
            await box.close();
          }
        } catch (e) {
          // Box might not exist or already closed, ignore
        }
      }
    });

    tearDownAll(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    group('Request Deduplication', () {
      test('prevents multiple concurrent requests for same symbol', () async {
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

        // Start multiple concurrent requests
        final futures = List.generate(
          5,
          (index) => sparklineRepo.fetchSparkline(testAsset),
        );

        // Wait a bit to ensure all requests are started
        await Future.delayed(const Duration(milliseconds: 10));

        // Complete the request
        final mockOhlc = CoinOhlc(
          ohlc: List.generate(
            7,
            (i) => Ohlc.binance(
              openTime: DateTime.now()
                  .subtract(Duration(days: 6 - i))
                  .millisecondsSinceEpoch,
              open: Decimal.fromInt(50000 + i),
              high: Decimal.fromInt(51000 + i),
              low: Decimal.fromInt(49000 + i),
              close: Decimal.fromInt(50500 + i),
              closeTime: DateTime.now()
                  .subtract(Duration(days: 6 - i))
                  .millisecondsSinceEpoch,
            ),
          ),
        );
        completer.complete(mockOhlc);

        // Wait for all requests to complete
        final results = await Future.wait(futures);

        // Verify: All requests return the same data
        for (final result in results) {
          expect(result, isNotNull);
          expect(result!.length, equals(7));
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

      test('allows new request after previous one completes', () async {
        // Setup: Primary repo returns immediately
        final mockOhlc = CoinOhlc(
          ohlc: List.generate(
            7,
            (i) => Ohlc.binance(
              openTime: DateTime.now()
                  .subtract(Duration(days: 6 - i))
                  .millisecondsSinceEpoch,
              open: Decimal.fromInt(50000 + i),
              high: Decimal.fromInt(51000 + i),
              low: Decimal.fromInt(49000 + i),
              close: Decimal.fromInt(50500 + i),
              closeTime: DateTime.now()
                  .subtract(Duration(days: 6 - i))
                  .millisecondsSinceEpoch,
            ),
          ),
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

        // First request
        final result1 = await sparklineRepo.fetchSparkline(testAsset);
        expect(result1, isNotNull);

        // Clear cache to force new request
        try {
          final box = Hive.box<SparklineData>('sparkline_data');
          await box.clear();
        } catch (e) {
          // Box might not exist, ignore
        }

        // Second request (should make new API call)
        final result2 = await sparklineRepo.fetchSparkline(testAsset);
        expect(result2, isNotNull);

        // Verify: Two API calls were made
        verify(
          () => primaryRepo.getCoinOhlc(
            testAsset,
            Stablecoin.usdt,
            GraphInterval.oneDay,
            startAt: any(named: 'startAt'),
            endAt: any(named: 'endAt'),
          ),
        ).called(2);
      });

      test('handles concurrent requests when first one fails', () async {
        // Setup: Primary repo fails, fallback succeeds
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
          ohlc: List.generate(
            7,
            (i) => Ohlc.binance(
              openTime: DateTime.now()
                  .subtract(Duration(days: 6 - i))
                  .millisecondsSinceEpoch,
              open: Decimal.fromInt(40000 + i),
              high: Decimal.fromInt(41000 + i),
              low: Decimal.fromInt(39000 + i),
              close: Decimal.fromInt(40500 + i),
              closeTime: DateTime.now()
                  .subtract(Duration(days: 6 - i))
                  .millisecondsSinceEpoch,
            ),
          ),
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

        // Start multiple concurrent requests
        final futures = List.generate(
          3,
          (index) => sparklineRepo.fetchSparkline(testAsset),
        );

        final results = await Future.wait(futures);

        // Verify: All requests return the same fallback data
        for (final result in results) {
          expect(result, isNotNull);
          expect(result!.length, equals(7));
          expect(result.first, equals(40500.0)); // First close price
        }
      });
    });

    group('Rate Limit Handling Integration', () {
      test('handles repository failure with fallback', () async {
        // Setup: Primary repo fails, fallback succeeds
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

        // Request should succeed with fallback data
        final result = await sparklineRepo.fetchSparkline(testAsset);

        // Verify: Request succeeds with fallback data
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

      test('handles different error types with fallback', () async {
        // Setup: Primary throws error, fallback succeeds
        when(
          () => primaryRepo.getCoinOhlc(
            testAsset,
            Stablecoin.usdt,
            GraphInterval.oneDay,
            startAt: any(named: 'startAt'),
            endAt: any(named: 'endAt'),
          ),
        ).thenThrow(Exception('General error'));

        when(
          () => fallbackRepo.getCoinOhlc(
            testAsset,
            Stablecoin.usdt,
            GraphInterval.oneDay,
            startAt: any(named: 'startAt'),
            endAt: any(named: 'endAt'),
          ),
        ).thenAnswer(
          (_) async => CoinOhlc(
            ohlc: [
              Ohlc.binance(
                openTime: DateTime.now().millisecondsSinceEpoch,
                open: Decimal.fromInt(50000),
                high: Decimal.fromInt(51000),
                low: Decimal.fromInt(49000),
                close: Decimal.fromInt(50500),
                closeTime: DateTime.now().millisecondsSinceEpoch,
              ),
            ],
          ),
        );

        // Request should succeed via fallback
        final result = await sparklineRepo.fetchSparkline(testAsset);
        expect(result, isNotNull);
        expect(result!.first, equals(50500.0));

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

      test('concurrent requests with fallback work correctly', () async {
        // Setup: Primary fails immediately, fallback succeeds
        when(
          () => primaryRepo.getCoinOhlc(
            testAsset,
            Stablecoin.usdt,
            GraphInterval.oneDay,
            startAt: any(named: 'startAt'),
            endAt: any(named: 'endAt'),
          ),
        ).thenThrow(Exception('Primary failed'));

        final mockOhlc = CoinOhlc(
          ohlc: [
            Ohlc.binance(
              openTime: DateTime.now().millisecondsSinceEpoch,
              open: Decimal.fromInt(48000),
              high: Decimal.fromInt(49000),
              low: Decimal.fromInt(47000),
              close: Decimal.fromInt(48500),
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

        // Start multiple concurrent requests
        final futures = List.generate(
          3,
          (index) => sparklineRepo.fetchSparkline(testAsset),
        );

        // Wait for all requests to complete
        final results = await Future.wait(futures);

        // Verify: All requests return the same fallback data
        for (final result in results) {
          expect(result, isNotNull);
          expect(result!.first, equals(48500.0));
          expect(result, equals(results.first));
        }

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
    });

    group('Cache Integration', () {
      test('returns cached data without making new requests', () async {
        // Setup mock OHLC data
        final mockOhlc = CoinOhlc(
          ohlc: List.generate(
            7,
            (i) => Ohlc.binance(
              openTime: DateTime.now()
                  .subtract(Duration(days: 6 - i))
                  .millisecondsSinceEpoch,
              open: Decimal.fromInt(52000 + i),
              high: Decimal.fromInt(53000 + i),
              low: Decimal.fromInt(51000 + i),
              close: Decimal.fromInt(52500 + i),
              closeTime: DateTime.now()
                  .subtract(Duration(days: 6 - i))
                  .millisecondsSinceEpoch,
            ),
          ),
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

        // First request - should hit API
        final result1 = await sparklineRepo.fetchSparkline(testAsset);
        expect(result1, isNotNull);

        // Second request - should return cached data
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

      test('concurrent requests with cache hit return immediately', () async {
        // Pre-populate cache manually through box
        final box = await Hive.openBox<SparklineData>('sparkline_data');
        final testData = [1.0, 2.0, 3.0, 4.0, 5.0];
        final cacheData = SparklineData.success(testData);
        await box.put(testAsset.symbol.configSymbol, cacheData);

        // Start multiple concurrent requests
        final futures = List.generate(
          5,
          (index) => sparklineRepo.fetchSparkline(testAsset),
        );

        final results = await Future.wait(futures);

        // Verify: All requests return cached data
        for (final result in results) {
          expect(result, equals(testData));
        }

        // Verify: No API calls were made
        verifyNever(
          () => primaryRepo.getCoinOhlc(
            any(),
            any(),
            any(),
            startAt: any(named: 'startAt'),
            endAt: any(named: 'endAt'),
          ),
        );
      });
    });

    group('Error Handling', () {
      test('handles repository failure gracefully', () async {
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

        // Make request
        final result = await sparklineRepo.fetchSparkline(testAsset);

        // Verify: Request returns null when all repositories fail
        expect(result, isNull);
      });

      test('throws exception when not initialized', () async {
        final uninitializedRepo = SparklineRepository();

        expect(
          () => uninitializedRepo.fetchSparkline(testAsset),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('not initialized'),
            ),
          ),
        );
      });
    });

    group('Stablecoin Handling', () {
      test('generates constant sparkline for stablecoins', () async {
        final usdtAsset = AssetId(
          id: 'USDT',
          name: 'Tether',
          symbol: AssetSymbol(assetConfigId: 'USDT'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.erc20,
        );

        final result = await sparklineRepo.fetchSparkline(usdtAsset);

        expect(result, isNotNull);
        expect(result!.isNotEmpty, isTrue);
        // All values should be approximately 1.0 for USDT
        for (final value in result) {
          expect(value, closeTo(1.0, 0.01));
        }

        // Verify: No API calls were made for stablecoin
        verifyNever(
          () => primaryRepo.getCoinOhlc(
            any(),
            any(),
            any(),
            startAt: any(named: 'startAt'),
            endAt: any(named: 'endAt'),
          ),
        );
      });
    });
  });
}
