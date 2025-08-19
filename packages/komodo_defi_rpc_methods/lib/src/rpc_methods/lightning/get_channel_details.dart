import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class GetChannelDetailsRequest
    extends BaseRequest<GetChannelDetailsResponse, GeneralErrorResponse> {
  GetChannelDetailsRequest({
    required String rpcPass,
    required this.coin,
    required this.rpcChannelId,
  }) : super(
         method: 'lightning::channels::get_channel_details',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String coin;
  final int rpcChannelId;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {'coin': coin, 'rpc_channel_id': rpcChannelId},
  });

  @override
  GetChannelDetailsResponse parse(Map<String, dynamic> json) =>
      GetChannelDetailsResponse.parse(json);
}

class GetChannelDetailsResponse extends BaseResponse {
  GetChannelDetailsResponse({required super.mmrpc, required this.channel});

  factory GetChannelDetailsResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    return GetChannelDetailsResponse(
      mmrpc: json.value<String>('mmrpc'),
      channel: ChannelInfo.fromJson(result.value<JsonMap>('channel')),
    );
  }

  final ChannelInfo channel;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'channel': channel.toJson()},
  };
}
