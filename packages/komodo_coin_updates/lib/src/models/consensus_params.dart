import 'package:freezed_annotation/freezed_annotation.dart';

part 'consensus_params.freezed.dart';
part 'consensus_params.g.dart';

@freezed
abstract class ConsensusParams with _$ConsensusParams {
  const factory ConsensusParams({
    num? overwinterActivationHeight,
    num? saplingActivationHeight,
    num? blossomActivationHeight,
    num? heartwoodActivationHeight,
    num? canopyActivationHeight,
    num? coinType,
    String? hrpSaplingExtendedSpendingKey,
    String? hrpSaplingExtendedFullViewingKey,
    String? hrpSaplingPaymentAddress,
    List<num>? b58PubkeyAddressPrefix,
    List<num>? b58ScriptAddressPrefix,
  }) = _ConsensusParams;

  factory ConsensusParams.fromJson(Map<String, dynamic> json) =>
      _$ConsensusParamsFromJson(json);
}
