// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProtocolData _$ProtocolDataFromJson(Map<String, dynamic> json) =>
    _ProtocolData(
      platform: json['platform'] as String?,
      contractAddress: json['contract_address'] as String?,
      consensusParams:
          json['consensus_params'] == null
              ? null
              : ConsensusParams.fromJson(
                json['consensus_params'] as Map<String, dynamic>,
              ),
      checkPointBlock:
          json['check_point_block'] == null
              ? null
              : CheckPointBlock.fromJson(
                json['check_point_block'] as Map<String, dynamic>,
              ),
      slpPrefix: json['slp_prefix'] as String?,
      decimals: json['decimals'] as num?,
      tokenId: json['token_id'] as String?,
      requiredConfirmations: json['required_confirmations'] as num?,
      denom: json['denom'] as String?,
      accountPrefix: json['account_prefix'] as String?,
      chainId: json['chain_id'] as String?,
      gasPrice: json['gas_price'] as num?,
    );

Map<String, dynamic> _$ProtocolDataToJson(_ProtocolData instance) =>
    <String, dynamic>{
      'platform': instance.platform,
      'contract_address': instance.contractAddress,
      'consensus_params': instance.consensusParams,
      'check_point_block': instance.checkPointBlock,
      'slp_prefix': instance.slpPrefix,
      'decimals': instance.decimals,
      'token_id': instance.tokenId,
      'required_confirmations': instance.requiredConfirmations,
      'denom': instance.denom,
      'account_prefix': instance.accountPrefix,
      'chain_id': instance.chainId,
      'gas_price': instance.gasPrice,
    };
