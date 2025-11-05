# Komodo DevTools Extension Integration

This document describes how the Komodo wallet app integrates with the Flutter DevTools extension to provide logging and RPC tracking capabilities.

## Overview

The DevTools extension listens for VM service extension events and provides a dashboard for viewing:

- Application logs
- RPC call traces and metrics

## Integration Points

### 1. DevTools Integration Service

The main integration is handled by `DevToolsIntegrationService` shipped with
`package:komodo_defi_sdk`. The SDK initializes this automatically, and
applications can import `DevToolsIntegrationService` from the SDK to post their
own log entries when needed.

This service:

- Posts log entries as extension events
- Posts RPC call traces as extension events
- Registers service extensions for snapshot requests
- Manages event batching for performance

### 2. Logger Integration

The logger integration is still in `lib/services/logger/get_logger.dart`, but it
now imports `DevToolsIntegrationService` and `RpcLogFilter` from the SDK:

```dart
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart'
    show DevToolsIntegrationService, RpcLogFilter;

// Post logs to DevTools (SDK initializes the service)
if (!RpcLogFilter.isSdkRpcLog(record.message)) {
  DevToolsIntegrationService.instance.postLogEntry(...);
}
```

### 3. RPC Tracking

RPC analytics are fully managed inside the SDK. The dependency injection layer
wraps the framework `ApiClient` with a DevTools-aware client so every RPC
invocation (SDK internals or legacy mm2 access) emits:

- Method name
- Duration
- Success/error status
- Error messages
- Request/response payload sizes

## Testing the Integration

1. Run the Komodo wallet app in debug mode
2. Open Flutter DevTools
3. Navigate to the "Komodo Dev Tools" tab
4. Verify that:
   - Logs appear in the Logs section
   - RPC calls appear in the RPC Analytics section
   - Snapshot buttons work correctly

## Development

To develop the extension itself:

```bash
cd sdk/packages/komodo_flutter_dev_tools
flutter run -d chrome --dart-define=use_simulated_environment=true
```

This runs the extension in a simulated DevTools environment for faster iteration.

## Double Logging Prevention

To avoid duplicate entries in DevTools:

1. RPC-related log messages are filtered out from regular log posting
2. The `RpcLogFilter.isSdkRpcLog()` helper (exported by the SDK) identifies RPC
   logs using common patterns:
   - Messages starting with `[RPC]` or `[ELECTRUM]`
   - Messages containing timing patterns like "completed in Xms" or "failed after Xms"
3. These are only posted as RPC analytics, not as regular log entries

This prevents the same RPC information from appearing twice in DevTools.

## Known Limitations

1. RPC tracking now captures request/response sizes for all calls, but payload
   contents are intentionally omitted for privacy/security reasons.
2. DevTools integration is only active in debug/profile builds (gated by
   `kDebugMode`). Release builds will no-op these hooks.
