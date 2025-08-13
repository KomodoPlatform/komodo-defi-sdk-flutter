import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to cancel a specific order
class CancelOrderRequest
    extends BaseRequest<CancelOrderResponse, GeneralErrorResponse> {
  CancelOrderRequest({required String rpcPass, required this.uuid})
    : super(method: 'cancel_order', rpcPass: rpcPass, mmrpc: RpcVersion.v2_0);

  /// UUID of the order to cancel
  final String uuid;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {'uuid': uuid},
  });

  @override
  CancelOrderResponse parse(Map<String, dynamic> json) =>
      CancelOrderResponse.parse(json);
}

/// Response from cancelling an order
class CancelOrderResponse extends BaseResponse {
  CancelOrderResponse({required super.mmrpc, required this.cancelled});

  factory CancelOrderResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    return CancelOrderResponse(
      mmrpc: json.value<String>('mmrpc'),
      cancelled: result.value<bool>('cancelled'),
    );
  }

  /// True if the order was cancelled successfully
  final bool cancelled;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'cancelled': cancelled},
  };
}
