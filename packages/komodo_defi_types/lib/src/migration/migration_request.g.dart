// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MigrationRequest _$MigrationRequestFromJson(Map<String, dynamic> json) =>
    _MigrationRequest(
      sourceWalletId: WalletId.fromJson(
        json['source_wallet_id'] as Map<String, dynamic>,
      ),
      targetWalletId: WalletId.fromJson(
        json['target_wallet_id'] as Map<String, dynamic>,
      ),
      selectedAssets: _assetIdListFromJson(json['selected_assets'] as List),
      activateCoinsOnly: json['activate_coins_only'] as bool? ?? false,
      feePreferences: json['fee_preferences'] == null
          ? const {}
          : _feePreferencesFromJson(
              json['fee_preferences'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$MigrationRequestToJson(_MigrationRequest instance) =>
    <String, dynamic>{
      'source_wallet_id': instance.sourceWalletId.toJson(),
      'target_wallet_id': instance.targetWalletId.toJson(),
      'selected_assets': _assetIdListToJson(instance.selectedAssets),
      'activate_coins_only': instance.activateCoinsOnly,
      'fee_preferences': _feePreferencesToJson(instance.feePreferences),
    };
