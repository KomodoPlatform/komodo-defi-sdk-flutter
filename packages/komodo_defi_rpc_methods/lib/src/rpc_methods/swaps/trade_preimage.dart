import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Request for trade_preimage which calculates details of a potential trade
class TradePreimageRequest
    extends BaseRequest<TradePreimageResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  TradePreimageRequest({
    required this.base,
    required this.rel,
    required this.swapMethod,
    required this.price,
    this.volume,
    this.max,
    super.rpcPass,
  }) : super(method: 'trade_preimage', mmrpc: '2.0');

  final String base;
  final String rel;
  final String swapMethod;
  final Decimal price;
  final Decimal? volume;
  final bool? max;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {
      'base': base,
      'rel': rel,
      'swap_method': swapMethod,
      'price': price.toJsonRationalValue(),
      if (volume != null) 'volume': volume!.toJsonRationalValue(),
      if (max != null) 'max': max,
    },
  };

  // Used by BaseRequest to parse the response. Equivalent to fromJson
  @override
  TradePreimageResponse parse(Map<String, dynamic> json) =>
      TradePreimageResponse.fromJson(json);
}

/// Response for trade_preimage
class TradePreimageResponse extends BaseResponse {
  TradePreimageResponse({required super.mmrpc, required this.result});

  factory TradePreimageResponse.fromJson(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');
    return TradePreimageResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: TradePreimageResult.fromJson(result),
    );
  }

  final TradePreimageResult result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result.toJson()};
}

/// Result data for trade_preimage
class TradePreimageResult {
  TradePreimageResult({
    required this.baseCoinFee,
    required this.relCoinFee,
    required this.totalFees,
    this.volume,
    this.volumeRat,
    this.volumeFraction,
    this.takerFee,
    this.feeToSendTakerFee,
  });

  factory TradePreimageResult.fromJson(Map<String, dynamic> json) {
    return TradePreimageResult(
      baseCoinFee: ExtendedFeeInfo.fromJson(
        json.value<JsonMap>('base_coin_fee'),
      ),
      relCoinFee: ExtendedFeeInfo.fromJson(json.value<JsonMap>('rel_coin_fee')),
      totalFees:
          json
              .value<List<dynamic>>('total_fees')
              .map((e) => TotalFeeInfo.fromJson(e as JsonMap))
              .toList(),
      volume: json.valueOrNull<String>('volume'),
      volumeRat:
          json.valueOrNull<List<dynamic>>('volume_rat') != null
              ? RationalValue.fromJson(
                json.value<List<dynamic>>('volume_rat'),
              ).toDecimal()
              : null,
      volumeFraction:
          json.valueOrNull<JsonMap>('volume_fraction') != null
              ? FractionalValue.fromJson(
                json.value<JsonMap>('volume_fraction'),
              ).toDecimal()
              : null,
      takerFee:
          json.containsKey('taker_fee')
              ? ExtendedFeeInfo.fromJson(json.value<JsonMap>('taker_fee'))
              : null,
      feeToSendTakerFee:
          json.containsKey('fee_to_send_taker_fee')
              ? ExtendedFeeInfo.fromJson(
                json.value<JsonMap>('fee_to_send_taker_fee'),
              )
              : null,
    );
  }

  final ExtendedFeeInfo baseCoinFee;
  final ExtendedFeeInfo relCoinFee;
  final List<TotalFeeInfo> totalFees;
  final String? volume;
  final Decimal? volumeRat;
  final Decimal? volumeFraction;
  final ExtendedFeeInfo? takerFee;
  final ExtendedFeeInfo? feeToSendTakerFee;

  Map<String, dynamic> toJson() => {
    'base_coin_fee': baseCoinFee.toJson(),
    'rel_coin_fee': relCoinFee.toJson(),
    'total_fees': totalFees.map((e) => e.toJson()).toList(),
    if (volume != null) 'volume': volume,
    if (volumeRat != null) 'volume_rat': volumeRat!.toJsonRationalValue(),
    if (volumeFraction != null)
      'volume_fraction': volumeFraction!.toJsonFractionalValue(),
    if (takerFee != null) 'taker_fee': takerFee!.toJson(),
    if (feeToSendTakerFee != null)
      'fee_to_send_taker_fee': feeToSendTakerFee!.toJson(),
  };
}

/// Extended fee information
class ExtendedFeeInfo {
  ExtendedFeeInfo({
    required this.coin,
    required this.amount,
    required this.amountFraction,
    required this.amountRat,
    required this.paidFromTradingVol,
  });

  factory ExtendedFeeInfo.fromJson(Map<String, dynamic> json) {
    return ExtendedFeeInfo(
      coin: json.value<String>('coin'),
      amount: json.value<String>('amount'),
      amountFraction:
          FractionalValue.fromJson(
            json.value<JsonMap>('amount_fraction'),
          ).toDecimal(),
      amountRat:
          RationalValue.fromJson(
            json.value<List<dynamic>>('amount_rat'),
          ).toDecimal(),
      paidFromTradingVol: json.value<bool>('paid_from_trading_vol'),
    );
  }

  final String coin;
  final String amount;
  final Decimal amountFraction;
  final Decimal amountRat;
  final bool paidFromTradingVol;

  Map<String, dynamic> toJson() => {
    'coin': coin,
    'amount': amount,
    'amount_fraction': amountFraction.toJsonFractionalValue(),
    'amount_rat': amountRat.toJsonRationalValue(),
    'paid_from_trading_vol': paidFromTradingVol,
  };
}

/// Total fee information
class TotalFeeInfo {
  TotalFeeInfo({
    required this.coin,
    required this.amount,
    required this.amountFraction,
    required this.amountRat,
    required this.requiredBalance,
    required this.requiredBalanceFraction,
    required this.requiredBalanceRat,
  });

  factory TotalFeeInfo.fromJson(Map<String, dynamic> json) {
    return TotalFeeInfo(
      coin: json.value<String>('coin'),
      amount: json.value<String>('amount'),
      amountFraction:
          FractionalValue.fromJson(
            json.value<JsonMap>('amount_fraction'),
          ).toDecimal(),
      amountRat:
          RationalValue.fromJson(
            json.value<List<dynamic>>('amount_rat'),
          ).toDecimal(),
      requiredBalance: json.value<String>('required_balance'),
      requiredBalanceFraction:
          FractionalValue.fromJson(
            json.value<JsonMap>('required_balance_fraction'),
          ).toDecimal(),
      requiredBalanceRat:
          RationalValue.fromJson(
            json.value<List<dynamic>>('required_balance_rat'),
          ).toDecimal(),
    );
  }

  final String coin;
  final String amount;
  final Decimal amountFraction;
  final Decimal amountRat;
  final String requiredBalance;
  final Decimal requiredBalanceFraction;
  final Decimal requiredBalanceRat;

  Map<String, dynamic> toJson() => {
    'coin': coin,
    'amount': amount,
    'amount_fraction': amountFraction.toJsonFractionalValue(),
    'amount_rat': amountRat.toJsonRationalValue(),
    'required_balance': requiredBalance,
    'required_balance_fraction':
        requiredBalanceFraction.toJsonFractionalValue(),
    'required_balance_rat': requiredBalanceRat.toJsonRationalValue(),
  };
}
