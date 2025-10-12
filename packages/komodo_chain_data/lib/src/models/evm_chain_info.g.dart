// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evm_chain_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NativeCurrency _$NativeCurrencyFromJson(Map<String, dynamic> json) =>
    _NativeCurrency(
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      decimals: (json['decimals'] as num).toInt(),
    );

Map<String, dynamic> _$NativeCurrencyToJson(_NativeCurrency instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'decimals': instance.decimals,
    };

_EvmChainInfo _$EvmChainInfoFromJson(Map<String, dynamic> json) =>
    _EvmChainInfo(
      name: json['name'] as String,
      chainId: (json['chainId'] as num).toInt(),
      shortName: json['shortName'] as String,
      networkId: (json['networkId'] as num).toInt(),
      nativeCurrency: NativeCurrency.fromJson(
        json['nativeCurrency'] as Map<String, dynamic>,
      ),
      rpc: (json['rpc'] as List<dynamic>).map((e) => e as String).toList(),
      faucets: (json['faucets'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      infoURL: json['infoURL'] as String,
    );

Map<String, dynamic> _$EvmChainInfoToJson(_EvmChainInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'chainId': instance.chainId,
      'shortName': instance.shortName,
      'networkId': instance.networkId,
      'nativeCurrency': instance.nativeCurrency.toJson(),
      'rpc': instance.rpc,
      'faucets': instance.faucets,
      'infoURL': instance.infoURL,
    };
