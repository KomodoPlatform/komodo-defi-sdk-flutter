import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class WithdrawMethodsNamespace extends BaseRpcMethodNamespace {
  WithdrawMethodsNamespace(super.client);

  /// Initialize a new withdrawal task
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
