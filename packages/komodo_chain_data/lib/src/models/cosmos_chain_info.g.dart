// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cosmos_chain_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CosmosChainInfo _$CosmosChainInfoFromJson(
  Map<String, dynamic> json,
) => _CosmosChainInfo(
  name: json['name'] as String,
  path: json['path'] as String,
  chainName: json['chain_name'] as String,
  networkType: json['network_type'] as String,
  prettyName: json['pretty_name'] as String,
  chainId: json['chain_id'] as String,
  status: json['status'] as String,
  bech32Prefix: json['bech32_prefix'] as String,
  slip44: (json['slip44'] as num).toInt(),
  symbol: json['symbol'] as String,
  display: json['display'] as String,
  denom: json['denom'] as String,
  decimals: (json['decimals'] as num).toInt(),
  bestApis: CosmosBestApis.fromJson(json['best_apis'] as Map<String, dynamic>),
  proxyStatus: CosmosProxyStatus.fromJson(
    json['proxy_status'] as Map<String, dynamic>,
  ),
  versions: CosmosVersions.fromJson(json['versions'] as Map<String, dynamic>),
  image: json['image'] as String?,
  website: json['website'] as String?,
  height: (json['height'] as num?)?.toInt(),
  explorers: (json['explorers'] as List<dynamic>?)
      ?.map((e) => CosmosExplorer.fromJson(e as Map<String, dynamic>))
      .toList(),
  assets: (json['assets'] as List<dynamic>?)
      ?.map((e) => CosmosAsset.fromJson(e as Map<String, dynamic>))
      .toList(),
  keywords: (json['keywords'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  coingeckoId: json['coingecko_id'] as String?,
);

Map<String, dynamic> _$CosmosChainInfoToJson(_CosmosChainInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'chain_name': instance.chainName,
      'network_type': instance.networkType,
      'pretty_name': instance.prettyName,
      'chain_id': instance.chainId,
      'status': instance.status,
      'bech32_prefix': instance.bech32Prefix,
      'slip44': instance.slip44,
      'symbol': instance.symbol,
      'display': instance.display,
      'denom': instance.denom,
      'decimals': instance.decimals,
      'best_apis': instance.bestApis.toJson(),
      'proxy_status': instance.proxyStatus.toJson(),
      'versions': instance.versions.toJson(),
      'image': instance.image,
      'website': instance.website,
      'height': instance.height,
      'explorers': instance.explorers?.map((e) => e.toJson()).toList(),
      'assets': instance.assets?.map((e) => e.toJson()).toList(),
      'keywords': instance.keywords,
      'coingecko_id': instance.coingeckoId,
    };
