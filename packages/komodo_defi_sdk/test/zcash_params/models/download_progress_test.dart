import 'package:komodo_defi_sdk/src/zcash_params/models/download_progress.dart';
import 'package:test/test.dart';

void main() {
  group('DownloadProgress', () {
    group('constructor', () {
      test('creates instance with all parameters', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 500,
          total: 1000,
        );

        expect(progress.fileName, equals('test.params'));
        expect(progress.downloaded, equals(500));
        expect(progress.total, equals(1000));
      });

      test('creates instance with zero values', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 0,
          total: 0,
        );

        expect(progress.fileName, equals('test.params'));
        expect(progress.downloaded, equals(0));
        expect(progress.total, equals(0));
      });
    });

    group('percentage', () {
      test('calculates correct percentage for normal values', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 500,
          total: 1000,
        );

        expect(progress.percentage, equals(50.0));
      });

      test('returns 100% when downloaded equals total', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 1000,
          total: 1000,
        );

        expect(progress.percentage, equals(100.0));
      });

      test('returns 0% when total is zero', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 100,
          total: 0,
        );

        expect(progress.percentage, equals(0.0));
      });

      test('returns 0% when total is negative', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 100,
          total: -1000,
        );

        expect(progress.percentage, equals(0.0));
      });

      test('handles fractional percentages', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 333,
          total: 1000,
        );

        expect(progress.percentage, closeTo(33.3, 0.1));
      });

      test('can exceed 100% if downloaded > total', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 1500,
          total: 1000,
        );

        expect(progress.percentage, equals(150.0));
      });
    });

    group('isComplete', () {
      test('returns true when downloaded equals total', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 1000,
          total: 1000,
        );

        expect(progress.isComplete, isTrue);
      });

      test('returns true when downloaded exceeds total', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 1500,
          total: 1000,
        );

        expect(progress.isComplete, isTrue);
      });

      test('returns false when downloaded is less than total', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 500,
          total: 1000,
        );

        expect(progress.isComplete, isFalse);
      });

      test('returns true when both are zero', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 0,
          total: 0,
        );

        expect(progress.isComplete, isTrue);
      });
    });

    group('displayText', () {
      test('formats display text correctly for normal values', () {
        const progress = DownloadProgress(
          fileName: 'sapling-spend.params',
          downloaded: 50 * 1024 * 1024, // 50 MB
          total: 100 * 1024 * 1024, // 100 MB
        );

        expect(
          progress.displayText,
          equals('sapling-spend.params: 50.0% (50.0/100.0 MB)'),
        );
      });

      test('formats display text for partial MB values', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 1536 * 1024, // 1.5 MB
          total: 3 * 1024 * 1024, // 3 MB
        );

        expect(progress.displayText, equals('test.params: 50.0% (1.5/3.0 MB)'));
      });

      test('formats display text for small files', () {
        const progress = DownloadProgress(
          fileName: 'small.params',
          downloaded: 512 * 1024, // 0.5 MB
          total: 1024 * 1024, // 1 MB
        );

        expect(
          progress.displayText,
          equals('small.params: 50.0% (0.5/1.0 MB)'),
        );
      });

      test('handles zero total size', () {
        const progress = DownloadProgress(
          fileName: 'unknown.params',
          downloaded: 1024 * 1024, // 1 MB
          total: 0,
        );

        expect(
          progress.displayText,
          equals('unknown.params: 0.0% (1.0/0.0 MB)'),
        );
      });
    });

    group('toString', () {
      test('returns formatted string representation', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 500,
          total: 1000,
        );

        final str = progress.toString();
        expect(str, contains('DownloadProgress'));
        expect(str, contains('test.params'));
        expect(str, contains('500'));
        expect(str, contains('1000'));
      });

      test('handles zero values', () {
        const progress = DownloadProgress(
          fileName: 'empty.params',
          downloaded: 0,
          total: 0,
        );

        final str = progress.toString();
        expect(str, contains('DownloadProgress'));
        expect(str, contains('empty.params'));
        expect(str, contains('0'));
      });
    });

    group('equality', () {
      test('returns true for identical progress objects', () {
        const progress1 = DownloadProgress(
          fileName: 'test.params',
          downloaded: 500,
          total: 1000,
        );
        const progress2 = DownloadProgress(
          fileName: 'test.params',
          downloaded: 500,
          total: 1000,
        );

        expect(progress1, equals(progress2));
        expect(progress1.hashCode, equals(progress2.hashCode));
      });

      test('returns false for different file names', () {
        const progress1 = DownloadProgress(
          fileName: 'test1.params',
          downloaded: 500,
          total: 1000,
        );
        const progress2 = DownloadProgress(
          fileName: 'test2.params',
          downloaded: 500,
          total: 1000,
        );

        expect(progress1, isNot(equals(progress2)));
      });

      test('returns false for different downloaded values', () {
        const progress1 = DownloadProgress(
          fileName: 'test.params',
          downloaded: 500,
          total: 1000,
        );
        const progress2 = DownloadProgress(
          fileName: 'test.params',
          downloaded: 600,
          total: 1000,
        );

        expect(progress1, isNot(equals(progress2)));
      });

      test('returns false for different total values', () {
        const progress1 = DownloadProgress(
          fileName: 'test.params',
          downloaded: 500,
          total: 1000,
        );
        const progress2 = DownloadProgress(
          fileName: 'test.params',
          downloaded: 500,
          total: 2000,
        );

        expect(progress1, isNot(equals(progress2)));
      });

      test('returns true for same instance', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 500,
          total: 1000,
        );

        expect(progress, equals(progress));
      });

      test('returns false for different types', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: 500,
          total: 1000,
        );

        expect(progress, isNot(equals('not a progress object')));
      });
    });

    group('edge cases', () {
      test('handles empty file name', () {
        const progress = DownloadProgress(
          fileName: '',
          downloaded: 500,
          total: 1000,
        );

        expect(progress.fileName, equals(''));
        expect(progress.percentage, equals(50.0));
      });

      test('handles very large file sizes', () {
        const progress = DownloadProgress(
          fileName: 'huge.params',
          downloaded: 1024 * 1024 * 1024 * 5, // 5 GB
          total: 1024 * 1024 * 1024 * 10, // 10 GB
        );

        expect(progress.percentage, equals(50.0));
        expect(progress.isComplete, isFalse);
      });

      test('handles negative downloaded value', () {
        const progress = DownloadProgress(
          fileName: 'test.params',
          downloaded: -100,
          total: 1000,
        );

        expect(progress.percentage, equals(-10.0));
        expect(progress.isComplete, isFalse);
      });

      test('handles very long file name', () {
        final longFileName = 'very-long-file-name' * 10 + '.params';
        final progress = DownloadProgress(
          fileName: longFileName,
          downloaded: 500,
          total: 1000,
        );

        expect(progress.fileName, equals(longFileName));
        expect(progress.percentage, equals(50.0));
      });
    });

    group('JSON serialization', () {
      test('JSON round-trip', () {
        const original = DownloadProgress(
          fileName: 'a.params',
          downloaded: 42,
          total: 100,
        );
        final json = original.toJson();
        final restored = DownloadProgress.fromJson(json);
        expect(restored, equals(original));
      });
    });
  });
}
