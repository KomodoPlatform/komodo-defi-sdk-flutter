import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to close a Lightning channel
class CloseChannelRequest
    extends BaseRequest<CloseChannelResponse, GeneralErrorResponse> {
  CloseChannelRequest({
    required String rpcPass,
    required this.coin,
    required this.channelId,
    this.forceClose = false,
  }) : super(
         method: 'lightning::close_channel',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String coin;
  final String channelId;
  final bool forceClose;

  @override
  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{
      'coin': coin,
      'channel_id': channelId,
    };

    if (forceClose) {
      params['force_close'] = forceClose;
    }

    return super.toJson().deepMerge({'params': params});
  }

  @override
  CloseChannelResponse parse(Map<String, dynamic> json) =>
      CloseChannelResponse.parse(json);
}

/// Response from closing a Lightning channel
class CloseChannelResponse extends BaseResponse {
  CloseChannelResponse({
    required super.mmrpc,
    required this.channelId,
    this.closingTxId,
    this.forceClosed,
  });

  factory CloseChannelResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return CloseChannelResponse(
      mmrpc: json.value<String>('mmrpc'),
      channelId: result.valueOrNull<String?>('channel_id') ??
          result.valueOrNull<String?>('rpc_channel_id')?.toString() ??
          '',
      closingTxId: result.valueOrNull<String?>('closing_tx_id') ??
          result.valueOrNull<String?>('tx_id'),
      forceClosed: result.valueOrNull<bool?>('force_closed'),
    );
  }

  final String channelId;
  final String? closingTxId;
  final bool? forceClosed;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'channel_id': channelId,
      if (closingTxId != null) 'closing_tx_id': closingTxId,
      if (forceClosed != null) 'force_closed': forceClosed,
    },
  };
}


