import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class KdfApiClient implements ApiClient {
  KdfApiClient(
    this._rpcCallback,
    // this.
    /*{required String rpcPassword}*/
  );

  final JsonMap Function(JsonMap) _rpcCallback;
  // final Future<StopStatus> Function() _stopCallback;

  // String? _rpcPassword;

  @override
  Future<JsonMap> executeRpc(JsonMap request) async {
    // if (!await isInitialized()) {
    //   throw StateError('API client is not initialized');
    // }
    return _rpcCallback(request);
  }

  // Not sure if this belongs here
  // @override
  // Future<void> stop() async {
  //   final status = await _stopCallback();
  //   if (status != StopStatus.ok) {
  //     throw StateError('Failed to stop API client: $status');
  //   }
  // }

  // @override
  // Future<bool> isInitialized() {
  //   return _kdf.isRunning();
  // }
}
