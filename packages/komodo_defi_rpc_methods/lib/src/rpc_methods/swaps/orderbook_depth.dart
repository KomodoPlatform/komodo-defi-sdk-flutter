import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get the number of asks and bids for specified trading pairs
class OrderbookDepthRequest
    extends BaseRequest<OrderbookDepthResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  OrderbookDepthRequest({required String rpcPass, required this.pairs})
    : super(method: 'orderbook_depth', rpcPass: rpcPass, mmrpc: null);

  /// Array of trading pairs, each pair is an array of 2 strings
  final List<List<String>> pairs;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({'pairs': pairs});
  }

  @override
  OrderbookDepthResponse parse(Map<String, dynamic> json) =>
      OrderbookDepthResponse.parse(json);
}

class OrderbookDepthResponse extends BaseResponse {
  OrderbookDepthResponse({
    required super.mmrpc,
    required this.result,
    super.id,
  });

  factory OrderbookDepthResponse.parse(Map<String, dynamic> json) {
    final result = json.value<List<dynamic>>('result');

    return OrderbookDepthResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      id: json.valueOrNull<String>('id'),
      result:
          result
              .map<PairDepth>((item) => PairDepth.fromJson(item as JsonMap))
              .toList(),
    );
  }

  /// Array of pair depth objects
  final List<PairDepth> result;

  @override
  Map<String, dynamic> toJson() {
    return {
      if (mmrpc != null) 'mmrpc': mmrpc,
      if (id != null) 'id': id,
      'result': result.map((item) => item.toJson()).toList(),
    };
  }
}

/// Represents the depth information for a trading pair
class PairDepth {
  PairDepth({required this.pair, required this.depth});

  factory PairDepth.fromJson(Map<String, dynamic> json) {
    return PairDepth(
      pair: json.value<List<dynamic>>('pair').cast<String>(),
      depth: DepthInfo.fromJson(json.value<JsonMap>('depth')),
    );
  }

  /// The orderbook pair (array of 2 strings)
  final List<String> pair;

  /// The depth information (asks and bids count)
  final DepthInfo depth;

  Map<String, dynamic> toJson() => {'pair': pair, 'depth': depth.toJson()};
}

/// Represents the depth information with asks and bids count
class DepthInfo {
  DepthInfo({required this.asks, required this.bids});

  factory DepthInfo.fromJson(Map<String, dynamic> json) {
    return DepthInfo(
      asks: json.value<int>('asks'),
      bids: json.value<int>('bids'),
    );
  }

  /// The number of asks
  final int asks;

  /// The number of bids
  final int bids;

  Map<String, dynamic> toJson() => {'asks': asks, 'bids': bids};
}
