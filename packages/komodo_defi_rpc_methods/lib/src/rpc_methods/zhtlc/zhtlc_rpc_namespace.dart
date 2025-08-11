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

  Future<UserActionResponse> sendUserAction({
    required int taskId,
    required String actionType,
    required String pin,
  }) {
    return execute(
      TaskEnableZhtlcUserAction(
        taskId: taskId,
        actionType: actionType,
        pin: pin,
        rpcPass: rpcPass,
      ),
    );
  }

  Future<ZhtlcCancelResponse> cancel({required int taskId}) {
    return execute(TaskEnableZhtlcCancel(taskId: taskId, rpcPass: rpcPass));
  }
}

// Also adding ZHTLC task requests:
class TaskEnableZhtlcInit
    extends BaseRequest<NewTaskResponse, GeneralErrorResponse> {
  TaskEnableZhtlcInit({
    required this.ticker,
    required this.params,
    super.rpcPass,
  }) : super(method: 'task::enable_z_coin::init', mmrpc: RpcVersion.v2_0);

  final String ticker;
  @override
  final ZhtlcActivationParams params;

  @override
  JsonMap toJson() => {
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

class TaskEnableZhtlcStatus
    extends BaseRequest<TaskStatusResponse, GeneralErrorResponse> {
  TaskEnableZhtlcStatus({
    required this.taskId,
    this.forgetIfFinished = true,
    super.rpcPass,
  }) : super(method: 'task::enable_z_coin::status', mmrpc: RpcVersion.v2_0);

  final int taskId;
  final bool forgetIfFinished;

  @override
  JsonMap toJson() => {
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

class TaskEnableZhtlcUserAction
    extends BaseRequest<UserActionResponse, GeneralErrorResponse> {
  TaskEnableZhtlcUserAction({
    required this.taskId,
    required this.actionType,
    required this.pin,
    super.rpcPass,
  }) : super(method: 'task::enable_z_coin::user_action', mmrpc: '2.0');

  final int taskId;
  final String actionType;
  final String pin;

  @override
  JsonMap toJson() => {
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
  UserActionResponse parse(Map<String, dynamic> json) {
    return UserActionResponse.parse(json);
  }
}

class TaskEnableZhtlcCancel
    extends BaseRequest<ZhtlcCancelResponse, GeneralErrorResponse> {
  TaskEnableZhtlcCancel({required this.taskId, super.rpcPass})
    : super(method: 'task::enable_z_coin::cancel', mmrpc: '2.0');

  final int taskId;

  @override
  JsonMap toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'mmrpc': mmrpc,
    'method': method,
    'params': {'task_id': taskId},
  };

  @override
  ZhtlcCancelResponse parse(Map<String, dynamic> json) {
    return ZhtlcCancelResponse.parse(json);
  }
}

class UserActionResponse extends BaseResponse {
  UserActionResponse({required super.mmrpc, required this.result});

  factory UserActionResponse.parse(JsonMap json) {
    return UserActionResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: json.value<String>('result'),
    );
  }

  final String result;

  @override
  JsonMap toJson() => {'mmrpc': mmrpc, 'result': result};
}

class ZhtlcCancelResponse extends BaseResponse {
  ZhtlcCancelResponse({required super.mmrpc, required this.result});

  factory ZhtlcCancelResponse.parse(JsonMap json) {
    return ZhtlcCancelResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: json.value<String>('result'),
    );
  }

  final String result;

  @override
  JsonMap toJson() => {'mmrpc': mmrpc, 'result': result};
}
