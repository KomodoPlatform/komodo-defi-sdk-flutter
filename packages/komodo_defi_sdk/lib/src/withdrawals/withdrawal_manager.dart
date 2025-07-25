import 'dart:async';
import 'dart:developer' show log;

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/withdrawals/legacy_withdrawal_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manages cryptocurrency asset withdrawals to external addresses.
///
/// The [WithdrawalManager] provides functionality for:
/// - Creating withdrawal previews to check fees and expected results
/// - Executing withdrawals with progress tracking
/// - Managing and canceling active withdrawal operations
///
/// It supports both task-based API operations for most chains and falls back to
/// legacy implementation for protocols that don't yet support tasks
/// (e.g., Tendermint).
///
/// The manager ensures proper fee estimation when not provided explicitly
/// and handles the full lifecycle of a withdrawal transaction:
/// 1. Asset activation (if needed)
/// 2. Transaction creation
/// 3. Broadcasting to the network
/// 4. Status tracking
///
/// Usage example:
/// ```dart
/// final manager = WithdrawalManager(...);
///
/// // Preview a withdrawal
/// final preview = await manager.previewWithdrawal(
///   WithdrawParameters(
///     asset: 'BTC',
///     toAddress: '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa',
///     amount: Decimal.parse('0.001'),
///   ),
/// );
///
/// // Execute a withdrawal with progress tracking
/// final progressStream = manager.withdraw(
///   WithdrawParameters(
///     asset: 'BTC',
///     toAddress: '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa',
///     amount: Decimal.parse('0.001'),
///   ),
/// );
///
/// await for (final progress in progressStream) {
///   print('Status: ${progress.status}, Message: ${progress.message}');
///   if (progress.withdrawalResult != null) {
///     print('Tx hash: ${progress.withdrawalResult!.txHash}');
///   }
/// }
/// ```
class WithdrawalManager {
  /// Creates a new [WithdrawalManager] instance.
  ///
  /// Requires:
  /// - [_client] - API client for making RPC calls
  /// - [_assetProvider] - Provider for looking up asset information
  /// - [_activationManager] - Manager for activating assets before withdrawal
  /// - [_feeManager] - Manager for fee estimation and management
  WithdrawalManager(
    this._client,
    this._assetProvider,
    this._activationManager,
    this._feeManager,
  );

  /// Default gas limit for basic ETH transactions.
  ///
  /// This is used when no specific gas limit is provided in the withdrawal
  /// parameters. For standard ETH transfers, 21000 gas is the standard amount
  /// required.
  static const int _defaultEthGasLimit = 21000;

  final ApiClient _client;
  final IAssetProvider _assetProvider;
  final ActivationManager _activationManager;
  final FeeManager _feeManager;
  final _activeWithdrawals = <int, StreamController<WithdrawalProgress>>{};

  /// Cancels an active withdrawal task.
  ///
  /// This method attempts to cancel a withdrawal task that is currently in
  /// progress. It's useful when a user wants to abort an ongoing withdrawal
  /// operation.
  ///
  /// Parameters:
  /// - [taskId] - The ID of the task to cancel
  ///
  /// Returns a [Future<bool>] that completes with:
  /// - `true` if the cancellation was successful
  /// - `false` if the cancellation failed
  ///
  /// The method will also clean up any resources associated with the task,
  /// regardless of whether the cancellation was successful.
  ///
  /// Example:
  /// ```dart
  /// final success = await withdrawalManager.cancelWithdrawal(taskId);
  /// if (success) {
  ///   print('Withdrawal canceled successfully');
  /// } else {
  ///   print('Failed to cancel withdrawal');
  /// }
  /// ```
  Future<bool> cancelWithdrawal(int taskId) async {
    try {
      final response = await _client.rpc.withdraw.cancel(taskId);
      return response.result == 'success';
    } catch (e, stackTrace) {
      // Log the error and stack trace for debugging purposes
      log('Error while canceling withdrawal: $e');
      log('Stack trace: $stackTrace');
      return false;
    } finally {
      await _activeWithdrawals[taskId]?.close();
      _activeWithdrawals.remove(taskId);
    }
  }

  /// Cleans up all active withdrawals and releases resources.
  ///
  /// This method should be called when the manager is no longer needed,
  /// typically when the application is shutting down or the user is
  /// logging out. It attempts to cancel all active withdrawal tasks and
  /// releases associated resources.
  ///
  /// Example:
  /// ```dart
  /// // When done with the withdrawal manager
  /// await withdrawalManager.dispose();
  /// ```
  Future<void> dispose() async {
    final withdrawals = _activeWithdrawals.entries.toList();
    _activeWithdrawals.clear();

    for (final withdrawal in withdrawals) {
      await withdrawal.value.close();
      await cancelWithdrawal(withdrawal.key);
    }
  }

  /// Creates a preview of a withdrawal operation without executing it.
  ///
  /// This method allows users to see what would happen if they executed the
  /// withdrawal, including fees, balance changes, and other transaction
  /// details, before committing to it.
  ///
  /// Parameters:
  /// - [parameters] - The withdrawal parameters defining the asset, amount,
  ///   and destination
  ///
  /// Returns a [Future<WithdrawalPreview>] containing the estimated transaction
  /// details.
  ///
  /// Throws:
  /// - [WithdrawalException] if the preview fails, with appropriate error code
  ///
  /// Note: For Tendermint-based assets, this method falls back to the legacy
  /// implementation since task-based API is not yet supported for these assets.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final preview = await withdrawalManager.previewWithdrawal(
  ///     WithdrawParameters(
  ///       asset: 'ETH',
  ///       toAddress: '0x1234...',
  ///       amount: Decimal.parse('0.1'),
  ///     ),
  ///   );
  ///
  ///   print('Estimated fee: ${preview.fee.totalFee}');
  ///   print('Balance change: ${preview.balanceChanges.netChange}');
  /// } catch (e) {
  ///   print('Preview failed: $e');
  /// }
  /// ```
  Future<WithdrawalPreview> previewWithdrawal(
    WithdrawParameters parameters,
  ) async {
    try {
      final asset =
          _assetProvider.findAssetsByConfigId(parameters.asset).single;
      final isTendermintProtocol = asset.protocol is TendermintProtocol;

      // Tendermint assets are not yet supported by the task-based API
      // and require a legacy implementation
      if (isTendermintProtocol) {
        final legacyManager = LegacyWithdrawalManager(_client);
        return await legacyManager.previewWithdrawal(parameters);
      }

      final paramsWithFee = await _ensureFee(parameters, asset);

      // Use task-based approach for non-Tendermint assets
      final stream = (await _client.rpc.withdraw.init(
        paramsWithFee,
      )).watch<WithdrawStatusResponse>(
        getTaskStatus:
            (int taskId) =>
                _client.rpc.withdraw.status(taskId, forgetIfFinished: false),
        isTaskComplete:
            (WithdrawStatusResponse status) => status.status != 'InProgress',
      );

      final lastStatus = await stream.last;

      if (lastStatus.status.toLowerCase() == 'error') {
        throw WithdrawalException(
          lastStatus.details as String,
          _mapErrorToCode(lastStatus.details as String),
        );
      }

      if (lastStatus.details is! WithdrawalPreview) {
        throw WithdrawalException(
          'Invalid preview response format',
          WithdrawalErrorCode.unknownError,
        );
      }

      return lastStatus.details as WithdrawalPreview;
    } catch (e) {
      if (e is WithdrawalException) {
        rethrow;
      }
      throw WithdrawalException(
        'Preview failed: $e',
        WithdrawalErrorCode.unknownError,
      );
    }
  }

  /// Executes a withdrawal operation and provides a progress stream.
  ///
  /// This method performs the full withdrawal process:
  /// 1. Ensures the asset is activated
  /// 2. Creates the transaction
  /// 3. Broadcasts it to the network
  /// 4. Tracks and reports progress
  ///
  /// Parameters:
  /// - [parameters] - The withdrawal parameters defining the asset, amount,
  ///   and destination
  ///
  /// Returns a [Stream<WithdrawalProgress>] that emits progress updates
  /// throughout the operation. The final event will either contain the
  /// completed withdrawal result or an error.
  ///
  /// Error handling:
  /// - Errors are emitted through the stream's error channel
  /// - All errors are wrapped in [WithdrawalException] with appropriate
  ///   error codes
  ///
  /// Protocol handling:
  /// - For Tendermint-based assets, this method uses a legacy implementation
  /// - For other asset types, it uses the task-based API
  ///
  /// Example:
  /// ```dart
  /// final progressStream = withdrawalManager.withdraw(
  ///   WithdrawParameters(
  ///     asset: 'BTC',
  ///     toAddress: '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa',
  ///     amount: Decimal.parse('0.001'),
  ///   ),
  /// );
  ///
  /// try {
  ///   await for (final progress in progressStream) {
  ///     if (progress.status == WithdrawalStatus.complete) {
  ///       final result = progress.withdrawalResult!;
  ///       print('Withdrawal complete! TX: ${result.txHash}');
  ///     } else {
  ///       print('Progress: ${progress.message}');
  ///     }
  ///   }
  /// } catch (e) {
  ///   print('Withdrawal failed: $e');
  /// }
  /// ```
  Stream<WithdrawalProgress> withdraw(WithdrawParameters parameters) async* {
    int? taskId;
    try {
      final asset =
          _assetProvider.findAssetsByConfigId(parameters.asset).single;
      final isTendermintProtocol = asset.protocol is TendermintProtocol;

      // Tendermint assets are not yet supported by the task-based API
      // and require a legacy implementation
      if (isTendermintProtocol) {
        final legacyManager = LegacyWithdrawalManager(_client);
        yield* legacyManager.withdraw(parameters);
        return;
      }

      final activationStatus =
          await _activationManager.activateAsset(asset).last;

      if (activationStatus.isComplete && !activationStatus.isSuccess) {
        throw WithdrawalException(
          'Failed to activate asset ${parameters.asset}',
          WithdrawalErrorCode.unknownError,
        );
      }

      final paramsWithFee = await _ensureFee(parameters, asset);

      // Initialize withdrawal task
      final initResponse = await _client.rpc.withdraw.init(paramsWithFee);
      taskId = initResponse.taskId;
      WithdrawStatusResponse? lastProgress;

      await for (final status in initResponse.watch<WithdrawStatusResponse>(
        getTaskStatus:
            (int taskId) async =>
                lastProgress = await _client.rpc.withdraw.status(
                  taskId,
                  forgetIfFinished: false,
                ),
        isTaskComplete:
            (WithdrawStatusResponse status) => status.status != 'InProgress',
      )) {
        if (status.status == 'Error') {
          yield* Stream.error(
            WithdrawalException(
              status.details as String,
              _mapErrorToCode(status.details as String),
            ),
          );
          return;
        }
        yield _mapStatusToProgress(status);
        // Break if we have a successful result to handle tx broadcast
        if (status.status == 'Ok' && status.details is WithdrawResult) {
          break;
        }
      }

      // Send the raw transaction to the network if successful
      if (lastProgress?.status == 'Ok' &&
          lastProgress?.details is WithdrawResult) {
        final details = lastProgress!.details as WithdrawResult;
        try {
          final response = await _client.rpc.withdraw.sendRawTransaction(
            coin: parameters.asset,
            txHex: details.txHex,
          );
          yield WithdrawalProgress(
            status: WithdrawalStatus.complete,
            message: 'Withdrawal complete',
            withdrawalResult: WithdrawalResult(
              txHash: response.txHash,
              balanceChanges: details.balanceChanges,
              coin: parameters.asset,
              toAddress: parameters.toAddress,
              fee: details.fee,
              kmdRewardsEligible:
                  details.kmdRewards != null &&
                  Decimal.parse(details.kmdRewards!.amount) > Decimal.zero,
            ),
          );
        } catch (e, stackTrace) {
          // Log the error and stack trace for debugging purposes
          log('Error while broadcasting transaction: $e');
          log('Stack trace: $stackTrace');
          yield* Stream.error(
            WithdrawalException(
              'Failed to broadcast transaction: $e',
              WithdrawalErrorCode.networkError,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      // Log the error and stack trace for debugging purposes
      log('Error during withdrawal: $e');
      log('Stack trace: $stackTrace');
      yield* Stream.error(
        WithdrawalException(
          'Withdrawal failed: $e',
          WithdrawalErrorCode.unknownError,
        ),
      );
    } finally {
      await _activeWithdrawals[taskId]?.close();
      _activeWithdrawals.remove(taskId);
    }
  }

  /// Maps error messages to withdrawal error codes.
  ///
  /// This helper method analyzes error messages from the API and maps them
  /// to appropriate [WithdrawalErrorCode] values for consistent error
  /// handling.
  ///
  /// Parameters:
  /// - [error] - The error message to analyze
  ///
  /// Returns the appropriate [WithdrawalErrorCode] based on the error content.
  WithdrawalErrorCode _mapErrorToCode(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('insufficient funds') ||
        errorLower.contains('not enough funds')) {
      return WithdrawalErrorCode.insufficientFunds;
    }

    if (errorLower.contains('invalid address')) {
      return WithdrawalErrorCode.invalidAddress;
    }

    if (errorLower.contains('fee')) {
      return WithdrawalErrorCode.networkError;
    }

    return WithdrawalErrorCode.unknownError;
  }

  /// Ensures fee parameters are set for the withdrawal.
  ///
  /// If fee parameters are already provided, returns the original parameters.
  /// Otherwise, estimates appropriate fees for the asset and adds them to the
  /// parameters.
  ///
  /// Parameters:
  /// - [params] - The original withdrawal parameters
  /// - [asset] - The asset being withdrawn
  ///
  /// Returns updated [WithdrawParameters] with fee information.
  Future<WithdrawParameters> _ensureFee(
    WithdrawParameters params,
    Asset asset,
  ) async {
    if (params.fee != null) return params;

    try {
      final estimation = await _feeManager.getEthEstimatedFeePerGas(
        asset.id.id,
      );
      final fee = FeeInfo.ethGas(
        coin: asset.id.id,
        gasPrice: estimation.medium.maxFeePerGas,
        gas: _defaultEthGasLimit,
      );
      return WithdrawParameters(
        asset: params.asset,
        toAddress: params.toAddress,
        amount: params.amount,
        fee: fee,
        from: params.from,
        memo: params.memo,
        ibcTransfer: params.ibcTransfer,
        ibcSourceChannel: params.ibcSourceChannel,
        isMax: params.isMax,
      );
    } catch (e, stackTrace) {
      // Log the error and stack trace for debugging purposes
      log('Error while estimating fee: $e');
      log('Stack trace: $stackTrace');
      return params;
    }
  }

  /// Maps API status response to domain progress model.
  ///
  /// Converts the raw API status response into a user-friendly progress object
  /// that can be consumed by the application.
  ///
  /// Parameters:
  /// - [status] - The API status response
  ///
  /// Returns a [WithdrawalProgress] object representing the current state.
  WithdrawalProgress _mapStatusToProgress(WithdrawStatusResponse status) {
    if (status.status == 'Ok') {
      final result = status.details as WithdrawResult;
      return WithdrawalProgress(
        status: WithdrawalStatus.inProgress,
        message: 'Withdrawal generated. Sending transaction...',
        withdrawalResult: WithdrawalResult(
          txHash: result.txHash,
          balanceChanges: result.balanceChanges,
          coin: result.coin,
          toAddress: result.to.first,
          fee: result.fee,
          kmdRewardsEligible:
              result.kmdRewards != null &&
              Decimal.parse(result.kmdRewards!.amount) > Decimal.zero,
        ),
      );
    }

    return WithdrawalProgress(
      status: WithdrawalStatus.inProgress,
      message: status.details as String,
    );
  }
}
