import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get best orders for a coin and action
class BestOrdersRequest
    extends BaseRequest<BestOrdersResponse, GeneralErrorResponse> {
  BestOrdersRequest({
    required String rpcPass,
    required this.coin,
    required this.action,
    required this.requestBy,
    this.excludeMine,
  }) : super(method: 'best_orders', rpcPass: rpcPass, mmrpc: RpcVersion.v2_0);

  /// Coin ticker to trade
  final String coin;

  /// Desired trade direction
  final OrderType action;

  /// Request-by selector (volume or number)
  final RequestBy requestBy;

  /// Whether to exclude orders created by the current wallet. Defaults to false in API.
  final bool? excludeMine;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {
      'coin': coin,
      'action': action.toJson(),
      if (excludeMine != null) 'exclude_mine': excludeMine,
      'request_by': requestBy.toJson(),
    },
  });

  @override
  BestOrdersResponse parse(Map<String, dynamic> json) =>
      BestOrdersResponse.parse(json);
}

/// Response containing best orders list
class BestOrdersResponse extends BaseResponse {
  BestOrdersResponse({required super.mmrpc, required this.orders});

  factory BestOrdersResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return BestOrdersResponse(
      mmrpc: json.value<String>('mmrpc'),
      orders: result.value<JsonList>('orders').map(OrderInfo.fromJson).toList(),
    );
  }

  /// Sorted list of best orders that can fulfill the request
  final List<OrderInfo> orders;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'orders': orders.map((e) => e.toJson()).toList()},
  };
}
