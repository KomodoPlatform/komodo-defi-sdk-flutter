// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cosmos_chain_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CosmosChainInfo _$CosmosChainInfoFromJson(Map<String, dynamic> json) =>
    _CosmosChainInfo(
      chainId: json['chain_id'] as String,
      name: json['name'] as String,
      rpc: json['rpc'] as String?,
      nativeCurrency: json['native_currency'] as String?,
      bech32Prefix: json['bech32_prefix'] as String?,
      apis: (json['apis'] as List<dynamic>?)?.map((e) => e as String).toList(),
      prettyName: json['pretty_name'] as String?,
      networkType: json['network_type'] as String?,
      keyAlgos: json['key_algos'] as List<dynamic>?,
      slip44: (json['slip44'] as num?)?.toInt(),
      fees: json['fees'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CosmosChainInfoToJson(_CosmosChainInfo instance) =>
    <String, dynamic>{
      'chain_id': instance.chainId,
      'name': instance.name,
      'rpc': instance.rpc,
      'native_currency': instance.nativeCurrency,
      'bech32_prefix': instance.bech32Prefix,
      'apis': instance.apis,
      'pretty_name': instance.prettyName,
      'network_type': instance.networkType,
      'key_algos': instance.keyAlgos,
      'slip44': instance.slip44,
      'fees': instance.fees,
    };
