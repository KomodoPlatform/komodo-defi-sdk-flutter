import 'package:komodo_defi_types/komodo_defi_types.dart';

class CounterpartyChannelConfig {
  CounterpartyChannelConfig({
    this.outboundChannelsConfirmations,
    this.forceAnnouncedChannelPreference,
    this.ourLocktimeLimit,
  });

  factory CounterpartyChannelConfig.fromJson(Map<String, dynamic> json) {
    return CounterpartyChannelConfig(
      outboundChannelsConfirmations:
          json.value<int?>('outbound_channels_confirmations'),
      forceAnnouncedChannelPreference:
          json.value<bool?>('force_announced_channel_preference'),
      ourLocktimeLimit: json.value<int?>('our_locktime_limit'),
    );
  }
  final int? outboundChannelsConfirmations;
  final bool? forceAnnouncedChannelPreference;
  final int? ourLocktimeLimit;

  Map<String, dynamic> toJson() {
    return {
      if (outboundChannelsConfirmations != null)
        'outbound_channels_confirmations': outboundChannelsConfirmations,
      if (forceAnnouncedChannelPreference != null)
        'force_announced_channel_preference': forceAnnouncedChannelPreference,
      if (ourLocktimeLimit != null) 'our_locktime_limit': ourLocktimeLimit,
    };
  }
}
