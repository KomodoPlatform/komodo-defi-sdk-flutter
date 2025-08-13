import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get minimum trading volume for a coin
class MinTradingVolumeRequest
    extends BaseRequest<MinTradingVolumeResponse, GeneralErrorResponse> {
  MinTradingVolumeRequest({required String rpcPass, required this.coin})
    : super(
        method: 'min_trading_vol',
        rpcPass: rpcPass,
        mmrpc: RpcVersion.v2_0,
      );

  /// Coin ticker to query minimum trading volume for
  final String coin;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {'coin': coin},
  });

  @override
  MinTradingVolumeResponse parse(Map<String, dynamic> json) =>
      MinTradingVolumeResponse.parse(json);
}

/// Response with minimum trading volume
class MinTradingVolumeResponse extends BaseResponse {
  MinTradingVolumeResponse({required super.mmrpc, required this.amount});

  factory MinTradingVolumeResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return MinTradingVolumeResponse(
      mmrpc: json.value<String>('mmrpc'),
      amount: result.value<String>('amount'),
    );
  }

  /// Minimum tradeable amount as a string numeric (coin units)
  final String amount;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'amount': amount},
  };
}
