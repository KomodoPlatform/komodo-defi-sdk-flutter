import 'dart:async';

import 'package:komodo_defi_framework/src/client/kdf_api_client.dart';
import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_framework/src/config/kdf_startup_config.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_factory.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

export 'package:komodo_defi_framework/src/client/kdf_api_client.dart';
export 'package:komodo_defi_framework/src/config/kdf_config.dart';
export 'package:komodo_defi_framework/src/config/kdf_startup_config.dart';
export 'package:komodo_defi_types/komodo_defi_types.dart' show SecurityUtils;

export 'src/operations/kdf_operations_interface.dart';

class KomodoDefiFramework {
  KomodoDefiFramework._({
    required IKdfHostConfig hostConfig,
    void Function(String)? externalLogger,
  }) {
    _kdfOperations = createKdfOperations(
      hostConfig: hostConfig,
      logCallback: _log,
    );

    if (externalLogger != null) {
      _initLogStream(externalLogger);
    }
  }

  factory KomodoDefiFramework.create({
    required IKdfHostConfig hostConfig,
    // KdfApiClient? client,
    void Function(String)? externalLogger,
  }) {
    return KomodoDefiFramework._(
      hostConfig: hostConfig,
      externalLogger: externalLogger,
      // client: client,
    );
  }

  late final ApiClient client = KdfApiClient(this);

  Future<void> _initLogStream(LogCallback logCallback) async {
    if (_loggerSub != null) {
      await _loggerSub!.cancel();

      _loggerSub = null;
    }

    _loggerSub = _logStream.stream.listen(logCallback);
  }

  StreamSubscription<String>? _loggerSub;

  // final IKdfHostConfig _hostConfig;
  late final IKdfOperations _kdfOperations;

  final StreamController<String> _logStream = StreamController.broadcast();

  Stream<String> get logStream => _logStream.stream;

  void _log(String message) => _logStream.add(message);

  Future<KdfStartupResult> startKdf(KdfStartupConfig startupConfig) async {
    _log('Starting KDF main...');
    final startParams = startupConfig.encodeStartParams();
    final result = await _kdfOperations.kdfMain(startParams);
    _log('KDF main result: $result');
    return result;
  }

  Future<MainStatus> kdfMainStatus() async {
    final status = await _kdfOperations.kdfMainStatus();
    _log('KDF main status: $status');
    return status;
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
    final response = await _kdfOperations.mm2Rpc(request);
    _log('RPC response: $response');
    return response;
  }

  Future<void> dispose() async {
    await _logStream.close();

    await _loggerSub?.cancel();
  }

  String get operationsName => _kdfOperations.operationsName;
}
