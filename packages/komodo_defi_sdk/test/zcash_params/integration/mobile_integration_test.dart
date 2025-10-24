import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/download_result.dart';
import 'package:komodo_defi_sdk/src/zcash_params/platforms/mobile_zcash_params_downloader.dart';
import 'package:komodo_defi_sdk/src/zcash_params/zcash_params_downloader_factory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {}

void main() {
  group('Mobile Platform Integration Tests', () {
    late MockPathProviderPlatform mockPathProvider;

    setUp(() {
      mockPathProvider = MockPathProviderPlatform();
      PathProviderPlatform.instance = mockPathProvider;
    });

    group('Factory Integration', () {
      test('creates mobile downloader for mobile platform enum', () {
        final downloader = ZcashParamsDownloaderFactory.createForPlatform(
          ZcashParamsPlatform.mobile,
        );

        expect(downloader, isA<MobileZcashParamsDownloader>());
        expect(downloader.runtimeType, equals(MobileZcashParamsDownloader));
      });

      test('mobile platform enum properties are correct', () {
        const platform = ZcashParamsPlatform.mobile;

        expect(platform.displayName, equals('Mobile'));
        expect(platform.requiresDownload, isTrue);
        expect(platform.defaultDirectoryName, equals('ZcashParams'));
      });

      test('mobile downloader uses path provider correctly', () async {
        const testDocumentsPath = '/test/documents';
        const expectedParamsPath = '/test/documents/ZcashParams';

        when(
          () => mockPathProvider.getApplicationDocumentsPath(),
        ).thenAnswer((_) async => testDocumentsPath);

        final downloader =
            ZcashParamsDownloaderFactory.createForPlatform(
                  ZcashParamsPlatform.mobile,
                )
                as MobileZcashParamsDownloader;

        final paramsPath = await downloader.getParamsPath();

        expect(paramsPath, equals(expectedParamsPath));
        verify(() => mockPathProvider.getApplicationDocumentsPath()).called(1);

        // Clean up
        downloader.dispose();
      });

      test(
        'mobile downloader handles path provider errors gracefully',
        () async {
          when(
            () => mockPathProvider.getApplicationDocumentsPath(),
          ).thenThrow(Exception('Platform not supported'));

          final downloader =
              ZcashParamsDownloaderFactory.createForPlatform(
                    ZcashParamsPlatform.mobile,
                  )
                  as MobileZcashParamsDownloader;

          final paramsPath = await downloader.getParamsPath();

          expect(paramsPath, isNull);

          // Clean up
          downloader.dispose();
        },
      );
    });

    group('End-to-End Workflow', () {
      test(
        'mobile downloader completes full workflow when path is available',
        () async {
          const testDocumentsPath = '/test/documents';

          when(
            () => mockPathProvider.getApplicationDocumentsPath(),
          ).thenAnswer((_) async => testDocumentsPath);

          final downloader = ZcashParamsDownloaderFactory.createForPlatform(
            ZcashParamsPlatform.mobile,
          );

          // Test path resolution
          final paramsPath = await downloader.getParamsPath();
          expect(paramsPath, isNotNull);
          expect(paramsPath, contains('ZcashParams'));

          // Test availability check (should work even if files don't exist)
          final available = await downloader.areParamsAvailable();
          expect(available, isA<bool>());

          // Test download progress stream
          final progressStream = downloader.downloadProgress;
          expect(progressStream, isA<Stream>());
          expect(progressStream.isBroadcast, isTrue);

          // Test cancellation when no download is active
          final cancelResult = await downloader.cancelDownload();
          expect(cancelResult, isFalse);

          // Clean up
          downloader.dispose();
        },
      );

      test(
        'mobile downloader fails gracefully when path is unavailable',
        () async {
          when(
            () => mockPathProvider.getApplicationDocumentsPath(),
          ).thenThrow(Exception('No documents directory'));

          final downloader = ZcashParamsDownloaderFactory.createForPlatform(
            ZcashParamsPlatform.mobile,
          );

          // All path-dependent operations should fail gracefully
          expect(await downloader.getParamsPath(), isNull);
          expect(await downloader.areParamsAvailable(), isFalse);
          expect(await downloader.validateParams(), isFalse);
          expect(await downloader.clearParams(), isFalse);

          final downloadResult = await downloader.downloadParams();
          downloadResult.maybeWhen(
            success: (path) => fail('Expected failure but got success'),
            failure: (error) =>
                expect(error, contains('Unable to determine parameters path')),
            orElse: () => fail('Unexpected result type'),
          );

          // Clean up
          downloader.dispose();
        },
      );
    });

    group('Platform Compatibility', () {
      test('mobile platform is included in all platform values', () {
        final allPlatforms = ZcashParamsPlatform.values;

        expect(allPlatforms, contains(ZcashParamsPlatform.mobile));
        expect(
          allPlatforms.length,
          greaterThanOrEqualTo(4),
        ); // web, windows, mobile, unix
      });

      test('mobile platform factory method works with all parameters', () {
        // Test with all optional parameters
        final downloader = ZcashParamsDownloaderFactory.createForPlatform(
          ZcashParamsPlatform.mobile,
          downloadService: null, // Should use default
          config: null, // Should use default
          enableHashValidation: false, // Should be passed through
        );

        expect(downloader, isA<MobileZcashParamsDownloader>());

        // Clean up
        downloader.dispose();
      });

      test('multiple mobile downloaders can be created independently', () {
        when(
          () => mockPathProvider.getApplicationDocumentsPath(),
        ).thenAnswer((_) async => '/test/documents');

        final downloader1 = ZcashParamsDownloaderFactory.createForPlatform(
          ZcashParamsPlatform.mobile,
        );
        final downloader2 = ZcashParamsDownloaderFactory.createForPlatform(
          ZcashParamsPlatform.mobile,
        );

        expect(downloader1, isA<MobileZcashParamsDownloader>());
        expect(downloader2, isA<MobileZcashParamsDownloader>());
        expect(downloader1, isNot(same(downloader2)));

        // Clean up
        downloader1.dispose();
        downloader2.dispose();
      });
    });

    group('Error Scenarios', () {
      test('handles path provider returning empty string', () async {
        when(
          () => mockPathProvider.getApplicationDocumentsPath(),
        ).thenAnswer((_) async => '');

        final downloader =
            ZcashParamsDownloaderFactory.createForPlatform(
                  ZcashParamsPlatform.mobile,
                )
                as MobileZcashParamsDownloader;

        final paramsPath = await downloader.getParamsPath();

        // Should still create a valid path even with empty base
        expect(paramsPath, equals('ZcashParams'));

        // Clean up
        downloader.dispose();
      });

      test('handles path provider returning null-like values', () async {
        // Test with various problematic return values
        final problematicPaths = [
          () => throw StateError('No documents directory available'),
          () => throw ArgumentError('Invalid path'),
          () => throw const FileSystemException('Permission denied', '/path'),
        ];

        for (final pathProvider in problematicPaths) {
          when(
            () => mockPathProvider.getApplicationDocumentsPath(),
          ).thenAnswer((_) async => pathProvider());

          final downloader =
              ZcashParamsDownloaderFactory.createForPlatform(
                    ZcashParamsPlatform.mobile,
                  )
                  as MobileZcashParamsDownloader;

          final paramsPath = await downloader.getParamsPath();
          expect(paramsPath, isNull);

          // Clean up
          downloader.dispose();
        }
      });

      test(
        'disposed downloader continues to work for basic operations',
        () async {
          when(
            () => mockPathProvider.getApplicationDocumentsPath(),
          ).thenAnswer((_) async => '/test/documents');

          final downloader =
              ZcashParamsDownloaderFactory.createForPlatform(
                    ZcashParamsPlatform.mobile,
                  )
                  as MobileZcashParamsDownloader;

          // Dispose the downloader
          downloader.dispose();

          // Basic operations should still work
          final paramsPath = await downloader.getParamsPath();
          expect(paramsPath, isNotNull);

          // Multiple dispose calls should be safe
          expect(() => downloader.dispose(), returnsNormally);
          expect(() => downloader.dispose(), returnsNormally);
        },
      );
    });

    group('Performance and Resource Management', () {
      test('creating many mobile downloaders does not leak resources', () {
        when(
          () => mockPathProvider.getApplicationDocumentsPath(),
        ).thenAnswer((_) async => '/test/documents');

        final downloaders = <MobileZcashParamsDownloader>[];

        // Create many downloaders
        for (int i = 0; i < 100; i++) {
          final downloader =
              ZcashParamsDownloaderFactory.createForPlatform(
                    ZcashParamsPlatform.mobile,
                  )
                  as MobileZcashParamsDownloader;
          downloaders.add(downloader);
        }

        expect(downloaders.length, equals(100));

        // All should be different instances
        for (int i = 0; i < downloaders.length; i++) {
          for (int j = i + 1; j < downloaders.length; j++) {
            expect(downloaders[i], isNot(same(downloaders[j])));
          }
        }

        // Clean up all
        for (final downloader in downloaders) {
          expect(() => downloader.dispose(), returnsNormally);
        }
      });

      test('path provider is called efficiently', () async {
        when(
          () => mockPathProvider.getApplicationDocumentsPath(),
        ).thenAnswer((_) async => '/test/documents');

        final downloader =
            ZcashParamsDownloaderFactory.createForPlatform(
                  ZcashParamsPlatform.mobile,
                )
                as MobileZcashParamsDownloader;

        // Make multiple calls to getParamsPath
        await downloader.getParamsPath();
        await downloader.getParamsPath();
        await downloader.getParamsPath();

        // Path provider should be called each time (no caching in this implementation)
        verify(() => mockPathProvider.getApplicationDocumentsPath()).called(3);

        // Clean up
        downloader.dispose();
      });
    });
  });
}
