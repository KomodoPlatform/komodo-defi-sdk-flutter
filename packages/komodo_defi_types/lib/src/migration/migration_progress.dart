import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'migration_progress.freezed.dart';
part 'migration_progress.g.dart';

/// Status of an individual asset migration
enum AssetMigrationStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
}

/// Overall status of a migration operation
enum MigrationStatus {
  /// Migration is starting up
  initializing,
  /// Migration is in progress
  inProgress,
  /// Migration completed successfully for all assets
  completed,
  /// Migration completed with some failures
  partiallyCompleted,
  /// Migration failed completely
  failed,
  /// Migration was cancelled by user
  cancelled,
}

/// Progress information for a single asset migration
@freezed
abstract class AssetMigrationProgress with _$AssetMigrationProgress {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory AssetMigrationProgress({
    @JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson)
    required AssetId assetId,
    required AssetMigrationStatus status,
    String? txHash,
    String? errorMessage,
    @Default(0.0) double progress, // 0.0 to 1.0
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _AssetMigrationProgress;

  factory AssetMigrationProgress.fromJson(JsonMap json) =>
      _$AssetMigrationProgressFromJson(json);

  /// Create a pending asset migration progress
  factory AssetMigrationProgress.pending(AssetId assetId) =>
      AssetMigrationProgress(
        assetId: assetId,
        status: AssetMigrationStatus.pending,
      );

  /// Create an in-progress asset migration
  factory AssetMigrationProgress.inProgress(
    AssetId assetId, {
    double progress = 0.5,
  }) =>
      AssetMigrationProgress(
        assetId: assetId,
        status: AssetMigrationStatus.inProgress,
        progress: progress,
        startedAt: DateTime.now(),
      );

  /// Create a completed asset migration
  factory AssetMigrationProgress.completed(
    AssetId assetId,
    String txHash,
  ) =>
      AssetMigrationProgress(
        assetId: assetId,
        status: AssetMigrationStatus.completed,
        txHash: txHash,
        progress: 1.0,
        completedAt: DateTime.now(),
      );

  /// Create a failed asset migration
  factory AssetMigrationProgress.failed(
    AssetId assetId,
    String errorMessage,
  ) =>
      AssetMigrationProgress(
        assetId: assetId,
        status: AssetMigrationStatus.failed,
        errorMessage: errorMessage,
        progress: 0.0,
        completedAt: DateTime.now(),
      );

  const AssetMigrationProgress._();

  /// Check if this asset migration is complete (success or failure)
  bool get isComplete =>
      status == AssetMigrationStatus.completed ||
      status == AssetMigrationStatus.failed ||
      status == AssetMigrationStatus.cancelled;

  /// Check if this asset migration was successful
  bool get isSuccessful => status == AssetMigrationStatus.completed;

  /// Get duration of the migration if completed
  Duration? get duration {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }
}

/// Overall progress of a migration operation
@freezed
abstract class MigrationProgress with _$MigrationProgress {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory MigrationProgress({
    required String migrationId,
    required MigrationStatus status,
    required List<AssetMigrationProgress> assetProgress,
    required int completedCount,
    required int totalCount,
    String? message,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _MigrationProgress;

  factory MigrationProgress.fromJson(JsonMap json) =>
      _$MigrationProgressFromJson(json);

  /// Create initial migration progress
  factory MigrationProgress.initial(
    String migrationId,
    List<AssetId> assets,
  ) =>
      MigrationProgress(
        migrationId: migrationId,
        status: MigrationStatus.initializing,
        assetProgress: assets
            .map((asset) => AssetMigrationProgress.pending(asset))
            .toList(),
        completedCount: 0,
        totalCount: assets.length,
        message: 'Initializing migration...',
        startedAt: DateTime.now(),
      );

  const MigrationProgress._();

  /// Calculate overall progress percentage (0.0 to 1.0)
  double get overallProgress => totalCount > 0 ? completedCount / totalCount : 0.0;

  /// Get progress as percentage (0-100)
  double get progressPercentage => overallProgress * 100;

  /// Get list of successfully migrated assets
  List<AssetMigrationProgress> get successfulAssets =>
      assetProgress.where((a) => a.status == AssetMigrationStatus.completed).toList();

  /// Get list of failed asset migrations
  List<AssetMigrationProgress> get failedAssets =>
      assetProgress.where((a) => a.status == AssetMigrationStatus.failed).toList();

  /// Get list of pending asset migrations
  List<AssetMigrationProgress> get pendingAssets =>
      assetProgress.where((a) => a.status == AssetMigrationStatus.pending).toList();

  /// Get list of assets currently in progress
  List<AssetMigrationProgress> get inProgressAssets =>
      assetProgress.where((a) => a.status == AssetMigrationStatus.inProgress).toList();

  /// Check if migration is complete
  bool get isComplete =>
      status == MigrationStatus.completed ||
      status == MigrationStatus.partiallyCompleted ||
      status == MigrationStatus.failed ||
      status == MigrationStatus.cancelled;

  /// Check if migration was successful (all assets migrated)
  bool get isFullySuccessful => status == MigrationStatus.completed;

  /// Check if migration had partial success
  bool get isPartiallySuccessful => status == MigrationStatus.partiallyCompleted;

  /// Get count of successful migrations
  int get successCount => successfulAssets.length;

  /// Get count of failed migrations
  int get failureCount => failedAssets.length;

  /// Get duration of the migration if completed
  Duration? get duration {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }

  /// Get estimated time remaining based on current progress
  Duration? get estimatedTimeRemaining {
    if (startedAt == null || completedCount == 0 || totalCount == 0) return null;

    final elapsed = DateTime.now().difference(startedAt!);
    final averageTimePerAsset = elapsed.inMilliseconds / completedCount;
    final remainingAssets = totalCount - completedCount;

    return Duration(
      milliseconds: (averageTimePerAsset * remainingAssets).round(),
    );
  }
}

/// Helper functions for AssetId JSON serialization
AssetId _assetIdFromJson(Map<String, dynamic> json) =>
    AssetId.parse(json, knownIds: null);

Map<String, dynamic> _assetIdToJson(AssetId assetId) => assetId.toJson();
