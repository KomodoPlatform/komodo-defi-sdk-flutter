import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get orderbook
class OrderbookRequest
    extends BaseRequest<OrderbookResponse, GeneralErrorResponse> {
  OrderbookRequest({
    required String rpcPass,
    required this.base,
    required this.rel,
  }) : super(
         method: 'orderbook',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String base;
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

/// Response containing orderbook data
class OrderbookResponse extends BaseResponse {
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

  factory OrderbookResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return OrderbookResponse(
      mmrpc: json.value<String>('mmrpc'),
      base: result.value<String>('base'),
      rel: result.value<String>('rel'),
      bids: (result.value<List<dynamic>>('bids'))
          .map((e) => OrderInfo.fromJson(e as JsonMap))
          .toList(),
      asks: (result.value<List<dynamic>>('asks'))
          .map((e) => OrderInfo.fromJson(e as JsonMap))
          .toList(),
      numBids: result.value<int>('num_bids'),
      numAsks: result.value<int>('num_asks'),
      timestamp: result.value<int>('timestamp'),
    );
  }

  final String base;
  final String rel;
  final List<OrderInfo> bids;
  final List<OrderInfo> asks;
  final int numBids;
  final int numAsks;
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

/// Information about an order
class OrderInfo {
  OrderInfo({
    required this.uuid,
    required this.price,
    required this.maxVolume,
    required this.minVolume,
    required this.pubkey,
    required this.age,
    required this.zcredits,
    required this.coin,
    required this.address,
  });

  factory OrderInfo.fromJson(JsonMap json) {
    return OrderInfo(
      uuid: json.value<String>('uuid'),
      price: json.value<String>('price'),
      maxVolume: json.value<String>('max_volume'),
      minVolume: json.value<String>('min_volume'),
      pubkey: json.value<String>('pubkey'),
      age: json.value<int>('age'),
      zcredits: json.value<int>('zcredits'),
      coin: json.value<String>('coin'),
      address: json.value<String>('address'),
    );
  }

  final String uuid;
  final String price;
  final String maxVolume;
  final String minVolume;
  final String pubkey;
  final int age;
  final int zcredits;
  final String coin;
  final String address;

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'price': price,
    'max_volume': maxVolume,
    'min_volume': minVolume,
    'pubkey': pubkey,
    'age': age,
    'zcredits': zcredits,
    'coin': coin,
    'address': address,
  };
}

/// Order type enum
enum OrderType {
  buy,
  sell;

  String toJson() => name;
}

/// Orderbook pair
class OrderbookPair {
  OrderbookPair({
    required this.base,
    required this.rel,
  });

  final String base;
  final String rel;

  Map<String, dynamic> toJson() => {
    'base': base,
    'rel': rel,
  };
}

/// Cancel orders type
class CancelOrdersType {
  CancelOrdersType.all() : coin = null, _type = 'all';
  CancelOrdersType.coin(this.coin) : _type = 'coin';

  final String? coin;
  final String _type;

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