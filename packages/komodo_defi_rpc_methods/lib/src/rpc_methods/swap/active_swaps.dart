import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class ActiveSwapsRequest
    extends BaseRequest<ActiveSwapsResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  ActiveSwapsRequest({required super.rpcPass})
    : super(method: 'active_swaps', mmrpc: '2.0');

  @override
  Map<String, dynamic> toJson() => super.toJson();

  @override
  ActiveSwapsResponse parse(Map<String, dynamic> json) =>
      ActiveSwapsResponse.parse(json);
}

class ActiveSwapsResponse extends BaseResponse {
  ActiveSwapsResponse({required super.mmrpc, required this.swaps});

  factory ActiveSwapsResponse.parse(Map<String, dynamic> json) =>
      ActiveSwapsResponse(
        mmrpc: json.value<String>('mmrpc'),
        swaps:
            (json.value<JsonList>('result') as List)
                .map((e) => SwapStatus.fromJson(e))
                .toList(),
      );

  final List<SwapStatus> swaps;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'swaps': swaps.map((e) => e.toJson()).toList(),
  };
}
