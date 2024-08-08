import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';

class KdfApiClient implements ApiClient {
  KdfApiClient(this._kdfOperations);
  final IKdfOperations _kdfOperations;

  @override
  Future<JsonMap> sendRequest(JsonMap request) async {
    if (!isInitialized()) {
      throw StateError('API client is not initialized');
    }
    return _kdfOperations.mm2Rpc(request);
  }

  @override
  Future<void> initialize(String passphrase) async {
    final result = await _kdfOperations.kdfMain(passphrase);
    if (result != KdfStartupResult.ok) {
      throw StateError('Failed to initialize API client: $result');
    }
  }

  @override
  Future<void> stop() async {
    final status = await _kdfOperations.kdfStop();
    if (status != StopStatus.ok) {
      throw StateError('Failed to stop API client: $status');
    }
  }

  @override
  bool isInitialized() {
    return _kdfOperations.isRunning();
  }
}
