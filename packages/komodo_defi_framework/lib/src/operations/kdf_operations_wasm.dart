import 'dart:async';
import 'dart:js_interop' as js_interop;
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http/http.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_framework/src/config/kdf_logging_config.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:mutex/mutex.dart';

const _kdfAsstsPath = 'kdf';
const _kdfJsBootstrapperPath = '$_kdfAsstsPath/res/kdflib_bootstrapper.js';

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
  js_interop.JSObject? _kdfModule;
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
    return _kdfModule
            ?.getProperty<js_interop.JSBoolean>('isInitialized'.toJS)
            .toDart ??
        false;
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

      final jsConfig = {
        'conf': config,
        'log_level': logLevel ?? 3,
      }.jsify() as js_interop.JSObject?;

      try {
        return await _executeKdfMain(jsConfig);
      } on int catch (errorCode) {
        return KdfStartupResult.fromDefaultInt(errorCode);
      } on js_interop.JSAny catch (jsError) {
        return _handleJsError(jsError);
      } catch (e) {
        _log('Unknown error starting KDF: [${e.runtimeType}] $e');

        if (e.toString().contains('error')) {
          throw ClientException('Failed to call KDF main: $e');
        }
        return KdfStartupResult.invalidParams;
      }
    });
  }

  Future<KdfStartupResult> _executeKdfMain(
    js_interop.JSObject? jsConfig,
  ) async {
    final future = _kdfModule!
        .callMethod(
          'mm2_main'.toJS,
          jsConfig,
          (int level, String message) {
            _log('[$level] KDF: $message');
          }.toJS,
        )
        .dartify() as Future<dynamic>?;

    final result = await future;
    _log('mm2_main called: $result');

    if (result is int) {
      return KdfStartupResult.fromDefaultInt(result);
    }

    throw Exception(
      'KDF main returned unexpected type: ${result.runtimeType}',
    );
  }

  KdfStartupResult _handleJsError(js_interop.JSAny jsError) {
    try {
      _log('Handling JSAny error: [${jsError.runtimeType}] $jsError');

      // Try to extract error code from JSNumber
      if (isInstance<js_interop.JSNumber>(jsError, 'JSNumber')) {
        final errorCode = (jsError as js_interop.JSNumber).toDartInt;
        _log('KdfOperationsWasm: Resolved as JSNumber error code: $errorCode');
        return KdfStartupResult.fromDefaultInt(errorCode);
      }

      // Try to extract error code from JSObject
      if (isInstance<js_interop.JSObject>(jsError, 'JSObject')) {
        final jsObj = jsError as js_interop.JSObject;

        // Check for code property
        if (jsObj.hasProperty('code'.toJS).toDart) {
          final code = jsObj.getProperty('code'.toJS);
          // Print all properties of the JSObject
          if (isInstance<js_interop.JSNumber>(code, 'JSNumber')) {
            final errorCode = (code! as js_interop.JSNumber).toDartInt;
            _log(
              'KdfOperationsWasm: Resolved as JSObject->JSNumber error code: $errorCode',
            );
            return KdfStartupResult.fromDefaultInt(errorCode);
          }
        }

        // Try toNumber method
        final asNumber = jsObj.callMethod('toNumber'.toJS);
        if (asNumber?.isDefinedAndNotNull ?? false) {
          final errorCode = (asNumber! as js_interop.JSNumber).toDartInt;
          _log(
            'KdfOperationsWasm: Resolved as JSNumber error code: $errorCode',
          );
          return KdfStartupResult.fromDefaultInt(errorCode);
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

  bool isInstance<T extends js_interop.JSAny?>(
    js_interop.JSAny? obj, [
    String? typeString,
  ]) {
    return obj is T ||
        obj.instanceOfString(typeString ?? T.runtimeType.toString());
  }

  @override
  Future<MainStatus> kdfMainStatus() async {
    await _ensureLoaded();
    final status = _kdfModule!.callMethod('mm2_main_status'.toJS);
    return MainStatus.fromDefaultInt(status! as int);
  }

  @override
  Future<StopStatus> kdfStop() async {
    await _ensureLoaded();

    try {
      final errorOrNull = await (_kdfModule!
          .callMethod('mm2_stop'.toJS)
          .dartify()! as Future<Object?>);

      if (errorOrNull is int) {
        return StopStatus.fromDefaultInt(errorOrNull);
      }

      _log('KDF stop result: $errorOrNull');

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
    } on int catch (e) {
      return StopStatus.fromDefaultInt(e);
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
  Future<js_interop.JSObject> _makeJsCall(JsonMap request) async {
    if (KdfLoggingConfig.verboseDebugLogging) {
      _log('mm2Rpc request: ${request.censored()}');
    }
    request['userpass'] = _config.rpcPassword;

    final jsRequest = request.jsify() as js_interop.JSObject?;
    final jsPromise = _kdfModule!.callMethod('mm2_rpc'.toJS, jsRequest)
        as js_interop.JSPromise?;

    if (jsPromise == null || jsPromise.isUndefinedOrNull) {
      throw Exception(
        'mm2_rpc call returned null for method: ${request['method']}'
        '\nRequest: $request',
      );
    }

    final jsResponse = await jsPromise.toDart
        .then((value) => value)
        .catchError((Object error) {
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
    });

    if (jsResponse == null || jsResponse.isUndefinedOrNull) {
      throw Exception(
        'mm2_rpc response was null for method: ${request['method']}'
        '\nRequest: $request',
      );
    }

    if (KdfLoggingConfig.verboseDebugLogging) {
      _log('Raw JS response: $jsResponse');
    }
    return jsResponse as js_interop.JSObject;
  }

  /// Converts JS response to Dart Map
  JsonMap _parseDartResponse(
    js_interop.JSObject jsResponse,
    JsonMap request,
  ) {
    try {
      final dynamic converted = jsResponse.dartify();
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
    js_interop.JSObject jsResponse,
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

    if (KdfLoggingConfig.verboseDebugLogging) {
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
    return _kdfModule?.hasProperty('mm2_main'.toJS).toDart ?? false;
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
    final initWasmPromise =
        _kdfModule?.callMethod('init_wasm'.toJS) as js_interop.JSPromise?;
    if (initWasmPromise != null) {
      await initWasmPromise.toDart;
    }
  }

  Future<void> _injectLibrary() async {
    try {
      _kdfModule = (await js_interop
              .importModule('./$_kdfJsBootstrapperPath'.toJS)
              .toDart)
          .getProperty('kdf'.toJS);

      _log('KDF library loaded successfully');
    } catch (e) {
      final message =
          'Failed to load and import script $_kdfJsBootstrapperPath\n$e';
      _log(message);

      final debugProperties = Map<String, String>.fromIterable(
        <String>[
          'isInitialized',
          'kdf',
          'initSync',
          'initWasm',
          'init',
          'mm2_main',
          'mm2_main_status',
          'mm2_stop',
          'mm2_init',
          'init_wasm',
          '__wbg_init',
        ],
        value: (key) =>
            'Has property: ${_kdfModule!.has(key as String)} with type: '
            '${_kdfModule!.getProperty(key.toJS).runtimeType}',
      );

      _log('KDF Has properties: $debugProperties');

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
