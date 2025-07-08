import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to recreate swap data from the opposite side of a trade
class RecreateSwapDataRequest
    extends BaseRequest<RecreateSwapDataResponse, GeneralErrorResponse> {
  RecreateSwapDataRequest({required String rpcPass, required this.swap})
    : super(method: 'recreate_swap_data', rpcPass: rpcPass, mmrpc: '2.0');

  /// Swap data from other side of trade
  final SwapStatus swap;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'params': {'swap': swap.toJson()},
    });
  }

  @override
  RecreateSwapDataResponse parse(Map<String, dynamic> json) =>
      RecreateSwapDataResponse.parse(json);
}

class RecreateSwapDataResponse extends BaseResponse {
  RecreateSwapDataResponse({
    required super.mmrpc,
    required this.swap,
    super.id,
  });

  factory RecreateSwapDataResponse.parse(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');
    final swapData = result.value<JsonMap>('swap');

    return RecreateSwapDataResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      id: json.valueOrNull<String>('id'),
      swap: SwapStatus.parse(swapData),
    );
  }

  /// Opposite side's swap data
  final SwapStatus swap;

  @override
  Map<String, dynamic> toJson() {
    return {'swap': swap.toJson()};
  }
}
