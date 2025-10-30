import 'dart:async';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart'
    as sset;
import 'package:flutter_client_sse/flutter_client_sse.dart' as sse;
import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:logging/logging.dart';

typedef EventStreamUnsubscribe = void Function();

Uri _buildEventsUrl(IKdfHostConfig hostConfig) {
  if (hostConfig is RemoteConfig) {
    final Uri base = hostConfig.rpcUrl;
    return base.replace(
      pathSegments: <String>[...base.pathSegments, 'event-stream'],
    );
  }

  return Uri(
    scheme: 'http',
    host: '127.0.0.1',
    port: 7783,
    pathSegments: const ['event-stream'],
  );
}

EventStreamUnsubscribe connectEventStream({
  required void Function(Object? data) onMessage,
  IKdfHostConfig? hostConfig,
}) {
  final IKdfHostConfig cfg = hostConfig!;
  final Uri url = _buildEventsUrl(cfg);
  bool isClosed = false;
  StreamSubscription<sse.SSEModel>? sub;
  final Logger logger = Logger('KdfEventStreamingService[IO]');
  final Stopwatch connectionTimer = Stopwatch()..start();

  Future<void> start() async {
    try {
      logger.info('[EventStream][IO] Starting SSE connection to $url');
      // Some servers accept rpc_pass in headers, but KDF exposes `?userpass=`
      // as query for SSE. We still set Accept header to ensure SSE content type.
      sub =
          sse.SSEClient.subscribeToSSE(
            url: url.toString(),
            method: sset.SSERequestType.GET,
            header: {
              'userpass': cfg.rpcPassword,
              'Content-Type': 'application/json',
              'Accept': 'text/event-stream',
              'Cache-Control': 'no-cache',
              'Connection': 'keep-alive',
            },
          ).listen(
            (event) {
              logger.info(
                '[EventStream][IO] Event: (${event.event}:${event.id}) ${event.data}',
              );
              final String? raw = event.data;
              if (raw == null) return;
              final String data = raw.trim();
              if (data.isEmpty) return;
              try {
                final decoded = jsonFromString(data);
                onMessage(decoded);
              } catch (e) {
                logger.warning(
                  '[EventStream][IO] Failed to decode event data: $e',
                );
              }
            },
            onError: (Object error) {
              logger.warning('[EventStream][IO] SSE error: $error');
            },
          );
      connectionTimer.stop();
      logger.info(
        '[EventStream][IO] Connected to $url in ${connectionTimer.elapsedMilliseconds}ms',
      );
    } catch (e) {
      connectionTimer.stop();
      logger.severe(
        '[EventStream][IO] Failed to start SSE after ${connectionTimer.elapsedMilliseconds}ms: $e',
      );
    }
  }

  // Fire and forget
  unawaited(start());

  return () async {
    if (isClosed) return;
    isClosed = true;
    try {
      await sub?.cancel();
      logger.info('[EventStream][IO] Disconnected from $url');
    } catch (e) {
      logger.warning('[EventStream][IO] Error during disconnect: $e');
    }
  };
}
