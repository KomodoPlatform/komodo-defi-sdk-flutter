import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

part 'adapters/consensus_params_adapter.dart';

class ConsensusParams extends Equatable {
  const ConsensusParams({
    this.overwinterActivationHeight,
    this.saplingActivationHeight,
    this.blossomActivationHeight,
    this.heartwoodActivationHeight,
    this.canopyActivationHeight,
    this.coinType,
    this.hrpSaplingExtendedSpendingKey,
    this.hrpSaplingExtendedFullViewingKey,
    this.hrpSaplingPaymentAddress,
    this.b58PubkeyAddressPrefix,
    this.b58ScriptAddressPrefix,
  });

  factory ConsensusParams.fromJson(Map<String, dynamic> json) {
    return ConsensusParams(
      overwinterActivationHeight: json['overwinter_activation_height'] as num?,
      saplingActivationHeight: json['sapling_activation_height'] as num?,
      blossomActivationHeight: json['blossom_activation_height'] as num?,
      heartwoodActivationHeight: json['heartwood_activation_height'] as num?,
      canopyActivationHeight: json['canopy_activation_height'] as num?,
      coinType: json['coin_type'] as num?,
      hrpSaplingExtendedSpendingKey:
          json['hrp_sapling_extended_spending_key'] as String?,
      hrpSaplingExtendedFullViewingKey:
          json['hrp_sapling_extended_full_viewing_key'] as String?,
      hrpSaplingPaymentAddress: json['hrp_sapling_payment_address'] as String?,
      b58PubkeyAddressPrefix:
          json['b58_pubkey_address_prefix'] != null
              ? List<num>.from(
                json['b58_pubkey_address_prefix'] as List<dynamic>,
              )
              : null,
      b58ScriptAddressPrefix:
          json['b58_script_address_prefix'] != null
              ? List<num>.from(
                json['b58_script_address_prefix'] as List<dynamic>,
              )
              : null,
    );
  }

  final num? overwinterActivationHeight;
  final num? saplingActivationHeight;
  final num? blossomActivationHeight;
  final num? heartwoodActivationHeight;
  final num? canopyActivationHeight;
  final num? coinType;
  final String? hrpSaplingExtendedSpendingKey;
  final String? hrpSaplingExtendedFullViewingKey;
  final String? hrpSaplingPaymentAddress;
  final List<num>? b58PubkeyAddressPrefix;
  final List<num>? b58ScriptAddressPrefix;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'overwinter_activation_height': overwinterActivationHeight,
      'sapling_activation_height': saplingActivationHeight,
      'blossom_activation_height': blossomActivationHeight,
      'heartwood_activation_height': heartwoodActivationHeight,
      'canopy_activation_height': canopyActivationHeight,
      'coin_type': coinType,
      'hrp_sapling_extended_spending_key': hrpSaplingExtendedSpendingKey,
      'hrp_sapling_extended_full_viewing_key': hrpSaplingExtendedFullViewingKey,
      'hrp_sapling_payment_address': hrpSaplingPaymentAddress,
      'b58_pubkey_address_prefix': b58PubkeyAddressPrefix,
      'b58_script_address_prefix': b58ScriptAddressPrefix,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    overwinterActivationHeight,
    saplingActivationHeight,
    blossomActivationHeight,
    heartwoodActivationHeight,
    canopyActivationHeight,
    coinType,
    hrpSaplingExtendedSpendingKey,
    hrpSaplingExtendedFullViewingKey,
    hrpSaplingPaymentAddress,
    b58PubkeyAddressPrefix,
    b58ScriptAddressPrefix,
  ];
}
