import 'dart:developer';

import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';



/// Specialized logger for migration operations.
///
/// Provides structured logging with consistent formatting for all
/// migration-related events, including start/completion, asset operations,
/// errors, and batch processing.
class MigrationLogger {
  /// Creates a new [MigrationLogger] instance.
  ///
  /// The [config] parameter determines the logging verbosity level.
  /// When [config.enableDetailedLogging] is false, only errors and
  /// major events are logged.
  MigrationLogger(this._config) : _logger = Logger('MigrationManager');

  static const String _loggerName = 'MigrationManager';
  final Logger _logger;
  final MigrationConfig _config;

  /// Logs the start of a migration operation.
  ///
  /// Records the migration ID, source/target wallets, and asset count.
  void logMigrationStart(
    String migrationId,
    WalletId sourceWallet,
    WalletId targetWallet,
    int assetCount,
  ) {
    _logger.info(
      'Migration started: $migrationId '
      '| Source: ${sourceWallet.name} '
      '| Target: ${targetWallet.name} '
      '| Assets: $assetCount',
    );

    if (_config.enableDetailedLogging) {
      _logDeveloper('Migration $migrationId started with $assetCount assets');
    }
  }

  /// Logs the successful activation of an asset during migration.
  ///
  /// Records the asset ID and any relevant activation details.
  void logAssetActivation(String migrationId, AssetId assetId, {String? details}) {
    if (_config.enableDetailedLogging) {
      _logger.fine(
        'Asset activated: $migrationId | Asset: ${assetId.id}'
        '${details != null ? ' | $details' : ''}',
      );
    }
  }

  /// Logs the completion of an individual asset migration.
  ///
  /// Records success/failure status and any relevant transaction details.
  void logAssetMigration(
    String migrationId,
    AssetId assetId,
    bool success, {
    String? txHash,
    String? error,
  }) {
    final status = success ? 'SUCCESS' : 'FAILED';
    final message = 'Asset migration $status: $migrationId '
        '| Asset: ${assetId.id}'
        '${txHash != null ? ' | TxHash: $txHash' : ''}'
        '${error != null ? ' | Error: $error' : ''}';

    if (success) {
      _logger.info(message);
    } else {
      _logger.warning(message);
    }

    if (_config.enableDetailedLogging && success && txHash != null) {
      _logDeveloper('Asset ${assetId.id} migrated successfully: $txHash');
    }
  }

  /// Logs the completion of the entire migration operation.
  ///
  /// Records overall success/failure counts and duration.
  void logMigrationComplete(
    String migrationId,
    MigrationResult result,
    Duration duration,
  ) {
    final successCount = result.successfulAssets.length;
    final totalCount = successCount + result.failedAssets.length;
    final durationText = '${duration.inSeconds}s';

    _logger.info(
      'Migration completed: $migrationId '
      '| Success: $successCount/$totalCount '
      '| Duration: $durationText '
      '| Status: ${result.status.name}',
    );

    if (_config.enableDetailedLogging) {
      _logDeveloper(
        'Migration $migrationId finished: '
        '$successCount succeeded, ${result.failedAssets.length} failed',
      );
    }
  }

  /// Logs migration errors with appropriate severity levels.
  ///
  /// Provides detailed error information for debugging purposes.
  void logError(
    String migrationId,
    String operation,
    Object error, {
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    final contextText = context != null
        ? ' | Context: ${context.entries.map((e) => '${e.key}=${e.value}').join(', ')}'
        : '';

    _logger.severe(
      'Migration error: $migrationId '
      '| Operation: $operation '
      '| Error: $error'
      '$contextText',
      error,
      stackTrace,
    );

    // Always log errors to developer console for debugging
    _logDeveloper(
      'Migration $migrationId failed during $operation: $error',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Logs the start of batch processing operations.
  ///
  /// Records batch information for activation and withdrawal operations.
  void logBatchStart(String migrationId, String batchType, int batchSize, int batchNumber) {
    if (_config.enableDetailedLogging) {
      _logger.fine(
        'Batch started: $migrationId '
        '| Type: $batchType '
        '| Size: $batchSize '
        '| Batch: $batchNumber',
      );
    }
  }

  /// Logs the completion of batch processing operations.
  ///
  /// Records batch results and timing information.
  void logBatchComplete(
    String migrationId,
    String batchType,
    int batchNumber,
    int successCount,
    int totalCount,
    Duration duration,
  ) {
    if (_config.enableDetailedLogging) {
      _logger.fine(
        'Batch completed: $migrationId '
        '| Type: $batchType '
        '| Batch: $batchNumber '
        '| Success: $successCount/$totalCount '
        '| Duration: ${duration.inMilliseconds}ms',
      );
    }
  }

  /// Logs migration cancellation events.
  ///
  /// Records the reason for cancellation and current migration state.
  void logMigrationCancelled(String migrationId, String reason, {int? completedAssets}) {
    _logger.warning(
      'Migration cancelled: $migrationId '
      '| Reason: $reason'
      '${completedAssets != null ? ' | Completed: $completedAssets assets' : ''}',
    );

    if (_config.enableDetailedLogging) {
      _logDeveloper('Migration $migrationId was cancelled: $reason');
    }
  }

  /// Logs retry attempt information.
  ///
  /// Records retry attempts for failed operations.
  void logRetryAttempt(
    String migrationId,
    String operation,
    int attemptNumber,
    int maxAttempts, {
    String? reason,
  }) {
    if (_config.enableDetailedLogging) {
      _logger.fine(
        'Retry attempt: $migrationId '
        '| Operation: $operation '
        '| Attempt: $attemptNumber/$maxAttempts'
        '${reason != null ? ' | Reason: $reason' : ''}',
      );
    }
  }

  /// Logs preview generation events.
  ///
  /// Records preview creation and caching information.
  void logPreviewGenerated(String previewId, int assetCount, Duration duration) {
    _logger.info(
      'Preview generated: $previewId '
      '| Assets: $assetCount '
      '| Duration: ${duration.inSeconds}s',
    );

    if (_config.enableDetailedLogging) {
      _logDeveloper('Migration preview $previewId generated for $assetCount assets');
    }
  }

  /// Internal helper for logging to developer console.
  ///
  /// Used for debugging information that should be visible in development
  /// but not necessarily in production logs.
  void _logDeveloper(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (error != null || stackTrace != null) {
      log(
        message,
        name: _loggerName,
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      log(message, name: _loggerName);
    }
  }
}
