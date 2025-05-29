import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request for trade_preimage which calculates details of a potential trade
class TradePreimageRequest
    extends BaseRequest<TradePreimageResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  TradePreimageRequest({
    required this.base,
    required this.rel,
    required this.price,
    required this.volume,
    this.maxVolume,
    this.dryRun,
    super.rpcPass,
  }) : super(method: 'trade_preimage', mmrpc: '2.0');

  final String base;
  final String rel;
  final dynamic price;
  final dynamic volume;
  final bool? maxVolume;
  final bool? dryRun;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'userpass': rpcPass,
        'params': {
          'base': base,
          'rel': rel,
          'price': price,
          'volume': volume,
          if (maxVolume != null) 'max_volume': maxVolume,
          if (dryRun != null) 'dry_run': dryRun,
        },
      };

  @override
  TradePreimageResponse parse(Map<String, dynamic> json) =>
      TradePreimageResponse.fromJson(json);
}

/// Response for trade_preimage
class TradePreimageResponse extends BaseResponse {
  TradePreimageResponse({
    required super.mmrpc,
    required this.result,
  });

  factory TradePreimageResponse.fromJson(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');
    return TradePreimageResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: TradePreimageResult.fromJson(result),
    );
  }

  final TradePreimageResult result;

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': result.toJson(),
      };
}

/// Result data for trade_preimage
class TradePreimageResult {
  TradePreimageResult({
    required this.baseTransactionFee,
    required this.baseTransactionFeeDetails,
    required this.relTransactionFee,
    required this.relTransactionFeeDetails,
    required this.totalFees,
    required this.totalFeesDetails,
    this.tradeFee,
    this.tradeFeeCoin,
    this.tradeFeeDetails,
    required this.volumeBaseToRel,
    required this.volumeBaseToRelRat,
    required this.volumeRelToBase,
    required this.volumeRelToBaseRat,
  });

  factory TradePreimageResult.fromJson(Map<String, dynamic> json) {
    return TradePreimageResult(
      baseTransactionFee: json.value<String>('base_transaction_fee'),
      baseTransactionFeeDetails: TransactionFeeDetails.fromJson(
        json.value<JsonMap>('base_transaction_fee_details'),
      ),
      relTransactionFee: json.value<String>('rel_transaction_fee'),
      relTransactionFeeDetails: TransactionFeeDetails.fromJson(
        json.value<JsonMap>('rel_transaction_fee_details'),
      ),
      totalFees: json.value<JsonMap>('total_fees'),
      totalFeesDetails: json.value<JsonMap>('total_fees_details'),
      tradeFee: json.valueOrNull<String>('trade_fee'),
      tradeFeeCoin: json.valueOrNull<String>('trade_fee_coin'),
      tradeFeeDetails: json.containsKey('trade_fee_details')
          ? json.value<JsonMap>('trade_fee_details')
          : null,
      volumeBaseToRel: json.value<String>('volume_base_to_rel'),
      volumeBaseToRelRat: json.value<dynamic>('volume_base_to_rel_rat'),
      volumeRelToBase: json.value<String>('volume_rel_to_base'),
      volumeRelToBaseRat: json.value<dynamic>('volume_rel_to_base_rat'),
    );
  }

  final String baseTransactionFee;
  final TransactionFeeDetails baseTransactionFeeDetails;
  final String relTransactionFee;
  final TransactionFeeDetails relTransactionFeeDetails;
  final Map<String, dynamic> totalFees;
  final Map<String, dynamic> totalFeesDetails;
  final String? tradeFee;
  final String? tradeFeeCoin;
  final Map<String, dynamic>? tradeFeeDetails;
  final String volumeBaseToRel;
  final dynamic volumeBaseToRelRat;
  final String volumeRelToBase;
  final dynamic volumeRelToBaseRat;

  Map<String, dynamic> toJson() => {
        'base_transaction_fee': baseTransactionFee,
        'base_transaction_fee_details': baseTransactionFeeDetails.toJson(),
        'rel_transaction_fee': relTransactionFee,
        'rel_transaction_fee_details': relTransactionFeeDetails.toJson(),
        'total_fees': totalFees,
        'total_fees_details': totalFeesDetails,
        if (tradeFee != null) 'trade_fee': tradeFee,
        if (tradeFeeCoin != null) 'trade_fee_coin': tradeFeeCoin,
        if (tradeFeeDetails != null) 'trade_fee_details': tradeFeeDetails,
        'volume_base_to_rel': volumeBaseToRel,
        'volume_base_to_rel_rat': volumeBaseToRelRat,
        'volume_rel_to_base': volumeRelToBase,
        'volume_rel_to_base_rat': volumeRelToBaseRat,
      };
}

/// Transaction fee details
class TransactionFeeDetails {
  TransactionFeeDetails({
    required this.type,
    required this.coin,
    required this.amount,
    this.amountFraction,
    this.totalAmount,
    this.gas,
    this.gasPrice,
  });

  factory TransactionFeeDetails.fromJson(Map<String, dynamic> json) {
    return TransactionFeeDetails(
      type: json.value<String>('type'),
      coin: json.value<String>('coin'),
      amount: json.value<String>('amount'),
      amountFraction: json.valueOrNull<dynamic>('amount_fraction'),
      totalAmount: json.valueOrNull<String>('total_amount'),
      gas: json.valueOrNull<int>('gas'),
      gasPrice: json.valueOrNull<String>('gas_price'),
    );
  }

  final String type;
  final String coin;
  final String amount;
  final dynamic amountFraction;
  final String? totalAmount;
  final int? gas;
  final String? gasPrice;

  Map<String, dynamic> toJson() => {
        'type': type,
        'coin': coin,
        'amount': amount,
        if (amountFraction != null) 'amount_fraction': amountFraction,
        if (totalAmount != null) 'total_amount': totalAmount,
        if (gas != null) 'gas': gas,
        if (gasPrice != null) 'gas_price': gasPrice,
      };
}
