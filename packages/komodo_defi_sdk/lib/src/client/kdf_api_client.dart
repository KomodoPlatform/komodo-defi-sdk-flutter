import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class KdfApiClient implements ApiClient {
  KdfApiClient(this._kdfOperations);
  final IKdfOperations _kdfOperations;

  String? _rpcPassword;

  @override
  Future<JsonMap> sendRequest(JsonMap request) async {
    if (!await isInitialized()) {
      throw StateError('API client is not initialized');
    }
    return _kdfOperations.mm2Rpc(
      request..putIfAbsent('userpass', () => _rpcPassword),
    );
  }

  @override
  Future<void> stop() async {
    final status = await _kdfOperations.kdfStop();
    if (status != StopStatus.ok) {
      throw StateError('Failed to stop API client: $status');
    }
  }

  @override
  Future<bool> isInitialized() {
    return _kdfOperations.isRunning();
  }
}
