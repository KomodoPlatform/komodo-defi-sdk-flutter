import 'dart:async';

import 'package:komodo_defi_framework/src/logger/logger.dart';
import 'package:komodo_defi_framework/src/startup_config_manager.dart';

enum MainStatus {
  notRunning,
  noContext,
  noRpc,
  rpcIsUp,
}

enum KdfStartupResult {
  ok,
  alreadyRunning,
  invalidParams,
  noCoinsInConf;

  // Int values
  // Ok = 0,
  // AlreadyRuns = 1,
  // InvalidParams = 2,
  // NoCoinsInConf = 3,

  static KdfStartupResult fromInt(int value) {
    switch (value) {
      case 0:
        return KdfStartupResult.ok;
      case 1:
        return KdfStartupResult.alreadyRunning;
      case 2:
        return KdfStartupResult.invalidParams;
      case 3:
        return KdfStartupResult.noCoinsInConf;
      default:
        throw ArgumentError('Unknown KdfStartupResult code: $value');
    }
  }
}

enum StopStatus { ok, notRunning, errorStopping, stoppingAlready }

abstract class IKdfOperations {
  IKdfOperations.create({
    required ILogger logger,
    required IConfigManager configManager,
  });

  Future<KdfStartupResult> kdfMain(String passphrase);
  MainStatus kdfMainStatus();
  Future<StopStatus> kdfStop();
  bool isRunning();

  Future<void> validateSetup();
}
