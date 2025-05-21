import 'dart:math' as math;

import 'package:komodo_defi_types/src/utils/retry_utils.dart';

/// Base class for defining backoff strategies.
///
/// Implement this abstract class to create custom backoff strategies
/// for use with [retry].
abstract class BackoffStrategy {
  /// Calculates the next delay based on the current attempt and state.
  ///
  /// [attempt] is the current retry attempt (0-based)
  /// [currentDelay] is the most recently used delay
  Duration nextDelay(int attempt, Duration currentDelay);

  /// Creates a deep copy of this strategy.
  ///
  /// This is used by the retry function to avoid mutating the original strategy.
  BackoffStrategy clone();
}

/// Implements exponential backoff with optional jitter.
///
/// This strategy doubles the delay after each attempt, capped by a maximum delay.
/// When jitter is enabled, it adds a random variance to prevent synchronized
/// retries in distributed systems.
class ExponentialBackoff implements BackoffStrategy {
  /// Creates an exponential backoff strategy
  ///
  /// [initialDelay] Starting delay between retries (default: 200ms)
  /// [maxDelay] Maximum delay between retries (default: 5s)
  /// [withJitter] Whether to add random jitter to prevent thundering herd (default: false)
  /// [random] Optional random number generator for testing
  ExponentialBackoff({
    this.initialDelay = const Duration(milliseconds: 200),
    this.maxDelay = const Duration(seconds: 5),
    this.withJitter = false,
    math.Random? random,
  }) : _random = random ?? math.Random();

  /// Initial delay duration before applying backoff
  final Duration initialDelay;

  /// Maximum delay duration to cap exponential growth
  final Duration maxDelay;

  /// Whether to add random jitter to the delay
  final bool withJitter;

  /// Random number generator for jitter calculation
  final math.Random _random;

  @override
  Duration nextDelay(int attempt, Duration currentDelay) {
    if (attempt == 0) {
      return _applyJitter(initialDelay);
    }

    final nextDelay = currentDelay * 2;
    final cappedDelay = nextDelay > maxDelay ? maxDelay : nextDelay;

    return _applyJitter(cappedDelay);
  }

  /// Applies jitter to the delay if enabled
  Duration _applyJitter(Duration delay) {
    if (!withJitter) return delay;

    final jitterFactor = 0.85 + (_random.nextDouble() * 0.3);
    final jitteredMs = (delay.inMilliseconds * jitterFactor).round();

    return Duration(milliseconds: jitteredMs);
  }

  @override
  BackoffStrategy clone() {
    return ExponentialBackoff(
      initialDelay: initialDelay,
      maxDelay: maxDelay,
      withJitter: withJitter,
    );
  }
}

/// Implements a constant backoff strategy with fixed delay.
///
/// This strategy uses the same delay for all retry attempts.
class ConstantBackoff implements BackoffStrategy {
  /// Creates a constant backoff strategy
  ///
  /// [delay] Fixed delay between retries (default: 1s)
  ConstantBackoff({
    this.delay = const Duration(seconds: 1),
  });

  /// Fixed delay to use between retry attempts
  final Duration delay;

  @override
  Duration nextDelay(int attempt, Duration currentDelay) {
    return delay;
  }

  @override
  BackoffStrategy clone() {
    return ConstantBackoff(delay: delay);
  }
}

/// Implements a linear backoff strategy.
///
/// This strategy increases the delay by a fixed amount after each attempt,
/// capped by a maximum delay.
class LinearBackoff implements BackoffStrategy {
  /// Creates a linear backoff strategy
  ///
  /// [initialDelay] Starting delay between retries (default: 200ms)
  /// [increment] Amount to increase delay by after each attempt (default: 200ms)
  /// [maxDelay] Maximum delay between retries (default: 5s)
  LinearBackoff({
    this.initialDelay = const Duration(milliseconds: 200),
    this.increment = const Duration(milliseconds: 200),
    this.maxDelay = const Duration(seconds: 5),
  });

  /// Initial delay duration
  final Duration initialDelay;

  /// Increment to add to the delay after each attempt
  final Duration increment;

  /// Maximum delay duration
  final Duration maxDelay;

  @override
  Duration nextDelay(int attempt, Duration currentDelay) {
    if (attempt == 0) {
      return initialDelay;
    }

    final nextDelay = currentDelay + increment;
    return nextDelay > maxDelay ? maxDelay : nextDelay;
  }

  @override
  BackoffStrategy clone() {
    return LinearBackoff(
      initialDelay: initialDelay,
      increment: increment,
      maxDelay: maxDelay,
    );
  }
}
