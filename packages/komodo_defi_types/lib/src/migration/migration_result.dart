import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/src/migration/migration_progress.dart';

part 'migration_result.freezed.dart';
part 'migration_result.g.dart';

/// Final status of a migration operation
enum MigrationResultStatus {
  /// Migration completed successfully for all assets
  completed,
  /// Migration completed with some failures
  partiallyCompleted,
  /// Migration failed completely
  failed,
  /// Migration was cancelled by user
  cancelled,
}

/// Result of a completed migration operation
@freezed
abstract class MigrationResult with _$MigrationResult {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory MigrationResult({
    required String migrationId,
    required MigrationResultStatus status,
    required List<AssetMigrationProgress> assetResults,
    required int successCount,
    required int failureCount,
    required int totalCount,
    required DateTime startedAt,
    required DateTime completedAt,
    String? summary,
    Map<String, dynamic>? metadata,
  }) = _MigrationResult;

  factory MigrationResult.fromJson(JsonMap json) =>
      _$MigrationResultFromJson(json);

  /// Create a successful migration result
  factory MigrationResult.successful(
    String migrationId,
    List<AssetMigrationProgress> assetResults,
    DateTime startedAt,
  ) {
    final successful = assetResults
        .where((asset) => asset.status == AssetMigrationStatus.completed)
        .length;

    return MigrationResult(
      migrationId: migrationId,
      status: MigrationResultStatus.completed,
      assetResults: assetResults,
      successCount: successful,
      failureCount: 0,
      totalCount: assetResults.length,
      startedAt: startedAt,
      completedAt: DateTime.now(),
      summary: 'Migration completed successfully for all $successful assets.',
    );
  }

  /// Create a partially successful migration result
  factory MigrationResult.partiallySuccessful(
    String migrationId,
    List<AssetMigrationProgress> assetResults,
    DateTime startedAt,
  ) {
    final successful = assetResults
        .where((asset) => asset.status == AssetMigrationStatus.completed)
        .length;
    final failed = assetResults
        .where((asset) => asset.status == AssetMigrationStatus.failed)
        .length;

    return MigrationResult(
      migrationId: migrationId,
      status: MigrationResultStatus.partiallyCompleted,
      assetResults: assetResults,
      successCount: successful,
      failureCount: failed,
      totalCount: assetResults.length,
      startedAt: startedAt,
      completedAt: DateTime.now(),
      summary: 'Migration completed with $successful successful and $failed failed assets.',
    );
  }

  /// Create a failed migration result
  factory MigrationResult.failed(
    String migrationId,
    List<AssetMigrationProgress> assetResults,
    DateTime startedAt,
    String errorMessage,
  ) {
    final failed = assetResults
        .where((asset) => asset.status == AssetMigrationStatus.failed)
        .length;

    return MigrationResult(
      migrationId: migrationId,
      status: MigrationResultStatus.failed,
      assetResults: assetResults,
      successCount: 0,
      failureCount: failed,
      totalCount: assetResults.length,
      startedAt: startedAt,
      completedAt: DateTime.now(),
      summary: 'Migration failed: $errorMessage',
    );
  }

  /// Create a cancelled migration result
  factory MigrationResult.cancelled(
    String migrationId,
    List<AssetMigrationProgress> assetResults,
    DateTime startedAt,
  ) {
    final successful = assetResults
        .where((asset) => asset.status == AssetMigrationStatus.completed)
        .length;
    final failed = assetResults
        .where((asset) => asset.status == AssetMigrationStatus.failed)
        .length;

    return MigrationResult(
      migrationId: migrationId,
      status: MigrationResultStatus.cancelled,
      assetResults: assetResults,
      successCount: successful,
      failureCount: failed,
      totalCount: assetResults.length,
      startedAt: startedAt,
      completedAt: DateTime.now(),
      summary: 'Migration was cancelled by user.',
    );
  }

  const MigrationResult._();

  /// Duration of the migration operation
  Duration get duration => completedAt.difference(startedAt);

  /// List of successfully migrated assets
  List<AssetMigrationProgress> get successfulAssets =>
      assetResults.where((a) => a.status == AssetMigrationStatus.completed).toList();

  /// List of failed asset migrations
  List<AssetMigrationProgress> get failedAssets =>
      assetResults.where((a) => a.status == AssetMigrationStatus.failed).toList();

  /// List of cancelled asset migrations
  List<AssetMigrationProgress> get cancelledAssets =>
      assetResults.where((a) => a.status == AssetMigrationStatus.cancelled).toList();

  /// Check if the migration was fully successful
  bool get isFullySuccessful => status == MigrationResultStatus.completed;

  /// Check if the migration had any successes
  bool get hasSuccesses => successCount > 0;

  /// Check if the migration had any failures
  bool get hasFailures => failureCount > 0;

  /// Get success rate as percentage (0-100)
  double get successRate => totalCount > 0 ? (successCount / totalCount) * 100 : 0.0;

  /// Get failure rate as percentage (0-100)
  double get failureRate => totalCount > 0 ? (failureCount / totalCount) * 100 : 0.0;

  /// Get a user-friendly status message
  String get statusMessage {
    switch (status) {
      case MigrationResultStatus.completed:
        return 'Migration completed successfully';
      case MigrationResultStatus.partiallyCompleted:
        return 'Migration partially completed';
      case MigrationResultStatus.failed:
        return 'Migration failed';
      case MigrationResultStatus.cancelled:
        return 'Migration cancelled';
    }
  }

  /// Get detailed summary with timing information
  String get detailedSummary {
    final durationText = _formatDuration(duration);
    final baseMessage = summary ?? statusMessage;

    return '$baseMessage (completed in $durationText)';
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      final seconds = duration.inSeconds % 60;
      return '${duration.inMinutes}m ${seconds}s';
    } else {
      final minutes = duration.inMinutes % 60;
      return '${duration.inHours}h ${minutes}m';
    }
  }
}
