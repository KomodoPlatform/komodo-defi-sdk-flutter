// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_errors.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssetMigrationError _$AssetMigrationErrorFromJson(Map<String, dynamic> json) =>
    _AssetMigrationError(
      assetId: _assetIdFromJson(json['asset_id'] as Map<String, dynamic>),
      errorType: $enumDecode(_$MigrationErrorTypeEnumMap, json['error_type']),
      message: json['message'] as String,
      userFriendlyMessage: json['user_friendly_message'] as String?,
      originalError: json['original_error'] as String?,
      occurredAt: json['occurred_at'] == null
          ? null
          : DateTime.parse(json['occurred_at'] as String),
    );

Map<String, dynamic> _$AssetMigrationErrorToJson(
  _AssetMigrationError instance,
) => <String, dynamic>{
  'asset_id': _assetIdToJson(instance.assetId),
  'error_type': _$MigrationErrorTypeEnumMap[instance.errorType]!,
  'message': instance.message,
  'user_friendly_message': instance.userFriendlyMessage,
  'original_error': instance.originalError,
  'occurred_at': instance.occurredAt?.toIso8601String(),
};

const _$MigrationErrorTypeEnumMap = {
  MigrationErrorType.activationFailed: 'activationFailed',
  MigrationErrorType.insufficientBalance: 'insufficientBalance',
  MigrationErrorType.insufficientFee: 'insufficientFee',
  MigrationErrorType.txCreationFailed: 'txCreationFailed',
  MigrationErrorType.txBroadcastFailed: 'txBroadcastFailed',
  MigrationErrorType.walletLocked: 'walletLocked',
  MigrationErrorType.invalidWallet: 'invalidWallet',
  MigrationErrorType.networkError: 'networkError',
  MigrationErrorType.cancelled: 'cancelled',
  MigrationErrorType.unknown: 'unknown',
};
