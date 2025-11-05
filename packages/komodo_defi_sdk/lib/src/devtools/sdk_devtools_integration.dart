import 'package:flutter/foundation.dart';
import 'package:komodo_defi_sdk/src/devtools/devtools_integration_service.dart';
import 'package:komodo_defi_sdk/src/devtools/devtools_rpc_tracking_client.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Handles SDK-level DevTools integration so applications don't need to
/// manually wire up RPC analytics.
class SdkDevToolsIntegration {
  SdkDevToolsIntegration._();

  static final SdkDevToolsIntegration instance = SdkDevToolsIntegration._();

  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized || !kDebugMode) return;
    await DevToolsIntegrationService.instance.initialize();
    _initialized = true;
  }

  ApiClient wrapClient(ApiClient client) {
    if (!kDebugMode || client is DevToolsRpcTrackingClient) {
      return client;
    }
    return DevToolsRpcTrackingClient(client);
  }
}
