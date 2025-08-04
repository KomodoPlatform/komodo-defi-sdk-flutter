// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MigrationPreview _$MigrationPreviewFromJson(Map<String, dynamic> json) =>
    _MigrationPreview(
      fromWalletId:
          WalletId.fromJson(json['from_wallet_id'] as Map<String, dynamic>),
      toWalletId:
          WalletId.fromJson(json['to_wallet_id'] as Map<String, dynamic>),
      pubkeyHash: json['pubkey_hash'] as String,
      withdrawals: (json['withdrawals'] as List<dynamic>)
          .map((e) => WithdrawResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MigrationPreviewToJson(_MigrationPreview instance) =>
    <String, dynamic>{
      'from_wallet_id': instance.fromWalletId.toJson(),
      'to_wallet_id': instance.toWalletId.toJson(),
      'pubkey_hash': instance.pubkeyHash,
      'withdrawals': instance.withdrawals.map((e) => e.toJson()).toList(),
    };
