import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:rational/rational.dart';
import '../../common_structures/primitive/mm2_rational.dart';
import '../../common_structures/primitive/fraction.dart';

/// Request to get the maximum taker volume for a coin/pair.
///
/// Calculates how much of `coin` can be traded as a taker when trading against
/// the optional `trade_with` counter coin, taking balance, fees and dust limits
/// into account.
class MaxTakerVolumeRequest
    extends BaseRequest<MaxTakerVolumeResponse, GeneralErrorResponse> {
  MaxTakerVolumeRequest({
    required String rpcPass,
    required this.coin,
    this.tradeWith,
  }) : super(method: 'max_taker_vol', rpcPass: rpcPass, mmrpc: RpcVersion.v2_0);

  /// Coin ticker to compute max taker volume for
  final String coin;

  /// Optional counter coin to trade against (`trade_with` in the API).
  ///
  /// This tells the API which other coin you intend to trade `coin` with, so
  /// the maximum volume is computed for that specific pair. If omitted, it
  /// defaults to the same value as `coin` (API default).
  final String? tradeWith;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {'coin': coin, if (tradeWith != null) 'trade_with': tradeWith},
  });

  @override
  MaxTakerVolumeResponse parse(Map<String, dynamic> json) =>
      MaxTakerVolumeResponse.parse(json);
}

/// Response with maximum taker volume for the requested coin/pair.
class MaxTakerVolumeResponse extends BaseResponse {
  MaxTakerVolumeResponse({
    required super.mmrpc,
    required this.amount,
    this.amountFraction,
    this.amountRat,
  });

  factory MaxTakerVolumeResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return MaxTakerVolumeResponse(
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

  /// Maximum tradable amount of `coin` as a string numeric, denominated in
  /// `coin` units, computed for the (`coin`, `trade_with`) pair.
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
