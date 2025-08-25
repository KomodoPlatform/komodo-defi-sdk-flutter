// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssetMigrationProgress _$AssetMigrationProgressFromJson(
  Map<String, dynamic> json,
) => _AssetMigrationProgress(
  assetId: _assetIdFromJson(json['asset_id'] as Map<String, dynamic>),
  status: $enumDecode(_$AssetMigrationStatusEnumMap, json['status']),
  txHash: json['tx_hash'] as String?,
  errorMessage: json['error_message'] as String?,
  progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
  startedAt: json['started_at'] == null
      ? null
      : DateTime.parse(json['started_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
);

Map<String, dynamic> _$AssetMigrationProgressToJson(
  _AssetMigrationProgress instance,
) => <String, dynamic>{
  'asset_id': _assetIdToJson(instance.assetId),
  'status': _$AssetMigrationStatusEnumMap[instance.status]!,
  'tx_hash': instance.txHash,
  'error_message': instance.errorMessage,
  'progress': instance.progress,
  'started_at': instance.startedAt?.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
};

const _$AssetMigrationStatusEnumMap = {
  AssetMigrationStatus.pending: 'pending',
  AssetMigrationStatus.inProgress: 'inProgress',
  AssetMigrationStatus.completed: 'completed',
  AssetMigrationStatus.failed: 'failed',
  AssetMigrationStatus.cancelled: 'cancelled',
};

_MigrationProgress _$MigrationProgressFromJson(Map<String, dynamic> json) =>
    _MigrationProgress(
      migrationId: json['migration_id'] as String,
      status: $enumDecode(_$MigrationStatusEnumMap, json['status']),
      assetProgress: (json['asset_progress'] as List<dynamic>)
          .map(
            (e) => AssetMigrationProgress.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      completedCount: (json['completed_count'] as num).toInt(),
      totalCount: (json['total_count'] as num).toInt(),
      message: json['message'] as String?,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$MigrationProgressToJson(_MigrationProgress instance) =>
    <String, dynamic>{
      'migration_id': instance.migrationId,
      'status': _$MigrationStatusEnumMap[instance.status]!,
      'asset_progress': instance.assetProgress.map((e) => e.toJson()).toList(),
      'completed_count': instance.completedCount,
      'total_count': instance.totalCount,
      'message': instance.message,
      'started_at': instance.startedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
    };

const _$MigrationStatusEnumMap = {
  MigrationStatus.initializing: 'initializing',
  MigrationStatus.inProgress: 'inProgress',
  MigrationStatus.completed: 'completed',
  MigrationStatus.partiallyCompleted: 'partiallyCompleted',
  MigrationStatus.failed: 'failed',
  MigrationStatus.cancelled: 'cancelled',
};
