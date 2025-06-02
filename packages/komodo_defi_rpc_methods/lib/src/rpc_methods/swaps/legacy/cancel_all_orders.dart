import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to cancel all orders based on a condition
class CancelAllOrdersRequest
    extends BaseRequest<CancelAllOrdersResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  CancelAllOrdersRequest({required this.cancelBy, super.rpcPass})
    : super(method: 'cancel_all_orders', mmrpc: null);

  final CancelBy cancelBy;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'params': {'cancel_by': cancelBy.toJson()},
  };

  @override
  CancelAllOrdersResponse parse(Map<String, dynamic> json) =>
      CancelAllOrdersResponse.fromJson(json);
}

/// Response for cancel_all_orders
class CancelAllOrdersResponse extends BaseResponse {
  CancelAllOrdersResponse({required super.mmrpc, required this.result});

  factory CancelAllOrdersResponse.fromJson(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');
    return CancelAllOrdersResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      result: CancelAllOrdersResult.fromJson(result),
    );
  }

  final CancelAllOrdersResult result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result.toJson()};
}

/// Result data for cancel_all_orders
class CancelAllOrdersResult {
  CancelAllOrdersResult({
    required this.cancelled,
    required this.currentlyMatching,
  });

  factory CancelAllOrdersResult.fromJson(Map<String, dynamic> json) {
    return CancelAllOrdersResult(
      cancelled: json.value<List<dynamic>>('cancelled').cast<String>(),
      currentlyMatching:
          json.value<List<dynamic>>('currently_matching').cast<String>(),
    );
  }

  final List<String> cancelled;
  final List<String> currentlyMatching;

  Map<String, dynamic> toJson() => {
    'cancelled': cancelled,
    'currently_matching': currentlyMatching,
  };
}
