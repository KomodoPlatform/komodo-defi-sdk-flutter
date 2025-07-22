import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Simple manager for accessing fee management RPC methods.
class FeeManager {
  FeeManager(this._client);

  final ApiClient _client;

  Future<EthEstimatedFeePerGas> getEthEstimatedFeePerGas(
    String coin, {
    FeeEstimatorType estimatorType = FeeEstimatorType.simple,
  }) async {
    final response = await _client.rpc.feeManagement.getEthEstimatedFeePerGas(
      coin: coin,
      estimatorType: estimatorType,
    );
    return response.result;
  }

  Future<FeePolicy> getSwapTransactionFeePolicy(String coin) async {
    final response = await _client.rpc.feeManagement
        .getSwapTransactionFeePolicy(coin: coin);
    return response.result;
  }

  Future<FeePolicy> setSwapTransactionFeePolicy(
    String coin,
    FeePolicy policy,
  ) async {
    final response = await _client.rpc.feeManagement
        .setSwapTransactionFeePolicy(coin: coin, swapTxFeePolicy: policy);
    return response.result;
  }

  /// Disposes of resources used by the FeeManager.
  ///
  /// This method is intentionally left empty as the FeeManager does not
  /// currently manage any resources that require explicit cleanup.
  Future<void> dispose() {
    // No resources to dispose. Return a future that completes immediately.
    return Future.value();
  }
}
