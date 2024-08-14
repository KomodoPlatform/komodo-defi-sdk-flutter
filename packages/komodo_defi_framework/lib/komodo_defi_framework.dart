import 'dart:async';

import 'package:http/http.dart';
import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_framework/src/extensions/map_extension.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_factory.dart';

import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
import 'package:komodo_defi_framework/src/startup_config_manager.dart';

export 'package:komodo_defi_framework/src/config/kdf_config.dart';
export 'src/operations/kdf_operations_interface.dart';

class KomodoDefiFramework {
  // static KomodoDefiFramework? _instance;

  KomodoDefiFramework._({
    required IKdfStartupConfig configManager,
    required KdfConfig config,
  }) : _configManager = configManager {
    _kdfOperations = createKdfOperations(
      configManager: configManager,
      config: config,
      logCallback: _log,
    );
  }

  factory KomodoDefiFramework.create({
    required KdfConfig config,
    void Function(String)? externalLogger,
  }) {
    // if (_instance != null) {
    //   return _instance!.._logger = externalLogger;
    // }

    final instance = KomodoDefiFramework._(
      configManager: StartupConfigManager(),
      config: config,
    );

    instance._logStream.stream.listen(externalLogger);

    return instance;

    // return _instance = framework.._logger = externalLogger;
  }
  final IKdfStartupConfig _configManager;
  late final IKdfOperations _kdfOperations;

  Type get kdfType => _kdfOperations.runtimeType;

  // void Function(String)? _logger;
  final StreamController<String> _logStream = StreamController.broadcast();

  void _log(String message) => _logStream.add(message);

  Future<KdfStartupResult> startKdf(String passphrase) async {
    _log('Starting KDF main...');
    // Something weird happening with parsing the
    final result = await _kdfOperations.kdfMain(passphrase);
    _log('KDF main result: $result');
    return result;
  }

  Future<MainStatus> kdfMainStatus() async {
    try {
      final status = await _kdfOperations.kdfMainStatus();

      _log('KDF main status: $status');
      return status;
    }
    // If the error is caused by ClientException, it means that the RPC server is not running
    on ClientException catch (e) {
      _log('KDF main status client error: ${e.message}');
      return MainStatus.noRpc;
    }
  }

  Future<StopStatus> kdfStop() async {
    _log('Stopping KDF...');
    final result = await _kdfOperations.kdfStop();
    _log('KDF stop result: $result');
    return result;
  }

  Future<bool> isRunning() async {
    final running = await _kdfOperations.isRunning();
    _log('KDF is running: $running');
    return running;
  }

  Future<String?> version() async {
    final version = await _kdfOperations.version();
    _log('KDF version: $version');
    return version;
  }

  Future<JsonMap> executeRpc(JsonMap request) async {
    _log('Executing RPC request: ${censorJson(request)}');
    final response = await _kdfOperations.mm2Rpc(request);
    _log('RPC response: ${censorJson(response)}');
    return response;
  }

  Future<void> dispose() async {
    _log('Disposing KomodoDefiFramework...');
    if (await isRunning()) {
      await kdfStop();
    }
    _log('KomodoDefiFramework disposed');

    _logStream.close();
  }

  /// Censor any sensitive data that should not be logged from the JSON
  /// requests or responses. This is a secondary layer of protection and the
  /// primary layer should be to avoid logging potentially sensitive data.
  JsonMap censorJson(JsonMap json) {
    final censoredJson = JsonMap.from(json);
    // Search recursively for the following keys and replace their values
    // with *s
    const sensitive = [
      'seed',
      'userpass',
      'passphrase',
      'password',
      'mnemonic',
      'private_key',
      'wif',
      'view_key',
      'spend_key',
      'address',
      'pubkey',
      'privkey',
      'userpass',
    ];

    // TODO! Implement so it searches recursively
    for (final key in sensitive) {
      if (censoredJson.containsKey(key)) {
        censoredJson[key] = '*' * censoredJson[key].toString().length;
      }
    }

    return censoredJson;
  }
}
