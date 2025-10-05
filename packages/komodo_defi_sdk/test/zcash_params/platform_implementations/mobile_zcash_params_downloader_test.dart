import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/download_progress.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/download_result.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/zcash_params_config.dart';
import 'package:komodo_defi_sdk/src/zcash_params/platforms/mobile_zcash_params_downloader.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../test_helpers/mock_classes.dart';

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {}

void main() {
  group('MobileZcashParamsDownloader', () {
    late MockZcashParamsDownloadService mockDownloadService;
    late MockPathProviderPlatform mockPathProvider;
    late MobileZcashParamsDownloader downloader;
    late Directory testDirectory;
    late File testFile;

    const testDirectoryPath = '/test/documents/ZcashParams';
    const testFilePath = '/test/documents/ZcashParams/test.params';
    const testDocumentsPath = '/test/documents';

    setUpAll(() {
      registerFallbackValue(Directory(''));
      registerFallbackValue(File(''));
      registerFallbackValue(ZcashParamsConfig.defaultConfig);
      registerFallbackValue(StreamController<DownloadProgress>());
    });

    setUp(() {
      mockDownloadService = MockZcashParamsDownloadService();
      mockPathProvider = MockPathProviderPlatform();
      testDirectory = MockDirectory();
      testFile = MockFile();

      // Setup path provider mock
      PathProviderPlatform.instance = mockPathProvider;
      when(
        () => mockPathProvider.getApplicationDocumentsPath(),
      ).thenAnswer((_) async => testDocumentsPath);

      downloader = MobileZcashParamsDownloader(
        downloadService: mockDownloadService,
        directoryFactory: (_) => testDirectory,
        fileFactory: (_) => testFile,
      );
    });

    tearDown(() {
      downloader.dispose();
    });

    group('getParamsPath', () {
      test('returns correct path in application documents directory', () async {
        final path = await downloader.getParamsPath();

        expect(path, equals(testDirectoryPath));
        verify(() => mockPathProvider.getApplicationDocumentsPath()).called(1);
      });

      test('returns null when path provider throws exception', () async {
        when(
          () => mockPathProvider.getApplicationDocumentsPath(),
        ).thenThrow(Exception('Path provider error'));

        final path = await downloader.getParamsPath();

        expect(path, isNull);
      });
    });

    group('downloadParams', () {
      setUp(() {
        when(
          () => mockDownloadService.ensureDirectoryExists(any(), any()),
        ).thenAnswer((_) async {});

        when(
          () => mockDownloadService.getMissingFiles(any(), any(), any()),
        ).thenAnswer((_) async => []);
      });

      test('succeeds when no files are missing', () async {
        final result = await downloader.downloadParams();

        expect(result, isA<DownloadResultSuccess>());
        result.when(
          success: (paramsPath) {
            expect(paramsPath, equals(testDirectoryPath));
          },
          failure: (error) {
            fail('Expected success but got failure: $error');
          },
        );

        verify(
          () => mockDownloadService.ensureDirectoryExists(
            testDirectoryPath,
            any(),
          ),
        ).called(1);

        verify(
          () => mockDownloadService.getMissingFiles(
            testDirectoryPath,
            any(),
            any(),
          ),
        ).called(1);
      });

      test('downloads missing files successfully', () async {
        const missingFiles = ['sapling-spend.params', 'sapling-output.params'];

        when(
          () => mockDownloadService.getMissingFiles(any(), any(), any()),
        ).thenAnswer((_) async => missingFiles);

        when(
          () => mockDownloadService.downloadMissingFiles(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((_) async => true);

        final result = await downloader.downloadParams();

        expect(result, isA<DownloadResultSuccess>());

        verify(
          () => mockDownloadService.downloadMissingFiles(
            testDirectoryPath,
            missingFiles,
            any(),
            any(),
            any(),
          ),
        ).called(1);
      });

      test('fails when download service fails', () async {
        const missingFiles = ['sapling-spend.params'];

        when(
          () => mockDownloadService.getMissingFiles(any(), any(), any()),
        ).thenAnswer((_) async => missingFiles);

        when(
          () => mockDownloadService.downloadMissingFiles(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((_) async => false);

        final result = await downloader.downloadParams();

        expect(result, isA<DownloadResultFailure>());
        result.when(
          success: (paramsPath) {
            fail('Expected failure but got success: $paramsPath');
          },
          failure: (error) {
            expect(
              error,
              equals('Failed to download one or more parameter files'),
            );
          },
        );
      });

      test('fails when getParamsPath returns null', () async {
        when(
          () => mockPathProvider.getApplicationDocumentsPath(),
        ).thenThrow(Exception('Path error'));

        final result = await downloader.downloadParams();

        expect(result, isA<DownloadResultFailure>());
        result.when(
          success: (paramsPath) {
            fail('Expected failure but got success: $paramsPath');
          },
          failure: (error) {
            expect(error, equals('Unable to determine parameters path'));
          },
        );
      });

      test('prevents concurrent downloads', () async {
        when(
          () => mockDownloadService.getMissingFiles(any(), any(), any()),
        ).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return <String>[];
        });

        // Start first download
        final future1 = downloader.downloadParams();

        // Start second download immediately
        final future2 = downloader.downloadParams();

        final results = await Future.wait([future1, future2]);

        // First should succeed, second should fail with "already in progress"
        expect(results[0], isA<DownloadResultSuccess>());
        expect(results[1], isA<DownloadResultFailure>());

        results[1].when(
          success: (paramsPath) {
            fail('Expected failure but got success: $paramsPath');
          },
          failure: (error) {
            expect(error, equals('Download already in progress'));
          },
        );
      });
    });

    group('areParamsAvailable', () {
      test('returns true when no files are missing', () async {
        when(
          () => mockDownloadService.getMissingFiles(any(), any(), any()),
        ).thenAnswer((_) async => []);

        final available = await downloader.areParamsAvailable();

        expect(available, isTrue);
      });

      test('returns false when files are missing', () async {
        when(
          () => mockDownloadService.getMissingFiles(any(), any(), any()),
        ).thenAnswer((_) async => ['sapling-spend.params']);

        final available = await downloader.areParamsAvailable();

        expect(available, isFalse);
      });

      test('returns false when getParamsPath returns null', () async {
        when(
          () => mockPathProvider.getApplicationDocumentsPath(),
        ).thenThrow(Exception('Path error'));

        final available = await downloader.areParamsAvailable();

        expect(available, isFalse);
      });
    });

    group('validateParams', () {
      test('delegates to download service', () async {
        when(
          () => mockDownloadService.validateFiles(any(), any(), any()),
        ).thenAnswer((_) async => true);

        final result = await downloader.validateParams();

        expect(result, isTrue);
        verify(
          () => mockDownloadService.validateFiles(
            testDirectoryPath,
            any(),
            any(),
          ),
        ).called(1);
      });

      test('returns false when getParamsPath returns null', () async {
        when(
          () => mockPathProvider.getApplicationDocumentsPath(),
        ).thenThrow(Exception('Path error'));

        final result = await downloader.validateParams();

        expect(result, isFalse);
      });
    });

    group('validateFileHash', () {
      test('delegates to download service', () async {
        const filePath = '/test/file.params';
        const expectedHash = 'abcd1234';

        when(
          () => mockDownloadService.validateFileHash(any(), any(), any()),
        ).thenAnswer((_) async => true);

        final result = await downloader.validateFileHash(
          filePath,
          expectedHash,
        );

        expect(result, isTrue);
        verify(
          () => mockDownloadService.validateFileHash(
            filePath,
            expectedHash,
            any(),
          ),
        ).called(1);
      });
    });

    group('getFileHash', () {
      test('delegates to download service', () async {
        const filePath = '/test/file.params';
        const expectedHash = 'abcd1234';

        when(
          () => mockDownloadService.getFileHash(any(), any()),
        ).thenAnswer((_) async => expectedHash);

        final result = await downloader.getFileHash(filePath);

        expect(result, equals(expectedHash));
        verify(
          () => mockDownloadService.getFileHash(filePath, any()),
        ).called(1);
      });
    });

    group('clearParams', () {
      test('delegates to download service', () async {
        when(
          () => mockDownloadService.clearFiles(any(), any()),
        ).thenAnswer((_) async => true);

        final result = await downloader.clearParams();

        expect(result, isTrue);
        verify(
          () => mockDownloadService.clearFiles(testDirectoryPath, any()),
        ).called(1);
      });

      test('returns false when getParamsPath returns null', () async {
        when(
          () => mockPathProvider.getApplicationDocumentsPath(),
        ).thenThrow(Exception('Path error'));

        final result = await downloader.clearParams();

        expect(result, isFalse);
      });
    });

    group('downloadProgress', () {
      test('provides broadcast stream', () {
        final stream = downloader.downloadProgress;

        expect(stream, isA<Stream<DownloadProgress>>());
        expect(stream.isBroadcast, isTrue);
      });
    });

    group('cancelDownload', () {
      test('returns false when no download is in progress', () async {
        final result = await downloader.cancelDownload();

        expect(result, isFalse);
      });

      test('returns true and cancels when download is in progress', () async {
        when(
          () => mockDownloadService.getMissingFiles(any(), any(), any()),
        ).thenAnswer((_) async => ['test.params']);

        when(
          () => mockDownloadService.downloadMissingFiles(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((invocation) async {
          final isCancelledCallback =
              invocation.positionalArguments[3] as bool Function();

          // Simulate checking cancellation during download
          await Future<void>.delayed(const Duration(milliseconds: 50));
          if (isCancelledCallback()) {
            return false;
          }
          return true;
        });

        when(
          () => mockDownloadService.ensureDirectoryExists(any(), any()),
        ).thenAnswer((_) async {});

        // Start download
        final downloadFuture = downloader.downloadParams();

        // Cancel after short delay
        await Future<void>.delayed(const Duration(milliseconds: 25));
        final cancelResult = await downloader.cancelDownload();

        expect(cancelResult, isTrue);

        // Download should fail due to cancellation
        final downloadResult = await downloadFuture;
        expect(downloadResult, isA<DownloadResultFailure>());
      });
    });

    group('dispose', () {
      test('disposes download service and closes progress controller', () {
        // Verify no exception is thrown
        expect(() => downloader.dispose(), returnsNormally);

        // Multiple dispose calls should be safe
        expect(() => downloader.dispose(), returnsNormally);
      });
    });

    group('error handling', () {
      test('handles download service exceptions gracefully', () async {
        when(
          () => mockDownloadService.ensureDirectoryExists(any(), any()),
        ).thenThrow(Exception('Directory creation failed'));

        final result = await downloader.downloadParams();

        expect(result, isA<DownloadResultFailure>());
      });

      test('handles path provider exceptions in multiple methods', () async {
        when(
          () => mockPathProvider.getApplicationDocumentsPath(),
        ).thenThrow(Exception('Path provider error'));

        expect(await downloader.getParamsPath(), isNull);
        expect(await downloader.areParamsAvailable(), isFalse);
        expect(await downloader.validateParams(), isFalse);
        expect(await downloader.clearParams(), isFalse);

        final downloadResult = await downloader.downloadParams();
        expect(downloadResult, isA<DownloadResultFailure>());
      });
    });
  });
}
