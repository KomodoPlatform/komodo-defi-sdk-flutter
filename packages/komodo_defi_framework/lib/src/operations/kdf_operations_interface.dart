import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

enum MainStatus {
  notRunning,
  noContext,
  noRpc,
  rpcIsUp;

  static MainStatus fromDefaultInt(int value) {
    switch (value) {
      case 0:
        return MainStatus.notRunning;
      case 1:
        return MainStatus.noContext;
      case 2:
        return MainStatus.noRpc;
      case 3:
        return MainStatus.rpcIsUp;
      default:
        throw ArgumentError('Unknown MainStatus code: $value');
    }
  }

  bool get isTerminal =>
      this == MainStatus.notRunning || this == MainStatus.rpcIsUp;
}

enum KdfStartupResult {
  ok,
  alreadyRunning,
  invalidParams,
  noCoinsInConf;

  // Getter for if the KDF is running successfully e.g. KdfStartupResult.ok
  // or KdfStartupResult.alreadyRunning
  bool isStartingOrAlreadyRunning() =>
      this == KdfStartupResult.ok || this == KdfStartupResult.alreadyRunning;

  bool get isAlreadyRunning => this == KdfStartupResult.alreadyRunning;

  bool get isOk => this == KdfStartupResult.ok;

  // Int values
  // Ok = 0,
  // AlreadyRuns = 1,
  // InvalidParams = 2,
  // NoCoinsInConf = 3,

  static KdfStartupResult fromDefaultInt(int value) {
    switch (value) {
      case 0:
        return KdfStartupResult.ok;
      case 1:
        return KdfStartupResult.alreadyRunning;
      case 2:
        return KdfStartupResult.invalidParams;
      case 3:
        return KdfStartupResult.noCoinsInConf;
      default:
        throw ArgumentError('Unknown KdfStartupResult code: $value');
    }
  }
}

enum StopStatus {
  ok,
  notRunning,
  errorStopping,
  stoppingAlready;

  bool get isError => this == StopStatus.errorStopping;

  static StopStatus fromDefaultInt(int status) {
    switch (status) {
      case 0:
        return StopStatus.ok;
      case 1:
        return StopStatus.notRunning;
      case 2:
        return StopStatus.errorStopping;
      case 3:
        return StopStatus.stoppingAlready;
      default:
        throw ArgumentError('Unknown StopStatus code: $status');
    }
  }
}

abstract interface class IKdfOperations {
  // IKdfOperations.create({
  //   required ILogger logger,
  //   required IConfigManager configManager,
  // });

  String get operationsName;

  Future<KdfStartupResult> kdfMain(JsonMap startParams, {int? logLevel});
  Future<MainStatus> kdfMainStatus();
  Future<StopStatus> kdfStop();
  Future<bool> isRunning();
  Future<String?> version();
  Future<Map<String, dynamic>> mm2Rpc(Map<String, dynamic> request);
  Future<void> validateSetup();

  Future<bool> isAvailable(IKdfHostConfig hostConfig);
}

class JsonRpcErrorResponse extends MapBase<String, dynamic>
    implements Exception {
  JsonRpcErrorResponse({
    required int? code,
    required String error,
    required String message,
  }) : _map = {
          'code': code,
          'error': error,
          'message': message,
        };

  /// Returns null if the response is not an error response,
  /// otherwise returns a [JsonRpcErrorResponse] instance.
  static JsonRpcErrorResponse? tryParse(JsonMap response) {
    if (response.containsKey('error')) {
      return JsonRpcErrorResponse(
        code: response.valueOrNull<int>('code'),
        error:
            response.valueOrNull<String>('error_type') ?? 'UNKNOWN_ERROR_TYPE',
        message: response.valueOrNull<String>('error') ?? 'NO ERROR MESSAGE',
      );
    }
    return null;
  }

  final Map<String, dynamic> _map;

  int? get code => _map.valueOrNull<int?>('code');

  String get error => _map.value<String>('error');

  String get message => _map.value<String>('message');

  @override
  dynamic operator [](Object? key) => _map[key];

  @override
  void operator []=(String key, dynamic value) {
    _map[key] = value;
  }

  @override
  void clear() => _map.clear();

  @override
  Iterable<String> get keys => _map.keys;

  @override
  dynamic remove(Object? key) => _map.remove(key);

  @mustCallSuper
  Map<String, dynamic> toJson() => _map;

  @override
  String toString() => toJson().toJsonString();
}

class ConnectionError extends JsonRpcErrorResponse {
  ConnectionError(
    String message, {
    this.originalException,
    super.code = -1,
  }) : super(
          error: 'ConnectionError',
          message: message,
        );

  Exception? originalException;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (originalException != null) {
      json['originalException'] = originalException.toString();
    }
    return json;
  }
}
