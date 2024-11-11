import 'package:komodo_defi_rpc_methods/src/common_structures/common_structures.dart';

class LightningActivationParams extends ActivationParams {
  LightningActivationParams({
    required this.name,
    required this.listeningPort,
    required this.color,
    required this.paymentRetries,
    this.acceptInboundChannels = true,
    this.acceptForwardsToPrivChannels = false,
    this.counterpartyChannelConfigLimits,
    this.channelOptions,
    this.ourChannelsConfig,
  });
  final String name;
  final int listeningPort;
  final String color;
  final int paymentRetries;
  final bool acceptInboundChannels;
  final bool acceptForwardsToPrivChannels;
  final CounterpartyChannelConfig? counterpartyChannelConfigLimits;
  final LightningChannelOptions? channelOptions;
  final LightningChannelConfig? ourChannelsConfig;

  @override
  Map<String, dynamic> toJsonRequestParams() => {
        'name': name,
        'listening_port': listeningPort,
        'color': color,
        'payment_retries': paymentRetries,
        'accept_inbound_channels': acceptInboundChannels,
        'accept_forwards_to_priv_channels': acceptForwardsToPrivChannels,
      };
}
