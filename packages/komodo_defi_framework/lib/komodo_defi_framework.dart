import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_framework/src/config/kdf_logging_config.dart';
import 'package:komodo_defi_framework/src/config/kdf_startup_config.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_factory.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

export 'package:komodo_defi_framework/src/client/kdf_api_client.dart';
export 'package:komodo_defi_framework/src/config/kdf_config.dart';
export 'package:komodo_defi_framework/src/config/kdf_startup_config.dart';
export 'package:komodo_defi_framework/src/services/seed_node_service.dart';

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

    _loggerSub = _logStream.stream.listen(
      logCallback,
      onError: (Object error, StackTrace stackTrace) {
        // Log the error internally but don't propagate it to avoid crashing
        if (kDebugMode) {
          print('[KomodoDefiFramework] Error in external logger callback:');
          print('  Error: $error');
          print('  Stack trace:\n$stackTrace');
        }
      },
      cancelOnError: false, // Continue listening even if the callback throws
    );
  }

  StreamSubscription<String>? _loggerSub;

  // final IKdfHostConfig _hostConfig;
  late final IKdfOperations _kdfOperations;

  final StreamController<String> _logStream = StreamController.broadcast();

  Stream<String> get logStream => _logStream.stream;

  void _log(String message) {
    if (!_logStream.isClosed) {
      _logStream.add(message);
    }
  }

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

    // Checking if KDF is running using `version` method covers the case
    // where implementations do not run as a singleton. E.g. `kdfMainStatus`
    // for `kdfOperationsLocalExecutable` will return `MainStatus.notRunning`
    // if that instance does not have a process running even if KDF is
    // running in another instance. Consider refactoring the architecture
    // to take this into account.
    if (status == MainStatus.notRunning) {
      final version = await _kdfOperations.version();
      if (version != null) {
        return MainStatus.rpcIsUp;
      }
    }

    return status;
  }

  Future<StopStatus> kdfStop() async {
    _log('Stopping KDF...');
    final result = await _kdfOperations.kdfStop();
    _log('KDF stop result: $result');
    // Await a max of 5 seconds for KDF to stop. Check every 500ms.
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!await isRunning()) {
        break;
      }
      if (i == 9) {
        throw Exception('Error stopping KDF: KDF did not stop in time.');
      }
    }

    return result;
  }

  Future<bool> isRunning() async {
    final running =
        await _kdfOperations.isRunning() ||
        await _kdfOperations.version() != null;
    if (!running) {
      _log('KDF is not running.');
    }
    return running;
  }

  Future<String?> version() async {
    final version = await _kdfOperations.version();
    _log('KDF version: $version');
    return version;
  }

  /// Checks if KDF is healthy and responsive by attempting a version RPC call.
  /// Returns true if KDF is running and responsive, false otherwise.
  /// This is useful for detecting when KDF has become unavailable, especially
  /// on mobile platforms after app backgrounding.
  Future<bool> isHealthy() async {
    try {
      final isRunningCheck = await isRunning();
      if (!isRunningCheck) {
        _log('KDF health check failed: not running');
        return false;
      }
      
      // Additional check: try to get version to verify RPC is responsive
      final versionCheck = await version();
      if (versionCheck == null) {
        _log('KDF health check failed: version call returned null');
        return false;
      }
      
      _log('KDF health check passed');
      return true;
    } catch (e) {
      _log('KDF health check failed with exception: $e');
      return false;
    }
  }

  @override
  Future<JsonMap> executeRpc(JsonMap request) async {
    final response = (await _kdfOperations.mm2Rpc(
      request..setIfAbsentOrEmpty('userpass', _hostConfig.rpcPassword),
    )).ensureJson();
    if (KdfLoggingConfig.verboseLogging) {
      _log('RPC response: ${response.toJsonString()}');
    }
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

  /// Closes the log stream and cancels the logger subscription.
  ///
  /// NB! This does not stop the KDF operations or the KDF process.
  Future<void> dispose() async {
    // Cancel subscription first before closing the stream
    await _loggerSub?.cancel();
    _loggerSub = null;

    // Close the log stream
    if (!_logStream.isClosed) {
      await _logStream.close();
    }

    // Dispose of KDF operations to free native resources
    final operations = _kdfOperations;
    operations.dispose();
  }

  String get operationsName => _kdfOperations.operationsName;
}
