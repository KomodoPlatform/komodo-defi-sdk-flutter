import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get recent swaps (history)
class RecentSwapsRequest
    extends BaseRequest<RecentSwapsResponse, GeneralErrorResponse> {
  RecentSwapsRequest({required String rpcPass, this.filter})
    : super(
        method: 'my_recent_swaps',
        rpcPass: rpcPass,
        mmrpc: RpcVersion.v2_0,
      );

  /// Optional typed filter
  final RecentSwapsFilter? filter;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {if (filter != null) 'filter': filter!.toJson()},
  });

  @override
  RecentSwapsResponse parse(Map<String, dynamic> json) =>
      RecentSwapsResponse.parse(json);
}

/// Response containing recent swaps
class RecentSwapsResponse extends BaseResponse {
  RecentSwapsResponse({required super.mmrpc, required this.swaps});

  factory RecentSwapsResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return RecentSwapsResponse(
      mmrpc: json.value<String>('mmrpc'),
      swaps: result.value<JsonList>('swaps').map(SwapInfo.fromJson).toList(),
    );
  }

  /// List of recent swaps matching the filter/pagination
  final List<SwapInfo> swaps;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'swaps': swaps.map((e) => e.toJson()).toList()},
  };
}
