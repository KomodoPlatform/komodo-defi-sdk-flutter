import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http/http.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_framework/src/config/kdf_logging_config.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:mutex/mutex.dart';

const _kdfAsstsPath = 'kdf';
const _kdfJsBootstrapperPath = '$_kdfAsstsPath/res/kdflib_bootstrapper.js';

// Type-safe JS interop interfaces
@JS('window.kdf')
external KdfModule get kdf;

typedef LogCallback = void Function(int level, String message);

@JS()
extension type KdfModule(JSObject _) implements JSObject {
  external bool get isInitialized;

  @JS('init_wasm')
  external JSPromise<JSNumber?> initWasm();

  @JS('mm2_main')
  external JSPromise<JSNumber> mm2Main(
    KdfMainParams params,
    JSFunction logCallback,
  );

  @JS('mm2_main_status')
  external int mm2MainStatus();

  @JS('mm2_rpc')
  external JSPromise mm2Rpc(JSObject payload);

  @JS('mm2_stop')
  external JSPromise mm2Stop();

  @JS('mm2_version')
  external JSObject mm2Version();
}

@JS()
extension type KdfMainParams(JSObject _) implements JSObject {}

IKdfOperations createLocalKdfOperations({
  required void Function(String)? logCallback,
  required LocalConfig config,
}) {
  return KdfOperationsWasm.create(
    logCallback: logCallback ?? print,
    config: config,
  );
}

class KdfOperationsWasm implements IKdfOperations {
  @override
  factory KdfOperationsWasm.create({
    required LocalConfig config,
    void Function(String)? logCallback,
  }) {
    return KdfOperationsWasm._(config).._logger = logCallback;
  }

  KdfOperationsWasm._(this._config);
  final _startupLock = Mutex();

  final LocalConfig _config;
  bool _libraryLoaded = false;
  KdfModule? _kdfModule;
  void Function(String)? _logger;

  void _log(String message) => (_logger ?? print).call(message);

  @override
  Future<bool> isAvailable(IKdfHostConfig hostConfig) async {
    try {
      await _ensureLoaded();
      return _areFunctionsLoaded();
    } catch (_) {
      return false;
    }
  }

  bool get _isWasmInitialized {
    return _kdfModule?.isInitialized ?? false;
  }

  @override
  String operationsName = 'Local WASM JS Library';

  @override
  Future<bool> isRunning() async =>
      (await kdfMainStatus()) == MainStatus.rpcIsUp;

  @override
  Future<KdfStartupResult> kdfMain(JsonMap config, {int? logLevel}) async {
    return _startupLock.protect(() async {
      await _ensureLoaded();

      // Create the config object
      final jsConfigObj = {
        'conf': config,
        'log_level': logLevel ?? 3,
      }.jsify()! as JSObject;

      // Cast to KdfMainParams
      final jsConfig = jsConfigObj as KdfMainParams;

      try {
        return await _executeKdfMain(jsConfig);
      } on int catch (errorCode) {
        return KdfStartupResult.fromDefaultInt(errorCode);
      } on JSAny catch (jsError) {
        return _handleStartupJsError(jsError);
      } catch (e) {
        _log('Unknown error starting KDF: [${e.runtimeType}] $e');

        if (e.toString().contains('error')) {
          throw ClientException('Failed to call KDF main: $e');
        }
        return KdfStartupResult.invalidParams;
      }
    });
  }

  Future<KdfStartupResult> _executeKdfMain(KdfMainParams jsConfig) async {
    final jsPromise = _kdfModule!.mm2Main(
      jsConfig,
      ((int level, String message) {
        _log('[$level] KDF: $message');
      }).toJS,
    );

    final result = await jsPromise.toDart;
    final resultInt = result.toDartInt;
    _log('mm2_main called: $resultInt');
    return KdfStartupResult.fromDefaultInt(resultInt);
  }

  KdfStartupResult _handleStartupJsError(JSAny jsError) {
    try {
      _log('Handling JSAny error: [${jsError.runtimeType}] $jsError');

      // Try to extract error code from JSNumber
      if (jsError is JSNumber) {
        final errorCode = jsError.toDartInt;
        _log('KdfOperationsWasm: Resolved as JSNumber error code: $errorCode');
        return KdfStartupResult.fromDefaultInt(errorCode);
      }

      // Try to extract error code from JSObject
      if (jsError is JSObject) {
        final jsObj = jsError;

        // Try dartify as first approach for JSObject
        final dynamic error = jsObj.dartify();
        _log(
          'Dartified JSObject error type: ${error.runtimeType}, value: $error',
        );

        if (error is int) {
          return KdfStartupResult.fromDefaultInt(error);
        } else if (error is num) {
          return KdfStartupResult.fromDefaultInt(error.toInt());
        } else if (error is String && int.tryParse(error) != null) {
          return KdfStartupResult.fromDefaultInt(int.parse(error));
        } else if (error is Map && error.containsKey('code')) {
          final code = error['code'];
          if (code is int) {
            return KdfStartupResult.fromDefaultInt(code);
          } else if (code is num) {
            return KdfStartupResult.fromDefaultInt(code.toInt());
          }
        }
      }

      // Try dartify as last resort
      final dynamic error = jsError.dartify();
      _log('Dartified error type: ${error.runtimeType}, value: $error');

      if (error is int) {
        return KdfStartupResult.fromDefaultInt(error);
      } else if (error is num) {
        return KdfStartupResult.fromDefaultInt(error.toInt());
      } else if (error is String && int.tryParse(error) != null) {
        return KdfStartupResult.fromDefaultInt(int.parse(error));
      }

      _log('Could not extract error code from JSAny: $error');
    } catch (conversionError) {
      _log('Error during JSAny conversion: $conversionError');
    }

    return KdfStartupResult.unknownError;
  }

  @override
  Future<MainStatus> kdfMainStatus() async {
    await _ensureLoaded();
    final status = _kdfModule!.mm2MainStatus();
    return MainStatus.fromDefaultInt(status);
  }

  @override
  Future<StopStatus> kdfStop() async {
    await _ensureLoaded();

    try {
      final jsPromise = _kdfModule!.mm2Stop();
      await jsPromise.toDart;

      _log('KDF stop result: stopped');

      await Future.doWhile(() async {
        final isStopped = (await kdfMainStatus()) == MainStatus.notRunning;

        if (!isStopped) {
          await Future<void>.delayed(const Duration(milliseconds: 300));
        }
        return !isStopped;
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('KDF stop timed out'),
      );
    } catch (e) {
      _log('Error stopping KDF: $e');
      return StopStatus.errorStopping;
    }

    return StopStatus.ok;
  }

  @override
  Future<JsonMap> mm2Rpc(JsonMap request) async {
    await _ensureLoaded();

    final jsResponse = await _makeJsCall(request);
    final dartResponse = _parseDartResponse(jsResponse, request);
    _validateResponse(dartResponse, request, jsResponse);

    return JsonMap.from(dartResponse);
  }

  /// Makes the JavaScript RPC call and returns the raw JS response
  Future<dynamic> _makeJsCall(JsonMap request) async {
    if (KdfLoggingConfig.debugLogging) {
      _log('mm2Rpc request: ${request.censored()}');
    }
    request['userpass'] = _config.rpcPassword;

    final jsRequest = request.jsify()! as JSObject;

    try {
      final jsPromise = _kdfModule!.mm2Rpc(jsRequest);
      final jsResponse = await jsPromise.toDart;

      if (jsResponse == null) {
        throw Exception(
          'mm2_rpc response was null for method: ${request['method']}'
          '\nRequest: $request',
        );
      }

      if (KdfLoggingConfig.debugLogging) {
        try {
          final stringified = jsResponse.toString();
          _log('Raw JS response: $stringified');
        } catch (e) {
          _log('Raw JS response: $jsResponse (stringify failed: $e)');
        }
      }
      return jsResponse;
    } catch (error) {
      if (error.toString().contains('RethrownDartError')) {
        final errorMessage = error.toString().split('\n')[0];
        throw Exception(
          'JavaScript error for method ${request['method']}: $errorMessage'
          '\nRequest: $request',
        );
      }
      throw Exception(
        'Unknown error for method ${request['method']}: $error'
        '\nRequest: $request',
      );
    }
  }

  /// Converts JS response to Dart Map
  JsonMap _parseDartResponse(dynamic jsResponse, JsonMap request) {
    try {
      final dynamic converted = (jsResponse as JSAny).dartify();
      if (converted is! JsonMap) {
        return _deepConvertMap(converted as Map);
      }
      return converted;
    } catch (e) {
      _log('Response parsing error for method ${request['method']}:\n'
          'Request: $request');
      rethrow;
    }
  }

  /// Validates the response structure
  void _validateResponse(
    JsonMap dartResponse,
    JsonMap request,
    dynamic jsResponse,
  ) {
    // Legacy RPCs have no standard response format to validate
    if (request.valueOrNull<String>('mmrpc') != '2.0') return;

    if (!dartResponse.containsKey('result') &&
        !dartResponse.containsKey('error')) {
      throw Exception(
        'Invalid response format for method ${request['method']}\nResponse: '
        '$dartResponse\nRaw JS Response: $jsResponse\nRequest: $request',
      );
    }

    if (KdfLoggingConfig.debugLogging) {
      _log('JS response validated: $dartResponse');
    }
  }

  /// Recursively converts the provided map to JsonMap. This is required, as
  /// many of the responses received from the sdk are
  /// LinkedHashMap<Object?, Object?>
  Map<String, dynamic> _deepConvertMap(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      if (value is Map) return MapEntry(key.toString(), _deepConvertMap(value));
      if (value is List) {
        return MapEntry(key.toString(), _deepConvertList(value));
      }
      return MapEntry(key.toString(), value);
    });
  }

  List<dynamic> _deepConvertList(List<dynamic> list) {
    return list.map((value) {
      if (value is Map) return _deepConvertMap(value);
      if (value is List) return _deepConvertList(value);
      return value;
    }).toList();
  }

  @override
  Future<void> validateSetup() async {
    await _ensureLoaded();
  }

  @override
  Future<String?> version() async {
    await _ensureLoaded();

    try {
      final response = await mm2Rpc({
        'userpass': _config.rpcPassword,
        'method': 'version',
      });

      return response['result'] as String?;
    } catch (e) {
      _log("Couldn't get KDF version: $e");
      return null;
    }
  }

  bool _areFunctionsLoaded() {
    return _kdfModule != null;
  }

  Future<void> _ensureLoaded() async {
    if (_libraryLoaded && _kdfModule != null) {
      return;
    }

    if (!_areFunctionsLoaded()) {
      await _injectLibrary();
    }

    if (!_isWasmInitialized) {
      await _initWasm();
    }

    _libraryLoaded = _areFunctionsLoaded()
        ? true
        : throw Exception('Failed to load KDF library: functions not found');
  }

  Future<void> _initWasm() async {
    final jsPromise = _kdfModule!.initWasm();
    await jsPromise.toDart;
  }

  Future<void> _injectLibrary() async {
    try {
      final modulePromise = importModule('./$_kdfJsBootstrapperPath'.toJS);
      await modulePromise.toDart;

      // After importing the module, the kdf object should be available globally
      _kdfModule = kdf;

      _log('KDF library loaded successfully');
    } catch (e) {
      final message =
          'Failed to load and import script $_kdfJsBootstrapperPath\n$e';
      _log(message);

      throw Exception(message);
    }
  }
}

class KdfPluginWeb {
  static void registerWith(Registrar registrar) {
    final channel = MethodChannel(
      'komodo_defi_framework',
      const StandardMethodCodec(),
      registrar,
    );
    channel.setMethodCallHandler((call) async {
      // Handle method calls here if needed
    });

    registrar.registerMessageHandler();
  }
}
