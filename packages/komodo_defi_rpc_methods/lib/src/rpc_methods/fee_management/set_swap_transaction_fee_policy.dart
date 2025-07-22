import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class SetSwapTransactionFeePolicyRequest
    extends
        BaseRequest<SetSwapTransactionFeePolicyResponse, GeneralErrorResponse> {
  SetSwapTransactionFeePolicyRequest({
    required super.rpcPass,
    required this.coin,
    required this.swapTxFeePolicy,
  }) : super(method: 'set_swap_transaction_fee_policy', mmrpc: '2.0');

  final String coin;
  final FeePolicy swapTxFeePolicy;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'coin': coin, 'swap_tx_fee_policy': swapTxFeePolicy.toString()},
  };

  @override
  SetSwapTransactionFeePolicyResponse parse(Map<String, dynamic> json) =>
      SetSwapTransactionFeePolicyResponse.parse(json);
}

class SetSwapTransactionFeePolicyResponse extends BaseResponse {
  SetSwapTransactionFeePolicyResponse({
    required super.mmrpc,
    required this.result,
  });

  factory SetSwapTransactionFeePolicyResponse.parse(
    Map<String, dynamic> json,
  ) => SetSwapTransactionFeePolicyResponse(
    mmrpc: json.value<String>('mmrpc'),
    result: FeePolicy.fromString(json.value<String>('result')),
  );

  final FeePolicy result;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': result.toString(),
  };
}
