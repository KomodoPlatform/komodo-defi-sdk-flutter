/// Configuration for asset activation behavior
class ActivationConfig {
  const ActivationConfig({
    this.useLegacyMode = false,
    this.legacyModePriority = false,
  });

  /// Whether to use legacy activation methods (e.g., electrum method)
  /// instead of task-based activation methods
  final bool useLegacyMode;

  /// Whether to prioritize legacy mode over modern task-based activation
  /// when both are available
  final bool legacyModePriority;

  /// Default configuration that uses modern task-based activation
  static const ActivationConfig modern = ActivationConfig(
    useLegacyMode: false,
    legacyModePriority: false,
  );

  /// Configuration that prioritizes legacy mode for compatibility
  static const ActivationConfig legacy = ActivationConfig(
    useLegacyMode: true,
    legacyModePriority: true,
  );

  /// Configuration that supports both modes but prioritizes modern
  static const ActivationConfig hybrid = ActivationConfig(
    useLegacyMode: true,
    legacyModePriority: false,
  );
}