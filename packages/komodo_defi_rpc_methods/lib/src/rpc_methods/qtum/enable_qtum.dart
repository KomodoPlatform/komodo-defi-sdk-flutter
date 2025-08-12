import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class TaskEnableQtumInit
    extends BaseRequest<NewTaskResponse, GeneralErrorResponse> {
  TaskEnableQtumInit({
    required this.ticker,
    required this.params,
    super.rpcPass,
  }) : super(method: 'task::enable_qtum::init', mmrpc: RpcVersion.v2_0);

  final String ticker;

  @override
  // ignore: overridden_fields
  final QtumActivationParams params;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'mmrpc': mmrpc,
    'method': method,
    'params': {'ticker': ticker, 'activation_params': params.toRpcParams()},
  };

  @override
  NewTaskResponse parse(Map<String, dynamic> json) {
    return NewTaskResponse.parse(json);
  }
}

class TaskEnableQtumStatus
    extends BaseRequest<TaskStatusResponse, GeneralErrorResponse> {
  TaskEnableQtumStatus({
    required this.taskId,
    this.forgetIfFinished = true,
    super.rpcPass,
  }) : super(method: 'task::enable_qtum::status', mmrpc: RpcVersion.v2_0);

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
  TaskStatusResponse parse(Map<String, dynamic> json) {
    return TaskStatusResponse.parse(json);
  }
}

class TaskEnableQtumUserAction
    extends BaseRequest<QtumUserActionResponse, GeneralErrorResponse> {
  TaskEnableQtumUserAction({
    required this.taskId,
    required this.actionType,
    required this.pin,
    super.rpcPass,
  }) : super(method: 'task::enable_qtum::user_action', mmrpc: RpcVersion.v2_0);

  final int taskId;
  final String actionType;
  final String pin;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'mmrpc': mmrpc,
    'method': method,
    'params': {
      'task_id': taskId,
      'user_action': {'action_type': actionType, 'pin': pin},
    },
  };

  @override
  QtumUserActionResponse parse(Map<String, dynamic> json) {
    return QtumUserActionResponse.parse(json);
  }
}

// lib/src/common_structures/activation/responses/user_action_response.dart
class QtumUserActionResponse extends BaseResponse {
  QtumUserActionResponse({required super.mmrpc, required this.result});

  factory QtumUserActionResponse.parse(JsonMap json) {
    return QtumUserActionResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: json.value<String>('result'),
    );
  }

  final String result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result};
}
