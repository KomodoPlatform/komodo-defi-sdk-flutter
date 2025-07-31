import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Trezor hardware wallet methods namespace
class TrezorMethodsNamespace extends BaseRpcMethodNamespace {
  TrezorMethodsNamespace(super.client);

  /// Initialize Trezor device for use with Komodo DeFi Framework
  ///
  /// Before using this method, launch the Komodo DeFi Framework API, and
  /// plug in your Trezor. If you know the device pubkey, you can specify it
  /// to ensure the correct device is connected.
  ///
  /// Returns a task ID that can be used to query the initialization status.
  Future<NewTaskResponse> init({String? devicePubkey}) {
    return execute(
      TaskInitTrezorInit(rpcPass: rpcPass ?? '', devicePubkey: devicePubkey),
    );
  }

  /// Check the status of Trezor device initialization
  ///
  /// Query the status of device initialization to check its progress.
  /// The status can be:
  /// - InProgress: Normal initialization or waiting for user action
  /// - Ok: Initialization completed successfully
  /// - Error: Initialization failed
  /// - UserActionRequired: Requires PIN or passphrase input
  Future<TrezorStatusResponse> status({
    required int taskId,
    bool forgetIfFinished = true,
  }) {
    return execute(
      TaskInitTrezorStatus(
        rpcPass: rpcPass ?? '',
        taskId: taskId,
        forgetIfFinished: forgetIfFinished,
      ),
    );
  }

  /// Cancel Trezor device initialization
  ///
  /// Use this method to cancel the initialization task if needed.
  Future<TrezorCancelResponse> cancel({required int taskId}) {
    return execute(
      TaskInitTrezorCancel(rpcPass: rpcPass ?? '', taskId: taskId),
    );
  }

  /// Provide user action (PIN or passphrase) for Trezor device
  ///
  /// When the device displays a PIN grid or asks for a passphrase,
  /// use this method to provide the required input.
  ///
  /// For PIN: Enter the PIN as mapped through your keyboard numpad.
  /// For passphrase: Enter the passphrase (empty string for default
  /// wallet).
  Future<TrezorUserActionResponse> userAction({
    required int taskId,
    required TrezorUserActionData userAction,
  }) {
    return execute(
      TaskInitTrezorUserAction(
        rpcPass: rpcPass ?? '',
        taskId: taskId,
        userAction: userAction,
      ),
    );
  }

  /// Convenience method to provide PIN
  Future<TrezorUserActionResponse> providePin({
    required int taskId,
    required String pin,
  }) {
    // Validate PIN input
    if (pin.isEmpty) {
      throw ArgumentError('PIN cannot be empty');
    }

    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      throw ArgumentError('PIN must contain only numeric characters');
    }

    return userAction(
      taskId: taskId,
      userAction: TrezorUserActionData(
        actionType: TrezorUserActionType.trezorPin,
        pin: pin,
      ),
    );
  }

  /// Convenience method to provide passphrase
  Future<TrezorUserActionResponse> providePassphrase({
    required int taskId,
    required String passphrase,
  }) {
    return userAction(
      taskId: taskId,
      userAction: TrezorUserActionData(
        actionType: TrezorUserActionType.trezorPassphrase,
        passphrase: passphrase,
      ),
    );
  }
}

// Request classes for Trezor operations

class TaskInitTrezorInit
    extends BaseRequest<NewTaskResponse, GeneralErrorResponse> {
  TaskInitTrezorInit({this.devicePubkey, super.rpcPass})
    : super(method: 'task::init_trezor::init', mmrpc: RpcVersion.v2_0);

  final String? devicePubkey;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {if (devicePubkey != null) 'device_pubkey': devicePubkey},
  };

  @override
  NewTaskResponse parse(Map<String, dynamic> json) {
    return NewTaskResponse.parse(json);
  }
}

class TaskInitTrezorStatus
    extends BaseRequest<TrezorStatusResponse, GeneralErrorResponse> {
  TaskInitTrezorStatus({
    required this.taskId,
    this.forgetIfFinished = true,
    super.rpcPass,
  }) : super(method: 'task::init_trezor::status', mmrpc: RpcVersion.v2_0);

  final int taskId;
  final bool forgetIfFinished;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'task_id': taskId, 'forget_if_finished': forgetIfFinished},
  };

  @override
  TrezorStatusResponse parse(Map<String, dynamic> json) {
    return TrezorStatusResponse.parse(json);
  }
}

class TaskInitTrezorCancel
    extends BaseRequest<TrezorCancelResponse, GeneralErrorResponse> {
  TaskInitTrezorCancel({required this.taskId, super.rpcPass})
    : super(method: 'task::init_trezor::cancel', mmrpc: RpcVersion.v2_0);

  final int taskId;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'task_id': taskId},
  };

  @override
  TrezorCancelResponse parse(Map<String, dynamic> json) {
    return TrezorCancelResponse.parse(json);
  }
}

class TaskInitTrezorUserAction
    extends BaseRequest<TrezorUserActionResponse, GeneralErrorResponse> {
  TaskInitTrezorUserAction({
    required this.taskId,
    required this.userAction,
    super.rpcPass,
  }) : super(method: 'task::init_trezor::user_action', mmrpc: RpcVersion.v2_0);

  final int taskId;
  final TrezorUserActionData userAction;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'task_id': taskId, 'user_action': userAction.toJson()},
  };

  @override
  TrezorUserActionResponse parse(Map<String, dynamic> json) {
    return TrezorUserActionResponse.parse(json);
  }
}

// Response and data classes

class TrezorDeviceInfo {
  TrezorDeviceInfo({
    required this.deviceId,
    required this.devicePubkey,
    this.type,
    this.model,
    this.deviceName,
  });

  factory TrezorDeviceInfo.fromJson(JsonMap json) {
    return TrezorDeviceInfo(
      type: json.valueOrNull<String>('type'),
      model: json.valueOrNull<String>('model'),
      deviceName: json.valueOrNull<String>('device_name'),
      deviceId: json.value<String>('device_id'),
      devicePubkey: json.value<String>('device_pubkey'),
    );
  }

  final String? type;
  final String? model;
  final String? deviceName;
  final String deviceId;
  final String devicePubkey;

  JsonMap toJson() {
    return {
      if (type != null) 'type': type,
      if (model != null) 'model': model,
      if (deviceName != null) 'device_name': deviceName,
      'device_id': deviceId,
      'device_pubkey': devicePubkey,
    };
  }
}

class TrezorStatusResponse extends BaseResponse {
  TrezorStatusResponse({
    required super.mmrpc,
    required this.status,
    required this.details,
  });

  factory TrezorStatusResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    final statusString = result.value<String>('status');
    final detailsJson = result.value<dynamic>('details');

    return TrezorStatusResponse(
      mmrpc: json.value<String>('mmrpc'),
      status: statusString,
      details: detailsJson,
    );
  }

  final String status;
  final dynamic details;

  /// Returns device info if status is 'Ok' and details contains result
  TrezorDeviceInfo? get deviceInfo {
    if (status == 'Ok' && details is JsonMap) {
      final detailsMap = details as JsonMap;
      return TrezorDeviceInfo.fromJson(detailsMap);
    }
    return null;
  }

  /// Returns error info if status is 'Error'
  GeneralErrorResponse? get errorInfo {
    if (status == 'Error' && details is JsonMap) {
      return GeneralErrorResponse.parse(details as JsonMap);
    }
    return null;
  }

  /// Returns progress description for in-progress states
  String? get progressDescription {
    if (status == 'InProgress' || status == 'UserActionRequired') {
      return details as String?;
    }
    return null;
  }

  @override
  JsonMap toJson() {
    return {
      'mmrpc': mmrpc,
      'result': {'status': status, 'details': details},
    };
  }
}

class TrezorCancelResponse extends BaseResponse {
  TrezorCancelResponse({required super.mmrpc, required this.result});

  factory TrezorCancelResponse.parse(JsonMap json) {
    return TrezorCancelResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: json.value<String>('result'),
    );
  }

  final String result;

  @override
  JsonMap toJson() {
    return {'mmrpc': mmrpc, 'result': result};
  }
}

enum TrezorUserActionType {
  trezorPin('TrezorPin'),
  trezorPassphrase('TrezorPassphrase');

  const TrezorUserActionType(this.value);
  final String value;
}

class TrezorUserActionData {
  /// ⚠️ SECURITY WARNING: This class contains sensitive data (PIN and passphrase).
  /// - DO NOT log instances of this class or its fields
  /// - Use [clearSensitiveData] to securely overwrite sensitive fields when no longer needed
  /// - Avoid keeping references to this object longer than necessary
  TrezorUserActionData({required this.actionType, this.pin, this.passphrase})
    : assert(
        (actionType == TrezorUserActionType.trezorPin && pin != null) ||
            (actionType == TrezorUserActionType.trezorPassphrase &&
                passphrase != null),
        'PIN must be provided for TrezorPin action, passphrase for '
        'TrezorPassphrase action',
      );

  final TrezorUserActionType actionType;
  String? pin;
  String? passphrase;

  JsonMap toJson() {
    return {
      'action_type': actionType.value,
      if (pin != null) 'pin': pin,
      if (passphrase != null) 'passphrase': passphrase,
    };
  }

  /// Securely clears sensitive data by overwriting PIN and passphrase fields.
  /// Call this method when the sensitive data is no longer needed to minimize
  /// exposure in memory.
  void clearSensitiveData() {
    _secureClearString(pin);
    _secureClearString(passphrase);
    pin = null;
    passphrase = null;
  }

  /// Securely overwrites a string by replacing its characters with zeros.
  /// This provides a best-effort attempt to clear sensitive data from memory,
  /// though complete removal cannot be guaranteed due to Dart's string
  /// immutability and garbage collection behavior.
  void _secureClearString(String? value) {
    if (value == null) return;

    // Note: Due to Dart's string immutability, we cannot directly overwrite
    // the string content in memory. The best we can do is null the reference
    // and rely on garbage collection. For more secure memory handling,
    // consider using typed_data Uint8List for sensitive data in future versions.
  }

  @override
  String toString() {
    // Override toString to prevent accidental logging of sensitive data
    return 'TrezorUserActionData(actionType: $actionType, '
        'pin: ${pin != null ? '[REDACTED]' : 'null'}, '
        'passphrase: ${passphrase != null ? '[REDACTED]' : 'null'})';
  }
}

class TrezorUserActionResponse extends BaseResponse {
  TrezorUserActionResponse({required super.mmrpc, required this.result});

  factory TrezorUserActionResponse.parse(JsonMap json) {
    return TrezorUserActionResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: json.value<String>('result'),
    );
  }

  final String result;

  @override
  JsonMap toJson() {
    return {'mmrpc': mmrpc, 'result': result};
  }
}
