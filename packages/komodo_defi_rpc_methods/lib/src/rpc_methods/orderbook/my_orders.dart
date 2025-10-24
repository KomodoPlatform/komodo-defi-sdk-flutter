import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get current user's orders
class MyOrdersRequest
    extends BaseRequest<MyOrdersResponse, GeneralErrorResponse> {
  MyOrdersRequest({required String rpcPass})
    : super(method: 'my_orders', rpcPass: rpcPass, mmrpc: RpcVersion.v2_0);

  @override
  MyOrdersResponse parse(Map<String, dynamic> json) =>
      MyOrdersResponse.parse(json);
}

/// Response with user's orders
class MyOrdersResponse extends BaseResponse {
  MyOrdersResponse({required super.mmrpc, required this.orders});

  factory MyOrdersResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return MyOrdersResponse(
      mmrpc: json.value<String>('mmrpc'),
      orders:
          result.value<JsonList>('orders').map(MyOrderInfo.fromJson).toList(),
    );
  }

  /// List of orders created by the current wallet
  final List<MyOrderInfo> orders;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'orders': orders.map((e) => e.toJson()).toList()},
  };
}
