// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evm_chain_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EvmChainInfo _$EvmChainInfoFromJson(Map<String, dynamic> json) =>
    _EvmChainInfo(
      chainId: json['chain_id'] as String,
      name: json['name'] as String,
      networkId: (json['network_id'] as num).toInt(),
      rpc: json['rpc'] as String?,
      nativeCurrency: json['native_currency'] as String?,
      explorers: (json['explorers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      shortName: json['short_name'] as String?,
      chain: json['chain'] as String?,
      icon: json['icon'] as String?,
      infoURL: json['infoURL'] as String?,
    );

Map<String, dynamic> _$EvmChainInfoToJson(_EvmChainInfo instance) =>
    <String, dynamic>{
      'chain_id': instance.chainId,
      'name': instance.name,
      'network_id': instance.networkId,
      'rpc': instance.rpc,
      'native_currency': instance.nativeCurrency,
      'explorers': instance.explorers,
      'short_name': instance.shortName,
      'chain': instance.chain,
      'icon': instance.icon,
      'infoURL': instance.infoURL,
    };
