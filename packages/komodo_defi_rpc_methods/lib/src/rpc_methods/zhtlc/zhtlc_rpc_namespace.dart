import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class ZhtlcMethodsNamespace extends BaseRpcMethodNamespace {
  ZhtlcMethodsNamespace(super.client);

  Future<NewTaskResponse> enableZhtlcInit({
    required String ticker,
    required ZhtlcActivationParams params,
  }) {
    return execute(
      TaskEnableZhtlcInit(
        rpcPass: rpcPass ?? '',
        ticker: ticker,
        params: params,
      ),
    );
  }

  Future<TaskStatusResponse> enableZhtlcStatus(
    int taskId, {
    bool forgetIfFinished = true,
  }) {
    return execute(
      TaskEnableZhtlcStatus(
        taskId: taskId,
        forgetIfFinished: forgetIfFinished,
        rpcPass: rpcPass,
      ),
    );
  }
}

// Also adding ZHTLC task requests:
class TaskEnableZhtlcInit
    extends BaseRequest<NewTaskResponse, GeneralErrorResponse> {
  TaskEnableZhtlcInit({
    required this.ticker,
    required this.params,
    super.rpcPass,
  }) : super(
          method: 'task::enable_z_coin::init',
          mmrpc: '2.0',
        );

  final String ticker;
  @override
  final ZhtlcActivationParams params;

  @override
  JsonMap toJson() => {
        ...super.toJson(),
        'userpass': rpcPass,
        'mmrpc': mmrpc,
        'method': method,
        'params': {
          'ticker': ticker,
          'activation_params': params.toJsonRequestParams(),
        },
      };

  @override
  NewTaskResponse parseResponse(String responseBody) {
    final json = jsonFromString(responseBody);
    if (GeneralErrorResponse.isErrorResponse(json)) {
      throw GeneralErrorResponse.parse(json);
    }
    return NewTaskResponse.parse(json);
  }
}

class TaskEnableZhtlcStatus
    extends BaseRequest<TaskStatusResponse, GeneralErrorResponse> {
  TaskEnableZhtlcStatus({
    required this.taskId,
    this.forgetIfFinished = true,
    super.rpcPass,
  }) : super(
          method: 'task::enable_z_coin::status',
          mmrpc: '2.0',
        );

  final int taskId;
  final bool forgetIfFinished;

  @override
  JsonMap toJson() => {
        ...super.toJson(),
        'userpass': rpcPass,
        'mmrpc': mmrpc,
        'method': method,
        'params': {
          'task_id': taskId,
          'forget_if_finished': forgetIfFinished,
        },
      };

  @override
  TaskStatusResponse parseResponse(String responseBody) {
    final json = jsonFromString(responseBody);
    if (GeneralErrorResponse.isErrorResponse(json)) {
      throw GeneralErrorResponse.parse(json);
    }
    return TaskStatusResponse.parse(json);
  }
}
