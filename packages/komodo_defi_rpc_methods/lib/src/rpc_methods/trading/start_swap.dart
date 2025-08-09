import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to start a new swap
class StartSwapRequest
    extends BaseRequest<StartSwapResponse, GeneralErrorResponse> {
  StartSwapRequest({
    required String rpcPass,
    required this.swapRequest,
  }) : super(
         method: 'start_swap',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final SwapRequest swapRequest;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'params': swapRequest.toJson(),
    });
  }

  @override
  StartSwapResponse parse(Map<String, dynamic> json) =>
      StartSwapResponse.parse(json);
}

/// Swap request parameters
class SwapRequest {
  SwapRequest({
    required this.base,
    required this.rel,
    required this.baseCoinAmount,
    required this.relCoinAmount,
    required this.method,
    this.senderPubkey,
    this.destPubkey,
  });

  final String base;
  final String rel;
  final String baseCoinAmount;
  final String relCoinAmount;
  final SwapMethod method;
  final String? senderPubkey;
  final String? destPubkey;

  Map<String, dynamic> toJson() => {
    'base': base,
    'rel': rel,
    'base_coin_amount': baseCoinAmount,
    'rel_coin_amount': relCoinAmount,
    'method': method.toJson(),
    if (senderPubkey != null) 'sender_pubkey': senderPubkey,
    if (destPubkey != null) 'dest_pubkey': destPubkey,
  };
}

/// Swap method type
enum SwapMethod {
  setPrice,
  buy,
  sell;

  Map<String, dynamic> toJson() {
    switch (this) {
      case SwapMethod.setPrice:
        return {'set_price': {}};
      case SwapMethod.buy:
        return {'buy': {}};
      case SwapMethod.sell:
        return {'sell': {}};
    }
  }
}

/// Response from starting a swap
class StartSwapResponse extends BaseResponse {
  StartSwapResponse({
    required super.mmrpc,
    required this.uuid,
    required this.status,
    required this.swapType,
  });

  factory StartSwapResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return StartSwapResponse(
      mmrpc: json.value<String>('mmrpc'),
      uuid: result.value<String>('uuid'),
      status: result.value<String>('status'),
      swapType: result.value<String>('swap_type'),
    );
  }

  final String uuid;
  final String status;
  final String swapType;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'uuid': uuid,
      'status': status,
      'swap_type': swapType,
    },
  };
}