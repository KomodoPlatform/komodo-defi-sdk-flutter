import 'package:freezed_annotation/freezed_annotation.dart';

part 'cosmos_asset.freezed.dart';
part 'cosmos_asset.g.dart';

/// Represents a denom unit from the Cosmos chain directory.
@freezed
abstract class CosmosDenomUnit with _$CosmosDenomUnit {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CosmosDenomUnit({
    required String denom,
    required int exponent,
    List<String>? aliases,
  }) = _CosmosDenomUnit;

  const CosmosDenomUnit._();

  factory CosmosDenomUnit.fromJson(Map<String, dynamic> json) =>
      _$CosmosDenomUnitFromJson(json);
}

/// Represents logo URIs from the Cosmos chain directory.
@freezed
abstract class CosmosLogoUris with _$CosmosLogoUris {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CosmosLogoUris({String? png, String? svg}) = _CosmosLogoUris;

  const CosmosLogoUris._();

  factory CosmosLogoUris.fromJson(Map<String, dynamic> json) =>
      _$CosmosLogoUrisFromJson(json);
}

/// Represents price information from CoinGecko.
@freezed
abstract class CosmosAssetPrices with _$CosmosAssetPrices {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CosmosAssetPrices({required double usd}) = _CosmosAssetPrices;

  const CosmosAssetPrices._();

  factory CosmosAssetPrices.fromJson(Map<String, dynamic> json) =>
      _$CosmosAssetPricesFromJson(json);
}

/// Represents an asset from the Cosmos chain directory.
@freezed
abstract class CosmosAsset with _$CosmosAsset {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CosmosAsset({
    required String name,
    String? description,
    required String symbol,
    required String denom,
    required int decimals,
    required CosmosDenomUnit base,
    required CosmosDenomUnit display,
    required List<CosmosDenomUnit> denomUnits,
    CosmosLogoUris? logoUris,
    String? image,
    String? coingeckoId,
    CosmosAssetPrices? prices,
  }) = _CosmosAsset;

  const CosmosAsset._();

  factory CosmosAsset.fromJson(Map<String, dynamic> json) =>
      _$CosmosAssetFromJson(json);
}
