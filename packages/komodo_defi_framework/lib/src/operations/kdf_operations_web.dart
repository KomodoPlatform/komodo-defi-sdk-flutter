import 'dart:async';
import 'dart:js_interop' as js_interop;
import 'dart:js_interop_unsafe';
import 'dart:js_util' as js_util;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http/http.dart';
import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
import 'package:komodo_defi_framework/src/startup_config_manager.dart';

const _kdfAsstsPath = 'kdf';
const _kdfJsBootstrapperPath = '$_kdfAsstsPath/res/kdflib_bootstrapper.js';

IKdfOperations createLocalKdfOperations({
  required void Function(String)? logCallback,
  required IKdfStartupConfig configManager,
  required LocalConfig config,
}) {
  return KdfOperationsWeb.create(
    logCallback: logCallback ?? print,
    configManager: configManager,
    config: config,
  );
}

class KdfOperationsWeb implements IKdfOperations {
  @override
  factory KdfOperationsWeb.create({
    required IKdfStartupConfig configManager,
    required LocalConfig config,
    void Function(String)? logCallback,
  }) {
    final operations = KdfOperationsWeb._(configManager, config);
    operations._logger = logCallback;
    return operations;
  }

  KdfOperationsWeb._(this._configManager, this._config);
  final IKdfStartupConfig _configManager;
  final LocalConfig _config;
  bool _libraryLoaded = false;
  js_interop.JSObject? _kdfModule;
  void Function(String)? _logger;

  bool get _isWasmInitialized {
    return _kdfModule
            ?.getProperty<js_interop.JSBoolean>('isInitialized'.toJS)
            .toDart ??
        false;
  }

  @override
  Future<bool> isRunning() async =>
      (await kdfMainStatus()) == MainStatus.rpcIsUp;

  @override
  // TODO! Ensure consistency accross implementations for behavior of kdMain
  // and kdfStop wrt if the method is responsible only for initiating the
  // operation or also for waiting for the operation to complete.
  // Likely, it is the former, and then additional logic on top of this
  // can be handled by [KomoDefiFramework] or the caller.
  Future<KdfStartupResult> kdfMain(String passphrase) async {
    await _ensureLoaded();
    final startParams = await _configManager.generateStartParamsFromDefault(
      passphrase,
      userpass: _config.userpass,
    );

    final config = {
      'conf': startParams,
      'log_level': 3,
    };

    final jsConfig = js_util.jsify(config) as js_interop.JSObject;

    try {
      final result = js_util.dartify(
        _kdfModule!.callMethod(
          'mm2_main'.toJS,
          jsConfig,
          (int level, String message) {
            _logger?.call('[$level] KDF: $message');
          }.toJS,
        ),
      );
      print('mm2_main result: $result');

      (_logger ?? print).call('mm2_main called: $result');
    } on int catch (e) {
      _logger?.call('Error starting KDF: $e');
      return KdfStartupResult.fromDefaultInt(e);
    } catch (e) {
      print('Error starting KDF: $e');
      _logger?.call('Unknown error starting KDF: $e');

      if (e.toString().contains('error')) {
        throw ClientException('Failed to call KDF main: $e');
      }
      return KdfStartupResult.invalidParams;
    }

    return KdfStartupResult.ok;
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
      _kdfModule!.callMethod('mm2_stop'.toJS);

      // Wait until the KDF is stopped. Timeout after 10 seconds
      await Future.doWhile(() async {
        final isStopped = (await kdfMainStatus()) == MainStatus.notRunning;

        if (!isStopped) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
        return !isStopped;
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('KDF stop timed out'),
      );
    } on int catch (e) {
      return StopStatus.fromDefaultInt(e);
    } catch (e) {
      _logger?.call('Error stopping KDF: $e');
      return StopStatus.errorStopping;
    }

    return StopStatus.ok;
  }

  @override
  Future<Map<String, dynamic>> mm2Rpc(Map<String, dynamic> request) async {
    try {
      await _ensureLoaded();

      request['userpass'] = _config.userpass;

      final jsResponse = await js_util.promiseToFuture<js_interop.JSObject>(
        _kdfModule!.callMethod(
          'mm2_rpc'.toJS,
          js_util.jsify(request) as js_interop.JSObject,
        ),
      );

      print('Response pre-cast: ${js_util.dartify(jsResponse)}');

      // Convert the JS object to a Dart map and ensure it's a Map<String, dynamic>
      final response =
          Map<String, dynamic>.from(js_util.dartify(jsResponse)! as Map);

      return response;
    } catch (e) {
      final message = 'Error calling mm2Rpc: $e. ${request['method']}';
      _logger?.call(message);
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
        'userpass': _config.userpass,
        'method': 'version',
      });

      return response['result'];
    } catch (e) {
      _logger?.call("Couldn't get KDF version: $e");
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

  // void _ensureLoadedSync() {
  //   if (!_libraryLoaded) {
  //     throw Exception('KDF library not loaded. Call kdfMain() first.');
  //   }
  // }

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
              // .importModule('./$_kdfJsBootstrapperPath'.toJS)
              .importModule('./$_kdfJsBootstrapperPath')
              .toDart)
          .getProperty('kdf'.toJS);

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

      _logger?.call('KDF Has properties: $debugProperties');
      _logger?.call('KDF library loaded successfully');
    } catch (e) {
      final message =
          'Failed to load and import script $_kdfJsBootstrapperPath\n$e';
      _logger?.call(message);
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
