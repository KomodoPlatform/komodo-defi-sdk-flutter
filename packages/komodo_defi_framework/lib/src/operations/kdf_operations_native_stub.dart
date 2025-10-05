import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

IKdfOperations createLocalKdfOperations({
  required void Function(String)? logCallback,
  required LocalConfig config,
}) {
  return KdfOperationsNativeLibrary();
}

class KdfOperationsNativeLibrary implements IKdfOperations {
  @override
  String get operationsName => 'Native Library Stub';

  @override
  Future<bool> isAvailable(IKdfHostConfig hostConfig) async => false;

  @override
  Future<bool> isRunning() async => false;

  @override
  Future<KdfStartupResult> kdfMain(
    JsonMap startParams, {
    int? logLevel,
  }) async => KdfStartupResult.spawnError;

  @override
  Future<MainStatus> kdfMainStatus() async => MainStatus.notRunning;

  @override
  Future<StopStatus> kdfStop() async => StopStatus.notRunning;

  @override
  Future<String?> version() async => null;

  @override
  Future<Map<String, dynamic>> mm2Rpc(Map<String, dynamic> request) async =>
      throw UnsupportedError(
        'Native operations not available on this platform',
      );

  @override
  Future<void> validateSetup() async {
    throw UnsupportedError('Native operations not available on this platform');
  }

  @override
  void dispose() {
    // No-op for stub
  }
}
