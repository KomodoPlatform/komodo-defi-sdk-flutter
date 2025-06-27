import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class TaskEnableSiaInit
    extends BaseRequest<NewTaskResponse, GeneralErrorResponse> {
  TaskEnableSiaInit({required this.ticker, required this.params, super.rpcPass})
    : super(method: 'task::enable_sia::init', mmrpc: '2.0');

  final String ticker;
  @override
  final SiaActivationParams params;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'mmrpc': mmrpc,
    'method': method,
    'params': {'ticker': ticker, 'activation_params': params.toRpcParams()},
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

class TaskEnableSiaStatus
    extends BaseRequest<TaskStatusResponse, GeneralErrorResponse> {
  TaskEnableSiaStatus({
    required this.taskId,
    this.forgetIfFinished = true,
    super.rpcPass,
  }) : super(method: 'task::enable_sia::status', mmrpc: '2.0');

  final int taskId;
  final bool forgetIfFinished;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'mmrpc': mmrpc,
    'method': method,
    'params': {'task_id': taskId, 'forget_if_finished': forgetIfFinished},
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

class TaskEnableSiaCancel
    extends BaseRequest<BaseResponse, GeneralErrorResponse> {
  TaskEnableSiaCancel({required this.taskId, super.rpcPass})
    : super(method: 'task::enable_sia::cancel', mmrpc: '2.0');

  final int taskId;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'mmrpc': mmrpc,
    'method': method,
    'params': {'task_id': taskId},
  };

  @override
  BaseResponse parseResponse(String responseBody) {
    final json = jsonFromString(responseBody);
    if (GeneralErrorResponse.isErrorResponse(json)) {
      throw GeneralErrorResponse.parse(json);
    }
    return GeneralErrorResponse.parse(json);
  }
}
