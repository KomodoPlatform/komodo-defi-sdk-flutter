import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class SiaWithdrawRequest
    extends BaseRequest<SiaWithdrawResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  SiaWithdrawRequest({
    required super.rpcPass,
    required this.coin,
    required this.to,
    required this.amount,
    this.fee,
    this.max = false,
  }) : super(method: 'withdraw', mmrpc: RpcVersion.v2_0);

  final String coin;
  final String to;
  final Decimal? amount;
  final FeeInfo? fee;
  final bool max;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {
      'coin': coin,
      'to': to,
      if (max) 'max': max,
      if (!max && amount != null) 'amount': amount?.toString(),
      if (fee != null) 'fee': fee!.toJson(),
    },
  };

  @override
  SiaWithdrawResponse parse(Map<String, dynamic> json) =>
      SiaWithdrawResponse.parse(json);
}

class SiaWithdrawResponse extends BaseResponse {
  SiaWithdrawResponse({
    required super.mmrpc,
    required this.txJson,
    required this.txHash,
    required this.from,
    required this.to,
    required this.totalAmount,
    required this.spentByMe,
    required this.receivedByMe,
    required this.myBalanceChange,
    required this.feeDetails,
  });

  factory SiaWithdrawResponse.parse(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');
    return SiaWithdrawResponse(
      mmrpc: json.value<String>('mmrpc'),
      txJson: result.value<JsonMap>('tx_json'),
      txHash: result.value<String>('tx_hash'),
      from: List<String>.from(result.value('from')),
      to: List<String>.from(result.value('to')),
      totalAmount: result.value<String>('total_amount'),
      spentByMe: result.value<String>('spent_by_me'),
      receivedByMe: result.value<String>('received_by_me'),
      myBalanceChange: result.value<String>('my_balance_change'),
      feeDetails: FeeInfo.fromJson(result.value('fee_details')),
    );
  }

  final JsonMap txJson; // Note: tx_json instead of tx_hex
  final String txHash;
  final List<String> from;
  final List<String> to;
  final String totalAmount;
  final String spentByMe;
  final String receivedByMe;
  final String myBalanceChange;
  final FeeInfo? feeDetails;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'tx_json': txJson,
      'tx_hash': txHash,
      'from': from,
      'to': to,
      'total_amount': totalAmount,
      'spent_by_me': spentByMe,
      'received_by_me': receivedByMe,
      'my_balance_change': myBalanceChange,
      if (feeDetails != null) 'fee_details': feeDetails!.toJson(),
    },
  };
}
