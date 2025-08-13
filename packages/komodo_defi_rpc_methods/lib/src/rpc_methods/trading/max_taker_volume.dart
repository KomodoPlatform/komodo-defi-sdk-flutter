import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get maximum taker volume for a coin
class MaxTakerVolumeRequest
    extends BaseRequest<MaxTakerVolumeResponse, GeneralErrorResponse> {
  MaxTakerVolumeRequest({
    required String rpcPass,
    required this.coin,
  }) : super(
         method: 'max_taker_vol',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String coin;

  @override
  Map<String, dynamic> toJson() =>
      super.toJson().deepMerge({'params': {'coin': coin}});

  @override
  MaxTakerVolumeResponse parse(Map<String, dynamic> json) =>
      MaxTakerVolumeResponse.parse(json);
}

/// Response with maximum taker volume
class MaxTakerVolumeResponse extends BaseResponse {
  MaxTakerVolumeResponse({
    required super.mmrpc,
    required this.amount,
  });

  factory MaxTakerVolumeResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return MaxTakerVolumeResponse(
      mmrpc: json.value<String>('mmrpc'),
      amount: result.value<String>('amount'),
    );
  }

  final String amount;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'amount': amount,
    },
  };
}


