import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class FeeManagementMethodsNamespace extends BaseRpcMethodNamespace {
  FeeManagementMethodsNamespace(super.client);

  /// Enable fee estimator for a specific coin
  Future<FeeEstimatorEnableResponse> feeEstimatorEnable({
    required String coin,
    required String estimatorType,
    String? rpcPass,
  }) => execute(
    FeeEstimatorEnableRequest(
      rpcPass: rpcPass ?? this.rpcPass ?? '',
      coin: coin,
      estimatorType: estimatorType,
    ),
  );

  /// Get estimated ETH gas fees
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

  /// Get estimated UTXO fees for Bitcoin-like protocols
  Future<GetUtxoEstimatedFeeResponse> getUtxoEstimatedFee({
    required String coin,
    FeeEstimatorType estimatorType = FeeEstimatorType.simple,
    String? rpcPass,
  }) => execute(
    GetUtxoEstimatedFeeRequest(
      rpcPass: rpcPass ?? this.rpcPass ?? '',
      coin: coin,
      estimatorType: estimatorType,
    ),
  );

  /// Get estimated Tendermint/Cosmos fees
  Future<GetTendermintEstimatedFeeResponse> getTendermintEstimatedFee({
    required String coin,
    FeeEstimatorType estimatorType = FeeEstimatorType.simple,
    String? rpcPass,
  }) => execute(
    GetTendermintEstimatedFeeRequest(
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
