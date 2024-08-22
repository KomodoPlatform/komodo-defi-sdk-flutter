import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class KdfApiClient implements ApiClient {
  KdfApiClient(this._kdf);
  final KomodoDefiFramework _kdf;

  String? _rpcPassword;

  @override
  Future<JsonMap> sendRequest(JsonMap request) async {
    if (!await isInitialized()) {
      throw StateError('API client is not initialized');
    }
    return _kdf.executeRpc(
      request..putIfAbsent('userpass', () => _rpcPassword),
    );
  }

  // Not sure if this belongs here
  @override
  Future<void> stop() async {
    final status = await _kdf.kdfStop();
    if (status != StopStatus.ok) {
      throw StateError('Failed to stop API client: $status');
    }
  }

  @override
  Future<bool> isInitialized() {
    return _kdf.isRunning();
  }
}
