import 'package:komodo_defi_sdk/src/zcash_params/models/download_result.dart';
import 'package:test/test.dart';

void main() {
  group('DownloadResult', () {
    group('success constructor', () {
      test('creates successful result with path', () {
        const result = DownloadResult.success(paramsPath: '/test/path');

        expect(result, isA<DownloadResultSuccess>());
        result.when(
          success: (paramsPath) {
            expect(paramsPath, equals('/test/path'));
          },
          failure: (error) {
            fail('Expected success but got failure');
          },
        );
      });

      test('creates successful result with empty path', () {
        const result = DownloadResult.success(paramsPath: '');

        expect(result, isA<DownloadResultSuccess>());
        result.when(
          success: (paramsPath) {
            expect(paramsPath, equals(''));
          },
          failure: (error) {
            fail('Expected success but got failure');
          },
        );
      });
    });

    group('failure constructor', () {
      test('creates failed result with error message', () {
        const result = DownloadResult.failure(error: 'Download failed');

        expect(result, isA<DownloadResultFailure>());
        result.when(
          success: (paramsPath) {
            fail('Expected failure but got success');
          },
          failure: (error) {
            expect(error, equals('Download failed'));
          },
        );
      });

      test('creates failed result with empty error', () {
        const result = DownloadResult.failure(error: '');

        expect(result, isA<DownloadResultFailure>());
        result.when(
          success: (paramsPath) {
            fail('Expected failure but got success');
          },
          failure: (error) {
            expect(error, equals(''));
          },
        );
      });
    });

    group('pattern matching', () {
      test('when method works correctly for success', () {
        const result = DownloadResult.success(paramsPath: '/test/path');

        final output = result.when(
          success: (paramsPath) => 'Success: $paramsPath',
          failure: (error) => 'Failure: $error',
        );

        expect(output, equals('Success: /test/path'));
      });

      test('when method works correctly for failure', () {
        const result = DownloadResult.failure(error: 'Test error');

        final output = result.when(
          success: (paramsPath) => 'Success: $paramsPath',
          failure: (error) => 'Failure: $error',
        );

        expect(output, equals('Failure: Test error'));
      });

      test('maybeWhen method works correctly', () {
        const result = DownloadResult.success(paramsPath: '/test/path');

        final output = result.maybeWhen(
          success: (paramsPath) => 'Success: $paramsPath',
          orElse: () => 'Unknown',
        );

        expect(output, equals('Success: /test/path'));
      });

      test('map method works correctly', () {
        const result = DownloadResult.success(paramsPath: '/test/path');

        final output = result.map(
          success: (success) => 'Success with path: ${success.paramsPath}',
          failure: (failure) => 'Failure with error: ${failure.error}',
        );

        expect(output, equals('Success with path: /test/path'));
      });
    });

    group('copyWith', () {
      test('copyWith works for success result', () {
        const original = DownloadResult.success(paramsPath: '/original/path');

        original.map(
          success: (successResult) {
            final copied = successResult.copyWith();
            expect(copied, equals(successResult));
            expect(identical(copied, successResult), isFalse);
            return null;
          },
          failure: (_) {
            fail('Expected success but got failure');
            return null;
          },
        );
      });

      test('copyWith works for failure result', () {
        const original = DownloadResult.failure(error: 'Original error');

        original.map(
          success: (_) {
            fail('Expected failure but got success');
            return null;
          },
          failure: (failureResult) {
            final copied = failureResult.copyWith();
            expect(copied, equals(failureResult));
            expect(identical(copied, failureResult), isFalse);
            return null;
          },
        );
      });
    });

    group('equality and hashCode', () {
      test('returns true for identical successful results', () {
        const result1 = DownloadResult.success(paramsPath: '/test/path');
        const result2 = DownloadResult.success(paramsPath: '/test/path');

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('returns true for identical failed results', () {
        const result1 = DownloadResult.failure(error: 'Test error');
        const result2 = DownloadResult.failure(error: 'Test error');

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('returns false for success vs failure', () {
        const result1 = DownloadResult.success(paramsPath: '/test/path');
        const result2 = DownloadResult.failure(error: 'Test error');

        expect(result1, isNot(equals(result2)));
      });

      test('returns false for different paths', () {
        const result1 = DownloadResult.success(paramsPath: '/test/path1');
        const result2 = DownloadResult.success(paramsPath: '/test/path2');

        expect(result1, isNot(equals(result2)));
      });

      test('returns false for different errors', () {
        const result1 = DownloadResult.failure(error: 'Error 1');
        const result2 = DownloadResult.failure(error: 'Error 2');

        expect(result1, isNot(equals(result2)));
      });

      test('returns true for same instance', () {
        const result = DownloadResult.success(paramsPath: '/test/path');

        expect(result, equals(result));
      });

      test('returns false for different types', () {
        const result = DownloadResult.success(paramsPath: '/test/path');

        expect(result, isNot(equals('not a download result')));
      });
    });

    group('JSON serialization', () {
      test('can serialize and deserialize success result', () {
        const original = DownloadResult.success(paramsPath: '/test/path');
        final json = original.toJson();
        final deserialized = DownloadResult.fromJson(json);

        expect(deserialized, equals(original));
      });

      test('can serialize and deserialize failure result', () {
        const original = DownloadResult.failure(error: 'Test error');
        final json = original.toJson();
        final deserialized = DownloadResult.fromJson(json);

        expect(deserialized, equals(original));
      });
    });

    group('toString', () {
      test('returns meaningful string for success', () {
        const result = DownloadResult.success(paramsPath: '/test/path');
        final str = result.toString();

        expect(str, contains('DownloadResult'));
        expect(str, contains('/test/path'));
      });

      test('returns meaningful string for failure', () {
        const result = DownloadResult.failure(error: 'Test error');
        final str = result.toString();

        expect(str, contains('DownloadResult'));
        expect(str, contains('Test error'));
      });
    });

    group('edge cases', () {
      test('handles very long path', () {
        final longPath = '/very/long/path' * 100;
        final result = DownloadResult.success(paramsPath: longPath)
          ..when(
            success: (paramsPath) {
              expect(paramsPath, equals(longPath));
            },
            failure: (error) {
              fail('Expected success but got failure');
            },
          );
      });

      test('handles very long error message', () {
        final longError = 'Very long error message ' * 100;
        final result = DownloadResult.failure(error: longError)
          ..when(
            success: (paramsPath) {
              fail('Expected failure but got success');
            },
            failure: (error) {
              expect(error, equals(longError));
            },
          );
      });

      test('handles unicode characters in path', () {
        const unicodePath = '/test/ñáéíóú/中文/🚀/path';
        const result = DownloadResult.success(paramsPath: unicodePath);

        result..when(
          success: (paramsPath) {
            expect(paramsPath, equals(unicodePath));
          },
          failure: (error) {
            fail('Expected success but got failure');
          },
        );
      });

      test('handles unicode characters in error', () {
        const unicodeError = 'Error with ñáéíóú and 中文 and 🚀';
        const result = DownloadResult.failure(error: unicodeError);

        result.when(
          success: (paramsPath) {
            fail('Expected failure but got success');
          },
          failure: (error) {
            expect(error, equals(unicodeError));
          },
        );
      });
    });
  });
}
