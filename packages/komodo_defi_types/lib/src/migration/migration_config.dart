import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'migration_config.freezed.dart';
part 'migration_config.g.dart';

/// Configuration settings for migration operations.
///
/// This class contains all the configurable parameters that control
/// how migrations are executed, including batch sizes, timeouts, and
/// retry behavior.
@freezed
abstract class MigrationConfig with _$MigrationConfig {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory MigrationConfig({
    /// Number of assets to activate in each batch.
    ///
    /// Lower values reduce memory usage but may increase total activation time.
    /// Higher values may cause timeouts or memory issues with large asset lists.
    @Default(MigrationConfig.defaultActivationBatchSize) int activationBatchSize,

    /// Maximum time to wait for individual operations to complete.
    ///
    /// This applies to asset activation, balance queries, and withdrawal operations.
    @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
    @Default(MigrationConfig.defaultOperationTimeout)
    Duration operationTimeout,

    /// Number of times to retry failed operations before giving up.
    ///
    /// Set to 0 to disable retries.
    @Default(MigrationConfig.defaultRetryAttempts) int retryAttempts,

    /// Delay between retry attempts.
    ///
    /// Uses exponential backoff: delay * (2 ^ attempt)
    @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
    @Default(MigrationConfig.defaultRetryDelay)
    Duration retryDelay,

    /// How long to cache migration preview results.
    ///
    /// Cached previews can be reused if the same migration is requested
    /// within this timeframe.
    @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
    @Default(MigrationConfig.defaultPreviewCacheTimeout)
    Duration previewCacheTimeout,

    /// Maximum number of concurrent withdrawal operations.
    ///
    /// Limits network load and prevents overwhelming the blockchain network.
    @Default(MigrationConfig.defaultMaxConcurrentWithdrawals)
    int maxConcurrentWithdrawals,

    /// Whether to emit detailed progress updates during migration.
    ///
    /// When false, only major status changes are reported.
    @Default(true) bool enableProgressUpdates,

    /// Whether to enable detailed logging for debugging purposes.
    ///
    /// When false, only errors and major events are logged.
    @Default(true) bool enableDetailedLogging,
  }) = _MigrationConfig;

  factory MigrationConfig.fromJson(JsonMap json) =>
      _$MigrationConfigFromJson(json);

  /// Default batch size for asset activation (10 assets per batch)
  static const int defaultActivationBatchSize = 10;

  /// Default timeout for individual operations (5 minutes)
  static const Duration defaultOperationTimeout = Duration(minutes: 5);

  /// Default number of retry attempts for failed operations
  static const int defaultRetryAttempts = 3;

  /// Default delay between retry attempts (2 seconds)
  static const Duration defaultRetryDelay = Duration(seconds: 2);

  /// Default timeout for preview cache (30 minutes)
  static const Duration defaultPreviewCacheTimeout = Duration(minutes: 30);

  /// Default maximum concurrent withdrawals
  static const int defaultMaxConcurrentWithdrawals = 5;
}

/// Helper functions for Duration JSON serialization
Duration _durationFromJson(int milliseconds) =>
    Duration(milliseconds: milliseconds);

int _durationToJson(Duration duration) => duration.inMilliseconds;

/// Abstract provider for migration configuration.
///
/// This allows for different configuration sources (local, remote, etc.)
/// while maintaining a consistent interface.
abstract class MigrationConfigProvider {
  /// Gets the current migration configuration.
  ///
  /// May fetch from remote sources or return cached values.
  Future<MigrationConfig> getConfig();
}

/// Default implementation of [MigrationConfigProvider] that returns
/// the default configuration values.
///
/// This can be extended or replaced with implementations that fetch
/// configuration from remote sources, local storage, or other providers.
class DefaultMigrationConfigProvider implements MigrationConfigProvider {
  /// Creates a new [DefaultMigrationConfigProvider] with optional
  /// default configuration override.
  const DefaultMigrationConfigProvider([this._defaultConfig]);

  final MigrationConfig? _defaultConfig;

  @override
  Future<MigrationConfig> getConfig() async {
    return _defaultConfig ?? const MigrationConfig();
  }
}
