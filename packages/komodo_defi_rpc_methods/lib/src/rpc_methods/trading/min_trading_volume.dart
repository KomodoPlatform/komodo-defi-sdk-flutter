import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:rational/rational.dart';
import '../../common_structures/primitive/mm2_rational.dart';
import '../../common_structures/primitive/fraction.dart';

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
  MinTradingVolumeResponse({
    required super.mmrpc,
    required this.amount,
    this.amountFraction,
    this.amountRat,
  });

  factory MinTradingVolumeResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return MinTradingVolumeResponse(
      mmrpc: json.value<String>('mmrpc'),
      amount: result.value<String>('amount'),
      amountFraction:
          result.valueOrNull<JsonMap>('amount_fraction') != null
              ? Fraction.fromJson(result.value<JsonMap>('amount_fraction'))
              : null,
      amountRat:
          result.valueOrNull<List<dynamic>>('amount_rat') != null
              ? rationalFromMm2(result.value<List<dynamic>>('amount_rat'))
              : null,
    );
  }

  /// Minimum tradeable amount as a string numeric (coin units)
  final String amount;

  /// Optional fractional representation of the amount
  final Fraction? amountFraction;

  /// Optional rational representation of the amount
  final Rational? amountRat;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'amount': amount,
      if (amountFraction != null) 'amount_fraction': amountFraction!.toJson(),
      if (amountRat != null) 'amount_rat': rationalToMm2(amountRat!),
    },
  };
}
