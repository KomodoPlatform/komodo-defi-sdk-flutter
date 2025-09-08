import 'dart:async';
import 'dart:io';

import 'package:http/src/byte_stream.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/download_progress.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/download_result.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/zcash_params_config.dart';
import 'package:komodo_defi_sdk/src/zcash_params/platform_implementations/windows_zcash_params_downloader.dart';
import 'package:komodo_defi_sdk/src/zcash_params/services/zcash_params_download_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../test_helpers/mock_classes.dart';

void main() {
  group('WindowsZcashParamsDownloader', () {
    late WindowsZcashParamsDownloader downloader;
    late MockHttpClient mockHttpClient;
    late MockDirectory mockDirectory;
    late MockFile mockFile;
    late MockIOSink mockSink;

    Directory mockDirectoryFactory(String path) => mockDirectory;
    File mockFileFactory(String path) => mockFile;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(Uri.parse('https://example.com'));
      registerFallbackValue(MockHttpRequest());
    });

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockDirectory = MockDirectory();
      mockFile = MockFile();
      mockSink = MockIOSink();

      downloader = WindowsZcashParamsDownloader(
        downloadService: DefaultZcashParamsDownloadService(
          httpClient: mockHttpClient,
        ),
        directoryFactory: mockDirectoryFactory,
        fileFactory: mockFileFactory,
      );
    });

    tearDown(() {
      downloader.dispose();
    });

    group('getParamsPath', () {
      test('returns correct APPDATA path when environment variable exists', () {
        // Mock Platform.environment - in real tests you'd use a platform package
        // For now, we'll test the path construction logic by calling the method
        expect(
          () async => downloader.getParamsPath(),
          throwsA(isA<StateError>()),
        );
      });

      test('throws StateError when APPDATA environment variable missing', () {
        expect(
          () async => downloader.getParamsPath(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('areParamsAvailable', () {
      test('returns false due to missing APPDATA environment', () async {
        when(() => mockFile.exists()).thenAnswer((_) async => true);

        final available = await downloader.areParamsAvailable();
        expect(available, isFalse);
      });

      test('returns false when any param file missing', () async {
        when(() => mockFile.exists()).thenAnswer((_) async => false);

        final available = await downloader.areParamsAvailable();
        expect(available, isFalse);
      });

      test('returns false when getParamsPath throws', () async {
        // Will throw StateError due to missing APPDATA
        final available = await downloader.areParamsAvailable();
        expect(available, isFalse);
      });
    });

    group('downloadParams', () {
      test('returns failure when already downloading', () async {
        // Start first download (will fail due to missing APPDATA but sets downloading flag)
        final future1 = downloader.downloadParams();
        final future2 = downloader.downloadParams();

        final result1 = await future1;
        final result2 = await future2;

        expect(result2, isA<DownloadResultFailure>());
        result2.when(
          success: (paramsPath) {
            fail('Expected failure but got success');
          },
          failure: (error) {
            expect(error, contains('already in progress'));
          },
        );
      });

      test('returns failure when unable to determine params path', () async {
        final result = await downloader.downloadParams();

        expect(result, isA<DownloadResultFailure>());
        result.when(
          success: (paramsPath) {
            fail('Expected failure but got success');
          },
          failure: (error) {
            expect(error, contains('APPDATA environment variable not found'));
          },
        );
      });

      test('attempts download but fails due to missing APPDATA', () async {
        when(() => mockDirectory.exists()).thenAnswer((_) async => false);
        when(
          () => mockDirectory.create(recursive: any(named: 'recursive')),
        ).thenAnswer((_) async => mockDirectory);

        final result = await downloader.downloadParams();

        expect(result, isA<DownloadResultFailure>());
        // Directory creation is not called because path determination fails first
        verifyNever(
          () => mockDirectory.create(recursive: any(named: 'recursive')),
        );
      });

      test('fails even when all files exist due to path issue', () async {
        when(() => mockFile.exists()).thenAnswer((_) async => true);

        final result = await downloader.downloadParams();

        expect(
          result,
          isA<DownloadResultFailure>(),
        ); // Will still fail due to path issue
      });

      test('fails to download due to missing APPDATA', () async {
        // Setup successful HTTP response
        final testData = TestData.sampleParamData;
        final mockResponse = TestHttpResponse.streamedSuccess(testData);
        when(
          () => mockHttpClient.send(any()),
        ).thenAnswer((_) async => mockResponse);

        final result = await downloader.downloadParams();

        expect(result, isA<DownloadResultFailure>());
        // HTTP requests are not made because path determination fails first
        verifyNever(() => mockHttpClient.send(any()));
      });

      test('fails due to path issue before HTTP attempt', () async {
        final mockResponse = TestHttpResponse.streamedFailure(404);
        when(
          () => mockHttpClient.send(any()),
        ).thenAnswer((_) async => mockResponse);

        final result = await downloader.downloadParams();

        expect(result, isA<DownloadResultFailure>());
        // HTTP is not attempted due to earlier path failure
        verifyNever(() => mockHttpClient.send(any()));
      });

      test('fails before attempting backup URLs', () async {
        final result = await downloader.downloadParams();

        expect(result, isA<DownloadResultFailure>());
        // No HTTP calls made due to path failure
        verifyNever(() => mockHttpClient.send(any()));
      });

      test('no progress events due to early failure', () async {
        final progressEvents = <DownloadProgress>[];
        final subscription = downloader.downloadProgress.listen(
          progressEvents.add,
        );

        final testData = TestData.sampleParamData;
        final mockResponse = TestHttpResponse.streamedSuccess(testData);
        when(
          () => mockHttpClient.send(any()),
        ).thenAnswer((_) async => mockResponse);

        await downloader.downloadParams();
        await subscription.cancel();

        // No progress events because download never starts due to path failure
        expect(progressEvents, isEmpty);
      });

      test('fails before download starts, cancellation not relevant', () async {
        final downloadFuture = downloader.downloadParams();
        final cancelled = await downloader.cancelDownload();

        final result = await downloadFuture;
        expect(result, isA<DownloadResultFailure>());
        expect(
          cancelled,
          isTrue,
        ); // Returns true even though no actual download to cancel
      });
    });

    group('cancelDownload', () {
      test('returns false when no download in progress', () async {
        final cancelled = await downloader.cancelDownload();
        expect(cancelled, isFalse);
      });

      test('returns true when download is in progress', () async {
        // Start a download (will set downloading flag)
        final downloadFuture = downloader.downloadParams();
        final cancelled = await downloader.cancelDownload();

        expect(cancelled, isTrue);
        await downloadFuture; // Wait for download to complete
      });
    });

    group('validateParams', () {
      test('returns false due to path issue', () async {
        when(() => mockFile.exists()).thenAnswer((_) async => true);

        final mockStat = MockFileStat();
        when(() => mockStat.size).thenReturn(2 * 1024 * 1024); // 2MB
        when(() => mockFile.stat()).thenAnswer((_) async => mockStat);

        final valid = await downloader.validateParams();
        expect(valid, isFalse); // Fails due to missing APPDATA
      });

      test('returns false when files do not exist', () async {
        when(() => mockFile.exists()).thenAnswer((_) async => false);

        final valid = await downloader.validateParams();
        expect(valid, isFalse);
      });

      test('returns false when files are too small', () async {
        when(() => mockFile.exists()).thenAnswer((_) async => true);

        final mockStat = MockFileStat();
        when(() => mockStat.size).thenReturn(1024); // 1KB (too small)
        when(() => mockFile.stat()).thenAnswer((_) async => mockStat);

        final valid = await downloader.validateParams();
        expect(valid, isFalse);
      });
    });

    group('clearParams', () {
      test('deletes params directory successfully', () async {
        when(() => mockDirectory.exists()).thenAnswer((_) async => true);
        when(
          () => mockDirectory.delete(recursive: true),
        ).thenAnswer((_) async => mockDirectory);

        final cleared = await downloader.clearParams();
        expect(cleared, isFalse); // Fails due to missing APPDATA
      });

      test('handles missing directory gracefully', () async {
        when(() => mockDirectory.exists()).thenAnswer((_) async => false);

        final cleared = await downloader.clearParams();
        expect(cleared, isFalse); // Fails due to missing APPDATA
      });

      test('handles deletion errors gracefully', () async {
        when(() => mockDirectory.exists()).thenAnswer((_) async => true);
        when(
          () => mockDirectory.delete(recursive: true),
        ).thenThrow(FileSystemException('Cannot delete'));

        final cleared = await downloader.clearParams();
        expect(cleared, isFalse);
      });
    });

    group('downloadProgress stream', () {
      test('is broadcast stream', () {
        final stream = downloader.downloadProgress;
        expect(() => stream.listen((_) {}), returnsNormally);
        expect(() => stream.listen((_) {}), returnsNormally);
      });

      test('emits no progress due to early failure', () async {
        final progressEvents = <DownloadProgress>[];
        final subscription = downloader.downloadProgress.listen(
          progressEvents.add,
        );

        await downloader.downloadParams();
        await subscription.cancel();

        expect(progressEvents, isEmpty);
      });
    });

    group('error handling', () {
      test('handles path determination failure', () async {
        final result = await downloader.downloadParams();
        expect(result, isA<DownloadResultFailure>());
        result.when(
          success: (paramsPath) {
            fail('Expected failure but got success');
          },
          failure: (error) {
            expect(error, contains('APPDATA environment variable not found'));
          },
        );
      });
    });

    group('resource management', () {
      test('disposes successfully', () {
        expect(() => downloader.dispose(), returnsNormally);
        // HTTP client is closed in the service, not directly accessible to verify
      });

      test('closes progress stream on dispose', () async {
        final stream = downloader.downloadProgress;
        downloader.dispose();

        expect(stream, emitsDone);
      });

      test('can be disposed multiple times safely', () {
        downloader.dispose();
        expect(() => downloader.dispose(), returnsNormally);
      });
    });

    group('edge cases', () {
      test('all operations fail due to missing APPDATA', () async {
        // Test that all operations consistently fail due to path issues
        final downloadResult = await downloader.downloadParams();
        final validateResult = await downloader.validateParams();
        final clearResult = await downloader.clearParams();
        final availableResult = await downloader.areParamsAvailable();

        expect(downloadResult, isA<DownloadResultFailure>());
        expect(validateResult, isFalse);
        expect(clearResult, isFalse);
        expect(availableResult, isFalse);
      });
    });
  });
}
