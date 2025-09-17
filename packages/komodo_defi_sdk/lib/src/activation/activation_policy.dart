import 'package:komodo_defi_types/komodo_defi_type_utils.dart'
    show RetryConfig, RetryStrategy;

/// Immutable configuration object that defines how activation should retry and
/// time out operations.
///
/// This policy is typically computed once and reused by activation components
/// such as executors and coordinators.
class ActivationPolicy {
  /// Creates a new [ActivationPolicy] with the given retry configuration and
  /// strategy.
  ///
  /// [retryConfig] The [RetryConfig] to use for activation operations.
  /// [retryStrategy] The [RetryStrategy] to use for activation operations.
  const ActivationPolicy(this.retryConfig, this.retryStrategy);

  /// Retry configuration applied to activation operations.
  final RetryConfig retryConfig;

  /// Strategy that executes the retries using [retryConfig].
  final RetryStrategy retryStrategy;

  /// Compute an overall timeout based on retry configuration (best effort).
  ///
  /// Returns null if the retry configuration does not specify a per-attempt
  /// timeout.
  Duration computeOverallTimeout() {
    final attempts = retryConfig.maxAttempts;
    final Duration per =
        retryConfig.perAttemptTimeout ?? const Duration(minutes: 2);
    final backoffTotal = retryConfig.backoffDelay * (attempts - 1);
    return per * attempts + backoffTotal + const Duration(seconds: 1);
  }
}
