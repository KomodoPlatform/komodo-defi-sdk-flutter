import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class ListClosedChannelsByFilterRequest
    extends
        BaseRequest<ListClosedChannelsByFilterResponse, GeneralErrorResponse> {
  ListClosedChannelsByFilterRequest({
    required String rpcPass,
    required this.coin,
    this.filter,
  }) : super(
         method: 'lightning::channels::list_closed_channels_by_filter',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String coin;
  final LightningClosedChannelsFilter? filter;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {'coin': coin, if (filter != null) 'filter': filter!.toJson()},
  });

  @override
  ListClosedChannelsByFilterResponse parse(Map<String, dynamic> json) =>
      ListClosedChannelsByFilterResponse.parse(json);
}

class ListClosedChannelsByFilterResponse extends BaseResponse {
  ListClosedChannelsByFilterResponse({
    required super.mmrpc,
    required this.channels,
  });

  factory ListClosedChannelsByFilterResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    return ListClosedChannelsByFilterResponse(
      mmrpc: json.value<String>('mmrpc'),
      channels:
          (result.valueOrNull<JsonList>('channels') ?? [])
              .map(ChannelInfo.fromJson)
              .toList(),
    );
  }
  final List<ChannelInfo> channels;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'channels': channels.map((e) => e.toJson()).toList()},
  };
}
