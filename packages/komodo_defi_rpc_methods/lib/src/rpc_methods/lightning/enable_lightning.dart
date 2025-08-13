import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to enable Lightning Network functionality for a given coin
class EnableLightningRequest
    extends BaseRequest<EnableLightningResponse, GeneralErrorResponse> {
  EnableLightningRequest({
    required String rpcPass,
    required this.ticker,
    required this.activationParams,
  }) : super(
         method: 'enable_lightning',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
         params: activationParams,
       );

  final String ticker;
  final LightningActivationParams activationParams;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'params': {
        'ticker': ticker,
        ...activationParams.toRpcParams(),
      },
    });
  }

  @override
  EnableLightningResponse parse(Map<String, dynamic> json) =>
      EnableLightningResponse.parse(json);
}

/// Response from enabling Lightning Network functionality
class EnableLightningResponse extends BaseResponse {
  EnableLightningResponse({
    required super.mmrpc,
    required this.nodeId,
    required this.listeningPort,
    required this.ourChannelsConfig,
    required this.counterpartyChannelConfigLimits,
    required this.channelOptions,
  });

  factory EnableLightningResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return EnableLightningResponse(
      mmrpc: json.value<String>('mmrpc'),
      nodeId: result.value<String>('node_id'),
      listeningPort: result.value<int>('listening_port'),
      ourChannelsConfig: LightningChannelConfig.fromJson(
        result.value<JsonMap>('our_channels_config'),
      ),
      counterpartyChannelConfigLimits: CounterpartyChannelConfig.fromJson(
        result.value<JsonMap>('counterparty_channel_config_limits'),
      ),
      channelOptions: LightningChannelOptions.fromJson(
        result.value<JsonMap>('channel_options'),
      ),
    );
  }

  final String nodeId;
  final int listeningPort;
  final LightningChannelConfig ourChannelsConfig;
  final CounterpartyChannelConfig counterpartyChannelConfigLimits;
  final LightningChannelOptions channelOptions;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'node_id': nodeId,
      'listening_port': listeningPort,
      'our_channels_config': ourChannelsConfig.toJson(),
      'counterparty_channel_config_limits': counterpartyChannelConfigLimits.toJson(),
      'channel_options': channelOptions.toJson(),
    },
  };
}