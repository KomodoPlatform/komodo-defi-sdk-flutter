// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MigrationResult _$MigrationResultFromJson(Map<String, dynamic> json) =>
    _MigrationResult(
      migrationId: json['migration_id'] as String,
      status: $enumDecode(_$MigrationResultStatusEnumMap, json['status']),
      assetResults: (json['asset_results'] as List<dynamic>)
          .map(
            (e) => AssetMigrationProgress.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      successCount: (json['success_count'] as num).toInt(),
      failureCount: (json['failure_count'] as num).toInt(),
      totalCount: (json['total_count'] as num).toInt(),
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: DateTime.parse(json['completed_at'] as String),
      summary: json['summary'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MigrationResultToJson(_MigrationResult instance) =>
    <String, dynamic>{
      'migration_id': instance.migrationId,
      'status': _$MigrationResultStatusEnumMap[instance.status]!,
      'asset_results': instance.assetResults.map((e) => e.toJson()).toList(),
      'success_count': instance.successCount,
      'failure_count': instance.failureCount,
      'total_count': instance.totalCount,
      'started_at': instance.startedAt.toIso8601String(),
      'completed_at': instance.completedAt.toIso8601String(),
      'summary': instance.summary,
      'metadata': instance.metadata,
    };

const _$MigrationResultStatusEnumMap = {
  MigrationResultStatus.completed: 'completed',
  MigrationResultStatus.partiallyCompleted: 'partiallyCompleted',
  MigrationResultStatus.failed: 'failed',
  MigrationResultStatus.cancelled: 'cancelled',
};
