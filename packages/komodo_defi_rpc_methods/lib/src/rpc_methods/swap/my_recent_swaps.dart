import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class MyRecentSwapsRequest
    extends BaseRequest<MyRecentSwapsResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  MyRecentSwapsRequest({required super.rpcPass, this.limit})
    : super(method: 'my_recent_swaps', mmrpc: '2.0');

  final int? limit;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {if (limit != null) 'limit': limit},
  };

  @override
  MyRecentSwapsResponse parse(Map<String, dynamic> json) =>
      MyRecentSwapsResponse.parse(json);
}

class MyRecentSwapsResponse extends BaseResponse {
  MyRecentSwapsResponse({required super.mmrpc, required this.swaps});

  factory MyRecentSwapsResponse.parse(Map<String, dynamic> json) =>
      MyRecentSwapsResponse(
        mmrpc: json.value<String>('mmrpc'),
        swaps:
            (json.value<JsonList>(
              'result',
              'swaps',
            )).map((e) => SwapStatus.fromJson(e)).toList(),
      );

  final List<SwapStatus> swaps;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'swaps': swaps.map((e) => e.toJson()).toList(),
  };
}
