import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class LightningChannelConfig {
  LightningChannelConfig({
    this.counterpartyLocktime,
    this.ourHtlcMinimumMsat,
    this.negotiateScidPrivacy,
    this.maxInboundInFlightHtlcPercent,
    this.commitUpfrontShutdownPubkey,
    this.inboundChannelsConfirmations,
    this.theirChannelReserveSats,
  });

  factory LightningChannelConfig.fromJson(Map<String, dynamic> json) {
    return LightningChannelConfig(
      counterpartyLocktime: json.valueOrNull<int?>('counterparty_locktime'),
      ourHtlcMinimumMsat: json.valueOrNull<int?>('our_htlc_minimum_msat'),
      negotiateScidPrivacy: json.valueOrNull<bool?>('negotiate_scid_privacy'),
      maxInboundInFlightHtlcPercent: json.valueOrNull<double?>(
        'max_inbound_in_flight_htlc_percent',
      ),
      commitUpfrontShutdownPubkey: json.valueOrNull<bool?>(
        'commit_upfront_shutdown_pubkey',
      ),
      inboundChannelsConfirmations: json.valueOrNull<int?>(
        'inbound_channels_confirmations',
      ),
      theirChannelReserveSats: json.valueOrNull<int?>(
        'their_channel_reserve_sats',
      ),
    );
  }
  final int? counterpartyLocktime;
  final int? ourHtlcMinimumMsat;
  final bool? negotiateScidPrivacy;
  final double? maxInboundInFlightHtlcPercent;
  final bool? commitUpfrontShutdownPubkey;
  final int? inboundChannelsConfirmations;
  final int? theirChannelReserveSats;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (counterpartyLocktime != null) {
      json['counterparty_locktime'] = counterpartyLocktime;
    }
    if (ourHtlcMinimumMsat != null) {
      json['our_htlc_minimum_msat'] = ourHtlcMinimumMsat;
    }
    if (negotiateScidPrivacy != null) {
      json['negotiate_scid_privacy'] = negotiateScidPrivacy;
    }
    if (maxInboundInFlightHtlcPercent != null) {
      json['max_inbound_in_flight_htlc_percent'] =
          maxInboundInFlightHtlcPercent;
    }
    if (commitUpfrontShutdownPubkey != null) {
      json['commit_upfront_shutdown_pubkey'] = commitUpfrontShutdownPubkey;
    }
    if (inboundChannelsConfirmations != null) {
      json['inbound_channels_confirmations'] = inboundChannelsConfirmations;
    }
    if (theirChannelReserveSats != null) {
      json['their_channel_reserve_sats'] = theirChannelReserveSats;
    }
    return json;
  }
}
