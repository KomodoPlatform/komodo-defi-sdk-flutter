// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_operation_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssetMigrationPreview _$AssetMigrationPreviewFromJson(
  Map<String, dynamic> json,
) => _AssetMigrationPreview(
  assetId: _assetIdFromJson(json['asset_id'] as Map<String, dynamic>),
  sourceAddress: json['source_address'] as String,
  targetAddress: json['target_address'] as String,
  balance: _decimalFromJson(json['balance'] as String),
  estimatedFee: _decimalFromJson(json['estimated_fee'] as String),
  netAmount: _decimalFromJson(json['net_amount'] as String),
  status: $enumDecode(_$MigrationAssetStatusEnumMap, json['status']),
  errorMessage: json['error_message'] as String?,
);

Map<String, dynamic> _$AssetMigrationPreviewToJson(
  _AssetMigrationPreview instance,
) => <String, dynamic>{
  'asset_id': _assetIdToJson(instance.assetId),
  'source_address': instance.sourceAddress,
  'target_address': instance.targetAddress,
  'balance': _decimalToJson(instance.balance),
  'estimated_fee': _decimalToJson(instance.estimatedFee),
  'net_amount': _decimalToJson(instance.netAmount),
  'status': _$MigrationAssetStatusEnumMap[instance.status]!,
  'error_message': instance.errorMessage,
};

const _$MigrationAssetStatusEnumMap = {
  MigrationAssetStatus.ready: 'ready',
  MigrationAssetStatus.activationFailed: 'activationFailed',
  MigrationAssetStatus.insufficientBalance: 'insufficientBalance',
  MigrationAssetStatus.unsupported: 'unsupported',
};

_MigrationSummary _$MigrationSummaryFromJson(Map<String, dynamic> json) =>
    _MigrationSummary(
      totalAssets: (json['total_assets'] as num).toInt(),
      readyAssets: (json['ready_assets'] as num).toInt(),
      failedAssets: (json['failed_assets'] as num).toInt(),
      totalEstimatedFees: _decimalFromJson(
        json['total_estimated_fees'] as String,
      ),
    );

Map<String, dynamic> _$MigrationSummaryToJson(_MigrationSummary instance) =>
    <String, dynamic>{
      'total_assets': instance.totalAssets,
      'ready_assets': instance.readyAssets,
      'failed_assets': instance.failedAssets,
      'total_estimated_fees': _decimalToJson(instance.totalEstimatedFees),
    };

_MigrationOperationPreview _$MigrationOperationPreviewFromJson(
  Map<String, dynamic> json,
) => _MigrationOperationPreview(
  previewId: json['preview_id'] as String,
  sourceWallet: WalletId.fromJson(
    json['source_wallet'] as Map<String, dynamic>,
  ),
  targetWallet: WalletId.fromJson(
    json['target_wallet'] as Map<String, dynamic>,
  ),
  assets: (json['assets'] as List<dynamic>)
      .map((e) => AssetMigrationPreview.fromJson(e as Map<String, dynamic>))
      .toList(),
  summary: MigrationSummary.fromJson(json['summary'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$MigrationOperationPreviewToJson(
  _MigrationOperationPreview instance,
) => <String, dynamic>{
  'preview_id': instance.previewId,
  'source_wallet': instance.sourceWallet.toJson(),
  'target_wallet': instance.targetWallet.toJson(),
  'assets': instance.assets.map((e) => e.toJson()).toList(),
  'summary': instance.summary.toJson(),
  'created_at': instance.createdAt.toIso8601String(),
};
