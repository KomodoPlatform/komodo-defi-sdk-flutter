// sdk_config.dart
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';

class KomodoDefiSdkConfig {
  const KomodoDefiSdkConfig({
    this.defaultAssets = const {'KMD', 'BTC', 'ETH', 'DOC', 'MARTY'},
    this.preActivateDefaultAssets = true,
    this.preActivateHistoricalAssets = true,
    this.preActivateCustomTokenAssets = true,
    this.maxPreActivationAttempts = 3,
    this.activationRetryDelay = const Duration(seconds: 2),
    this.marketDataConfig = const MarketDataConfig(),
  });

  /// Set of asset IDs that should be enabled by default
  final Set<String> defaultAssets;

  /// Whether to automatically activate default assets on login
  final bool preActivateDefaultAssets;

  /// Whether to automatically activate previously used assets on login
  final bool preActivateHistoricalAssets;

  /// Whether to automatically activate custom tokens on login
  final bool preActivateCustomTokenAssets;

  /// Maximum number of retry attempts for pre-activation
  final int maxPreActivationAttempts;

  /// Delay between retry attempts
  final Duration activationRetryDelay;

  /// Configuration for market data repositories
  final MarketDataConfig marketDataConfig;

  KomodoDefiSdkConfig copyWith({
    Set<String>? defaultAssets,
    bool? preActivateDefaultAssets,
    bool? preActivateHistoricalAssets,
    bool? preActivateCustomTokenAssets,
    int? maxPreActivationAttempts,
    Duration? activationRetryDelay,
    MarketDataConfig? marketDataConfig,
  }) {
    return KomodoDefiSdkConfig(
      defaultAssets: defaultAssets ?? this.defaultAssets,
      preActivateDefaultAssets:
          preActivateDefaultAssets ?? this.preActivateDefaultAssets,
      preActivateHistoricalAssets:
          preActivateHistoricalAssets ?? this.preActivateHistoricalAssets,
      preActivateCustomTokenAssets:
          preActivateCustomTokenAssets ?? this.preActivateCustomTokenAssets,
      maxPreActivationAttempts:
          maxPreActivationAttempts ?? this.maxPreActivationAttempts,
      activationRetryDelay: activationRetryDelay ?? this.activationRetryDelay,
      marketDataConfig: marketDataConfig ?? this.marketDataConfig,
    );
  }
}
