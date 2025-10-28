import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart' as sse;
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart'
    as sset;
import 'package:komodo_defi_framework/src/config/kdf_config.dart';

typedef EventStreamUnsubscribe = void Function();

// Centralized constants to avoid repeated literals
const String _kEventStreamPath = '/event-stream';
const String _kLocalRpcBaseUrl = 'http://127.0.0.1:7783';
const Map<String, String> _defaultSseHeaders = <String, String>{};

String _composeEventsPath(String basePath) {
  if (basePath.isEmpty || basePath == '/') return _kEventStreamPath;
  return basePath.endsWith('/')
      ? '${basePath.substring(0, basePath.length)}event-stream'
      : '$basePath$_kEventStreamPath';
}

bool _isLikelyJson(String data) => data.startsWith('{') || data.startsWith('[');

Uri _buildEventsUrl(IKdfHostConfig hostConfig) {
  if (hostConfig is RemoteConfig) {
    final uri = hostConfig.rpcUrl;
    final eventsPath = _composeEventsPath(uri.path);
    return uri.replace(path: eventsPath);
  }

  final uri = Uri.parse(_kLocalRpcBaseUrl);
  return uri.replace(path: _kEventStreamPath);
}

EventStreamUnsubscribe connectEventStream({
  IKdfHostConfig? hostConfig,
  required void Function(Object? data) onMessage,
}) {
  assert(hostConfig != null, 'hostConfig is required');
  final IKdfHostConfig cfg = hostConfig!;
  final Uri url = _buildEventsUrl(cfg);
  final String urlString = url.toString();
  bool isClosed = false;
  StreamSubscription<sse.SSEModel>? sub;

  void log(String msg) {
    if (kDebugMode) {
      print('[EventStream][IO] $msg');
    }
  }

  Future<void> start() async {
    try {
      sub =
          sse.SSEClient.subscribeToSSE(
            url: urlString,
            method: sset.SSERequestType.GET,
            header: _defaultSseHeaders,
          ).listen(
            (event) {
              final String? raw = event.data;
              if (raw == null) return;
              final String data = raw.trim();
              if (data.isEmpty) return;
              final bool looksJson = _isLikelyJson(data);
              if (!looksJson) return;
              try {
                final decoded = json.decode(data);
                onMessage(decoded);
              } catch (e) {
                log('Failed to decode event data: $e');
              }
            },
            onError: (Object error, StackTrace stack) {
              log('SSE error: $error');
            },
          );
      log('Connected to $urlString');
    } catch (e) {
      log('Failed to start SSE: $e');
    }
  }

  // Fire and forget
  unawaited(start());

  return () async {
    if (isClosed) return;
    isClosed = true;
    try {
      await sub?.cancel();
    } catch (_) {}
  };
}
