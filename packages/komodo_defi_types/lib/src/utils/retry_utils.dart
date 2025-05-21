import 'dart:async';

import 'package:komodo_defi_types/src/utils/backoff_strategy.dart';

/// Retry utility with configurable backoff strategy.
///
/// This function executes [functionToRetry] and retries on failure using
/// the provided backoff strategy.
///
/// Parameters:
/// - [functionToRetry]: The asynchronous function to execute and retry.
/// - [maxAttempts]: Maximum number of retry attempts (default: 5).
/// - [backoffStrategy]: Strategy for calculating delay between retries
///   (default: [ExponentialBackoff] without jitter).
/// - [retryTimeout]: Optional overall timeout for all retry attempts. NOTE:
///   This timeout is not applied to the individual function calls, but to the
///   retry operation as a whole. If the function takes longer than this
///   timeout to complete, the retry operation will be aborted.
/// - [shouldRetry]: Optional function that determines if a specific error
///   should trigger a retry. If it returns false, the error is rethrown immediately.
/// - [shouldRetryNoIncrement]: Optional function for special cases where an
///   error should trigger a retry without incrementing the attempt counter.
///   Use with caution. Intended for false positives where the error doesn't
///   indicate a failure of [functionToRetry].
/// - [onRetry]: Optional callback executed before each retry attempt with
///   the current attempt count, error, and delay information.
///
/// Example:
/// ```dart
/// final result = await retry(
///   () => fetchDataFromApi(),
///   maxAttempts: 3,
///   backoffStrategy: ExponentialBackoff(withJitter: true),
///   shouldRetry: (e) => e is NetworkTimeoutException,
///   onRetry: (attempt, error, delay) =>
///     print('Retry $attempt after $delay due to $error'),
/// );
/// ```
Future<T> retry<T>(
  Future<T> Function() functionToRetry, {
  int maxAttempts = 5,
  BackoffStrategy? backoffStrategy,
  Duration? retryTimeout,
  bool Function(Object error)? shouldRetry,
  bool Function(Object error)? shouldRetryNoIncrement,
  void Function(int attempt, Object error, Duration delay)? onRetry,
}) async {
  backoffStrategy ??= ExponentialBackoff();
  final strategy = backoffStrategy.clone();
  var attempt = 0;
  var delay = Duration.zero;
  final stopwatch = Stopwatch()..start();

  while (true) {
    if (retryTimeout != null && stopwatch.elapsed >= retryTimeout) {
      throw TimeoutException(
        'Retry operation timed out after ${stopwatch.elapsed}',
        retryTimeout,
      );
    }

    try {
      // RPC calls are scheduled microtasks, so we need to run them in a zone
      // to catch errors that are thrown in the microtask queue, which would
      // otherwise be unhandled.
      final completer = Completer<T>();

      // Completer is awaited and used to return the result, so we can unawait
      // the result of the runZonedGuarded call. awaiting this would block
      // the function from returning until the completer is completed - breaking
      // the retry loop and unit tests.
      unawaited(
        runZonedGuarded(
          () async {
            try {
              final result = await functionToRetry();
              if (!completer.isCompleted) {
                completer.complete(result);
              }
            } catch (e, stack) {
              if (!completer.isCompleted) {
                completer.completeError(e, stack);
              }
            }
          },
          (error, stack) {
            if (!completer.isCompleted) {
              completer.completeError(error, stack);
            }
          },
        ),
      );

      final result = await completer.future;
      return result;
    } catch (e) {
      if (shouldRetryNoIncrement != null && shouldRetryNoIncrement(e)) {
        delay = strategy.nextDelay(attempt, delay);

        if (onRetry != null) {
          onRetry(attempt, e, delay);
        }

        await Future<void>.delayed(delay);
        continue;
      }

      attempt++;
      if (attempt >= maxAttempts || (shouldRetry != null && !shouldRetry(e))) {
        if (onRetry != null) {
          onRetry(attempt, e, delay);
        }
        rethrow;
      }

      delay = strategy.nextDelay(attempt - 1, delay);

      if (onRetry != null) {
        onRetry(attempt, e, delay);
      }

      await Future<void>.delayed(delay);
    }
  }
}
