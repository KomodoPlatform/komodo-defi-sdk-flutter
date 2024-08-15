import 'dart:async';

import 'package:http/http.dart';
import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_factory.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
import 'package:komodo_defi_framework/src/startup_config_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

export 'package:komodo_defi_framework/src/config/kdf_config.dart';
export 'package:komodo_defi_types/komodo_defi_types.dart' show SecurityUtils;

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
    final instance = KomodoDefiFramework._(
      configManager: StartupConfigManager(),
      config: config,
    );

    instance._logStream.stream.listen(externalLogger);

    return instance;
  }
  final IKdfStartupConfig _configManager;
  late final IKdfOperations _kdfOperations;

  String get operationsName => _kdfOperations.operationsName;

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
    _log('Executing RPC request: ${request.censor()}');
    final response = await _kdfOperations.mm2Rpc(request);
    _log('RPC response: ${response.censor()}');
    return response;
  }

  /// Dispose of the framework and release any resources.
  ///
  /// NB! This does not stop the RPC server if it is running. You should
  /// call [kdfStop] before disposing of the framework if you want to stop
  /// the RPC server.
  Future<void> dispose() async {
    _log('Disposing KomodoDefiFramework...');

    if (await isRunning()) {
      _log(
        'Warning: KDF is still running. If KDF should be stopped, call kdfStop '
        'before disposing of the framework.',
      );
    }

    await _logStream.close();

    _log('KomodoDefiFramework disposed');
  }
}
