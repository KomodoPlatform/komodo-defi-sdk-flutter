import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/src/byte_stream.dart';
import 'package:mocktail/mocktail.dart';

/// Mock HTTP client for testing download functionality
class MockHttpClient extends Mock implements http.Client {}

/// Mock HTTP request for testing
class MockHttpRequest extends Mock implements http.BaseRequest {}

/// Mock HTTP response for testing
class MockHttpResponse extends Mock implements http.Response {}

/// Mock HTTP streamed response for testing download streams
class MockStreamedResponse extends Mock implements http.StreamedResponse {}

/// Mock directory for testing file system operations
class MockDirectory extends Mock implements Directory {}

/// Mock file for testing file operations
class MockFile extends Mock implements File {}

/// Mock file stat for testing file properties
class MockFileStat extends Mock implements FileStat {}

/// Mock IOSink for testing file writing
class MockIOSink extends Mock implements IOSink {}

/// Helper class to create test HTTP responses
class TestHttpResponse {
  /// Creates a successful HTTP response with given data
  static http.Response success(List<int> bodyBytes, {int statusCode = 200}) {
    final response = MockHttpResponse();
    when(() => response.statusCode).thenReturn(statusCode);
    when(() => response.bodyBytes).thenReturn(Uint8List.fromList(bodyBytes));
    when(() => response.body).thenReturn(String.fromCharCodes(bodyBytes));
    return response;
  }

  /// Creates a failed HTTP response with given status code
  static http.Response failure(int statusCode, [String? body]) {
    final response = MockHttpResponse();
    when(() => response.statusCode).thenReturn(statusCode);
    when(() => response.bodyBytes).thenReturn(Uint8List.fromList([]));
    when(() => response.body).thenReturn(body ?? '');
    return response;
  }

  /// Creates a streamed response for testing streaming downloads
  static http.StreamedResponse streamedSuccess(
    List<int> data, {
    int statusCode = 200,
    int? contentLength,
  }) {
    final response = MockStreamedResponse();
    when(() => response.statusCode).thenReturn(statusCode);
    when(() => response.contentLength).thenReturn(contentLength ?? data.length);

    // Create a stream that emits the data in chunks
    final controller = StreamController<List<int>>();
    const chunkSize = 1024;

    // Emit data in chunks to simulate real download
    Future.delayed(Duration.zero, () {
      for (int i = 0; i < data.length; i += chunkSize) {
        final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
        controller.add(data.sublist(i, end));
      }
      controller.close();
    });

    when(
      () => response.stream,
    ).thenAnswer((_) => ByteStream(controller.stream));
    return response;
  }

  /// Creates a streamed response that fails during download
  static http.StreamedResponse streamedFailure(int statusCode) {
    final response = MockStreamedResponse();
    when(() => response.statusCode).thenReturn(statusCode);
    when(() => response.contentLength).thenReturn(null);
    when(() => response.stream).thenAnswer(
      (_) => ByteStream(
        Stream.error(HttpException('Download failed with status $statusCode')),
      ),
    );
    return response;
  }
}

/// Helper class to set up mock file system operations
class TestFileSystem {
  /// Sets up a mock directory that exists and can be created
  static void setupMockDirectory(
    MockDirectory directory, {
    bool exists = true,
    bool canCreate = true,
  }) {
    when(() => directory.exists()).thenAnswer((_) async => exists);

    if (canCreate) {
      when(
        () => directory.create(recursive: any(named: 'recursive')),
      ).thenAnswer((_) async => directory);
    } else {
      when(
        () => directory.create(recursive: any(named: 'recursive')),
      ).thenThrow(FileSystemException('Cannot create directory'));
    }

    when(
      () => directory.delete(recursive: any(named: 'recursive')),
    ).thenAnswer((_) async => directory);
  }

  /// Sets up a mock file with specified properties
  static void setupMockFile(
    MockFile file, {
    bool exists = false,
    int size = 0,
    bool canWrite = true,
    bool canDelete = true,
  }) {
    when(() => file.exists()).thenAnswer((_) async => exists);

    final stat = MockFileStat();
    when(() => stat.size).thenReturn(size);
    when(() => file.stat()).thenAnswer((_) async => stat);

    if (canWrite) {
      final sink = MockIOSink();
      when(() => sink.add(any())).thenReturn(null);
      when(() => sink.close()).thenAnswer((_) async {});
      when(() => file.openWrite()).thenReturn(sink);
      when(() => file.writeAsBytes(any())).thenAnswer((_) async => file);
    } else {
      when(
        () => file.openWrite(),
      ).thenThrow(FileSystemException('Cannot write to file'));
      when(
        () => file.writeAsBytes(any()),
      ).thenThrow(FileSystemException('Cannot write to file'));
    }

    if (canDelete) {
      when(() => file.delete()).thenAnswer((_) async => file);
    } else {
      when(
        () => file.delete(),
      ).thenThrow(FileSystemException('Cannot delete file'));
    }
  }

  /// Sets up mock environment variables for testing
  static void setupMockEnvironment(Map<String, String> environment) {
    // Note: In real tests, you would use a package like `platform`
    // that allows mocking Platform.environment
    // For now, this is a placeholder for the pattern
  }
}

/// Helper class for creating test data
class TestData {
  /// Sample ZCash parameter file data (small for testing)
  static List<int> get sampleParamData => List.generate(1024, (i) => i % 256);

  /// Large sample data for testing progress reporting
  static List<int> get largeSampleData => List.generate(
    10 * 1024 * 1024, // 10 MB
    (i) => i % 256,
  );

  /// Creates test data of specified size
  static List<int> createTestData(int sizeInBytes) {
    return List.generate(sizeInBytes, (i) => i % 256);
  }

  /// Sample file names for testing
  static const List<String> sampleFileNames = [
    'test-spend.params',
    'test-output.params',
    'test-groth16.params',
  ];

  /// Sample URLs for testing
  static const List<String> sampleUrls = [
    'https://test.example.com/downloads/',
    'https://backup.example.com/downloads/',
  ];

  /// Sample Windows APPDATA path
  static const String sampleWindowsAppData =
      r'C:\Users\TestUser\AppData\Roaming';

  /// Sample Unix HOME path
  static const String sampleUnixHome = '/home/testuser';

  /// Sample macOS HOME path
  static const String sampleMacOSHome = '/Users/testuser';
}

/// Helper class for testing download progress
class ProgressCapture {
  final List<double> _percentages = [];
  final List<String> _fileNames = [];
  final List<int> _downloadedBytes = [];
  final List<int> _totalBytes = [];

  /// Captures progress from a download progress stream
  StreamSubscription<T> captureProgress<T>(
    Stream<T> stream,
    void Function(T) captureFunction,
  ) {
    return stream.listen(captureFunction);
  }

  /// Records a progress event
  void recordProgress(String fileName, int downloaded, int total) {
    _fileNames.add(fileName);
    _downloadedBytes.add(downloaded);
    _totalBytes.add(total);
    _percentages.add(total > 0 ? (downloaded / total) * 100 : 0);
  }

  /// Gets all recorded percentages
  List<double> get percentages => List.unmodifiable(_percentages);

  /// Gets all recorded file names
  List<String> get fileNames => List.unmodifiable(_fileNames);

  /// Gets all recorded downloaded byte counts
  List<int> get downloadedBytes => List.unmodifiable(_downloadedBytes);

  /// Gets all recorded total byte counts
  List<int> get totalBytes => List.unmodifiable(_totalBytes);

  /// Clears all recorded data
  void clear() {
    _percentages.clear();
    _fileNames.clear();
    _downloadedBytes.clear();
    _totalBytes.clear();
  }

  /// Gets the last recorded percentage
  double? get lastPercentage =>
      _percentages.isNotEmpty ? _percentages.last : null;

  /// Checks if progress was reported for a specific file
  bool hasProgressFor(String fileName) => _fileNames.contains(fileName);

  /// Gets progress count for a specific file
  int getProgressCount(String fileName) {
    return _fileNames.where((name) => name == fileName).length;
  }
}

/// Helper for testing error scenarios
class ErrorScenarios {
  /// Creates an HTTP exception
  static HttpException httpException(String message) {
    return HttpException(message);
  }

  /// Creates a file system exception
  static FileSystemException fileSystemException(String message) {
    return FileSystemException(message);
  }

  /// Creates a timeout exception
  static TimeoutException timeoutException(String message) {
    return TimeoutException(message);
  }

  /// Creates a socket exception
  static SocketException socketException(String message) {
    return SocketException(message);
  }
}

/// Test utilities for common operations
class TestUtils {
  /// Waits for a stream to emit a specific number of events
  static Future<List<T>> collectStreamEvents<T>(
    Stream<T> stream,
    int expectedCount, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final events = <T>[];
    final completer = Completer<List<T>>();
    late StreamSubscription<T> subscription;

    subscription = stream.listen(
      (event) {
        events.add(event);
        if (events.length >= expectedCount) {
          subscription.cancel();
          completer.complete(events);
        }
      },
      onError: (error) {
        subscription.cancel();
        completer.completeError(error);
      },
      onDone: () {
        subscription.cancel();
        completer.complete(events);
      },
    );

    return completer.future.timeout(timeout);
  }

  /// Creates a temporary directory for testing
  static Future<Directory> createTempDirectory() async {
    final tempDir = await Directory.systemTemp.createTemp('zcash_params_test');
    return tempDir;
  }

  /// Cleans up a temporary directory
  static Future<void> cleanupTempDirectory(Directory dir) async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Creates a temporary file with specified content
  static Future<File> createTempFile(
    Directory parent,
    String name,
    List<int> content,
  ) async {
    final file = File('${parent.path}/$name');
    await file.writeAsBytes(content);
    return file;
  }

  /// Verifies that a future completes within a specified time
  static Future<T> expectTimely<T>(
    Future<T> future, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    return future.timeout(timeout);
  }

  /// Verifies that a future throws a specific exception type
  static Future<void> expectThrows<T extends Exception>(
    Future<void> future,
  ) async {
    try {
      await future;
      throw AssertionError('Expected exception of type $T but none was thrown');
    } catch (e) {
      if (e is! T) {
        throw AssertionError(
          'Expected exception of type $T but got ${e.runtimeType}',
        );
      }
    }
  }
}
