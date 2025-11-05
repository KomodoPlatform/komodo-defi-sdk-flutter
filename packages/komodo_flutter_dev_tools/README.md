# Komodo Flutter DevTools Extension

Komodo Flutter DevTools is a Flutter web extension that surfaces rich logging
and RPC analytics for Komodo Wallet developers directly inside the DevTools UI.
The extension focuses on helping teams trace noisy log streams, spot repeated
or wasteful RPC calls, and get immediate insight into payload sizes, error
rates, and performance regressions.

> Built following the official [Dart & Flutter DevTools extensions
> guide](https://blog.flutter.dev/dart-flutter-devtools-extensions-c8bc1aaf8e5f).

## Key Capabilities

- **Live log stream** with level filters, quick search, and metadata drill-down.
- **RPC analytics dashboard** summarising call volume, latency (avg/p95),
  duplicate payloads, bandwidth usage, and failure rates.
- **Timeline visualisation** of call durations with hover tooltips for method
  inspection.
- **Wasteful call insights** highlighting methods that are strong candidates for
  caching, batching, or optimisation.
- **One-click snapshots** for both logs and RPC traces (backed by service
  extensions) that can be exported or reviewed offline.

## Workspace Layout

```
komodo_flutter_dev_tools/
  lib/
    main.dart                     # Wraps the DevToolsExtension widget.
    src/
      app.dart                    # Top-level dependency injection & BLoCs.
      core/                       # Shared constants and formatters.
      data/                       # VM service bridge and data models.
      features/                   # Logs, RPC analytics, connection UI.
  extension/
    devtools/
      config.yaml                 # Extension metadata consumed by DevTools.
      build/                      # Populated via build_and_copy (see below).
```

## Instrumentation Contract

The extension listens for VM service extension events and provides helper
service calls. To integrate a running app with the dashboard, emit events using
`dart:developer.postEvent` and expose the following optional service
extensions:

| Purpose | Event Kind / RPC | Payload |
| --- | --- | --- |
| Stream individual log entries | `ext.komodo.log.entry` | `{ id, timestamp, level, category, message, metadata?, tags? }` |
| Stream batches of logs | `ext.komodo.log.batch` | `{ entries: [<log entry>...] }` |
| Stream individual RPC traces | `ext.komodo.rpc.call` | `{ id, method, status, startTimestamp, endTimestamp?, durationMs?, requestBytes?, responseBytes?, metadata? }` |
| Stream batches of RPC traces | `ext.komodo.rpc.batch` | `{ calls: [<rpc call>...] }` |
| Push pre-computed summaries | `ext.komodo.rpc.summary` | `{ totalCalls, failedCalls, cachedHits, uniqueMethods, generatedAt }` |
| Respond to log snapshot requests | `ext.komodo.logs.snapshot` | `{ entries: [...] }` |
| Respond to RPC snapshot requests | `ext.komodo.rpc.snapshot` | `{ calls: [...] }` |
| Toggle RPC tracing at runtime | `ext.komodo.rpc.toggleTracing` | `{ enabled: true|false }` |
| Refresh insights server-side | `ext.komodo.rpc.refreshInsights` | `{}` |

All payloads are treated defensively—missing fields are tolerated and the UI
falls back to calculated metrics where necessary.

## Building the Extension Assets

The DevTools loader expects a pre-built Flutter web bundle inside
`extension/devtools/build`. During development you can rely on the simulated
DevTools environment (`--dart-define=use_simulated_environment=true`), but for a
production build:

```bash
cd sdk/packages/komodo_flutter_dev_tools
flutter pub get
dart run devtools_extensions build_and_copy --source=. --dest=extension/devtools
```

This command compiles the web app and copies the artefacts into the directory
that DevTools will serve. Re-run the command whenever you update the UI.

## Working in Simulated DevTools

Add the following launch configuration (VS Code example) to enable the built-in
simulated environment for rapid iteration:

```json
{
  "name": "komodo_flutter_dev_tools (simulated DevTools)",
  "request": "launch",
  "type": "dart",
  "args": ["--dart-define=use_simulated_environment=true"]
}
```

The simulated host gives you hot-reload, fake connection management, and a
lightweight VM service stub.

## Integrating With Komodo Wallet

1. Add the `komodo_flutter_dev_tools` package as a **dev dependency** in the
   wallet app.
2. Emit log and RPC events using the schemas above (wrapping existing
   instrumentation from `dragon_logs`, RPC middlewares, etc.).
3. Optionally register the snapshot / tracing service extensions to enable the
   shortcut buttons inside DevTools.
4. Build the extension assets (`build_and_copy`) and run the wallet as usual.
   DevTools will detect the dependency and surface the “Komodo Dev Tools” tab.

## Contributing

- Keep business logic inside BLoCs (`logs_bloc.dart`, `rpc_metrics_bloc.dart`,
  `vm_connection_bloc.dart`).
- Prefer structured models over generic maps when adding new event types.
- Run `flutter analyze` and `dart format .` before sending patches.
- Update this README when adding new events or service extensions.

For questions or feature requests, please use the Komodo Wallet tracker.
