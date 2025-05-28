import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class MySwapStatusRequest
    extends BaseRequest<MySwapStatusResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  MySwapStatusRequest({required super.rpcPass, required this.uuid})
    : super(method: 'my_swap_status', mmrpc: '2.0');

  final String uuid;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'uuid': uuid},
  };

  @override
  MySwapStatusResponse parse(Map<String, dynamic> json) =>
      MySwapStatusResponse.parse(json);
}

class MySwapStatusResponse extends BaseResponse {
  MySwapStatusResponse({required super.mmrpc, required this.swap});

  factory MySwapStatusResponse.parse(Map<String, dynamic> json) =>
      MySwapStatusResponse(
        mmrpc: json.value<String>('mmrpc'),
        swap: SwapStatus.fromJson(json.value<JsonMap>('result')),
      );

  final SwapStatus swap;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': swap.toJson()};
}
