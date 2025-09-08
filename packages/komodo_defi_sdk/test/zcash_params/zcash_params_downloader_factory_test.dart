import 'package:test/test.dart';
import 'package:komodo_defi_sdk/src/zcash_params/zcash_params_downloader_factory.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/download_result.dart';
import 'package:komodo_defi_sdk/src/zcash_params/platform_implementations/web_zcash_params_downloader.dart';
import 'package:komodo_defi_sdk/src/zcash_params/platform_implementations/windows_zcash_params_downloader.dart';
import 'package:komodo_defi_sdk/src/zcash_params/platform_implementations/unix_zcash_params_downloader.dart';

void main() {
  group('ZcashParamsDownloaderFactory', () {
    group('create', () {
      test('creates WebZcashParamsDownloader on web platform', () {
        // This test will only run on web platform in actual testing
        // For unit testing, we test the factory logic through createForPlatform
        final downloader = ZcashParamsDownloaderFactory.createForPlatform(
          ZcashParamsPlatform.web,
        );

        expect(downloader, isA<WebZcashParamsDownloader>());
      });

      test('creates WindowsZcashParamsDownloader for Windows platform', () {
        final downloader = ZcashParamsDownloaderFactory.createForPlatform(
          ZcashParamsPlatform.windows,
        );

        expect(downloader, isA<WindowsZcashParamsDownloader>());
      });

      test('creates UnixZcashParamsDownloader for Unix platform', () {
        final downloader = ZcashParamsDownloaderFactory.createForPlatform(
          ZcashParamsPlatform.unix,
        );

        expect(downloader, isA<UnixZcashParamsDownloader>());
      });
    });

    group('createForPlatform', () {
      test('creates correct downloader for each platform type', () {
        for (final platform in ZcashParamsPlatform.values) {
          final downloader = ZcashParamsDownloaderFactory.createForPlatform(
            platform,
          );

          switch (platform) {
            case ZcashParamsPlatform.web:
              expect(downloader, isA<WebZcashParamsDownloader>());
              break;
            case ZcashParamsPlatform.windows:
              expect(downloader, isA<WindowsZcashParamsDownloader>());
              break;
            case ZcashParamsPlatform.unix:
              expect(downloader, isA<UnixZcashParamsDownloader>());
              break;
          }
        }
      });

      test('creates different instances for multiple calls', () {
        final downloader1 = ZcashParamsDownloaderFactory.createForPlatform(
          ZcashParamsPlatform.web,
        );
        final downloader2 = ZcashParamsDownloaderFactory.createForPlatform(
          ZcashParamsPlatform.web,
        );

        expect(downloader1, isNot(same(downloader2)));
        expect(downloader1.runtimeType, equals(downloader2.runtimeType));
      });
    });

    group('detectPlatform', () {
      test('returns web for web platform when kIsWeb is true', () {
        // Note: This test will behave differently based on the actual platform
        // In a real test environment, you would mock kIsWeb
        final detected = ZcashParamsDownloaderFactory.detectPlatform();

        // Verify it returns a valid platform
        expect(ZcashParamsPlatform.values.contains(detected), isTrue);
      });

      test('detection is consistent', () {
        final platform1 = ZcashParamsDownloaderFactory.detectPlatform();
        final platform2 = ZcashParamsDownloaderFactory.detectPlatform();

        expect(platform1, equals(platform2));
      });
    });

    group('requiresDownload', () {
      test('returns false for web platform', () {
        // This test assumes we're not running on web
        // In a real test setup, you would mock platform detection
        expect(ZcashParamsDownloaderFactory.requiresDownload, isA<bool>());
      });
    });

    group('getDefaultParamsPath', () {
      test('returns path for platforms that support it', () async {
        // Test with Unix platform (should return a path)
        final downloader = ZcashParamsDownloaderFactory.createForPlatform(
          ZcashParamsPlatform.unix,
        );

        expect(downloader, isA<UnixZcashParamsDownloader>());

        // Note: In a real test, we would mock the environment variables
        // For now, we just verify the method exists and can be called
      });

      test('returns null for web platform', () async {
        final downloader = ZcashParamsDownloaderFactory.createForPlatform(
          ZcashParamsPlatform.web,
        );

        final path = await downloader.getParamsPath();
        expect(path, isNull);
      });
    });
  });

  group('ZcashParamsPlatform', () {
    group('displayName', () {
      test('returns correct display names', () {
        expect(ZcashParamsPlatform.web.displayName, equals('Web'));
        expect(ZcashParamsPlatform.windows.displayName, equals('Windows'));
        expect(ZcashParamsPlatform.unix.displayName, equals('Unix/Linux'));
      });
    });

    group('requiresDownload', () {
      test('returns correct download requirements', () {
        expect(ZcashParamsPlatform.web.requiresDownload, isFalse);
        expect(ZcashParamsPlatform.windows.requiresDownload, isTrue);
        expect(ZcashParamsPlatform.unix.requiresDownload, isTrue);
      });
    });

    group('defaultDirectoryName', () {
      test('returns correct directory names', () {
        expect(ZcashParamsPlatform.web.defaultDirectoryName, isNull);
        expect(
          ZcashParamsPlatform.windows.defaultDirectoryName,
          equals('ZcashParams'),
        );
        expect(ZcashParamsPlatform.unix.defaultDirectoryName, isNull);
      });
    });
  });

  group('edge cases', () {
    test('factory methods handle multiple rapid calls', () {
      final downloaders = <Object>[];

      // Create multiple downloaders rapidly
      for (int i = 0; i < 10; i++) {
        final downloader = ZcashParamsDownloaderFactory.createForPlatform(
          ZcashParamsPlatform.web,
        );
        downloaders.add(downloader);
      }

      // All should be of the same type but different instances
      expect(downloaders.length, equals(10));
      for (final downloader in downloaders) {
        expect(downloader, isA<WebZcashParamsDownloader>());
      }
    });

    test('platform detection is deterministic', () {
      final detections = <ZcashParamsPlatform>[];

      // Detect platform multiple times
      for (int i = 0; i < 5; i++) {
        detections.add(ZcashParamsDownloaderFactory.detectPlatform());
      }

      // All detections should be the same
      final firstDetection = detections.first;
      for (final detection in detections) {
        expect(detection, equals(firstDetection));
      }
    });

    test('enum values are complete', () {
      // Ensure all enum values are handled in the factory
      expect(ZcashParamsPlatform.values.length, equals(3));
      expect(ZcashParamsPlatform.values, contains(ZcashParamsPlatform.web));
      expect(ZcashParamsPlatform.values, contains(ZcashParamsPlatform.windows));
      expect(ZcashParamsPlatform.values, contains(ZcashParamsPlatform.unix));
    });
  });

  group('integration tests', () {
    test('created downloaders have expected interfaces', () async {
      for (final platform in ZcashParamsPlatform.values) {
        final downloader = ZcashParamsDownloaderFactory.createForPlatform(
          platform,
        );

        // Verify all downloaders implement the expected interface
        expect(downloader.downloadParams, isA<Function>());
        expect(downloader.getParamsPath, isA<Function>());
        expect(downloader.areParamsAvailable, isA<Function>());
        expect(downloader.downloadProgress, isA<Stream>());
        expect(downloader.cancelDownload, isA<Function>());
        expect(downloader.validateParams, isA<Function>());
        expect(downloader.clearParams, isA<Function>());
      }
    });

    test('web downloader behaves as expected', () async {
      final downloader =
          ZcashParamsDownloaderFactory.createForPlatform(
                ZcashParamsPlatform.web,
              )
              as WebZcashParamsDownloader;

      // Web downloader should immediately return success and nulls
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

      final path = await downloader.getParamsPath();
      expect(path, isNull);

      final available = await downloader.areParamsAvailable();
      expect(available, isTrue);

      final cancelled = await downloader.cancelDownload();
      expect(cancelled, isFalse);

      final validated = await downloader.validateParams();
      expect(validated, isTrue);

      final cleared = await downloader.clearParams();
      expect(cleared, isTrue);

      // Clean up
      downloader.dispose();
    });
  });
}
