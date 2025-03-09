import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manages asset withdrawals using task-based API
class WithdrawalManager {
  WithdrawalManager(
    this._client,
    this._auth,
    this._assetManager,
  );
  final ApiClient _client;

  final KomodoDefiLocalAuth _auth;
  final AssetManager _assetManager;
  final _activeWithdrawals = <int, StreamController<WithdrawalProgress>>{};

  /// Cancel an active withdrawal task
  Future<bool> cancelWithdrawal(int taskId) async {
    try {
      final response = await _client.rpc.withdraw.cancel(taskId);
      return response.result == 'success';
    } catch (e) {
      return false;
    } finally {
      await _activeWithdrawals[taskId]?.close();
      _activeWithdrawals.remove(taskId);
    }
  }

  /// Cleanup any active withdrawals
  Future<void> dispose() async {
    final withdrawals = _activeWithdrawals.entries.toList();
    _activeWithdrawals.clear();

    for (final withdrawal in withdrawals) {
      await withdrawal.value.close();
      await cancelWithdrawal(withdrawal.key);
    }
  }

  Future<WithdrawalPreview> previewWithdrawal(
    WithdrawParameters parameters,
  ) async {
    try {
      final stream = (await _client.rpc.withdraw.init(parameters))
          .watch<WithdrawStatusResponse>(
        getTaskStatus: (int taskId) =>
            _client.rpc.withdraw.status(taskId, forgetIfFinished: false),
        isTaskComplete: (WithdrawStatusResponse status) =>
            status.status != 'InProgress',
      );

      final lastStatus = await stream.last;

      if (lastStatus.status.toLowerCase() == 'Error') {
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

  /// Start a withdrawal operation and return a progress stream
  Stream<WithdrawalProgress> withdraw(WithdrawParameters parameters) async* {
    int? taskId;
    try {
      await _assetManager
          // ignore: deprecated_member_use_from_same_package
          .activateAsset(
            _assetManager.findAssetsByTicker(parameters.asset).single,
          )
          .last;

      // Initialize withdrawal task
      final initResponse = await _client.rpc.withdraw.init(parameters);
      taskId = initResponse.taskId;

      WithdrawStatusResponse? lastProgress;

      await for (final status in initResponse.watch<WithdrawStatusResponse>(
        getTaskStatus: (int taskId) async => lastProgress =
            await _client.rpc.withdraw.status(taskId, forgetIfFinished: false),
        isTaskComplete: (WithdrawStatusResponse status) =>
            status.status != 'InProgress',
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
              kmdRewardsEligible: details.kmdRewards != null &&
                  Decimal.parse(details.kmdRewards!.amount) > Decimal.zero,
            ),
          );
        } catch (e) {
          yield* Stream.error(
            WithdrawalException(
              'Failed to broadcast transaction: $e',
              WithdrawalErrorCode.networkError,
            ),
          );
        }
      }
    } catch (e) {
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

  /// Maps error messages to withdrawal error codes
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

  /// Map API status response to domain progress model
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
          kmdRewardsEligible: result.kmdRewards != null &&
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
