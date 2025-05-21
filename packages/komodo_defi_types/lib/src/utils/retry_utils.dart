import 'dart:async';

/// Retry utility with exponential backoff.
///
/// This function executes [functionToRetry] and retries on failure with an
/// increasing delay between attempts (exponential backoff).
///
/// Parameters:
/// - [functionToRetry]: The asynchronous function to execute and retry.
/// - [maxAttempts]: Maximum number of retry attempts (default: 5).
/// - [initialDelay]: Starting delay between retries (default: 200ms).
/// - [maxDelay]: Maximum delay between retries (default: 5s).
/// - [timeout]: Optional overall timeout for all retry attempts.
/// - [shouldRetry]: Optional function that determines if a specific error 
///   trigger a retry. If it returns false, the error is rethrown immediately.
/// - [shouldRetryNoIncrement]: Optional function for special cases where an
///   error should trigger a retry without incrementing the attempt counter.
///   Use with caution. Intended for false positives where the error doesn't
///   indicate a failure of [functionToRetry].
///
/// Example:
/// ```dart
/// final result = await retryWithBackoff(
///   () => fetchDataFromApi(),
///   maxAttempts: 3,
///   shouldRetry: (e) => e is NetworkTimeoutException,
/// );
/// ```
Future<T> retryWithBackoff<T>(
  Future<T> Function() functionToRetry, {
  int maxAttempts = 5,
  Duration initialDelay = const Duration(milliseconds: 200),
  Duration maxDelay = const Duration(seconds: 5),
  Duration? timeout,
  bool Function(Object error)? shouldRetry,
  bool Function(Object error)? shouldRetryNoIncrement,
}) async {
  var attempt = 0;
  var delay = initialDelay;
  final stopwatch = Stopwatch()..start();

  while (true) {
    if (timeout != null && stopwatch.elapsed >= timeout) {
      throw TimeoutException(
        'Retry operation timed out after ${stopwatch.elapsed}',
        timeout,
      );
    }

    final completer = Completer<T>();

    // RPC calls are scheduled microtasks, so we need to run them in a zone
    // to catch errors that are thrown in the microtask queue, which would
    // otherwise be unhandled.
    await runZonedGuarded(
      () async {
        final result = await functionToRetry();
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      },
      (error, stack) {
        if (!completer.isCompleted) {
          completer.completeError(error, stack);
        }
      },
    );

    try {
      return await completer.future;
    } catch (e) {
      if (shouldRetryNoIncrement != null && shouldRetryNoIncrement(e)) {
        await Future<void>.delayed(delay);
        delay = _calculateNextDelay(delay, maxDelay);
        continue;
      }

      attempt++;
      if (attempt >= maxAttempts || (shouldRetry != null && !shouldRetry(e))) {
        rethrow;
      }

      await Future<void>.delayed(delay);
      delay = _calculateNextDelay(delay, maxDelay);
    }
  }
}

/// Calculates the next delay using exponential backoff, capped by maxDelay.
Duration _calculateNextDelay(Duration currentDelay, Duration maxDelay) {
  final nextDelay = currentDelay * 2;
  return nextDelay > maxDelay ? maxDelay : nextDelay;
}
