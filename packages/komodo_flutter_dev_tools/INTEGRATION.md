# Komodo DevTools Extension Integration

This document describes how the Komodo wallet app integrates with the Flutter DevTools extension to provide logging and RPC tracking capabilities.

## Overview

The DevTools extension listens for VM service extension events and provides a dashboard for viewing:

- Application logs
- RPC call traces and metrics

## Integration Points

### 1. DevTools Integration Service

The main integration is handled by `DevToolsIntegrationService` located at `lib/services/devtools/devtools_integration_service.dart`.

This service:

- Posts log entries as extension events
- Posts RPC call traces as extension events
- Registers service extensions for snapshot requests
- Manages event batching for performance

### 2. Logger Integration

The logger integration is in `lib/services/logger/get_logger.dart`:

```dart
// Initialize DevTools integration
await DevToolsIntegrationService.instance.initialize();

// Post logs to DevTools
DevToolsIntegrationService.instance.postLogEntry(
  id: uniqueId,
  timestamp: record.time,
  level: record.level,
  category: record.loggerName,
  message: record.message,
  metadata: {...},
);
```

### 3. RPC Tracking

RPC tracking is implemented in two ways:

#### Legacy RPC Calls

For legacy `mm2.call()` method, `RpcTrackingClient` wraps the calls:

```dart
// In lib/mm2/mm2.dart
final trackingClient = RpcTrackingClient(_kdfSdk.client);
return await trackingClient.executeRpc(jsonRequest);
```

#### SDK RPC Calls

For direct SDK usage (`sdk.client.rpc.*` or `sdk.client.executeRpc`), the `KdfLogInterceptor` listens to framework logs:

```dart
// Automatically initialized in get_logger.dart
KdfLogInterceptor.instance.initialize();
```

This intercepts KDF framework's built-in RPC logging and forwards to DevTools, tracking:

- Method name
- Duration
- Success/error status
- Error messages

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
2. The `KdfLogInterceptor.isRpcLogMessage()` method identifies RPC logs by pattern:
   - Messages starting with `[RPC]` or `[ELECTRUM]`
   - Messages containing timing patterns like "completed in Xms" or "failed after Xms"
3. These are only posted as RPC calls, not as regular log entries

This prevents the same RPC information from appearing twice in DevTools.

## Known Limitations

1. RPC tracking for SDK calls relies on KDF framework's debug logging, which provides:

   - Method name and duration
   - Success/error status
   - But NOT request/response sizes (unlike legacy RPC tracking)

2. The KdfLogInterceptor is not disposed when the app closes (minor memory leak in debug mode)
