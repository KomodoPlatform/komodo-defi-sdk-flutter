import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Request to get the maximum volume of a coin which can be used to create a
/// maker order
class MaxMakerVolRequest
    extends BaseRequest<MaxMakerVolResponse, GeneralErrorResponse> {
  MaxMakerVolRequest({required String rpcPass, required this.coin})
    : super(method: 'max_maker_vol', rpcPass: rpcPass, mmrpc: '2.0');

  /// The ticker of the coin you want to query
  final String coin;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'params': {'coin': coin},
    });
  }

  @override
  MaxMakerVolResponse parse(Map<String, dynamic> json) =>
      MaxMakerVolResponse.parse(json);
}

class MaxMakerVolResponse extends BaseResponse {
  MaxMakerVolResponse({
    required super.mmrpc,
    required this.coin,
    required this.volume,
    required this.balance,
    required this.lockedBySwaps,
    super.id,
  });

  factory MaxMakerVolResponse.parse(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');

    return MaxMakerVolResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      id: json.valueOrNull<String>('id'),
      coin: result.value<String>('coin'),
      volume: NumericFormatsValue.fromJson(result.value<JsonMap>('volume')),
      balance: NumericFormatsValue.fromJson(result.value<JsonMap>('balance')),
      lockedBySwaps: NumericFormatsValue.fromJson(
        result.value<JsonMap>('locked_by_swaps'),
      ),
    );
  }

  /// The ticker of the coin you queried
  final String coin;

  /// A standard NumericFormatsValue object representing the tradable maker
  /// volume
  final NumericFormatsValue volume;

  /// A standard NumericFormatsValue object representing the tradable taker
  /// balance
  final NumericFormatsValue balance;

  /// A standard NumericFormatsValue object representing the volume of a coin's
  /// balance which is locked by swaps in progress
  final NumericFormatsValue lockedBySwaps;

  @override
  Map<String, dynamic> toJson() {
    return {
      'coin': coin,
      'volume': volume.toJson(),
      'balance': balance.toJson(),
      'locked_by_swaps': lockedBySwaps.toJson(),
    };
  }
}
