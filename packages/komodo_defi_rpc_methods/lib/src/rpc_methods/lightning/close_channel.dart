import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to close a Lightning channel
class CloseChannelRequest
    extends BaseRequest<CloseChannelResponse, GeneralErrorResponse> {
  CloseChannelRequest({
    required String rpcPass,
    required this.coin,
    required this.rpcChannelId,
    this.forceClose = false,
  }) : super(
         method: 'lightning::channels::close_channel',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  /// Coin ticker for the Lightning-enabled asset (e.g. 'BTC')
  final String coin;

  /// RPC identifier of the channel to close (integer id)
  final int rpcChannelId;

  /// If true, attempts an uncooperative force-close
  final bool forceClose;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {
      'coin': coin,
      'rpc_channel_id': rpcChannelId,
      if (forceClose) 'force_close': forceClose,
    },
  });

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
      channelId: result.valueOrNull<String?>('channel_id') ?? '',
      closingTxId:
          result.valueOrNull<String?>('closing_tx_id') ??
          result.valueOrNull<String?>('tx_id'),
      forceClosed: result.valueOrNull<bool?>('force_closed'),
    );
  }

  /// Identifier of the channel that was closed
  final String channelId;

  /// On-chain transaction ID used to close the channel, if applicable
  final String? closingTxId;

  /// True if the channel was force-closed
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
