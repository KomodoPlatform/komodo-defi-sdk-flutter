// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MigrationConfig _$MigrationConfigFromJson(Map<String, dynamic> json) =>
    _MigrationConfig(
      activationBatchSize:
          (json['activation_batch_size'] as num?)?.toInt() ??
          MigrationConfig.defaultActivationBatchSize,
      operationTimeout: json['operation_timeout'] == null
          ? MigrationConfig.defaultOperationTimeout
          : _durationFromJson((json['operation_timeout'] as num).toInt()),
      retryAttempts:
          (json['retry_attempts'] as num?)?.toInt() ??
          MigrationConfig.defaultRetryAttempts,
      retryDelay: json['retry_delay'] == null
          ? MigrationConfig.defaultRetryDelay
          : _durationFromJson((json['retry_delay'] as num).toInt()),
      previewCacheTimeout: json['preview_cache_timeout'] == null
          ? MigrationConfig.defaultPreviewCacheTimeout
          : _durationFromJson((json['preview_cache_timeout'] as num).toInt()),
      maxConcurrentWithdrawals:
          (json['max_concurrent_withdrawals'] as num?)?.toInt() ??
          MigrationConfig.defaultMaxConcurrentWithdrawals,
      enableProgressUpdates: json['enable_progress_updates'] as bool? ?? true,
      enableDetailedLogging: json['enable_detailed_logging'] as bool? ?? true,
    );

Map<String, dynamic> _$MigrationConfigToJson(_MigrationConfig instance) =>
    <String, dynamic>{
      'activation_batch_size': instance.activationBatchSize,
      'operation_timeout': _durationToJson(instance.operationTimeout),
      'retry_attempts': instance.retryAttempts,
      'retry_delay': _durationToJson(instance.retryDelay),
      'preview_cache_timeout': _durationToJson(instance.previewCacheTimeout),
      'max_concurrent_withdrawals': instance.maxConcurrentWithdrawals,
      'enable_progress_updates': instance.enableProgressUpdates,
      'enable_detailed_logging': instance.enableDetailedLogging,
    };
