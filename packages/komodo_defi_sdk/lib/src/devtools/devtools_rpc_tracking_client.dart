import 'package:komodo_defi_sdk/src/devtools/devtools_integration_service.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Wraps an [ApiClient] to automatically report RPC analytics to DevTools.
class DevToolsRpcTrackingClient implements ApiClient {
  DevToolsRpcTrackingClient(this._inner);

  final ApiClient _inner;

  @override
  Future<JsonMap> executeRpc(JsonMap request) async {
    final method = request['method'] as String? ?? 'unknown';
    final rpcId =
        '${DateTime.now().millisecondsSinceEpoch}_${request.hashCode}';
    final startTime = DateTime.now();
    final stopwatch = Stopwatch()..start();

    final requestBytes = request.toString().length;

    try {
      final response = await _inner.executeRpc(request);
      stopwatch.stop();

      final responseBytes = response.toString().length;

      DevToolsIntegrationService.instance.postRpcCall(
        id: rpcId,
        method: method,
        status: 'success',
        startTimestamp: startTime,
        endTimestamp: DateTime.now(),
        durationMs: stopwatch.elapsedMilliseconds,
        requestBytes: requestBytes,
        responseBytes: responseBytes,
        metadata: {
          'hasError': response.containsKey('error'),
          if (response.containsKey('error'))
            'errorMessage': response['error'].toString(),
        },
      );

      return response;
    } catch (e) {
      stopwatch.stop();

      DevToolsIntegrationService.instance.postRpcCall(
        id: rpcId,
        method: method,
        status: 'error',
        startTimestamp: startTime,
        endTimestamp: DateTime.now(),
        durationMs: stopwatch.elapsedMilliseconds,
        requestBytes: requestBytes,
        metadata: {
          'errorType': e.runtimeType.toString(),
          'errorMessage': e.toString(),
        },
      );

      rethrow;
    }
  }
}
