import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class SiaMethodsNamespace extends BaseRpcMethodNamespace {
  SiaMethodsNamespace(super.client);

  Future<NewTaskResponse> enableSiaInit({
    required String ticker,
    required SiaActivationParams params,
  }) {
    return execute(
      TaskEnableSiaInit(rpcPass: rpcPass ?? '', ticker: ticker, params: params),
    );
  }

  Future<TaskStatusResponse> enableSiaStatus(
    int taskId, {
    bool forgetIfFinished = true,
  }) {
    return execute(
      TaskEnableSiaStatus(
        taskId: taskId,
        forgetIfFinished: forgetIfFinished,
        rpcPass: rpcPass,
      ),
    );
  }

  Future<BaseResponse> enableSiaCancel(int taskId) {
    return execute(TaskEnableSiaCancel(taskId: taskId, rpcPass: rpcPass));
  }

  Future<SiaWithdrawResponse> withdraw({
    required String coin,
    required String to,
    Decimal? amount,
    FeeInfo? fee,
    bool max = false,
  }) {
    return execute(
      SiaWithdrawRequest(
        rpcPass: rpcPass ?? '',
        coin: coin,
        to: to,
        amount: amount,
        fee: fee,
        max: max,
      ),
    );
  }
}
