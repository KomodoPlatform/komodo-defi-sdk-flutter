import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

class QtumMethodsNamespace extends BaseRpcMethodNamespace {
  QtumMethodsNamespace(super.client);

  Future<NewTaskResponse> enableQtumInit({
    required String ticker,
    required QtumActivationParams params,
  }) {
    return execute(
      TaskEnableQtumInit(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        params: params,
      ),
    );
  }

  Future<TaskStatusResponse> enableQtumStatus(
    int taskId, {
    bool forgetIfFinished = true,
  }) {
    return execute(
      TaskEnableQtumStatus(
        taskId: taskId,
        forgetIfFinished: forgetIfFinished,
        rpcPass: rpcPass,
      ),
    );
  }

  Future<QtumUserActionResponse> sendUserAction({
    required int taskId,
    required String actionType,
    required String pin,
  }) {
    return execute(
      TaskEnableQtumUserAction(
        taskId: taskId,
        actionType: actionType,
        pin: pin,
        rpcPass: rpcPass,
      ),
    );
  }
}
