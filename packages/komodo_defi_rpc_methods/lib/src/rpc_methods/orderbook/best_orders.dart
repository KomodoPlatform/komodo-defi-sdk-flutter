import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get best orders for a coin and action
class BestOrdersRequest
    extends BaseRequest<BestOrdersResponse, GeneralErrorResponse> {
  BestOrdersRequest({
    required String rpcPass,
    required this.coin,
    required this.action,
    required this.volume,
  }) : super(
         method: 'best_orders',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String coin;
  final OrderType action;
  final String volume;

  @override
  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{
      'coin': coin,
      'action': action.toJson(),
      'request_by': {
        'type': 'volume',
        'value': double.tryParse(volume) ?? volume,
      },
    };

    return super.toJson().deepMerge({'params': params});
  }

  @override
  BestOrdersResponse parse(Map<String, dynamic> json) =>
      BestOrdersResponse.parse(json);
}

/// Response containing best orders list
class BestOrdersResponse extends BaseResponse {
  BestOrdersResponse({
    required super.mmrpc,
    required this.orders,
  });

  factory BestOrdersResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return BestOrdersResponse(
      mmrpc: json.value<String>('mmrpc'),
      orders: (result.value<List<dynamic>>('orders'))
          .map((e) => OrderInfo.fromJson(e as JsonMap))
          .toList(),
    );
  }

  final List<OrderInfo> orders;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'orders': orders.map((e) => e.toJson()).toList(),
    },
  };
}


