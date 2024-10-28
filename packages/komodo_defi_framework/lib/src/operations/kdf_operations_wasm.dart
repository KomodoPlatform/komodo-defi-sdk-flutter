import 'dart:async';
import 'dart:js_interop' as js_interop;
import 'dart:js_interop_unsafe';
import 'dart:js_util' as js_util;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http/http.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

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
  // TODO! Ensure consistency accross implementations for behavior of kdMain
  // and kdfStop wrt if the method is responsible only for initiating the
  // operation or also for waiting for the operation to complete.
  // Likely, it is the former, and then additional logic on top of this
  // can be handled by [KomoDefiFramework] or the caller.
  Future<KdfStartupResult> kdfMain(JsonMap config, {int? logLevel}) async {
    await _ensureLoaded();
    // final startParams = await _configManager.generateStartParamsFromDefault(
    //   passphrase,
    //   userpass: _config.userpass,
    // );

    final mm2Config = {
      'conf': config,
      'log_level': logLevel ?? 3,
    };

    final jsConfig = js_util.jsify(mm2Config) as js_interop.JSObject;

    try {
      final result = js_util.dartify(
        _kdfModule!.callMethod(
          'mm2_main'.toJS,
          jsConfig,
          (int level, String message) {
            _log('[$level] KDF: $message');
          }.toJS,
        ),
      );

      _log('mm2_main called: $result');

      // Similar logic to the local executable implementation: wait for kdf to
      // start before returning, and assume failure instead of success if no
      // response is received from the isRunning function.
      final timer = Stopwatch()..start();
      while (timer.elapsed.inSeconds < 15) {
        if (await isRunning()) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    } on int catch (e) {
      _log('Error starting KDF: $e');
      return KdfStartupResult.fromDefaultInt(e);
    } catch (e) {
      _log('Unknown error starting KDF: $e');

      if (e.toString().contains('error')) {
        throw ClientException('Failed to call KDF main: $e');
      }
      return KdfStartupResult.invalidParams;
    }

    if (await isRunning()) {
      return KdfStartupResult.ok;
    }

    throw Exception('Error starting KDF: process not running.');
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
      final errorOrNull =
          await (js_util.dartify(_kdfModule!.callMethod('mm2_stop'.toJS))!
              as Future<Object?>);

      if (errorOrNull is int) {
        return StopStatus.fromDefaultInt(errorOrNull);
      }

      _log('KDF stop result: $errorOrNull');

      // Wait until the KDF is stopped. Timeout after 10 seconds
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
    try {
      await _ensureLoaded();

      request['userpass'] = _config.rpcPassword;

      final jsResponse = await js_util.promiseToFuture<js_interop.JSObject>(
        _kdfModule!.callMethod(
          'mm2_rpc'.toJS,
          js_util.jsify(request) as js_interop.JSObject,
        ),
      );

      print('Response pre-cast: ${js_util.dartify(jsResponse)}');

      // Convert the JS object to a Dart map and ensure it's a JsonMap
      final response =
          JsonMap.from((jsResponse.dartify()! as Map).cast<String, dynamic>());

      return response;
    } catch (e) {
      final message = 'Error calling mm2Rpc: $e. ${request['method']}';
      _log(message);
      throw Exception(message);
    }
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
