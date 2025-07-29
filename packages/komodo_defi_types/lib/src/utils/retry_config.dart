import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'retry_config.freezed.dart';

/// Configuration for retry behavior in activation operations.
///
/// This class defines how activation operations should be retried
/// in case of failures, including the number of attempts, timeouts,
/// and conditions for retrying.
@Freezed(fromJson: false, toJson: false)
abstract class RetryConfig with _$RetryConfig {
  /// Creates a new retry configuration.
  ///
  /// [maxAttempts] - Maximum number of retry attempts (default: 3)
  /// [perAttemptTimeout] - Timeout for each individual attempt
  /// [shouldRetry] - Function to determine if an error should trigger a retry
  /// [onRetry] - Callback executed before each retry attempt
  /// [backoffDelay] - Delay between retry attempts
  const factory RetryConfig({
    @Default(3) int maxAttempts,
    Duration? perAttemptTimeout,
    bool Function(Object error)? shouldRetry,
    void Function(int attempt, Object error)? onRetry,
    @Default(Duration(milliseconds: 100)) Duration backoffDelay,
  }) = _RetryConfig;

  const RetryConfig._();

  /// Configuration with no retries - fails immediately on first error.
  static const noRetry = RetryConfig(maxAttempts: 1);

  /// Configuration with quick timeout for testing.
  static const quickTimeout = RetryConfig(
    maxAttempts: 1,
    perAttemptTimeout: Duration(milliseconds: 100),
  );

  /// Configuration optimized for testing - no retries and quick timeout.
  static const testing = RetryConfig(
    maxAttempts: 1,
    perAttemptTimeout: Duration(milliseconds: 500),
    backoffDelay: Duration.zero,
  );

  /// Configuration for production use with reasonable defaults.
  static const production = RetryConfig(
    maxAttempts: 3,
    perAttemptTimeout: Duration(seconds: 30),
    backoffDelay: Duration(milliseconds: 500),
  );

  /// Default retry condition - retries on TimeoutException and Exception.
  bool defaultShouldRetry(Object error) {
    return error is TimeoutException || error is Exception;
  }
}

/// Strategy interface for different retry implementations.
abstract class RetryStrategy {
  /// Executes a stream-producing function with retry logic.
  Stream<T> executeWithRetry<T>(
    Stream<T> Function() streamFactory,
    RetryConfig config,
  );
}

/// Default retry strategy using the existing retryStream utility.
class DefaultRetryStrategy implements RetryStrategy {
  const DefaultRetryStrategy();

  @override
  Stream<T> executeWithRetry<T>(
    Stream<T> Function() streamFactory,
    RetryConfig config,
  ) async* {
    int attempt = 0;
    while (true) {
      attempt++;
      final buffer = <T>[];
      try {
        final stream = config.perAttemptTimeout != null
            ? streamFactory().timeout(config.perAttemptTimeout!)
            : streamFactory();

        await for (final event in stream) {
          buffer.add(event);
        }

        // Success: yield all buffered events
        for (final event in buffer) {
          yield event;
        }
        return;
      } catch (e) {
        final shouldRetry = config.shouldRetry ?? config.defaultShouldRetry;
        if (!shouldRetry(e)) rethrow;
        if (attempt >= config.maxAttempts) rethrow;

        config.onRetry?.call(attempt, e);

        if (config.backoffDelay > Duration.zero) {
          await Future<void>.delayed(config.backoffDelay);
        }
      }
    }
  }
}

/// No-retry strategy that executes once without any retry logic.
class NoRetryStrategy implements RetryStrategy {
  const NoRetryStrategy();

  @override
  Stream<T> executeWithRetry<T>(
    Stream<T> Function() streamFactory,
    RetryConfig config,
  ) async* {
    final stream = config.perAttemptTimeout != null
        ? streamFactory().timeout(config.perAttemptTimeout!)
        : streamFactory();

    yield* stream;
  }
}

/// Test-friendly retry strategy that allows external control.
class ControllableRetryStrategy implements RetryStrategy {
  /// Creates a controllable retry strategy.
  ///
  /// [forceFailureAfterAttempts] - If set, forces failure after this many attempts
  /// [customDelay] - Custom delay to use instead of config delay
  const ControllableRetryStrategy({
    this.forceFailureAfterAttempts,
    this.customDelay,
  });

  /// Forces failure after this many attempts for testing.
  final int? forceFailureAfterAttempts;

  /// Custom delay override for testing.
  final Duration? customDelay;

  @override
  Stream<T> executeWithRetry<T>(
    Stream<T> Function() streamFactory,
    RetryConfig config,
  ) async* {
    int attempt = 0;
    while (true) {
      attempt++;

      // Force failure if configured for testing
      if (forceFailureAfterAttempts != null &&
          attempt > forceFailureAfterAttempts!) {
        throw Exception(
          'Forced failure after $forceFailureAfterAttempts attempts',
        );
      }

      final buffer = <T>[];
      try {
        final stream = config.perAttemptTimeout != null
            ? streamFactory().timeout(config.perAttemptTimeout!)
            : streamFactory();

        await for (final event in stream) {
          buffer.add(event);
        }

        // Success: yield all buffered events
        for (final event in buffer) {
          yield event;
        }
        return;
      } catch (e) {
        final shouldRetry = config.shouldRetry ?? config.defaultShouldRetry;
        if (!shouldRetry(e)) rethrow;
        if (attempt >= config.maxAttempts) rethrow;

        config.onRetry?.call(attempt, e);

        final delay = customDelay ?? config.backoffDelay;
        if (delay > Duration.zero) {
          await Future<void>.delayed(delay);
        }
      }
    }
  }
}
