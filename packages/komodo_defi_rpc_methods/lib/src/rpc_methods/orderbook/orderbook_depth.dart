import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get orderbook depth for multiple pairs
class OrderbookDepthRequest
    extends BaseRequest<OrderbookDepthResponse, GeneralErrorResponse> {
  OrderbookDepthRequest({required String rpcPass, required this.pairs})
    : super(
        method: 'orderbook_depth',
        rpcPass: rpcPass,
        mmrpc: RpcVersion.v2_0,
      );

  /// List of trading pairs to query depth for
  final List<OrderbookPair> pairs;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {
      'pairs': pairs.map((e) => [e.base, e.rel]).toList(),
    },
  });

  @override
  OrderbookDepthResponse parse(Map<String, dynamic> json) =>
      OrderbookDepthResponse.parse(json);
}

/// Response containing orderbook depth for pairs
class OrderbookDepthResponse extends BaseResponse {
  OrderbookDepthResponse({required super.mmrpc, required this.depth});

  factory OrderbookDepthResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return OrderbookDepthResponse(
      mmrpc: json.value<String>('mmrpc'),
      depth: result.map(
        (key, value) => MapEntry(
          key,
          OrderbookResponse.parse({
            'mmrpc': json.value<String>('mmrpc'),
            'result': value as JsonMap,
          }),
        ),
      ),
    );
  }

  /// Map of "BASE-REL" -> OrderbookResponse snapshot
  final Map<String, OrderbookResponse> depth;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': depth.map((k, v) => MapEntry(k, v.toJson()['result'])),
  };
}
