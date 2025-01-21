import 'package:komodo_defi_types/komodo_defi_types.dart';

class LightningChannelOptions {
  LightningChannelOptions({
    this.proportionalFeeInMillionthsSats,
    this.baseFeeMsat,
    this.cltvExpiryDelta,
    this.maxDustHtlcExposureMsat,
    this.forceCloseAvoidanceMaxFeeSatoshis,
  });

  factory LightningChannelOptions.fromJson(Map<String, dynamic> json) {
    return LightningChannelOptions(
      proportionalFeeInMillionthsSats:
          json.valueOrNull<int?>('proportional_fee_in_millionths_sats'),
      baseFeeMsat: json.valueOrNull<int?>('base_fee_msat'),
      cltvExpiryDelta: json.valueOrNull<int?>('cltv_expiry_delta'),
      maxDustHtlcExposureMsat:
          json.valueOrNull<int?>('max_dust_htlc_exposure_msat'),
      forceCloseAvoidanceMaxFeeSatoshis:
          json.valueOrNull<int?>('force_close_avoidance_max_fee_satoshis'),
    );
  }
  final int? proportionalFeeInMillionthsSats;
  final int? baseFeeMsat;
  final int? cltvExpiryDelta;
  final int? maxDustHtlcExposureMsat;
  final int? forceCloseAvoidanceMaxFeeSatoshis;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (proportionalFeeInMillionthsSats != null) {
      json['proportional_fee_in_millionths_sats'] =
          proportionalFeeInMillionthsSats;
    }
    if (baseFeeMsat != null) json['base_fee_msat'] = baseFeeMsat;
    if (cltvExpiryDelta != null) json['cltv_expiry_delta'] = cltvExpiryDelta;
    if (maxDustHtlcExposureMsat != null) {
      json['max_dust_htlc_exposure_msat'] = maxDustHtlcExposureMsat;
    }
    if (forceCloseAvoidanceMaxFeeSatoshis != null) {
      json['force_close_avoidance_max_fee_satoshis'] =
          forceCloseAvoidanceMaxFeeSatoshis;
    }
    return json;
  }
}
