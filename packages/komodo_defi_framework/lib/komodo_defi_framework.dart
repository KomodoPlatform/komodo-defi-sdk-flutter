import 'dart:async';

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

class KomodoDefiFramework implements ApiClient {
  KomodoDefiFramework._({
    required IKdfHostConfig hostConfig,
    void Function(String)? externalLogger,
    // required KdfApiClient? client,
  }) : _hostConfig = hostConfig {
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
    void Function(String)? externalLogger,
  }) {
    return KomodoDefiFramework._(
      hostConfig: hostConfig,
      externalLogger: externalLogger,
      // client: KdfApiClient(this, rpcPassword: hostConfig.rpcPassword),
    );
  }

  /// TODO: Test if this factory method works as expected.
  factory KomodoDefiFramework.createWithOperations({
    required IKdfHostConfig hostConfig,
    required IKdfOperations kdfOperations,
    void Function(String)? externalLogger,
  }) {
    return KomodoDefiFramework._(
      hostConfig: hostConfig,
      externalLogger: externalLogger,
      // client: KdfApiClient(this, rpcPassword: hostConfig.rpcPassword),
    ).._kdfOperations = kdfOperations;
  }

  // late final ApiClient client;
  final IKdfHostConfig _hostConfig;

  ApiClient get client => this;

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

  //TODO! Figure out best way to handle overlap between startup and host
  //TODO! Handle common KDF operations startup log scanning here or in a
  //shared class. This is important to ensure consistent startup error handling
  //across different KDF operations implementations.
  Future<KdfStartupResult> startKdf(
    KdfStartupConfig startupConfig, {
    bool validateHostConfig = true,
  }) async {
    _log('Starting KDF main...');

    if (validateHostConfig) {
      _assertHostConfigMatchesStartupConfig(startupConfig, _hostConfig);
    }

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
    // Await a max of 5 seconds for KDF to stop. Check every 100ms.
    for (var i = 0; i < 50; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!await isRunning()) {
        break;
      }
      if (i == 49) {
        throw Exception('Error stopping KDF: KDF did not stop in time.');
      }
    }

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

  @override
  Future<JsonMap> executeRpc(JsonMap request) async {
    final response = await _kdfOperations.mm2Rpc(
      request..setIfAbsentOrEmpty('userpass', _hostConfig.rpcPassword),
    );
    // For string fields, try converting to JSON
    for (final key in response.keys) {
      if (response[key] is String) {
        try {
          response[key] = jsonFromString(response[key] as String);
        } catch (_) {}
      }
    }
    _log('RPC response: ${response.toJsonString()}');
    return response;
  }

  void _assertHostConfigMatchesStartupConfig(
    KdfStartupConfig startupConfig,
    IKdfHostConfig hostConfig,
  ) {
    if (startupConfig.rpcPassword != hostConfig.rpcPassword) {
      throw ArgumentError(
        'RPC password mismatch between startup and host configs.',
      );
    }

    if (hostConfig is RemoteConfig) {
      if (startupConfig.rpcIp != hostConfig.ipAddress) {
        throw ArgumentError(
          'RPC IP mismatch between startup and host configs.',
        );
      }

      if (startupConfig.rpcPort != hostConfig.port) {
        throw ArgumentError(
          'RPC port mismatch between startup and host configs.',
        );
      }
    }
  }

  Future<void> dispose() async {
    await _logStream.close();

    await _loggerSub?.cancel();
  }

  String get operationsName => _kdfOperations.operationsName;
}
