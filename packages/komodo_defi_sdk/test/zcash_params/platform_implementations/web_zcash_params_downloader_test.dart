import 'package:komodo_defi_sdk/src/zcash_params/models/download_progress.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/download_result.dart';
import 'package:komodo_defi_sdk/src/zcash_params/platform_implementations/web_zcash_params_downloader.dart';
import 'package:test/test.dart';

void main() {
  group('WebZcashParamsDownloader', () {
    late WebZcashParamsDownloader downloader;

    setUp(() {
      downloader = WebZcashParamsDownloader();
    });

    tearDown(() {
      downloader.dispose();
    });

    group('downloadParams', () {
      test('returns immediate success', () async {
        final result = await downloader.downloadParams();

        expect(result, isA<DownloadResultSuccess>());
        result.when(
          success: (paramsPath) {
            expect(paramsPath, isNotNull);
          },
          failure: (error) {
            fail('Expected success but got failure: $error');
          },
        );
      });

      test('returns consistent results on multiple calls', () async {
        final result1 = await downloader.downloadParams();
        final result2 = await downloader.downloadParams();

        expect(result1.runtimeType, equals(result2.runtimeType));

        // Both should be success results
        expect(result1, isA<DownloadResultSuccess>());
        expect(result2, isA<DownloadResultSuccess>());
      });

      test('is fast (completes immediately)', () async {
        final stopwatch = Stopwatch()..start();
        await downloader.downloadParams();
        stopwatch.stop();

        // Should complete in well under 100ms since it's a no-op
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('getParamsPath', () {
      test('returns null', () async {
        final path = await downloader.getParamsPath();
        expect(path, isNull);
      });

      test('returns consistent null on multiple calls', () async {
        final path1 = await downloader.getParamsPath();
        final path2 = await downloader.getParamsPath();

        expect(path1, isNull);
        expect(path2, isNull);
        expect(path1, equals(path2));
      });

      test('is fast (completes immediately)', () async {
        final stopwatch = Stopwatch()..start();
        await downloader.getParamsPath();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });

    group('areParamsAvailable', () {
      test('returns true', () async {
        final available = await downloader.areParamsAvailable();
        expect(available, isTrue);
      });

      test('returns consistent true on multiple calls', () async {
        final available1 = await downloader.areParamsAvailable();
        final available2 = await downloader.areParamsAvailable();

        expect(available1, isTrue);
        expect(available2, isTrue);
        expect(available1, equals(available2));
      });

      test('is fast (completes immediately)', () async {
        final stopwatch = Stopwatch()..start();
        await downloader.areParamsAvailable();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });

    group('downloadProgress', () {
      test('stream is empty', () async {
        final events = <DownloadProgress>[];
        final subscription = downloader.downloadProgress.listen(events.add);

        // Wait a short time to ensure no events are emitted
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await subscription.cancel();

        expect(events, isEmpty);
      });

      test('stream can be listened to multiple times', () async {
        final events1 = <DownloadProgress>[];
        final events2 = <DownloadProgress>[];

        final sub1 = downloader.downloadProgress.listen(events1.add);
        final sub2 = downloader.downloadProgress.listen(events2.add);

        await Future<void>.delayed(const Duration(milliseconds: 100));

        await sub1.cancel();
        await sub2.cancel();

        expect(events1, isEmpty);
        expect(events2, isEmpty);
      });

      test('stream is broadcast', () {
        final stream = downloader.downloadProgress;

        // Should be able to listen multiple times (broadcast stream)
        expect(() => stream.listen((_) {}), returnsNormally);
        expect(() => stream.listen((_) {}), returnsNormally);
      });
    });

    group('cancelDownload', () {
      test('returns false', () async {
        final cancelled = await downloader.cancelDownload();
        expect(cancelled, isFalse);
      });

      test('returns consistent false on multiple calls', () async {
        final cancelled1 = await downloader.cancelDownload();
        final cancelled2 = await downloader.cancelDownload();

        expect(cancelled1, isFalse);
        expect(cancelled2, isFalse);
        expect(cancelled1, equals(cancelled2));
      });

      test('can be called after downloadParams', () async {
        await downloader.downloadParams();
        final cancelled = await downloader.cancelDownload();
        expect(cancelled, isFalse);
      });

      test('is fast (completes immediately)', () async {
        final stopwatch = Stopwatch()..start();
        await downloader.cancelDownload();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });

    group('validateParams', () {
      test('returns true', () async {
        final valid = await downloader.validateParams();
        expect(valid, isTrue);
      });

      test('returns consistent true on multiple calls', () async {
        final valid1 = await downloader.validateParams();
        final valid2 = await downloader.validateParams();

        expect(valid1, isTrue);
        expect(valid2, isTrue);
        expect(valid1, equals(valid2));
      });

      test('can be called before downloadParams', () async {
        final valid = await downloader.validateParams();
        expect(valid, isTrue);
      });

      test('can be called after downloadParams', () async {
        await downloader.downloadParams();
        final valid = await downloader.validateParams();
        expect(valid, isTrue);
      });

      test('is fast (completes immediately)', () async {
        final stopwatch = Stopwatch()..start();
        await downloader.validateParams();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });

    group('clearParams', () {
      test('returns true', () async {
        final cleared = await downloader.clearParams();
        expect(cleared, isTrue);
      });

      test('returns consistent true on multiple calls', () async {
        final cleared1 = await downloader.clearParams();
        final cleared2 = await downloader.clearParams();

        expect(cleared1, isTrue);
        expect(cleared2, isTrue);
        expect(cleared1, equals(cleared2));
      });

      test('can be called before downloadParams', () async {
        final cleared = await downloader.clearParams();
        expect(cleared, isTrue);
      });

      test('can be called after downloadParams', () async {
        await downloader.downloadParams();
        final cleared = await downloader.clearParams();
        expect(cleared, isTrue);
      });

      test('is fast (completes immediately)', () async {
        final stopwatch = Stopwatch()..start();
        await downloader.clearParams();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });

    group('dispose', () {
      test('can be called safely', () {
        expect(() => downloader.dispose(), returnsNormally);
      });

      test('can be called multiple times', () {
        downloader.dispose();
        expect(() => downloader.dispose(), returnsNormally);
      });

      test('closes progress stream', () async {
        final stream = downloader.downloadProgress;
        downloader.dispose();

        // Stream should be closed after dispose
        expect(stream, emitsDone);
      });
    });

    group('integration scenarios', () {
      test('complete workflow behaves correctly', () async {
        // Check availability first
        final available = await downloader.areParamsAvailable();
        expect(available, isTrue);

        // Get params path
        final path = await downloader.getParamsPath();
        expect(path, isNull);

        // Download params
        final result = await downloader.downloadParams();
        expect(result, isA<DownloadResultSuccess>());
        result.when(
          success: (paramsPath) {
            expect(paramsPath, isNotNull);
          },
          failure: (error) {
            fail('Expected success but got failure: $error');
          },
        );

        // Validate params
        final valid = await downloader.validateParams();
        expect(valid, isTrue);

        // Clear params
        final cleared = await downloader.clearParams();
        expect(cleared, isTrue);
      });

      test('can handle rapid sequential calls', () async {
        final futures = <Future>[];

        // Make multiple rapid calls to all methods
        for (int i = 0; i < 10; i++) {
          futures
            ..add(downloader.downloadParams())
            ..add(downloader.getParamsPath())
            ..add(downloader.areParamsAvailable())
            ..add(downloader.cancelDownload())
            ..add(downloader.validateParams())
            ..add(downloader.clearParams());
        }

        // All should complete successfully
        await Future.wait(futures);
      });

      test('maintains state consistency across operations', () async {
        // Perform operations in different orders
        await downloader.clearParams();
        await downloader.validateParams();
        await downloader.downloadParams();

        final available = await downloader.areParamsAvailable();
        final path = await downloader.getParamsPath();

        expect(available, isTrue);
        expect(path, isNull);
      });
    });

    group('error conditions', () {
      test('handles dispose during operation gracefully', () async {
        final downloadFuture = downloader.downloadParams();
        downloader.dispose();

        // Download should still complete successfully
        final result = await downloadFuture;
        expect(result, isA<DownloadResultSuccess>());
      });

      test('all methods work after dispose', () async {
        downloader.dispose();

        // All methods should still work (they're no-ops anyway)
        final result = await downloader.downloadParams();
        expect(result, isA<DownloadResult>());
        expect(result, isA<DownloadResultSuccess>());
        expect(await downloader.getParamsPath(), isNull);
        expect(await downloader.areParamsAvailable(), isTrue);
        expect(await downloader.cancelDownload(), isFalse);
        expect(await downloader.validateParams(), isTrue);
        expect(await downloader.clearParams(), isTrue);
      });
    });

    group('resource management', () {
      test('multiple instances can coexist', () {
        final downloader2 = WebZcashParamsDownloader();
        final downloader3 = WebZcashParamsDownloader();

        expect(downloader, isNot(same(downloader2)));
        expect(downloader2, isNot(same(downloader3)));

        downloader2.dispose();
        downloader3.dispose();
      });

      test('instances are independent', () async {
        final downloader2 = WebZcashParamsDownloader();

        final result1 = await downloader.downloadParams();
        final result2 = await downloader2.downloadParams();

        expect(result1.runtimeType, equals(result2.runtimeType));
        expect(result1, isA<DownloadResultSuccess>());
        expect(result2, isA<DownloadResultSuccess>());

        downloader2.dispose();
      });
    });
  });
}
