import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

class KdfApiClient implements ApiClient {
  KdfApiClient(
    this._rpcCallback,
    // this.
    /*{required String rpcPassword}*/
  ) {
    _logger = Logger('KdfApiClient');
  }

  final JsonMap Function(JsonMap) _rpcCallback;
  // final Future<StopStatus> Function() _stopCallback;

  // String? _rpcPassword;
  
  late final Logger _logger;
  
  /// Enable debug logging for RPC calls (method names, durations, success/failure)
  /// This can be controlled via app configuration
  static bool enableDebugLogging = true;

  @override
  Future<JsonMap> executeRpc(JsonMap request) async {
    // if (!await isInitialized()) {
    //   throw StateError('API client is not initialized');
    // }
    
    if (!enableDebugLogging) {
      return _rpcCallback(request);
    }
    
    // Extract method name for logging
    final method = request['method'] as String?;
    final stopwatch = Stopwatch()..start();
    
    try {
      final response = _rpcCallback(request);
      stopwatch.stop();
      
      _logger.info(
        '[RPC] ${method ?? 'unknown'} completed in ${stopwatch.elapsedMilliseconds}ms',
      );
      
      // Log electrum-related methods with more detail
      if (method != null && _isElectrumRelatedMethod(method)) {
        _logger.info('[ELECTRUM] Method: $method, Duration: ${stopwatch.elapsedMilliseconds}ms');
        _logElectrumConnectionInfo(method, response);
      }
      
      return response;
    } catch (e) {
      stopwatch.stop();
      _logger.warning(
        '[RPC] ${method ?? 'unknown'} failed after ${stopwatch.elapsedMilliseconds}ms: $e',
      );
      rethrow;
    }
  }
  
  bool _isElectrumRelatedMethod(String method) {
    return method.contains('electrum') ||
        method.contains('enable') ||
        method.contains('utxo') ||
        method == 'get_enabled_coins' ||
        method == 'my_balance';
  }
  
  void _logElectrumConnectionInfo(String method, JsonMap response) {
    try {
      // Log connection information from enable responses
      if (method.contains('enable') && response['result'] != null) {
        final result = response['result'] as Map<String, dynamic>?;
        if (result != null) {
          final address = result['address'] as String?;
          final balance = result['balance'] as String?;
          _logger.info(
            '[ELECTRUM] Coin enabled - Address: ${address ?? 'N/A'}, Balance: ${balance ?? 'N/A'}',
          );
          
          // Log server information if available
          if (result['servers'] != null) {
            final servers = result['servers'];
            _logger.info('[ELECTRUM] Connected servers: $servers');
          }
        }
      }
      
      // Log balance information
      if (method == 'my_balance' && response['result'] != null) {
        final result = response['result'] as Map<String, dynamic>?;
        if (result != null) {
          final coin = result['coin'] as String?;
          final balance = result['balance'] as String?;
          _logger.info(
            '[ELECTRUM] Balance query - Coin: ${coin ?? 'N/A'}, Balance: ${balance ?? 'N/A'}',
          );
        }
      }
    } catch (e) {
      // Silently ignore logging errors
    }
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
