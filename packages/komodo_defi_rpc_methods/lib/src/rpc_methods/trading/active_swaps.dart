import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get active swaps
class ActiveSwapsRequest
    extends BaseRequest<ActiveSwapsResponse, GeneralErrorResponse> {
  ActiveSwapsRequest({
    required String rpcPass,
    this.coin,
  }) : super(
         method: 'active_swaps',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String? coin;

  @override
  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{};
    if (coin != null) {
      params['coin'] = coin;
    }

    return super.toJson().deepMerge({
      'params': params,
    });
  }

  @override
  ActiveSwapsResponse parse(Map<String, dynamic> json) =>
      ActiveSwapsResponse.parse(json);
}

/// Response containing active swaps
class ActiveSwapsResponse extends BaseResponse {
  ActiveSwapsResponse({
    required super.mmrpc,
    required this.uuids,
    required this.swaps,
  });

  factory ActiveSwapsResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return ActiveSwapsResponse(
      mmrpc: json.value<String>('mmrpc'),
      uuids: (result.value<List<dynamic>>('uuids'))
          .map((e) => e as String)
          .toList(),
      swaps: (result.value<List<dynamic>>('swaps'))
          .map((e) => SwapInfo.fromJson(e as JsonMap))
          .toList(),
    );
  }

  final List<String> uuids;
  final List<SwapInfo> swaps;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'uuids': uuids,
      'swaps': swaps.map((e) => e.toJson()).toList(),
    },
  };
}