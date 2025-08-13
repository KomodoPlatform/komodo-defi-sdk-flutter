import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to cancel orders by type (all or by coin)
class CancelAllOrdersRequest
    extends BaseRequest<CancelAllOrdersResponse, GeneralErrorResponse> {
  CancelAllOrdersRequest({required String rpcPass, this.cancelType})
    : super(
        method: 'cancel_all_orders',
        rpcPass: rpcPass,
        mmrpc: RpcVersion.v2_0,
      );

  /// Criteria for which orders to cancel (all or by coin)
  final CancelOrdersType? cancelType;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
        'params': {
          if (cancelType != null) 'cancel_by': cancelType!.toJson(),
        },
      });

  @override
  CancelAllOrdersResponse parse(Map<String, dynamic> json) =>
      CancelAllOrdersResponse.parse(json);
}

/// Response from cancelling orders by type
class CancelAllOrdersResponse extends BaseResponse {
  CancelAllOrdersResponse({required super.mmrpc, required this.cancelled});

  factory CancelAllOrdersResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    return CancelAllOrdersResponse(
      mmrpc: json.value<String>('mmrpc'),
      cancelled: result.value<bool>('cancelled'),
    );
  }

  /// True if the cancellation request succeeded
  final bool cancelled;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'cancelled': cancelled},
  };
}
