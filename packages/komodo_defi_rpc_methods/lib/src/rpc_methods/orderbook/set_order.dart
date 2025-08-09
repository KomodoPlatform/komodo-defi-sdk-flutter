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
  }) : super(
         method: 'setprice',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String base;
  final String rel;
  final String price;
  final String volume;
  final OrderType? orderType;
  final bool? minVolume;
  final String? baseConfs;
  final String? baseNota;
  final String? relConfs;
  final String? relNota;

  @override
  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{
      'base': base,
      'rel': rel,
      'price': price,
      'volume': volume,
    };

    if (orderType != null) params['order_type'] = orderType!.toJson();
    if (minVolume != null) params['min_volume'] = minVolume.toString();
    if (baseConfs != null) params['base_confs'] = baseConfs;
    if (baseNota != null) params['base_nota'] = baseNota;
    if (relConfs != null) params['rel_confs'] = relConfs;
    if (relNota != null) params['rel_nota'] = relNota;

    return super.toJson().deepMerge({
      'params': params,
    });
  }

  @override
  SetOrderResponse parse(Map<String, dynamic> json) =>
      SetOrderResponse.parse(json);
}

/// Response from creating an order
class SetOrderResponse extends BaseResponse {
  SetOrderResponse({
    required super.mmrpc,
    required this.orderInfo,
  });

  factory SetOrderResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return SetOrderResponse(
      mmrpc: json.value<String>('mmrpc'),
      orderInfo: MyOrderInfo.fromJson(result),
    );
  }

  final MyOrderInfo orderInfo;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': orderInfo.toJson(),
  };
}