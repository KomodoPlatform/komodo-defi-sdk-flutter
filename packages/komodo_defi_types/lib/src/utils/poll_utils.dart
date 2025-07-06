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
    if (stopwatch.elapsed >= maxDuration) {
      throw TimeoutException(
        'Polling timed out after ${stopwatch.elapsed}',
        maxDuration,
      );
    }

    try {
      final result = await functionToPoll();
      if (isComplete(result)) {
        return result;
      }
      delay = strategy.nextDelay(attempt, delay);
      onPoll?.call(attempt, delay);
      attempt++;
      await Future<void>.delayed(delay);
    } catch (e) {
      if (shouldContinueOnError != null && shouldContinueOnError(e)) {
        delay = strategy.nextDelay(attempt, delay);
        onPoll?.call(attempt, delay);
        attempt++;
        await Future<void>.delayed(delay);
        continue;
      }
      rethrow;
    }
  }
}
