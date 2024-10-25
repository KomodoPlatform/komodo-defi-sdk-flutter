// sdk_config.dart
class KomodoDefiSdkConfig {
  const KomodoDefiSdkConfig({
    this.defaultAssets = const {},
    this.preActivateDefaultAssets = true,
    this.preActivateHistoricalAssets = true,
    this.maxPreActivationAttempts = 3,
    this.activationRetryDelay = const Duration(seconds: 2),
  });

  /// Set of asset IDs that should be enabled by default
  final Set<String> defaultAssets;

  /// Whether to automatically activate default assets on login
  final bool preActivateDefaultAssets;

  /// Whether to automatically activate previously used assets on login
  final bool preActivateHistoricalAssets;

  /// Maximum number of retry attempts for pre-activation
  final int maxPreActivationAttempts;

  /// Delay between retry attempts
  final Duration activationRetryDelay;

  KomodoDefiSdkConfig copyWith({
    Set<String>? defaultAssets,
    bool? preActivateDefaultAssets,
    bool? preActivateHistoricalAssets,
    int? maxPreActivationAttempts,
    Duration? activationRetryDelay,
  }) {
    return KomodoDefiSdkConfig(
      defaultAssets: defaultAssets ?? this.defaultAssets,
      preActivateDefaultAssets:
          preActivateDefaultAssets ?? this.preActivateDefaultAssets,
      preActivateHistoricalAssets:
          preActivateHistoricalAssets ?? this.preActivateHistoricalAssets,
      maxPreActivationAttempts:
          maxPreActivationAttempts ?? this.maxPreActivationAttempts,
      activationRetryDelay: activationRetryDelay ?? this.activationRetryDelay,
    );
  }
}
