import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_sdk/src/withdrawals/withdrawal_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Implementation of withdrawal manager using non-task-based withdrawal methods
class LegacyWithdrawalManager implements WithdrawalManager {
  LegacyWithdrawalManager(this._client);

  final ApiClient _client;

  /// Start a withdrawal operation and return a progress stream
  @override
  Stream<WithdrawalProgress> withdraw(WithdrawParameters parameters) async* {
    try {
      // Initial progress update
      yield const WithdrawalProgress(
        status: WithdrawalStatus.inProgress,
        message: 'Initiating withdrawal...',
      );

      // Execute withdrawal request
      final response = await _client.rpc.withdraw.withdraw(parameters);

      if (response.status == 'Error') {
        yield* Stream.error(
          WithdrawalException(
            response.details as String,
            WithdrawalException.mapErrorToCode(response.details as String),
          ),
        );
        return;
      }

      final result = response.details as WithdrawResult;

      // Progress update for successful generation
      yield WithdrawalProgress(
        status: WithdrawalStatus.inProgress,
        message: 'Transaction generated. Broadcasting to network...',
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

      try {
        // Broadcast the transaction
        final broadcastResponse = await _client.rpc.withdraw.sendRawTransaction(
          coin: parameters.asset,
          txHex: result.txHex,
        );

        // Final success update
        yield WithdrawalProgress(
          status: WithdrawalStatus.complete,
          message: 'Withdrawal complete',
          withdrawalResult: WithdrawalResult(
            txHash: broadcastResponse.txHash,
            balanceChanges: result.balanceChanges,
            coin: parameters.asset,
            toAddress: parameters.toAddress,
            fee: result.fee,
            kmdRewardsEligible:
                result.kmdRewards != null &&
                Decimal.parse(result.kmdRewards!.amount) > Decimal.zero,
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
    } catch (e) {
      yield* Stream.error(
        WithdrawalException(
          'Withdrawal failed: $e',
          WithdrawalErrorCode.unknownError,
        ),
      );
    }
  }

  /// Preview a withdrawal operation without executing it
  @override
  Future<WithdrawalPreview> previewWithdrawal(
    WithdrawParameters parameters,
  ) async {
    try {
      final response = await _client.rpc.withdraw.withdraw(parameters);

      if (response.status == 'Error') {
        throw WithdrawalException(
          response.details as String,
          WithdrawalException.mapErrorToCode(response.details as String),
        );
      }

      if (response.details is! WithdrawResult) {
        throw WithdrawalException(
          'Invalid preview response format',
          WithdrawalErrorCode.unknownError,
        );
      }

      return response.details as WithdrawResult;
    } catch (e, s) {
      if (e is WithdrawalException) {
        rethrow;
      }
      throw WithdrawalException(
        'Preview failed: $e',
        WithdrawalErrorCode.unknownError,
      );
    }
  }

  /// No-op for legacy implementation since there's no task to cancel
  @override
  Future<bool> cancelWithdrawal(int taskId) async => false;

  /// No cleanup needed for legacy implementation
  @override
  Future<void> dispose() async {
    // Do any cleanup here
  }
}
