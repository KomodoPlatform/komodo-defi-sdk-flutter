import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// Extensions for Orderbook-related RPC methods
class OrderbookMethodsNamespace extends BaseRpcMethodNamespace {
  OrderbookMethodsNamespace(super.client);

  /// Get orderbook for a trading pair
  Future<OrderbookResponse> orderbook({
    required String base,
    required String rel,
    String? rpcPass,
  }) {
    return execute(
      OrderbookRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        base: base,
        rel: rel,
      ),
    );
  }

  /// Get orderbook depth for a trading pair
  Future<OrderbookDepthResponse> orderbookDepth({
    required List<OrderbookPair> pairs,
    String? rpcPass,
  }) {
    return execute(
      OrderbookDepthRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        pairs: pairs,
      ),
    );
  }

  /// Get best orders
  Future<BestOrdersResponse> bestOrders({
    required String coin,
    required OrderType action,
    required String volume,
    String? rpcPass,
  }) {
    return execute(
      BestOrdersRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        coin: coin,
        action: action,
        volume: volume,
      ),
    );
  }

  /// Create a new order (maker)
  Future<SetOrderResponse> setOrder({
    required String base,
    required String rel,
    required String price,
    required String volume,
    OrderType? orderType,
    bool? minVolume,
    String? baseConfs,
    String? baseNota,
    String? relConfs,
    String? relNota,
    String? rpcPass,
  }) {
    return execute(
      SetOrderRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        base: base,
        rel: rel,
        price: price,
        volume: volume,
        orderType: orderType,
        minVolume: minVolume,
        baseConfs: baseConfs,
        baseNota: baseNota,
        relConfs: relConfs,
        relNota: relNota,
      ),
    );
  }

  /// Cancel an order
  Future<CancelOrderResponse> cancelOrder({
    required String uuid,
    String? rpcPass,
  }) {
    return execute(
      CancelOrderRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        uuid: uuid,
      ),
    );
  }

  /// Cancel all orders for a specific coin or all orders
  Future<CancelAllOrdersResponse> cancelAllOrders({
    CancelOrdersType? cancelType,
    String? rpcPass,
  }) {
    return execute(
      CancelAllOrdersRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
        cancelType: cancelType,
      ),
    );
  }

  /// Get my orders
  Future<MyOrdersResponse> myOrders({
    String? rpcPass,
  }) {
    return execute(
      MyOrdersRequest(
        rpcPass: rpcPass ?? this.rpcPass ?? '',
      ),
    );
  }
}