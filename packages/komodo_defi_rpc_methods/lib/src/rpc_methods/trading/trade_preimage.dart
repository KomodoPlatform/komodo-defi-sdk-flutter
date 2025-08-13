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
    this.volume,
    this.max,
    this.price,
  }) : super(
         method: 'trade_preimage',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String base;
  final String rel;
  final SwapMethod swapMethod;
  final String? volume;
  final bool? max;
  final String? price;

  @override
  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{
      'base': base,
      'rel': rel,
      'swap_method':
          swapMethod == SwapMethod.setPrice ? 'setprice' : swapMethod.name,
    };
    if (volume != null) params['volume'] = volume;
    if (max != null) params['max'] = max;
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
    this.baseCoinFee,
    this.relCoinFee,
    this.takerFee,
    this.feeToSendTakerFee,
    required this.totalFees,
  });

  factory TradePreimageResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return TradePreimageResponse(
      mmrpc: json.value<String>('mmrpc'),
      baseCoinFee:
          result.containsKey('base_coin_fee')
              ? PreimageCoinFee.fromJson(result.value<JsonMap>('base_coin_fee'))
              : null,
      relCoinFee:
          result.containsKey('rel_coin_fee')
              ? PreimageCoinFee.fromJson(result.value<JsonMap>('rel_coin_fee'))
              : null,
      takerFee:
          result.containsKey('taker_fee')
              ? PreimageCoinFee.fromJson(result.value<JsonMap>('taker_fee'))
              : null,
      feeToSendTakerFee:
          result.containsKey('fee_to_send_taker_fee')
              ? PreimageCoinFee.fromJson(
                result.value<JsonMap>('fee_to_send_taker_fee'),
              )
              : null,
      totalFees:
          (result.valueOrNull<List<dynamic>>('total_fees') ?? [])
              .map((e) => PreimageTotalFee.fromJson(e as JsonMap))
              .toList(),
    );
  }

  final PreimageCoinFee? baseCoinFee;
  final PreimageCoinFee? relCoinFee;
  final PreimageCoinFee? takerFee;
  final PreimageCoinFee? feeToSendTakerFee;
  final List<PreimageTotalFee> totalFees;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      if (baseCoinFee != null) 'base_coin_fee': baseCoinFee!.toJson(),
      if (relCoinFee != null) 'rel_coin_fee': relCoinFee!.toJson(),
      if (takerFee != null) 'taker_fee': takerFee!.toJson(),
      if (feeToSendTakerFee != null)
        'fee_to_send_taker_fee': feeToSendTakerFee!.toJson(),
      'total_fees': totalFees.map((e) => e.toJson()).toList(),
    },
  };
}

class PreimageCoinFee {
  PreimageCoinFee({
    required this.coin,
    required this.amount,
    required this.amountFraction,
    required this.amountRat,
    required this.paidFromTradingVol,
  });

  factory PreimageCoinFee.fromJson(JsonMap json) {
    return PreimageCoinFee(
      coin: json.value<String>('coin'),
      amount: json.value<String>('amount'),
      amountFraction: PreimageFraction.fromJson(
        json.value<JsonMap>('amount_fraction'),
      ),
      amountRat: json.value<dynamic>('amount_rat'),
      paidFromTradingVol: json.value<bool>('paid_from_trading_vol'),
    );
  }

  final String coin;
  final String amount;
  final PreimageFraction amountFraction;
  final dynamic amountRat;
  final bool paidFromTradingVol;

  Map<String, dynamic> toJson() => {
    'coin': coin,
    'amount': amount,
    'amount_fraction': amountFraction.toJson(),
    'amount_rat': amountRat,
    'paid_from_trading_vol': paidFromTradingVol,
  };
}

class PreimageTotalFee {
  PreimageTotalFee({
    required this.coin,
    required this.amount,
    required this.amountFraction,
    required this.amountRat,
    required this.requiredBalance,
    required this.requiredBalanceFraction,
    required this.requiredBalanceRat,
  });

  factory PreimageTotalFee.fromJson(JsonMap json) {
    return PreimageTotalFee(
      coin: json.value<String>('coin'),
      amount: json.value<String>('amount'),
      amountFraction: PreimageFraction.fromJson(
        json.value<JsonMap>('amount_fraction'),
      ),
      amountRat: json.value<dynamic>('amount_rat'),
      requiredBalance: json.value<String>('required_balance'),
      requiredBalanceFraction: PreimageFraction.fromJson(
        json.value<JsonMap>('required_balance_fraction'),
      ),
      requiredBalanceRat: json.value<dynamic>('required_balance_rat'),
    );
  }

  final String coin;
  final String amount;
  final PreimageFraction amountFraction;
  final dynamic amountRat;
  final String requiredBalance;
  final PreimageFraction requiredBalanceFraction;
  final dynamic requiredBalanceRat;

  Map<String, dynamic> toJson() => {
    'coin': coin,
    'amount': amount,
    'amount_fraction': amountFraction.toJson(),
    'amount_rat': amountRat,
    'required_balance': requiredBalance,
    'required_balance_fraction': requiredBalanceFraction.toJson(),
    'required_balance_rat': requiredBalanceRat,
  };
}

class PreimageFraction {
  PreimageFraction({required this.numer, required this.denom});

  factory PreimageFraction.fromJson(JsonMap json) {
    return PreimageFraction(
      numer: json.value<String>('numer'),
      denom: json.value<String>('denom'),
    );
  }

  final String numer;
  final String denom;

  Map<String, dynamic> toJson() => {'numer': numer, 'denom': denom};
}
