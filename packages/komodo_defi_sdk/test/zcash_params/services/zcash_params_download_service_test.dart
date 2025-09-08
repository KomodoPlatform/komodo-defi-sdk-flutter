import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_defi_sdk/src/zcash_params/models/download_progress.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/zcash_params_config.dart';
import 'package:komodo_defi_sdk/src/zcash_params/services/zcash_params_download_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../test_helpers/mock_classes.dart';

void main() {
  group('DefaultZcashParamsDownloadService', () {
    late DefaultZcashParamsDownloadService service;
    late MockHttpClient mockHttpClient;
    late ZcashParamsConfig testConfig;

    // Test data
    final testData = Uint8List.fromList(List.generate(1024, (i) => i % 256));
    final testHash = sha256.convert(testData).toString();

    setUp(() {
      mockHttpClient = MockHttpClient();
      service = DefaultZcashParamsDownloadService(httpClient: mockHttpClient);

      testConfig = const ZcashParamsConfig(
        paramFiles: [
          ZcashParamFile(
            fileName: 'test-spend.params',
            sha256Hash: 'testhash1',
            expectedSize: 1024,
          ),
          ZcashParamFile(
            fileName: 'test-output.params',
            sha256Hash: 'testhash2',
            expectedSize: 2048,
          ),
        ],
        primaryUrl: 'https://test.example.com/downloads/',
        backupUrl: 'https://backup.example.com/downloads/',
        downloadTimeoutSeconds: 30,
      );

      // Register fallback values for mocktail
      registerFallbackValue(Uri.parse('https://example.com'));
      registerFallbackValue(
        http.Request('GET', Uri.parse('https://example.com')),
      );
    });

    tearDown(() {
      service.dispose();
    });

    group('getMissingFiles', () {
      test('returns empty list when all files exist and are valid', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => true);
          when(() => file.path).thenReturn(path);
          when(
            () => file.openRead(),
          ).thenAnswer((_) => Stream.fromIterable([testData]));
          return file;
        }

        final missingFiles = await service.getMissingFiles(
          '/test/dir',
          fileFactory,
          testConfig.copyWith(
            paramFiles: [
              ZcashParamFile(
                fileName: 'test-spend.params',
                sha256Hash: testHash,
                expectedSize: 1024,
              ),
            ],
          ),
        );

        expect(missingFiles, isEmpty);
      });

      test('returns files that do not exist', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => false);
          when(() => file.path).thenReturn(path);
          return file;
        }

        final missingFiles = await service.getMissingFiles(
          '/test/dir',
          fileFactory,
          testConfig,
        );

        expect(
          missingFiles,
          equals(['test-spend.params', 'test-output.params']),
        );
      });

      test('returns files with invalid hashes', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => true);
          when(() => file.path).thenReturn(path);
          when(
            () => file.openRead(),
          ).thenAnswer((_) => Stream.fromIterable([testData]));
          return file;
        }

        final missingFiles = await service.getMissingFiles(
          '/test/dir',
          fileFactory,
          testConfig,
        );

        expect(
          missingFiles,
          equals(['test-spend.params', 'test-output.params']),
        );
      });

      test('handles file read errors gracefully', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => true);
          when(() => file.path).thenReturn(path);
          when(
            () => file.openRead(),
          ).thenThrow(FileSystemException('Read error'));
          return file;
        }

        final missingFiles = await service.getMissingFiles(
          '/test/dir',
          fileFactory,
          testConfig,
        );

        expect(
          missingFiles,
          equals(['test-spend.params', 'test-output.params']),
        );
      });
    });

    group('ensureDirectoryExists', () {
      test('creates directory when it does not exist', () async {
        final mockDirectory = MockDirectory();
        when(() => mockDirectory.existsSync()).thenReturn(false);
        when(
          () => mockDirectory.create(recursive: true),
        ).thenAnswer((_) async => mockDirectory);

        Directory directoryFactory(String path) => mockDirectory;

        await service.ensureDirectoryExists('/test/dir', directoryFactory);

        verify(() => mockDirectory.create(recursive: true)).called(1);
      });

      test('does nothing when directory already exists', () async {
        final mockDirectory = MockDirectory();
        when(() => mockDirectory.existsSync()).thenReturn(true);

        Directory directoryFactory(String path) => mockDirectory;

        await service.ensureDirectoryExists('/test/dir', directoryFactory);

        verifyNever(
          () => mockDirectory.create(recursive: any(named: 'recursive')),
        );
      });

      test('handles directory creation errors', () async {
        final mockDirectory = MockDirectory();
        when(() => mockDirectory.existsSync()).thenReturn(false);
        when(
          () => mockDirectory.create(recursive: true),
        ).thenThrow(FileSystemException('Permission denied'));

        Directory directoryFactory(String path) => mockDirectory;

        expect(
          () => service.ensureDirectoryExists('/test/dir', directoryFactory),
          throwsA(isA<FileSystemException>()),
        );
      });
    });

    group('validateFiles', () {
      test('returns true when all files exist and have valid hashes', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => true);
          when(() => file.path).thenReturn(path);
          when(
            () => file.openRead(),
          ).thenAnswer((_) => Stream.fromIterable([testData]));
          return file;
        }

        final isValid = await service.validateFiles(
          '/test/dir',
          fileFactory,
          testConfig.copyWith(
            paramFiles: [
              ZcashParamFile(
                fileName: 'test-spend.params',
                sha256Hash: testHash,
                expectedSize: 1024,
              ),
            ],
          ),
        );

        expect(isValid, isTrue);
      });

      test('returns false when any file does not exist', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => false);
          when(() => file.path).thenReturn(path);
          return file;
        }

        final isValid = await service.validateFiles(
          '/test/dir',
          fileFactory,
          testConfig,
        );

        expect(isValid, isFalse);
      });

      test('returns false when any file has invalid hash', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => true);
          when(() => file.path).thenReturn(path);
          when(
            () => file.openRead(),
          ).thenAnswer((_) => Stream.fromIterable([testData]));
          return file;
        }

        final isValid = await service.validateFiles(
          '/test/dir',
          fileFactory,
          testConfig, // Uses different hash than testData
        );

        expect(isValid, isFalse);
      });

      test('returns false on exceptions', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(
            () => file.exists(),
          ).thenThrow(FileSystemException('Access denied'));
          when(() => file.path).thenReturn(path);
          return file;
        }

        final isValid = await service.validateFiles(
          '/test/dir',
          fileFactory,
          testConfig,
        );

        expect(isValid, isFalse);
      });
    });

    group('validateFileHash', () {
      test('returns true for valid hash', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => true);
          when(() => file.path).thenReturn(path);
          when(
            () => file.openRead(),
          ).thenAnswer((_) => Stream.fromIterable([testData]));
          return file;
        }

        final isValid = await service.validateFileHash(
          '/test/file.params',
          testHash,
          fileFactory,
        );

        expect(isValid, isTrue);
      });

      test('returns false for invalid hash', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => true);
          when(() => file.path).thenReturn(path);
          when(
            () => file.openRead(),
          ).thenAnswer((_) => Stream.fromIterable([testData]));
          return file;
        }

        final isValid = await service.validateFileHash(
          '/test/file.params',
          'invalidhash',
          fileFactory,
        );

        expect(isValid, isFalse);
      });

      test('is case insensitive', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => true);
          when(() => file.path).thenReturn(path);
          when(
            () => file.openRead(),
          ).thenAnswer((_) => Stream.fromIterable([testData]));
          return file;
        }

        final isValid = await service.validateFileHash(
          '/test/file.params',
          testHash.toUpperCase(),
          fileFactory,
        );

        expect(isValid, isTrue);
      });

      test('returns false when file does not exist', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => false);
          when(() => file.path).thenReturn(path);
          return file;
        }

        final isValid = await service.validateFileHash(
          '/test/file.params',
          testHash,
          fileFactory,
        );

        expect(isValid, isFalse);
      });

      test('handles read errors gracefully', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => true);
          when(() => file.path).thenReturn(path);
          when(
            () => file.openRead(),
          ).thenThrow(FileSystemException('Read error'));
          return file;
        }

        final isValid = await service.validateFileHash(
          '/test/file.params',
          testHash,
          fileFactory,
        );

        expect(isValid, isFalse);
      });
    });

    group('getFileHash', () {
      test('returns correct hash for existing file', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => true);
          when(() => file.path).thenReturn(path);
          when(
            () => file.openRead(),
          ).thenAnswer((_) => Stream.fromIterable([testData]));
          return file;
        }

        final hash = await service.getFileHash(
          '/test/file.params',
          fileFactory,
        );

        expect(hash, equals(testHash));
      });

      test('returns null when file does not exist', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => false);
          when(() => file.path).thenReturn(path);
          return file;
        }

        final hash = await service.getFileHash(
          '/test/file.params',
          fileFactory,
        );

        expect(hash, isNull);
      });

      test('returns null on read errors', () async {
        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => true);
          when(() => file.path).thenReturn(path);
          when(
            () => file.openRead(),
          ).thenThrow(FileSystemException('Read error'));
          return file;
        }

        final hash = await service.getFileHash(
          '/test/file.params',
          fileFactory,
        );

        expect(hash, isNull);
      });
    });

    group('getRemoteFileSize', () {
      test('returns content length from successful HEAD request', () async {
        final mockResponse = MockHttpResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.headers).thenReturn({'content-length': '1024'});
        when(
          () => mockHttpClient.head(any()),
        ).thenAnswer((_) async => mockResponse);

        final size = await service.getRemoteFileSize(
          'https://example.com/file.params',
        );

        expect(size, equals(1024));
      });

      test('returns null when HEAD request fails', () async {
        final mockResponse = MockHttpResponse();
        when(() => mockResponse.statusCode).thenReturn(404);
        when(
          () => mockHttpClient.head(any()),
        ).thenAnswer((_) async => mockResponse);

        final size = await service.getRemoteFileSize(
          'https://example.com/file.params',
        );

        expect(size, isNull);
      });

      test('returns null when content-length header is missing', () async {
        final mockResponse = MockHttpResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.headers).thenReturn(<String, String>{});
        when(
          () => mockHttpClient.head(any()),
        ).thenAnswer((_) async => mockResponse);

        final size = await service.getRemoteFileSize(
          'https://example.com/file.params',
        );

        expect(size, isNull);
      });

      test('returns null when content-length is not a valid number', () async {
        final mockResponse = MockHttpResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(
          () => mockResponse.headers,
        ).thenReturn({'content-length': 'invalid'});
        when(
          () => mockHttpClient.head(any()),
        ).thenAnswer((_) async => mockResponse);

        final size = await service.getRemoteFileSize(
          'https://example.com/file.params',
        );

        expect(size, isNull);
      });

      test('returns null on network errors', () async {
        when(
          () => mockHttpClient.head(any()),
        ).thenThrow(SocketException('Network error'));

        final size = await service.getRemoteFileSize(
          'https://example.com/file.params',
        );

        expect(size, isNull);
      });
    });

    group('clearFiles', () {
      test('successfully deletes existing directory', () async {
        final mockDirectory = MockDirectory();
        when(() => mockDirectory.existsSync()).thenReturn(true);
        when(
          () => mockDirectory.delete(recursive: true),
        ).thenAnswer((_) async => mockDirectory);

        Directory directoryFactory(String path) => mockDirectory;

        final result = await service.clearFiles('/test/dir', directoryFactory);

        expect(result, isTrue);
        verify(() => mockDirectory.delete(recursive: true)).called(1);
      });

      test('returns true when directory does not exist', () async {
        final mockDirectory = MockDirectory();
        when(() => mockDirectory.existsSync()).thenReturn(false);

        Directory directoryFactory(String path) => mockDirectory;

        final result = await service.clearFiles('/test/dir', directoryFactory);

        expect(result, isTrue);
        verifyNever(
          () => mockDirectory.delete(recursive: any(named: 'recursive')),
        );
      });

      test('returns false on deletion errors', () async {
        final mockDirectory = MockDirectory();
        when(() => mockDirectory.existsSync()).thenReturn(true);
        when(
          () => mockDirectory.delete(recursive: true),
        ).thenThrow(FileSystemException('Permission denied'));

        Directory directoryFactory(String path) => mockDirectory;

        final result = await service.clearFiles('/test/dir', directoryFactory);

        expect(result, isFalse);
      });
    });

    group('downloadMissingFiles', () {
      test('returns true for empty missing files list', () async {
        final progressController = StreamController<DownloadProgress>();
        bool isCancelled() => false;

        final result = await service.downloadMissingFiles(
          '/test/dir',
          [], // Empty list
          progressController,
          isCancelled,
          testConfig,
        );

        expect(result, isTrue);
        progressController.close();
      });

      test('returns false when download is cancelled immediately', () async {
        final progressController = StreamController<DownloadProgress>();
        bool isCancelled() => true; // Always cancelled

        final result = await service.downloadMissingFiles(
          '/test/dir',
          ['test-spend.params'],
          progressController,
          isCancelled,
          testConfig,
        );

        expect(result, isFalse);
        progressController.close();
      });

      test('handles timeout errors gracefully', () async {
        when(
          () => mockHttpClient.send(any()),
        ).thenAnswer((_) async => throw TimeoutException('Request timeout'));

        final progressController = StreamController<DownloadProgress>();
        bool isCancelled() => false;

        final result = await service.downloadMissingFiles(
          '/test/dir',
          ['test-spend.params'],
          progressController,
          isCancelled,
          testConfig,
        );

        expect(result, isFalse);
        progressController.close();
      });

      test('handles HTTP client exceptions gracefully', () async {
        when(
          () => mockHttpClient.send(any()),
        ).thenAnswer((_) async => throw HttpException('Connection failed'));

        final progressController = StreamController<DownloadProgress>();
        bool isCancelled() => false;

        final result = await service.downloadMissingFiles(
          '/test/dir',
          ['test-spend.params'],
          progressController,
          isCancelled,
          testConfig,
        );

        expect(result, isFalse);
        progressController.close();
      });
    });

    group('dispose', () {
      test('closes HTTP client', () {
        service.dispose();

        verify(() => mockHttpClient.close()).called(1);
      });

      test('can be called multiple times safely', () {
        service.dispose();
        service.dispose();

        verify(() => mockHttpClient.close()).called(2);
      });
    });

    group('interface methods', () {
      test('implements all required ZcashParamsDownloadService methods', () {
        expect(service, isA<ZcashParamsDownloadService>());

        // Verify that all interface methods are implemented
        expect(service.downloadMissingFiles, isA<Function>());
        expect(service.getMissingFiles, isA<Function>());
        expect(service.ensureDirectoryExists, isA<Function>());
        expect(service.validateFiles, isA<Function>());
        expect(service.validateFileHash, isA<Function>());
        expect(service.getFileHash, isA<Function>());
        expect(service.getRemoteFileSize, isA<Function>());
        expect(service.clearFiles, isA<Function>());
        expect(service.dispose, isA<Function>());
      });
    });

    group('constructor', () {
      test('creates instance with default HTTP client when none provided', () {
        final serviceWithDefaults = DefaultZcashParamsDownloadService();
        expect(serviceWithDefaults, isA<DefaultZcashParamsDownloadService>());
        serviceWithDefaults.dispose();
      });

      test('creates instance with provided HTTP client', () {
        final customClient = MockHttpClient();
        final serviceWithCustomClient = DefaultZcashParamsDownloadService(
          httpClient: customClient,
        );

        expect(
          serviceWithCustomClient,
          isA<DefaultZcashParamsDownloadService>(),
        );

        serviceWithCustomClient.dispose();
        verify(() => customClient.close()).called(1);
      });
    });

    group('edge cases and error handling', () {
      test('handles null or malformed URLs gracefully', () async {
        expect(() => service.getRemoteFileSize(''), returnsNormally);
      });

      test('handles config with no param files', () async {
        final emptyConfig = testConfig.copyWith(paramFiles: []);

        File fileFactory(String path) => MockFile();

        final missingFiles = await service.getMissingFiles(
          '/test/dir',
          fileFactory,
          emptyConfig,
        );

        expect(missingFiles, isEmpty);
      });

      test('handles very long file paths', () async {
        final longPath = 'a' * 1000; // Very long path

        File fileFactory(String path) {
          final file = MockFile();
          when(() => file.exists()).thenAnswer((_) async => false);
          when(() => file.path).thenReturn(path);
          return file;
        }

        final hash = await service.getFileHash(longPath, fileFactory);
        expect(hash, isNull);
      });
    });
  });
}
