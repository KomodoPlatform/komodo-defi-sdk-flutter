import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'package:komodo_coin_updates/src/models/checkpoint_block.dart';
import 'package:komodo_coin_updates/src/models/consensus_params.dart';

part 'adapters/protocol_data_adapter.dart';

class ProtocolData extends Equatable {
  const ProtocolData({
    this.platform,
    this.contractAddress,
    this.consensusParams,
    this.checkPointBlock,
    this.slpPrefix,
    this.decimals,
    this.tokenId,
    this.requiredConfirmations,
    this.denom,
    this.accountPrefix,
    this.chainId,
    this.gasPrice,
  });

  factory ProtocolData.fromJson(Map<String, dynamic> json) {
    return ProtocolData(
      platform: json['platform'] as String?,
      contractAddress: json['contract_address'] as String?,
      consensusParams:
          json['consensus_params'] != null
              ? ConsensusParams.fromJson(
                json['consensus_params'] as Map<String, dynamic>,
              )
              : null,
      checkPointBlock:
          json['check_point_block'] != null
              ? CheckPointBlock.fromJson(
                json['check_point_block'] as Map<String, dynamic>,
              )
              : null,
      slpPrefix: json['slp_prefix'] as String?,
      decimals: json['decimals'] as num?,
      tokenId: json['token_id'] as String?,
      requiredConfirmations: json['required_confirmations'] as num?,
      denom: json['denom'] as String?,
      accountPrefix: json['account_prefix'] as String?,
      chainId: json['chain_id'] as String?,
      gasPrice: json['gas_price'] as num?,
    );
  }

  final String? platform;
  final String? contractAddress;
  final ConsensusParams? consensusParams;
  final CheckPointBlock? checkPointBlock;
  final String? slpPrefix;
  final num? decimals;
  final String? tokenId;
  final num? requiredConfirmations;
  final String? denom;
  final String? accountPrefix;
  final String? chainId;
  final num? gasPrice;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'platform': platform,
      'contract_address': contractAddress,
      'consensus_params': consensusParams?.toJson(),
      'check_point_block': checkPointBlock?.toJson(),
      'slp_prefix': slpPrefix,
      'decimals': decimals,
      'token_id': tokenId,
      'required_confirmations': requiredConfirmations,
      'denom': denom,
      'account_prefix': accountPrefix,
      'chain_id': chainId,
      'gas_price': gasPrice,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    platform,
    contractAddress,
    consensusParams,
    checkPointBlock,
    slpPrefix,
    decimals,
    tokenId,
    requiredConfirmations,
    denom,
    accountPrefix,
    chainId,
    gasPrice,
  ];
}
