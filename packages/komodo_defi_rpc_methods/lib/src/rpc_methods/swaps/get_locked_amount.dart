import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Request to get the amount of a coin which is currently locked by a swap
/// in progress
class GetLockedAmountRequest
    extends BaseRequest<GetLockedAmountResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  GetLockedAmountRequest({required String rpcPass, required this.coin})
    : super(method: 'get_locked_amount', rpcPass: rpcPass, mmrpc: '2.0');

  /// The ticker of the coin you want to query
  final String coin;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'params': {'coin': coin},
    });
  }

  @override
  GetLockedAmountResponse parse(Map<String, dynamic> json) =>
      GetLockedAmountResponse.parse(json);
}

class GetLockedAmountResponse extends BaseResponse {
  GetLockedAmountResponse({
    required super.mmrpc,
    required this.coin,
    required this.lockedAmount,
    super.id,
  });

  factory GetLockedAmountResponse.parse(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');

    return GetLockedAmountResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      id: json.valueOrNull<String>('id'),
      coin: result.value<String>('coin'),
      lockedAmount: NumericFormatsValue.fromJson(
        result.value<JsonMap>('locked_amount'),
      ),
    );
  }

  /// The ticker of the coin you queried
  final String coin;

  /// An object containing the locked amount in decimal, fraction and rational
  /// formats
  final NumericFormatsValue lockedAmount;

  @override
  Map<String, dynamic> toJson() {
    return {'coin': coin, 'locked_amount': lockedAmount.toJson()};
  }
}
