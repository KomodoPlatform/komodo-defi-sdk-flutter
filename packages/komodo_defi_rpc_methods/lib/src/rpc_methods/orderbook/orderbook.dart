import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to retrieve orderbook information for a trading pair.
/// 
/// This RPC method fetches the current state of the orderbook for a specified
/// trading pair, including all active buy and sell orders.
class OrderbookRequest
    extends BaseRequest<OrderbookResponse, GeneralErrorResponse> {
  /// Creates a new [OrderbookRequest].
  /// 
  /// - [rpcPass]: RPC password for authentication
  /// - [base]: The base coin of the trading pair
  /// - [rel]: The rel/quote coin of the trading pair
  OrderbookRequest({
    required String rpcPass,
    required this.base,
    required this.rel,
  }) : super(
         method: 'orderbook',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  /// The base coin of the trading pair.
  /// 
  /// This is the coin being bought or sold in orders.
  final String base;
  
  /// The rel/quote coin of the trading pair.
  /// 
  /// This is the coin used to price the base coin.
  final String rel;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'params': {
        'base': base,
        'rel': rel,
      },
    });
  }

  @override
  OrderbookResponse parse(Map<String, dynamic> json) =>
      OrderbookResponse.parse(json);
}

/// Response containing orderbook data for a trading pair.
/// 
/// This response provides comprehensive orderbook information including
/// all active bids and asks, along with metadata about the orderbook state.
class OrderbookResponse extends BaseResponse {
  /// Creates a new [OrderbookResponse].
  /// 
  /// - [mmrpc]: The RPC version
  /// - [base]: The base coin of the trading pair
  /// - [rel]: The rel/quote coin of the trading pair
  /// - [bids]: List of buy orders
  /// - [asks]: List of sell orders
  /// - [numBids]: Total number of bid orders
  /// - [numAsks]: Total number of ask orders
  /// - [timestamp]: Unix timestamp of when the orderbook was fetched
  OrderbookResponse({
    required super.mmrpc,
    required this.base,
    required this.rel,
    required this.bids,
    required this.asks,
    required this.numBids,
    required this.numAsks,
    required this.timestamp,
  });

  /// Parses an [OrderbookResponse] from a JSON map.
  factory OrderbookResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return OrderbookResponse(
      mmrpc: json.value<String>('mmrpc'),
      base: result.value<String>('base'),
      rel: result.value<String>('rel'),
      bids: result.value<JsonList>('bids').map(OrderInfo.fromJson).toList(),
      asks: result.value<JsonList>('asks').map(OrderInfo.fromJson).toList(),
      numBids: result.value<int>('num_bids'),
      numAsks: result.value<int>('num_asks'),
      timestamp: result.value<int>('timestamp'),
    );
  }

  /// The base coin of the trading pair.
  final String base;
  
  /// The rel/quote coin of the trading pair.
  final String rel;
  
  /// List of buy orders (bids) in the orderbook.
  /// 
  /// These are orders from users wanting to buy the base coin with the rel coin.
  /// Orders are typically sorted by price in descending order (best bid first).
  final List<OrderInfo> bids;
  
  /// List of sell orders (asks) in the orderbook.
  /// 
  /// These are orders from users wanting to sell the base coin for the rel coin.
  /// Orders are typically sorted by price in ascending order (best ask first).
  final List<OrderInfo> asks;
  
  /// Total number of bid orders in the orderbook.
  /// 
  /// This may be larger than the length of [bids] if pagination is applied.
  final int numBids;
  
  /// Total number of ask orders in the orderbook.
  /// 
  /// This may be larger than the length of [asks] if pagination is applied.
  final int numAsks;
  
  /// Unix timestamp of when this orderbook snapshot was taken.
  /// 
  /// Useful for determining the freshness of the orderbook data.
  final int timestamp;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'base': base,
      'rel': rel,
      'bids': bids.map((e) => e.toJson()).toList(),
      'asks': asks.map((e) => e.toJson()).toList(),
      'num_bids': numBids,
      'num_asks': numAsks,
      'timestamp': timestamp,
    },
  };
}

/// Represents the type of order cancellation.
/// 
/// This class provides factory methods to create different cancellation types
/// for the cancel_all_orders RPC method.
class CancelOrdersType {
  /// Creates a cancellation type to cancel all orders across all coins.
  CancelOrdersType.all() : coin = null, _type = 'all';
  
  /// Creates a cancellation type to cancel all orders for a specific coin.
  /// 
  /// - [coin]: The ticker of the coin whose orders should be cancelled
  CancelOrdersType.coin(this.coin) : _type = 'coin';

  /// The coin ticker for coin-specific cancellation.
  /// 
  /// `null` when cancelling all orders across all coins.
  final String? coin;
  
  /// Internal type identifier.
  final String _type;

  /// Converts this [CancelOrdersType] to its JSON representation.
  /// 
  /// Returns different structures based on the cancellation type:
  /// - For all orders: `{"type": "all"}`
  /// - For specific coin: `{"type": "coin", "data": {"coin": "TICKER"}}`
  Map<String, dynamic> toJson() {
    if (_type == 'all') {
      return {'type': 'all'};
    } else {
      return {
        'type': 'coin',
        'data': {'coin': coin},
      };
    }
  }
}