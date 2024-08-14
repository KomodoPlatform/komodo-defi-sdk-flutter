import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_aws.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_digital_ocean.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_remote.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_wasm.dart'
    if (dart.library.io) 'package:komodo_defi_framework/src/operations/kdf_operations_native.dart'
    as local;
import 'package:komodo_defi_framework/src/startup_config_manager.dart';

IKdfOperations createKdfOperations({
  required void Function(String)? logCallback,
  required IKdfStartupConfig configManager,
  required KdfConfig config,
}) {
  assert(config.runtimeType is! String);

  switch (config.runtimeType) {
    case const (LocalConfig):
      return local.createLocalKdfOperations(
        logCallback: logCallback ?? print,
        configManager: configManager,
        config: config as LocalConfig,
      );

    case const (RemoteConfig):
      return KdfOperationsRemote.create(
        logCallback: logCallback ?? print,
        configManager: configManager,
        ipAddress: (config as RemoteConfig).ipAddress,
        port: config.port,
        userpass: config.userpass,
      );
    case const (AwsConfig):
      return KdfOperationsAWS.createFromConfig(
        logCallback: logCallback ?? print,
        configManager: configManager,
        config: config as AwsConfig,
      );
    case const (DigitalOceanConfig):
      return KdfOperationsDigitalOcean.create(
        logCallback: logCallback ?? print,
        configManager: configManager,
        config: config as DigitalOceanConfig,
      );
    default:
      throw ArgumentError('Unsupported host type: ${config.runtimeType}');
  }
}
