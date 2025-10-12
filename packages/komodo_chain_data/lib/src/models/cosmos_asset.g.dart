// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cosmos_asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CosmosDenomUnit _$CosmosDenomUnitFromJson(Map<String, dynamic> json) =>
    _CosmosDenomUnit(
      denom: json['denom'] as String,
      exponent: (json['exponent'] as num).toInt(),
      aliases: (json['aliases'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CosmosDenomUnitToJson(_CosmosDenomUnit instance) =>
    <String, dynamic>{
      'denom': instance.denom,
      'exponent': instance.exponent,
      'aliases': instance.aliases,
    };

_CosmosLogoUris _$CosmosLogoUrisFromJson(Map<String, dynamic> json) =>
    _CosmosLogoUris(png: json['png'] as String?, svg: json['svg'] as String?);

Map<String, dynamic> _$CosmosLogoUrisToJson(_CosmosLogoUris instance) =>
    <String, dynamic>{'png': instance.png, 'svg': instance.svg};

_CosmosAssetPrices _$CosmosAssetPricesFromJson(Map<String, dynamic> json) =>
    _CosmosAssetPrices(usd: (json['usd'] as num).toDouble());

Map<String, dynamic> _$CosmosAssetPricesToJson(_CosmosAssetPrices instance) =>
    <String, dynamic>{'usd': instance.usd};

_CosmosAsset _$CosmosAssetFromJson(Map<String, dynamic> json) => _CosmosAsset(
  name: json['name'] as String,
  description: json['description'] as String?,
  symbol: json['symbol'] as String,
  denom: json['denom'] as String,
  decimals: (json['decimals'] as num).toInt(),
  base: CosmosDenomUnit.fromJson(json['base'] as Map<String, dynamic>),
  display: CosmosDenomUnit.fromJson(json['display'] as Map<String, dynamic>),
  denomUnits: (json['denom_units'] as List<dynamic>)
      .map((e) => CosmosDenomUnit.fromJson(e as Map<String, dynamic>))
      .toList(),
  logoUris: json['logo_uris'] == null
      ? null
      : CosmosLogoUris.fromJson(json['logo_uris'] as Map<String, dynamic>),
  image: json['image'] as String?,
  coingeckoId: json['coingecko_id'] as String?,
  prices: json['prices'] == null
      ? null
      : CosmosAssetPrices.fromJson(json['prices'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CosmosAssetToJson(_CosmosAsset instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'symbol': instance.symbol,
      'denom': instance.denom,
      'decimals': instance.decimals,
      'base': instance.base,
      'display': instance.display,
      'denom_units': instance.denomUnits,
      'logo_uris': instance.logoUris,
      'image': instance.image,
      'coingecko_id': instance.coingeckoId,
      'prices': instance.prices,
    };
