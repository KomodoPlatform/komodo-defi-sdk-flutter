// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consensus_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConsensusParams _$ConsensusParamsFromJson(Map<String, dynamic> json) =>
    _ConsensusParams(
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
          (json['b58_pubkey_address_prefix'] as List<dynamic>?)
              ?.map((e) => e as num)
              .toList(),
      b58ScriptAddressPrefix:
          (json['b58_script_address_prefix'] as List<dynamic>?)
              ?.map((e) => e as num)
              .toList(),
    );

Map<String, dynamic> _$ConsensusParamsToJson(
  _ConsensusParams instance,
) => <String, dynamic>{
  'overwinter_activation_height': instance.overwinterActivationHeight,
  'sapling_activation_height': instance.saplingActivationHeight,
  'blossom_activation_height': instance.blossomActivationHeight,
  'heartwood_activation_height': instance.heartwoodActivationHeight,
  'canopy_activation_height': instance.canopyActivationHeight,
  'coin_type': instance.coinType,
  'hrp_sapling_extended_spending_key': instance.hrpSaplingExtendedSpendingKey,
  'hrp_sapling_extended_full_viewing_key':
      instance.hrpSaplingExtendedFullViewingKey,
  'hrp_sapling_payment_address': instance.hrpSaplingPaymentAddress,
  'b58_pubkey_address_prefix': instance.b58PubkeyAddressPrefix,
  'b58_script_address_prefix': instance.b58ScriptAddressPrefix,
};
