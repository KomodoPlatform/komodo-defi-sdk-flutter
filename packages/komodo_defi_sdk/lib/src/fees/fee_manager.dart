import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manages cryptocurrency transaction fee operations and policies.
///
/// The [FeeManager] provides functionality for:
/// - Retrieving estimated gas fees for Ethereum-based transactions
/// - Getting and setting fee policies for swap transactions
/// - Managing fee-related configuration for blockchain operations
///
/// This manager abstracts away the complexity of fee estimation and management,
/// providing a simple interface for applications to work with transaction fees
/// across different blockchain protocols.
///
/// Usage example:
/// ```dart
/// final feeManager = FeeManager(apiClient);
///
/// // Get ETH gas fee estimates
/// final gasEstimates = await feeManager.getEthEstimatedFeePerGas('ETH');
/// print('Slow fee: ${gasEstimates.slow.maxFeePerGas} gwei');
/// print('Medium fee: ${gasEstimates.medium.maxFeePerGas} gwei');
/// print('Fast fee: ${gasEstimates.fast.maxFeePerGas} gwei');
///
/// // Get current swap fee policy for a coin
/// final policy = await feeManager.getSwapTransactionFeePolicy('KMD');
/// print('Current fee policy: ${policy.type}');
///
/// // Update fee policy if needed
/// if (policy.type != 'standard') {
///   final newPolicy = FeePolicy(type: 'standard', ...);
///   await feeManager.setSwapTransactionFeePolicy('KMD', newPolicy);
/// }
/// ```
class FeeManager {
  /// Creates a new [FeeManager] instance.
  ///
  /// Requires:
  /// - [_client] - API client for making RPC calls to fee management endpoints
  FeeManager(this._client);

  final ApiClient _client;

  /// Retrieves estimated fee per gas for Ethereum-based transactions.
  ///
  /// This method provides up-to-date gas fee estimates for Ethereum-compatible
  /// chains with different speed options (slow, medium, fast).
  ///
  /// Parameters:
  /// - [coin] - The ticker symbol of the coin (e.g., 'ETH', 'MATIC')
  /// - [estimatorType] - The type of estimator to use (default: simple)
  ///
  /// Returns a [Future<EthEstimatedFeePerGas>] containing gas fee estimates at
  /// different priority levels:
  /// - `slow` - Lower cost but potentially longer confirmation time
  /// - `medium` - Balanced cost and confirmation time
  /// - `fast` - Higher cost for faster confirmation
  ///
  /// Each estimate includes:
  /// - `maxFeePerGas` - Maximum fee per gas unit
  /// - `maxPriorityFeePerGas` - Maximum priority fee per gas unit
  ///
  /// Example:
  /// ```dart
  /// final estimates = await feeManager.getEthEstimatedFeePerGas('ETH');
  ///
  /// // Choose a fee based on desired confirmation speed
  /// final selectedFee = estimates.medium;
  ///
  /// print('Max fee: ${selectedFee.maxFeePerGas} gwei');
  /// print('Max priority fee: ${selectedFee.maxPriorityFeePerGas} gwei');
  /// ```
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

  /// Retrieves the current fee policy for swap transactions of a specific coin.
  ///
  /// Fee policies determine how transaction fees are calculated and applied
  /// for swap operations involving the specified coin.
  ///
  /// Parameters:
  /// - [coin] - The ticker symbol of the coin (e.g., 'KMD', 'BTC')
  ///
  /// Returns a [Future<FeePolicy>] containing the current fee policy
  /// configuration.
  ///
  /// Example:
  /// ```dart
  /// final policy = await feeManager.getSwapTransactionFeePolicy('KMD');
  /// 
  /// if (policy.type == 'utxo_per_kbyte') {
  ///   print('Fee rate: ${policy.feePerKbyte} sat/KB');
  /// }
  /// ```
  Future<FeePolicy> getSwapTransactionFeePolicy(String coin) async {
    final response = await _client.rpc.feeManagement
        .getSwapTransactionFeePolicy(coin: coin);
    return response.result;
  }

  /// Sets a new fee policy for swap transactions of a specific coin.
  ///
  /// This method allows customizing how transaction fees are calculated and
  /// applied for swap operations involving the specified coin.
  ///
  /// Parameters:
  /// - [coin] - The ticker symbol of the coin (e.g., 'KMD', 'BTC')
  /// - [policy] - The new fee policy to apply
  ///
  /// Returns a [Future<FeePolicy>] containing the updated fee policy
  /// configuration.
  ///
  /// Example:
  /// ```dart
  /// // Create a new UTXO fee policy with a specific rate
  /// final newPolicy = FeePolicy(
  ///   type: 'utxo_per_kbyte',
  ///   feePerKbyte: 1000, // 1000 satoshis per kilobyte
  /// );
  ///
  /// final updatedPolicy = await feeManager.setSwapTransactionFeePolicy(
  ///   'BTC',
  ///   newPolicy,
  /// );
  ///
  /// print('Updated fee policy: ${updatedPolicy.type}');
  /// ```
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
  /// This method is called when the FeeManager is no longer needed.
  /// Currently, it doesn't perform any cleanup operations as the FeeManager
  /// doesn't manage any resources that require explicit disposal.
  ///
  /// Example:
  /// ```dart
  /// // When done with the fee manager
  /// await feeManager.dispose();
  /// ```
  Future<void> dispose() {
    // No resources to dispose. Return a future that completes immediately.
    return Future.value();
  }
}
