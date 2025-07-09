import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Request to get the maximum taker volume available for a coin.
///
/// This value can be used directly when placing a `sell` order or divided by
/// the trade price for a `buy` order. It accounts for DEX fees and blockchain
/// miner fees so that the returned volume is immediately usable.
class MaxTakerVolRequest
    extends BaseRequest<MaxTakerVolResponse, GeneralErrorResponse> {
  MaxTakerVolRequest({
    required String rpcPass,
    required this.coin,
    this.tradeWith,
  }) : super(method: 'max_taker_vol', rpcPass: rpcPass, mmrpc: null);

  /// The ticker of the coin you want to query
  final String coin;

  /// The coin to trade with. Defaults to [coin] if not provided
  final String? tradeWith;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'params': {'coin': coin, if (tradeWith != null) 'trade_with': tradeWith},
    });
  }

  @override
  MaxTakerVolResponse parse(Map<String, dynamic> json) =>
      MaxTakerVolResponse.parse(json);
}

class MaxTakerVolResponse extends BaseResponse {
  MaxTakerVolResponse({
    required super.mmrpc,
    required this.result,
    this.coin,
    super.id,
  });

  factory MaxTakerVolResponse.parse(Map<String, dynamic> json) {
    return MaxTakerVolResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      id: json.valueOrNull<String>('id'),
      coin: json.valueOrNull<String>('coin'),
      result: FractionalValue.fromJson(json.value<JsonMap>('result')),
    );
  }

  /// The coin queried, if provided by the API
  final String? coin;

  /// The maximum taker volume available represented as a [FractionalValue]
  final FractionalValue result;

  @override
  Map<String, dynamic> toJson() {
    return {'result': result.toJson(), if (coin != null) 'coin': coin};
  }
}
