import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/rpc/rpc_task_buddy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Refactored withdrawal manager to use new task-based APIs
class WithdrawalManager {
  WithdrawalManager(this._client);

  final ApiClient _client;
  // TODO: Persist to storage or add an RPC method to get active withdrawals.
  final _activeWithdrawals = <int, StreamController<WithdrawalProgress>>{};

  /// Start a withdrawal operation and return a progress stream
  Stream<WithdrawalProgress> withdraw(WithdrawParameters parameters) async* {
    // Initialize withdrawal task
    final initResponse = await _client.rpc.withdraw.init(parameters);

    final taskId = initResponse.taskId;
    final controller = StreamController<WithdrawalProgress>();

    WithdrawStatusResponse? lastProgress;

    try {
      await initResponse
          .watch<WithdrawStatusResponse>(
            getTaskStatus: (int taskId) async => lastProgress = await _client
                .rpc.withdraw
                .status(taskId, forgetIfFinished: false),
            isTaskComplete: (WithdrawStatusResponse status) =>
                status.status != 'InProgress',
          )
          .takeWhile((status) => !controller.isClosed)
          .map(_mapStatusToProgress)
          .forEach(controller.add);

      // Send the raw transaction to the network if successful
      if (lastProgress?.status == 'Ok' &&
          lastProgress?.details is WithdrawResult) {
        final details = lastProgress!.details as WithdrawResult;

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
      }
    } finally {
      await controller.close();
      _activeWithdrawals.remove(taskId);
    }
  }

  /// Cancel an active withdrawal task
  Future<bool> cancelWithdrawal(int taskId) async {
    try {
      final response = await _client.rpc.withdraw.cancel(taskId);
      return response.result == 'success';
    } catch (e) {
      return false;
    } finally {
      _activeWithdrawals[taskId]?.close();
      _activeWithdrawals.remove(taskId);
    }
  }

  /// Map API status response to domain progress model
  WithdrawalProgress _mapStatusToProgress(WithdrawStatusResponse status) {
    if (status.status == 'Error') {
      return WithdrawalProgress(
        status: WithdrawalStatus.error,
        message: status.details as String,
        errorCode: WithdrawalErrorCode.unknownError,
        errorMessage: status.details as String,
      );
    }

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

  Future<WithdrawalPreview> previewWithdrawal(
    WithdrawParameters parameters,
  ) async {
    final stream = (await _client.rpc.withdraw.init(parameters))
        .watch<WithdrawStatusResponse>(
      getTaskStatus: (int taskId) =>
          _client.rpc.withdraw.status(taskId, forgetIfFinished: false),
      isTaskComplete: (WithdrawStatusResponse status) =>
          status.status != 'InProgress',
    );

    final lastStatus = await stream.last;

    if (lastStatus.status == 'Error' ||
        lastStatus.details is! WithdrawalPreview) {
      throw Exception("Couldn't preview withdrawal: $lastStatus");
    }

    return lastStatus.details as WithdrawalPreview;
  }

  /// Cleanup any active withdrawals
  void dispose() {
    for (final controller in _activeWithdrawals.values) {
      controller.close();
    }
    _activeWithdrawals.clear();
  }
}
