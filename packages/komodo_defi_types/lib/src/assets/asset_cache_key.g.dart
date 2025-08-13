// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_cache_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssetCacheKey _$AssetCacheKeyFromJson(Map<String, dynamic> json) =>
    _AssetCacheKey(
      assetConfigId: json['assetConfigId'] as String,
      chainId: json['chainId'] as String,
      subClass: json['subClass'] as String,
      protocolKey: json['protocolKey'] as String,
      customFields:
          json['customFields'] as Map<String, dynamic>? ??
          const <String, Object?>{},
    );

Map<String, dynamic> _$AssetCacheKeyToJson(_AssetCacheKey instance) =>
    <String, dynamic>{
      'assetConfigId': instance.assetConfigId,
      'chainId': instance.chainId,
      'subClass': instance.subClass,
      'protocolKey': instance.protocolKey,
      'customFields': instance.customFields,
    };
