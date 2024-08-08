import 'dart:async';

// Import platform-specific implementations
import 'src/logger/logger.dart';
import 'src/operations/kdf_operations_interface.dart';
import 'src/operations/kdf_operations_native.dart'
    if (dart.library.html) 'src/operations/kdf_operations_web.dart';
import 'src/startup_config_manager.dart';

export 'src/operations/kdf_operations_interface.dart';

class KomodoDefiFramework {
  final ILogger _logger;
  final IConfigManager _configManager;
  late final IKdfOperations _kdfOperations;

  static KomodoDefiFramework? _instance;

  KomodoDefiFramework._({
    required ILogger logger,
    required IConfigManager configManager,
  })  : _logger = logger,
        _configManager = configManager {
    // Ensure the correct platform-specific implementation is used
    _kdfOperations =
        createKdfOperations(logger: logger, configManager: _configManager);
  }

  factory KomodoDefiFramework.create({
    void Function(String)? externalLogger,
  }) {
    if (_instance != null) {
      return _instance!;
    }

    final logger = ConsoleLogger(externalLogger: externalLogger);

    final framework = KomodoDefiFramework._(
      logger: logger,
      configManager: StartupConfigManager(),
    );

    // unawaited(_kdfOperations.validateSetup());

    return _instance = framework;
  }

  // Methods calling _kdfOperations
  Future<KdfStartupResult> startKdf(String passphrase) async {
    _logger.log('Starting KDF main...');
    final result = await _kdfOperations.kdfMain(passphrase);
    _logger.log('KDF main result: $result');
    return result;
  }

  MainStatus kdfMainStatus() {
    final status = _kdfOperations.kdfMainStatus();
    _logger.log('KDF main status: $status');
    return status;
  }

  Future<StopStatus> kdfStop() async {
    _logger.log('Stopping KDF...');
    final result = await _kdfOperations.kdfStop();
    _logger.log('KDF stop result: $result');
    return result;
  }

  bool isRunning() {
    final running = _kdfOperations.isRunning();
    _logger.log('KDF is running: $running');
    return running;
  }

  Stream<String> get logStream => _logger.logStream;

  Future<void> dispose() async {
    _logger.log('Disposing KomodoDefiFramework...');
    if (isRunning()) {
      await kdfStop();
    }
    _logger.dispose();
    _logger.log('KomodoDefiFramework disposed');
  }
}
