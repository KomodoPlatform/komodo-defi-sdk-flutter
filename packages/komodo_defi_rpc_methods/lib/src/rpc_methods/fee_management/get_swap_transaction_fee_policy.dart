import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class GetSwapTransactionFeePolicyRequest
    extends
        BaseRequest<GetSwapTransactionFeePolicyResponse, GeneralErrorResponse> {
  GetSwapTransactionFeePolicyRequest({
    required super.rpcPass,
    required this.coin,
  }) : super(method: 'get_swap_transaction_fee_policy', mmrpc: '2.0');

  final String coin;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'coin': coin},
  };

  @override
  GetSwapTransactionFeePolicyResponse parse(Map<String, dynamic> json) =>
      GetSwapTransactionFeePolicyResponse.parse(json);
}

class GetSwapTransactionFeePolicyResponse extends BaseResponse {
  GetSwapTransactionFeePolicyResponse({
    required super.mmrpc,
    required this.result,
  });

  factory GetSwapTransactionFeePolicyResponse.parse(
    Map<String, dynamic> json,
  ) => GetSwapTransactionFeePolicyResponse(
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
