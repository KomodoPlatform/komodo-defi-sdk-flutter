import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to create a new order
class SetOrderRequest
    extends BaseRequest<SetOrderResponse, GeneralErrorResponse> {
  SetOrderRequest({
    required String rpcPass,
    required this.base,
    required this.rel,
    required this.price,
    required this.volume,
    this.orderType,
    this.minVolume,
    this.baseConfs,
    this.baseNota,
    this.relConfs,
    this.relNota,
  }) : super(method: 'setprice', rpcPass: rpcPass, mmrpc: RpcVersion.v2_0);

  /// Base coin ticker to trade
  final String base;
  /// Rel/quote coin ticker to trade
  final String rel;
  /// Price per unit of [base] in [rel] (string numeric)
  final String price;
  /// Amount of [base] to trade (string numeric)
  final String volume;
  /// Optional order type specification (maker/taker config)
  final OrderType? orderType;

  /// Minimum acceptable fill amount (string numeric)
  final String? minVolume;

  /// Required confirmations for base coin
  final int? baseConfs;
  /// Required confirmations for rel coin
  final int? relConfs;

  /// Whether notarization is required for base coin
  final bool? baseNota;
  /// Whether notarization is required for rel coin
  final bool? relNota;

  @override
  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{
      'base': base,
      'rel': rel,
      'price': price,
      'volume': volume,
    };

    if (orderType != null) params['order_type'] = orderType!.toJson();
    if (minVolume != null) params['min_volume'] = minVolume;
    if (baseConfs != null) params['base_confs'] = baseConfs;
    if (baseNota != null) params['base_nota'] = baseNota;
    if (relConfs != null) params['rel_confs'] = relConfs;
    if (relNota != null) params['rel_nota'] = relNota;

    return super.toJson().deepMerge({'params': params});
  }

  @override
  SetOrderResponse parse(Map<String, dynamic> json) =>
      SetOrderResponse.parse(json);
}

/// Response from creating an order
class SetOrderResponse extends BaseResponse {
  SetOrderResponse({required super.mmrpc, required this.orderInfo});

  factory SetOrderResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return SetOrderResponse(
      mmrpc: json.value<String>('mmrpc'),
      orderInfo: MyOrderInfo.fromJson(result),
    );
  }

  /// Information about the created order
  final MyOrderInfo orderInfo;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': orderInfo.toJson(),
  };
}
