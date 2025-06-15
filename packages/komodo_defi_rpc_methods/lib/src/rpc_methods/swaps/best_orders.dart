import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get the best priced trades available on the orderbook
class BestOrdersRequest
    extends BaseRequest<BestOrdersResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  BestOrdersRequest({
    required String rpcPass,
    required this.coin,
    required this.action,
    required this.requestBy,
    this.excludeMine = false,
  }) : super(method: 'best_orders', rpcPass: rpcPass, mmrpc: '2.0');

  /// The ticker of the coin to get best orders for
  final String coin;

  /// Whether to buy or sell the selected coin
  final String action;

  /// Whether to exclude the user's own orders from the response
  final bool excludeMine;

  /// How to request the orders - either by number or volume
  final RequestBy requestBy;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'params': {
        'coin': coin,
        'action': action,
        'exclude_mine': excludeMine,
        'request_by': requestBy.toJson(),
      },
    });
  }

  @override
  BestOrdersResponse parse(Map<String, dynamic> json) =>
      BestOrdersResponse.parse(json);
}

class BestOrdersResponse extends BaseResponse {
  BestOrdersResponse({
    required super.mmrpc,
    required this.orders,
    required this.originalTickers,
    super.id,
  });

  factory BestOrdersResponse.parse(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');

    final ordersJson = result.value<JsonMap>('orders');
    final orders = <String, List<OrderData>>{};

    for (final entry in ordersJson.entries) {
      final ordersList = entry.value as List<dynamic>;
      orders[entry.key] =
          ordersList.cast<JsonMap>().map(OrderData.fromJson).toList();
    }

    final originalTickersJson = result.value<JsonMap>('original_tickers');
    final originalTickers = <String, List<String>>{};

    for (final entry in originalTickersJson.entries) {
      final tickersList = entry.value as List<dynamic>;
      originalTickers[entry.key] = tickersList.cast<String>();
    }

    return BestOrdersResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      id: json.valueOrNull<String>('id'),
      orders: orders,
      originalTickers: originalTickers,
    );
  }

  /// Map of ticker to array of OrderData objects
  final Map<String, List<OrderData>> orders;

  /// Tickers included in response when orderbook_ticker is configured
  final Map<String, List<String>> originalTickers;

  @override
  Map<String, dynamic> toJson() {
    final ordersJson = <String, dynamic>{};
    for (final entry in orders.entries) {
      ordersJson[entry.key] =
          entry.value.map((order) => order.toJson()).toList();
    }

    return {'orders': ordersJson, 'original_tickers': originalTickers};
  }
}
