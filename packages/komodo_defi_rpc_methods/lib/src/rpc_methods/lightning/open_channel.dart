import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to open a Lightning channel
class OpenChannelRequest
    extends BaseRequest<OpenChannelResponse, GeneralErrorResponse> {
  OpenChannelRequest({
    required String rpcPass,
    required this.coin,
    required this.nodeAddress,
    required this.amount,
    this.pushMsat,
    this.options,
  }) : super(
         method: 'lightning::channels::open_channel',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String coin;
  final String nodeAddress;
  final LightningChannelAmount amount;
  final int? pushMsat;
  final LightningChannelOptions? options;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'params': {
        'coin': coin,
        'node_address': nodeAddress,
        'amount': amount.toJson(),
        if (pushMsat != null) 'push_msat': pushMsat,
        if (options != null) 'channel_options': options!.toJson(),
      },
    });
  }

  @override
  OpenChannelResponse parse(Map<String, dynamic> json) =>
      OpenChannelResponse.parse(json);
}

/// Response from opening a Lightning channel
class OpenChannelResponse extends BaseResponse {
  OpenChannelResponse({
    required super.mmrpc,
    required this.channelId,
    required this.fundingTxId,
  });

  factory OpenChannelResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return OpenChannelResponse(
      mmrpc: json.value<String>('mmrpc'),
      channelId: result.value<String>('channel_id'),
      fundingTxId: result.value<String>('funding_tx_id'),
    );
  }

  final String channelId;
  final String fundingTxId;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'channel_id': channelId, 'funding_tx_id': fundingTxId},
  };
}
