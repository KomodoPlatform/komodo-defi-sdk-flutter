import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'migration_operation_preview.freezed.dart';
part 'migration_operation_preview.g.dart';

/// Status of an individual asset in the migration preview
enum MigrationAssetStatus {
  /// Asset is ready to be migrated
  ready,
  /// Asset failed activation
  activationFailed,
  /// Insufficient balance to cover fees
  insufficientBalance,
  /// Asset is not supported for migration
  unsupported,
}

/// Preview information for a single asset migration
@freezed
abstract class AssetMigrationPreview with _$AssetMigrationPreview {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory AssetMigrationPreview({
    @JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson)
    required AssetId assetId,
    required String sourceAddress,
    required String targetAddress,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    required Decimal balance,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    required Decimal estimatedFee,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    required Decimal netAmount,
    required MigrationAssetStatus status,
    String? errorMessage,
  }) = _AssetMigrationPreview;

  factory AssetMigrationPreview.fromJson(JsonMap json) =>
      _$AssetMigrationPreviewFromJson(json);
}

/// Summary statistics for a migration preview
@freezed
abstract class MigrationSummary with _$MigrationSummary {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory MigrationSummary({
    required int totalAssets,
    required int readyAssets,
    required int failedAssets,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    required Decimal totalEstimatedFees,
  }) = _MigrationSummary;

  factory MigrationSummary.fromJson(JsonMap json) =>
      _$MigrationSummaryFromJson(json);

  /// Calculate success rate as percentage (0-100)
  const MigrationSummary._();

  double get successRate =>
      totalAssets > 0 ? (readyAssets / totalAssets) * 100 : 0.0;

  /// Check if migration is viable (at least one asset ready)
  bool get isViable => readyAssets > 0;
}

/// Complete preview of a migration operation
@freezed
abstract class MigrationOperationPreview with _$MigrationOperationPreview {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory MigrationOperationPreview({
    required String previewId,
    required WalletId sourceWallet,
    required WalletId targetWallet,
    required List<AssetMigrationPreview> assets,
    required MigrationSummary summary,
    required DateTime createdAt,
  }) = _MigrationOperationPreview;

  factory MigrationOperationPreview.fromJson(JsonMap json) =>
      _$MigrationOperationPreviewFromJson(json);

  /// Get assets that are ready for migration
  const MigrationOperationPreview._();

  List<AssetMigrationPreview> get readyAssets =>
      assets.where((asset) => asset.status == MigrationAssetStatus.ready).toList();

  /// Get assets that failed during preview
  List<AssetMigrationPreview> get failedAssets =>
      assets.where((asset) => asset.status != MigrationAssetStatus.ready).toList();

  /// Check if preview has expired (older than 10 minutes)
  bool get isExpired =>
      DateTime.now().difference(createdAt).inMinutes > 10;
}

/// Helper functions for AssetId JSON serialization
AssetId _assetIdFromJson(Map<String, dynamic> json) =>
    AssetId.parse(json, knownIds: null);

Map<String, dynamic> _assetIdToJson(AssetId assetId) => assetId.toJson();

/// Helper functions for Decimal JSON serialization
Decimal _decimalFromJson(String value) => Decimal.parse(value);

String _decimalToJson(Decimal decimal) => decimal.toString();
