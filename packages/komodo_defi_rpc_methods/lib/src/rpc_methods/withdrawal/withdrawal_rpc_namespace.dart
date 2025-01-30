import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class WithdrawMethodsNamespace extends BaseRpcMethodNamespace {
  WithdrawMethodsNamespace(super.client);

  /// Soon to be deprecated. After the bug with the task-based withdrawal API
  /// is fixed, this method will be deprecated in favor of the new task-based
  /// withdrawal API.
  Future<WithdrawStatusResponse> withdraw(WithdrawParameters params) {
    return execute(
      WithdrawRequest(
        rpcPass: rpcPass ?? '',
        coin: params.asset,
        to: params.toAddress,
        amount: params.amount,
        fee: params.fee,
        from: params.from,
        memo: params.memo,
        max: params.isMax ?? false,
      ),
    );
  }

  /// Initialize a new withdrawal task
  // TODO: Consider refactoring to use individual parameters instead of a single
  // object for the request parameters for the sake of consistency with other
  // requests and since the objective for the RPC methods is to be as close to
  // the API as possible.
  Future<WithdrawInitResponse> init(WithdrawParameters params) {
    return execute(
      WithdrawInitRequest(rpcPass: rpcPass ?? '', params: params),
    );
  }

  /// Get status of a withdrawal task
  Future<WithdrawStatusResponse> status(
    int taskId, {
    bool forgetIfFinished = true,
  }) {
    return execute(
      WithdrawStatusRequest(
        rpcPass: rpcPass ?? '',
        taskId: taskId,
        forgetIfFinished: forgetIfFinished,
      ),
    );
  }

  /// Cancel a withdrawal task
  Future<WithdrawCancelResponse> cancel(int taskId) {
    return execute(
      WithdrawCancelRequest(
        rpcPass: rpcPass ?? '',
        taskId: taskId,
      ),
    );
  }

  Future<SendRawTransactionResponse> sendRawTransaction({
    required String coin,
    required String txHex,
    WithdrawalSource? from,
  }) {
    return execute(
      SendRawTransactionLegacyRequest(
        rpcPass: rpcPass ?? '',
        coin: coin,
        txHex: txHex,
      ),
    );
  }
}
