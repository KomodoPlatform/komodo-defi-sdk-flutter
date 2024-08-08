import 'dart:async';

import 'package:komodo_defi_framework/src/extensions/map_extension.dart';
import 'package:komodo_defi_framework/src/logger/logger.dart';
import 'package:komodo_defi_framework/src/startup_config_manager.dart';

enum MainStatus {
  notRunning,
  noContext,
  noRpc,
  rpcIsUp;

  static MainStatus fromDefaultInt(int value) {
    switch (value) {
      case 0:
        return MainStatus.notRunning;
      case 1:
        return MainStatus.noContext;
      case 2:
        return MainStatus.noRpc;
      case 3:
        return MainStatus.rpcIsUp;
      default:
        throw ArgumentError('Unknown MainStatus code: $value');
    }
  }
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

  static KdfStartupResult fromDefaultInt(int value) {
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

enum StopStatus {
  ok,
  notRunning,
  errorStopping,
  stoppingAlready;

  static StopStatus fromDefaultInt(int status) {
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

abstract class IKdfOperations {
  IKdfOperations.create({
    required ILogger logger,
    required IConfigManager configManager,
  });

  Future<KdfStartupResult> kdfMain(String passphrase);
  MainStatus kdfMainStatus();
  Future<StopStatus> kdfStop();
  bool isRunning();

  Future<JsonMap> mm2Rpc(JsonMap request);

  Future<void> validateSetup();
}
