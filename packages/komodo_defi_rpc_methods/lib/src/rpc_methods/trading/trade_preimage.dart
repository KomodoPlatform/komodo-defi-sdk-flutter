import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to calculate trade preimage (fees, validation)
class TradePreimageRequest
    extends BaseRequest<TradePreimageResponse, GeneralErrorResponse> {
  TradePreimageRequest({
    required String rpcPass,
    required this.base,
    required this.rel,
    required this.swapMethod,
    required this.volume,
    this.price,
  }) : super(
         method: 'trade_preimage',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String base;
  final String rel;
  final SwapMethod swapMethod;
  final String volume;
  final String? price;

  @override
  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{
      'base': base,
      'rel': rel,
      'swap_method':
          swapMethod.name == 'setPrice' ? 'setprice' : swapMethod.name,
      'volume': volume,
    };
    if (price != null) params['price'] = price;

    return super.toJson().deepMerge({'params': params});
  }

  @override
  TradePreimageResponse parse(Map<String, dynamic> json) =>
      TradePreimageResponse.parse(json);
}

/// Response containing trade preimage details
class TradePreimageResponse extends BaseResponse {
  TradePreimageResponse({
    required super.mmrpc,
    required this.totalFee,
    required this.volume,
  });

  factory TradePreimageResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return TradePreimageResponse(
      mmrpc: json.value<String>('mmrpc'),
      totalFee: result.value<String>('total_fee'),
      volume: result.value<String>('volume'),
    );
  }

  final String totalFee;
  final String volume;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'total_fee': totalFee, 'volume': volume},
  };
}
