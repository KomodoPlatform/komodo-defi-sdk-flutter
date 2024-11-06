import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

class UtxoMethodsNamespace extends BaseRpcMethodNamespace {
  UtxoMethodsNamespace(super.client);

  Future<NewTaskResponse> enableUtxoInit({
    required String ticker,
    required UtxoActivationParams params,
  }) {
    return execute(
      TaskEnableUtxoInit(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        params: params,
      ),
    );
  }

  Future<TaskStatusResponse> taskEnableStatus(int taskId, [String? rpcPass]) =>
      execute(
        TaskStatusRequest(
          taskId: taskId,
          rpcPass: rpcPass,
          method: 'task::enable_utxo::status',
        ),
      );
}
