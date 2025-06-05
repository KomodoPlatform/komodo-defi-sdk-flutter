import 'dart:async';
import 'dart:math' as math;

import 'package:komodo_defi_types/src/utils/backoff_strategy.dart';
import 'package:komodo_defi_types/src/utils/retry_utils.dart';
import 'package:test/test.dart';

void main() {
  group('retry function', () {
    test('succeeds on first try', () async {
      var callCount = 0;

      final result = await retry(() async {
        callCount++;
        return 'success';
      });

      expect(result, equals('success'));
      expect(callCount, equals(1));
    });

    test('retries on failure and succeeds', () async {
      var callCount = 0;

      final result = await retry(() async {
        callCount++;
        if (callCount == 1) {
          throw Exception('Simulated failure');
        }
        return 'success after retry';
      });

      expect(result, equals('success after retry'));
      expect(callCount, equals(2));
    });

    test('respects retryTimeout', () async {
      expect(
        retry(
          () async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            throw Exception('Will timeout');
          },
          maxAttempts: 10,
          retryTimeout: const Duration(milliseconds: 100),
          backoffStrategy:
              ConstantBackoff(delay: const Duration(milliseconds: 10)),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('respects shouldRetry callback', () async {
      var callCount = 0;
      final retryError = Exception('Should retry');
      final nonRetryError = Exception('Should not retry');

      try {
        await retry<void>(
          () {
            callCount++;
            throw retryError;
          },
          maxAttempts: 3,
          shouldRetry: (e) => e.toString() == retryError.toString(),
          backoffStrategy:
              ConstantBackoff(delay: const Duration(milliseconds: 10)),
        );
      } catch (e) {
        expect(e.toString(), equals(retryError.toString()));
      }
      expect(callCount, equals(3));

      callCount = 0;
      try {
        await retry<void>(
          () {
            callCount++;
            throw nonRetryError;
          },
          maxAttempts: 3,
          shouldRetry: (e) => e.toString() == retryError.toString(),
          backoffStrategy:
              ConstantBackoff(delay: const Duration(milliseconds: 10)),
        );
      } catch (e) {
        expect(e.toString(), equals(nonRetryError.toString()));
      }
      expect(callCount, equals(1));
    });

    test('respects shouldRetryNoIncrement callback', () async {
      var callCount = 0;
      final attempts = <int>[];

      try {
        await retry(
          () async {
            callCount++;
            if (callCount <= 2) {
              throw Exception('No increment');
            } else if (callCount <= 4) {
              throw Exception('Normal failure');
            }
            return 'Success';
          },
          maxAttempts: 2,
          shouldRetryNoIncrement: (e) => e.toString().contains('No increment'),
          backoffStrategy:
              ConstantBackoff(delay: const Duration(milliseconds: 10)),
          onRetry: (attempt, error, delay) {
            attempts.add(attempt);
          },
        );
      } catch (e) {
        // Expected to fail after maxAttempts
      }

      // We expect 2 retries that don't increment the counter
      // followed by 2 normal retries that do
      expect(callCount, equals(4));
      expect(attempts, equals([0, 0, 1, 2]));
    });

    test('calls onRetry with correct arguments', () async {
      final attempts = <int>[];
      final errors = <String>[];
      final delays = <Duration>[];

      try {
        await retry(
          () async {
            throw Exception('Test error ${attempts.length}');
          },
          maxAttempts: 3,
          backoffStrategy:
              ConstantBackoff(delay: const Duration(milliseconds: 15)),
          onRetry: (attempt, error, delay) {
            attempts.add(attempt);
            errors.add(error.toString());
            delays.add(delay);
          },
        );
      } catch (e) {
        // Expected to fail
      }

      expect(attempts, equals([1, 2, 3]));
      expect(errors.length, equals(3));
      expect(errors[0], contains('Test error 0'));
      expect(errors[1], contains('Test error 1'));
      expect(errors[2], contains('Test error 2'));
      expect(delays, everyElement(equals(const Duration(milliseconds: 15))));
    });

    test('propagates original exception', () async {
      final originalError = StateError('Original error');

      expect(
        () async {
          await retry<void>(
            () {
              throw originalError;
            },
            maxAttempts: 2,
            backoffStrategy:
                ConstantBackoff(delay: const Duration(milliseconds: 10)),
          );
        },
        throwsA(same(originalError)),
      );
    });

    test('handles errors in microtask queue with runZonedGuarded', () async {
      expect(
        () async {
          await retry(
            () async {
              scheduleMicrotask(() => throw Exception('Microtask error'));

              // This future will never complete because the error above
              // should be caught
              return Completer<String>().future;
            },
            maxAttempts: 2,
            backoffStrategy:
                ConstantBackoff(delay: const Duration(milliseconds: 10)),
          );
        },
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Microtask error'),
          ),
        ),
      );
    });
  });

  group('ExponentialBackoff', () {
    test('uses initialDelay for first attempt', () {
      final strategy = ExponentialBackoff(
        initialDelay: const Duration(milliseconds: 100),
      );

      final delay = strategy.nextDelay(0, Duration.zero);
      expect(delay, equals(const Duration(milliseconds: 100)));
    });

    test('doubles delay for each subsequent attempt', () {
      final strategy = ExponentialBackoff(
        initialDelay: const Duration(milliseconds: 100),
        maxDelay: const Duration(seconds: 10),
      );

      var delay = strategy.nextDelay(0, Duration.zero);
      expect(delay, equals(const Duration(milliseconds: 100)));

      delay = strategy.nextDelay(1, delay);
      expect(delay, equals(const Duration(milliseconds: 200)));

      delay = strategy.nextDelay(2, delay);
      expect(delay, equals(const Duration(milliseconds: 400)));

      delay = strategy.nextDelay(3, delay);
      expect(delay, equals(const Duration(milliseconds: 800)));
    });

    test('caps delay at maxDelay', () {
      final strategy = ExponentialBackoff(
        initialDelay: const Duration(milliseconds: 1000),
        maxDelay: const Duration(milliseconds: 3000),
      );

      var delay = strategy.nextDelay(0, Duration.zero);
      expect(delay, equals(const Duration(milliseconds: 1000)));

      delay = strategy.nextDelay(1, delay);
      expect(delay, equals(const Duration(milliseconds: 2000)));

      delay = strategy.nextDelay(2, delay);
      // This would be 4000ms but should be capped at 3000ms
      expect(delay, equals(const Duration(milliseconds: 3000)));

      delay = strategy.nextDelay(3, delay);
      // Still capped at 3000ms
      expect(delay, equals(const Duration(milliseconds: 3000)));
    });

    test('produces consistent delays without jitter', () {
      final strategy = ExponentialBackoff(
        initialDelay: const Duration(milliseconds: 100),
      );

      final firstRun = <Duration>[];
      var delay = Duration.zero;
      for (var i = 0; i < 5; i++) {
        delay = strategy.nextDelay(i, delay);
        firstRun.add(delay);
      }

      final secondRun = <Duration>[];
      delay = Duration.zero;
      for (var i = 0; i < 5; i++) {
        delay = strategy.nextDelay(i, delay);
        secondRun.add(delay);
      }

      // Without jitter, delays should be exactly the same
      for (var i = 0; i < 5; i++) {
        expect(firstRun[i], equals(secondRun[i]));
      }
    });

    test('applies jitter when enabled', () {
      // Use fixed random for deterministic testing
      final random = _FixedRandom(0.5);
      final strategy = ExponentialBackoff(
        initialDelay: const Duration(milliseconds: 100),
        withJitter: true,
        random: random,
      );

      final delay = strategy.nextDelay(0, Duration.zero);
      // With jitter factor of 0.5, we expect jitterFactor to be 0.85 + (0.5 * 0.3) = 1.0
      // So delay should be 100ms * 1.0 = 100ms
      expect(delay.inMilliseconds, equals(100));
    });

    test('clone creates proper copy', () {
      final original = ExponentialBackoff(
        initialDelay: const Duration(milliseconds: 150),
        maxDelay: const Duration(seconds: 3),
        withJitter: true,
      );

      final clone = original.clone() as ExponentialBackoff;

      expect(clone.initialDelay, equals(original.initialDelay));
      expect(clone.maxDelay, equals(original.maxDelay));
      expect(clone.withJitter, equals(original.withJitter));

      // Make sure they're truly separate instances
      expect(identical(clone, original), isFalse);
    });
  });
}

/// A fixed random number generator for deterministic tests
class _FixedRandom implements math.Random {
  _FixedRandom(this.value);

  final double value;

  @override
  bool nextBool() => value > 0.5;

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => (value * max).floor();
}
