import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_coin_updates/src/models/checkpoint_block.dart';
import 'package:komodo_coin_updates/src/models/consensus_params.dart';

part 'protocol_data.freezed.dart';
part 'protocol_data.g.dart';

@freezed
abstract class ProtocolData with _$ProtocolData {
  const factory ProtocolData({
    String? platform,
    String? contractAddress,
    ConsensusParams? consensusParams,
    CheckPointBlock? checkPointBlock,
    String? slpPrefix,
    num? decimals,
    String? tokenId,
    num? requiredConfirmations,
    String? denom,
    String? accountPrefix,
    String? chainId,
    num? gasPrice,
  }) = _ProtocolData;

  factory ProtocolData.fromJson(Map<String, dynamic> json) =>
      _$ProtocolDataFromJson(json);
}
