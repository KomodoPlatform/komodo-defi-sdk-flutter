import 'dart:async';
import 'dart:js' as js;
import 'dart:js_interop' as js_interop;
import 'dart:js_interop_unsafe';
import 'dart:js_util' as js_util;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:komodo_defi_framework/src/logger/logger.dart';
import 'package:komodo_defi_framework/src/startup_config_manager.dart';

import 'kdf_operations_interface.dart';

const _kdfAsstsPath = 'kdf';
const _kdfJsBootstrapperPath = '$_kdfAsstsPath/res/kdflib_bootstrapper.js';

IKdfOperations createKdfOperations({
  required ILogger logger,
  required IConfigManager configManager,
}) {
  return KdfOperationsWeb.create(logger: logger, configManager: configManager);
}

class KdfOperationsWeb implements IKdfOperations {
  KdfOperationsWeb._(this._logger, this._configManager);

  final ILogger _logger;
  final IConfigManager _configManager;
  bool _libraryLoaded = false;
  js_interop.JSObject? _kdfModule;

  @override
  factory KdfOperationsWeb.create({
    required ILogger logger,
    required IConfigManager configManager,
  }) {
    return KdfOperationsWeb._(logger, configManager);
  }

  @override
  Future<KdfStartupResult> kdfMain(String passphrase) async {
    await _ensureLoaded();
    final startParams =
        await _configManager.generateStartParamsFromDefault(passphrase);

    final config = {
      'conf': startParams,
      'log_level': 3, // Ensure LOG_LEVEL is properly defined
    };

    final jsConfig = js_util.jsify(config);

    try {
      _kdfModule!.callMethod(
        'mm2_main'.toJS,
        jsConfig,
        js.allowInterop((int level, String message) {
          _logger.log('[$level] KDF: $message');
        }).toJS,
      );
    } on int catch (e) {
      _logger.log('Error starting KDF: $e');
      return KdfStartupResult.fromInt(e);
    } catch (e) {
      _logger.log('Unknown error starting KDF: $e');
    }

    return KdfStartupResult.ok;
  }

  @override
  MainStatus kdfMainStatus() {
    _ensureLoadedSync();
    final status = _kdfModule!.callMethod('mm2_main_status'.toJS);
    return _intToMainStatus(status as int);
  }

  @override
  Future<StopStatus> kdfStop() async {
    await _ensureLoaded();
    final result = _kdfModule!.callMethod('mm2_stop'.toJS);
    return _intToStopStatus(result as int);
  }

  @override
  bool isRunning() => kdfMainStatus() == MainStatus.rpcIsUp;

  @override
  Future<void> validateSetup() async {
    await _ensureLoaded();
  }

  Future<void> _ensureLoaded() async {
    if (_libraryLoaded) return;

    if (!_areFunctionsLoaded()) {
      await _injectLibrary();
    }

    if (!_isWasmInitialized) {
      // Wait for the existing initialization
      await _initWasm();
    }

    _libraryLoaded = _areFunctionsLoaded()
        ? true
        : throw Exception('Failed to load KDF library: functions not found');
  }

  bool get _isWasmInitialized {
    return _kdfModule
            ?.getProperty<js_interop.JSBoolean>('isInitialized'.toJS)
            .toDart ??
        false;
  }

  Future<void> _initWasm() async {
    final initWasmPromise =
        _kdfModule?.callMethod('init_wasm'.toJS) as js_interop.JSPromise?;
    if (initWasmPromise != null) {
      await initWasmPromise.toDart;
    }
  }

  bool _areFunctionsLoaded() {
    return _kdfModule?.hasProperty('mm2_main'.toJS).toDart ?? false;
  }

  Future<void> _injectLibrary() async {
    try {
      _kdfModule =
          (await js_interop.importModule('./$_kdfJsBootstrapperPath').toDart)
              .getProperty('kdf'.toJS);

      final debugProperties = Map<String, String>.fromIterable(
        [
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
            'Has property: ${_kdfModule!.has(key)} with type: ${_kdfModule!.getProperty(key).runtimeType}',
      );

      _logger.log('KDF Has properties: ${debugProperties.toString()}');
      _logger.log('KDF library loaded successfully');
    } catch (e) {
      final message =
          'Failed to load and import script $_kdfJsBootstrapperPath\n$e';
      _logger.log(message);
      throw Exception(message);
    }
  }

  void _ensureLoadedSync() {
    if (!_libraryLoaded) {
      throw Exception('KDF library not loaded. Call kdfMain() first.');
    }
  }

  MainStatus _intToMainStatus(int status) {
    switch (status) {
      case 0:
        return MainStatus.notRunning;
      case 1:
        return MainStatus.noContext;
      case 2:
        return MainStatus.noRpc;
      case 3:
        return MainStatus.rpcIsUp;
      default:
        throw ArgumentError('Unknown MainStatus code: $status');
    }
  }

  StopStatus _intToStopStatus(int status) {
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
