import 'dart:async';

import 'package:komodo_defi_types/src/utils/backoff_strategy.dart';

/// Poll utility with configurable backoff strategy and optional timeout.
///
/// Executes [functionToPoll] repeatedly until [isComplete] returns true or
/// [maxDuration] is exceeded. Errors are rethrown unless [shouldContinueOnError]
/// returns true.
Future<T> poll<T>(
  Future<T> Function() functionToPoll, {
  required bool Function(T result) isComplete,
  Duration maxDuration = const Duration(seconds: 30),
  BackoffStrategy? backoffStrategy,
  bool Function(Object error)? shouldContinueOnError,
  void Function(int attempt, Duration delay)? onPoll,
}) async {
  backoffStrategy ??= const ConstantBackoff();
  final strategy = backoffStrategy.clone();
  var attempt = 0;
  var delay = Duration.zero;
  final stopwatch = Stopwatch()..start();

  while (true) {
    // Check timeout before invoking the function to avoid starting a call that would exceed the budget
    final remainingBeforeCall = maxDuration - stopwatch.elapsed;
    if (remainingBeforeCall <= Duration.zero) {
      throw TimeoutException(
        'Polling timed out after ${stopwatch.elapsed}',
        maxDuration,
      );
    }

    try {
      // Ensure the call itself respects the remaining time budget
      final result = await functionToPoll().timeout(remainingBeforeCall);
      if (isComplete(result)) {
        return result;
      }
      delay = strategy.nextDelay(attempt, delay);
      onPoll?.call(attempt, delay);
      attempt++;

      // Cap or skip delay based on remaining budget after the call
      final remainingBeforeDelay = maxDuration - stopwatch.elapsed;
      if (remainingBeforeDelay <= Duration.zero) {
        throw TimeoutException(
          'Polling timed out after ${stopwatch.elapsed}',
          maxDuration,
        );
      }

      final effectiveDelay = delay <= remainingBeforeDelay ? delay : remainingBeforeDelay;
      if (effectiveDelay > Duration.zero) {
        await Future<void>.delayed(effectiveDelay);
      }
    } catch (e) {
      // Always propagate timeouts immediately
      if (e is TimeoutException) {
        rethrow;
      }
      if (shouldContinueOnError != null && shouldContinueOnError(e)) {
        delay = strategy.nextDelay(attempt, delay);
        onPoll?.call(attempt, delay);
        attempt++;

        final remainingBeforeDelay = maxDuration - stopwatch.elapsed;
        if (remainingBeforeDelay <= Duration.zero) {
          throw TimeoutException(
            'Polling timed out after ${stopwatch.elapsed}',
            maxDuration,
          );
        }

        final effectiveDelay = delay <= remainingBeforeDelay ? delay : remainingBeforeDelay;
        if (effectiveDelay > Duration.zero) {
          await Future<void>.delayed(effectiveDelay);
        }
        continue;
      }
      rethrow;
    }
  }
}
