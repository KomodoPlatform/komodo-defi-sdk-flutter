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

  Future<UserActionResponse> enableZhtlcUserAction({
    required int taskId,
    required String actionType,
    String? pin,
    String? passphrase,
  }) {
    return execute(
      TaskEnableZhtlcUserAction(
        taskId: taskId,
        actionType: actionType,
        pin: pin,
        passphrase: passphrase,
        rpcPass: rpcPass,
      ),
    );
  }

  /// For Trezor support flows using the legacy/user-action RPC name
  Future<UserActionResponse> initZCoinUserAction({
    required int taskId,
    required String actionType,
    String? pin,
    String? passphrase,
  }) {
    return execute(
      TaskInitZCoinUserAction(
        taskId: taskId,
        actionType: actionType,
        pin: pin,
        passphrase: passphrase,
        rpcPass: rpcPass,
      ),
    );
  }

  Future<ZhtlcCancelResponse> enableZhtlcCancel({required int taskId}) {
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

class TaskEnableZhtlcUserAction
    extends BaseRequest<UserActionResponse, GeneralErrorResponse> {
  TaskEnableZhtlcUserAction({
    required this.taskId,
    required this.actionType,
    this.pin,
    this.passphrase,
    super.rpcPass,
  }) : super(method: 'task::enable_z_coin::user_action', mmrpc: '2.0');

  final int taskId;
  final String actionType;
  final String? pin;
  final String? passphrase;

  @override
  JsonMap toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'mmrpc': mmrpc,
    'method': method,
    'params': {
      'task_id': taskId,
      'user_action': {
        'action_type': actionType,
        if (pin != null) 'pin': pin,
        if (passphrase != null) 'passphrase': passphrase,
      },
    },
  };

  @override
  UserActionResponse parse(JsonMap json) {
    return UserActionResponse.parse(json);
  }
}

/// Trezor-specific user action endpoint used by some environments
class TaskInitZCoinUserAction
    extends BaseRequest<UserActionResponse, GeneralErrorResponse> {
  TaskInitZCoinUserAction({
    required this.taskId,
    required this.actionType,
    this.pin,
    this.passphrase,
    super.rpcPass,
  }) : super(method: 'init_z_coin_user_action', mmrpc: RpcVersion.v2_0);

  final int taskId;
  final String actionType;
  final String? pin;
  final String? passphrase;

  @override
  JsonMap toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'mmrpc': mmrpc,
    'method': method,
    'params': {
      'task_id': taskId,
      'user_action': {
        'action_type': actionType,
        if (pin != null) 'pin': pin,
        if (passphrase != null) 'passphrase': passphrase,
      },
    },
  };

  @override
  UserActionResponse parse(JsonMap json) {
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

class ZhtlcCancelResponse extends BaseResponse {
  ZhtlcCancelResponse({required super.mmrpc, required this.result});

  factory ZhtlcCancelResponse.parse(Map<String, dynamic> json) {
    return ZhtlcCancelResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: json.value<String>('result'),
    );
  }

  final String result;

  @override
  JsonMap toJson() => {'mmrpc': mmrpc, 'result': result};
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
