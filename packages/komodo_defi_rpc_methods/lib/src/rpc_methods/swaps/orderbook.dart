import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get the currently available orders for the specified trading pair
class OrderbookRequest
    extends BaseRequest<OrderbookResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  OrderbookRequest({
    required String rpcPass,
    required this.base,
    required this.rel,
  }) : super(method: 'orderbook', rpcPass: rpcPass, mmrpc: '2.0');

  /// Base currency of a pair
  final String base;

  /// Related currency, also known as the "quote currency"
  final String rel;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'params': {'base': base, 'rel': rel},
    });
  }

  @override
  OrderbookResponse parse(Map<String, dynamic> json) =>
      OrderbookResponse.parse(json);
}

class OrderbookResponse extends BaseResponse {
  OrderbookResponse({
    required super.mmrpc,
    required this.base,
    required this.rel,
    required this.numasks,
    required this.numbids,
    required this.netid,
    required this.asks,
    required this.bids,
    required this.timestamp,
    required this.totalAsksBaseVol,
    required this.totalAsksRelVol,
    required this.totalBidsBaseVol,
    required this.totalBidsRelVol,
    super.id,
  });

  factory OrderbookResponse.parse(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');

    return OrderbookResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      id: json.valueOrNull<String>('id'),
      base: result.value<String>('base'),
      rel: result.value<String>('rel'),
      numasks: result.value<int>('num_asks'),
      numbids: result.value<int>('num_bids'),
      netid: result.value<int>('net_id'),
      asks:
          result
              .value<List<dynamic>>('asks')
              .map<OrderData>((ask) => OrderData.fromJson(ask as JsonMap))
              .toList(),
      bids:
          result
              .value<List<dynamic>>('bids')
              .map<OrderData>((bid) => OrderData.fromJson(bid as JsonMap))
              .toList(),
      timestamp: result.value<int>('timestamp'),
      totalAsksBaseVol: VolumeData.fromJson(
        result.value<JsonMap>('total_asks_base_vol'),
      ),
      totalAsksRelVol: VolumeData.fromJson(
        result.value<JsonMap>('total_asks_rel_vol'),
      ),
      totalBidsBaseVol: VolumeData.fromJson(
        result.value<JsonMap>('total_bids_base_vol'),
      ),
      totalBidsRelVol: VolumeData.fromJson(
        result.value<JsonMap>('total_bids_rel_vol'),
      ),
    );
  }

  /// The name of the coin the user desires to receive
  final String base;

  /// The name of the coin the user will trade
  final String rel;

  /// The number of outstanding asks
  final int numasks;

  /// The number of outstanding bids
  final int numbids;

  /// The id of the network on which the request is made (default is 8762)
  final int netid;

  /// An array of standard OrderData objects containing outstanding asks
  final List<OrderData> asks;

  /// An array of standard OrderData objects containing outstanding bids
  final List<OrderData> bids;

  /// A UNIX timestamp representing when the orderbook was requested
  final int timestamp;

  /// Total asks base volume
  final VolumeData totalAsksBaseVol;

  /// Total asks rel volume
  final VolumeData totalAsksRelVol;

  /// Total bids base volume
  final VolumeData totalBidsBaseVol;

  /// Total bids rel volume
  final VolumeData totalBidsRelVol;

  @override
  Map<String, dynamic> toJson() {
    return {
      'base': base,
      'rel': rel,
      'num_asks': numasks,
      'num_bids': numbids,
      'net_id': netid,
      'asks': asks.map((ask) => ask.toJson()).toList(),
      'bids': bids.map((bid) => bid.toJson()).toList(),
      'timestamp': timestamp,
      'total_asks_base_vol': totalAsksBaseVol.toJson(),
      'total_asks_rel_vol': totalAsksRelVol.toJson(),
      'total_bids_base_vol': totalBidsBaseVol.toJson(),
      'total_bids_rel_vol': totalBidsRelVol.toJson(),
    };
  }
}
