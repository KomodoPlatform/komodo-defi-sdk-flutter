import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_remote.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_wasm.dart'
    if (dart.library.io) 'package:komodo_defi_framework/src/operations/kdf_operations_native.dart'
    as local;
import 'package:logging/logging.dart';

final _log = Logger('KdfOperationsFactory');

IKdfOperations createKdfOperations({required IKdfHostConfig hostConfig}) {
  _log.finer('createKdfOperations for ${hostConfig.runtimeType}');
  final implementation = _selectKdfImplementation(hostConfig: hostConfig);
  _log.fine('Selected implementation: ${implementation.operationsName}');
  return implementation;
}

Future<IKdfOperations> createKdfOperationsAsync({
  required IKdfHostConfig hostConfig,
}) async {
  final implementation = await _selectKdfImplementationAsync(
    hostConfig: hostConfig,
  );
  if (await implementation.isAvailable(hostConfig)) {
    return implementation;
  }
  throw ArgumentError(
    'No available KDF operations found for ${hostConfig.runtimeType}',
  );
}

IKdfOperations _selectKdfImplementation({required IKdfHostConfig hostConfig}) {
  _log.finer('Selecting implementation (sync) for ${hostConfig.runtimeType}');
  switch (hostConfig.runtimeType) {
    case LocalConfig:
      _log.finer('Using LocalConfig operations');
      return local.createLocalKdfOperations(config: hostConfig as LocalConfig);
    case RemoteConfig:
      _log.finer('Using RemoteConfig operations');
      return KdfOperationsRemote.create(
        rpcUrl: (hostConfig as RemoteConfig).rpcUrl,
        userpass: hostConfig.rpcPassword,
      );
    default:
      throw ArgumentError('Unsupported host type: ${hostConfig.runtimeType}');
  }
}

Future<IKdfOperations> _selectKdfImplementationAsync({
  required IKdfHostConfig hostConfig,
}) async {
  _log.finer('Selecting implementation (async) for ${hostConfig.runtimeType}');
  switch (hostConfig.runtimeType) {
    case LocalConfig:
      _log.finer('Using LocalConfig operations');
      return local.createLocalKdfOperations(config: hostConfig as LocalConfig);

    case RemoteConfig:
      _log.finer('Using RemoteConfig operations');
      return KdfOperationsRemote.create(
        rpcUrl: Uri.parse(
          '${(hostConfig as RemoteConfig).https == true ? 'https' : 'http'}://${hostConfig.ipAddress}:${hostConfig.port}',
        ),
        userpass: hostConfig.rpcPassword,
      );

    // TOOD: Other implementations (AWS, DigitalOcean)

    default:
      throw ArgumentError('Unsupported host type: ${hostConfig.runtimeType}');
  }
}
