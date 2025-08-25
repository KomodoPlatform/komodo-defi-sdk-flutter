import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'migration_request.freezed.dart';
part 'migration_request.g.dart';

/// Represents a migration request from a source wallet to a target wallet
@freezed
abstract class MigrationRequest with _$MigrationRequest {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory MigrationRequest({
    /// The wallet ID to migrate assets from
    required WalletId sourceWalletId,

    /// The wallet ID to migrate assets to
    required WalletId targetWalletId,

    /// List of asset IDs selected for migration
    @JsonKey(fromJson: _assetIdListFromJson, toJson: _assetIdListToJson)
    required List<AssetId> selectedAssets,

    /// Whether to only show/migrate already activated coins
    @Default(false) bool activateCoinsOnly,

    /// Custom fee preferences per asset (optional)
    @JsonKey(fromJson: _feePreferencesFromJson, toJson: _feePreferencesToJson)
    @Default({}) Map<AssetId, WithdrawalFeeLevel> feePreferences,
  }) = _MigrationRequest;

  factory MigrationRequest.fromJson(JsonMap json) =>
      _$MigrationRequestFromJson(json);
}

/// Helper functions for AssetId JSON serialization
List<AssetId> _assetIdListFromJson(List<dynamic> json) =>
    json.map((e) => AssetId.parse(e as Map<String, dynamic>, knownIds: null)).toList();

List<Map<String, dynamic>> _assetIdListToJson(List<AssetId> assetIds) =>
    assetIds.map((e) => e.toJson()).toList();

Map<AssetId, WithdrawalFeeLevel> _feePreferencesFromJson(Map<String, dynamic> json) {
  final Map<AssetId, WithdrawalFeeLevel> result = {};
  json.forEach((key, value) {
    final assetId = AssetId.parse(Map<String, dynamic>.from(key as Map), knownIds: null);
    final feeLevel = WithdrawalFeeLevel.values.firstWhere(
      (level) => level.name == value,
      orElse: () => WithdrawalFeeLevel.medium,
    );
    result[assetId] = feeLevel;
  });
  return result;
}

Map<String, dynamic> _feePreferencesToJson(Map<AssetId, WithdrawalFeeLevel> feePreferences) {
  final Map<String, dynamic> result = {};
  feePreferences.forEach((assetId, feeLevel) {
    result[assetId.toJson().toString()] = feeLevel.name;
  });
  return result;
}
