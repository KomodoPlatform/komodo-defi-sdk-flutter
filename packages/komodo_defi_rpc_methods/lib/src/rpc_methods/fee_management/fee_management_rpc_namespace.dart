import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class FeeManagementMethodsNamespace extends BaseRpcMethodNamespace {
  FeeManagementMethodsNamespace(super.client);

  Future<GetEthEstimatedFeePerGasResponse> getEthEstimatedFeePerGas({
    required String coin,
    required FeeEstimatorType estimatorType,
    String? rpcPass,
  }) => execute(
    GetEthEstimatedFeePerGasRequest(
      rpcPass: rpcPass ?? this.rpcPass ?? '',
      coin: coin,
      estimatorType: estimatorType,
    ),
  );

  Future<GetSwapTransactionFeePolicyResponse> getSwapTransactionFeePolicy({
    required String coin,
    String? rpcPass,
  }) => execute(
    GetSwapTransactionFeePolicyRequest(
      rpcPass: rpcPass ?? this.rpcPass ?? '',
      coin: coin,
    ),
  );

  Future<SetSwapTransactionFeePolicyResponse> setSwapTransactionFeePolicy({
    required String coin,
    required FeePolicy swapTxFeePolicy,
    String? rpcPass,
  }) => execute(
    SetSwapTransactionFeePolicyRequest(
      rpcPass: rpcPass ?? this.rpcPass ?? '',
      coin: coin,
      swapTxFeePolicy: swapTxFeePolicy,
    ),
  );
}
