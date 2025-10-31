import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

typedef EventStreamUnsubscribe = void Function();

// Default client ID used for SSE connections
const int _kDefaultClientId = 0;

Uri _buildEventsUrl(IKdfHostConfig hostConfig, {int clientId = _kDefaultClientId}) {
  if (hostConfig is RemoteConfig) {
    final Uri base = hostConfig.rpcUrl;
    return base.replace(
      pathSegments: <String>[...base.pathSegments, 'event-stream'],
      queryParameters: {'id': clientId.toString()},
    );
  }

  return Uri(
    scheme: 'http',
    host: '127.0.0.1',
    port: 7783,
    pathSegments: const ['event-stream'],
    queryParameters: {'id': clientId.toString()},
  );
}

/// Production-visible logger that always logs (not behind kDebugMode)
void _log(String msg) {
  // Production-visible logging - always print for critical SSE lifecycle events
  print('[EventStream][IO] $msg');
}

/// Performs a preflight RPC check to ensure KDF is ready before SSE connection
Future<bool> _preflightCheck(IKdfHostConfig cfg) async {
  try {
    _log('Preflight: Checking KDF availability...');
    final client = HttpClient();
    try {
      final uri = cfg is RemoteConfig
          ? cfg.rpcUrl
          : Uri(scheme: 'http', host: '127.0.0.1', port: 7783);
      
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      
      // Simple version check to verify KDF is responding
      final payload = jsonEncode({
        'userpass': cfg.rpcPassword,
        'method': 'version',
      });
      request.write(payload);
      
      final response = await request.close().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _log('Preflight: Timeout waiting for KDF response');
          throw TimeoutException('KDF version check timeout');
        },
      );
      
      if (response.statusCode == 200) {
        _log('Preflight: KDF is ready (status ${response.statusCode})');
        await response.drain();
        return true;
      } else {
        _log('Preflight: KDF returned status ${response.statusCode}');
        await response.drain();
        return false;
      }
    } finally {
      client.close();
    }
  } catch (e) {
    _log('Preflight: Failed - $e');
    return false;
  }
}

/// Verifies SSE handshake by checking HTTP status and content-type
Future<bool> _verifyHandshake(HttpClientResponse response) async {
  if (response.statusCode != 200) {
    _log('Handshake: Failed - HTTP ${response.statusCode}');
    return false;
  }
  
  final contentType = response.headers.contentType?.toString() ?? '';
  if (!contentType.contains('text/event-stream')) {
    _log('Handshake: Failed - Invalid content-type: $contentType');
    return false;
  }
  
  _log('Handshake: Success - HTTP 200, content-type: $contentType');
  return true;
}

EventStreamUnsubscribe connectEventStream({
  required void Function(Object? data) onMessage,
  required void Function() onFirstByte,
  IKdfHostConfig? hostConfig,
  int clientId = _kDefaultClientId,
}) {
  final IKdfHostConfig cfg = hostConfig!;
  final Uri url = _buildEventsUrl(cfg, clientId: clientId);
  bool isClosed = false;
  bool firstByteReceived = false;
  HttpClient? httpClient;
  HttpClientRequest? request;
  StreamSubscription<String>? streamSubscription;
  int retryCount = 0;
  const int maxRetries = 3;
  const Duration retryDelay = Duration(seconds: 2);

  _log('SSE Start: Initializing connection to $url (client_id=$clientId)');

  Future<void> start() async {
    if (isClosed) return;

    try {
      // Step 1: Preflight RPC check
      final preflightOk = await _preflightCheck(cfg);
      if (!preflightOk) {
        _log('SSE Start: Preflight check failed, retrying in ${retryDelay.inSeconds}s...');
        if (retryCount < maxRetries && !isClosed) {
          retryCount++;
          await Future.delayed(retryDelay);
          unawaited(start());
        } else {
          _log('SSE Start: Max retries ($maxRetries) reached, giving up');
        }
        return;
      }

      // Step 2: Open SSE connection with proper handshake verification
      httpClient = HttpClient();
      httpClient!.connectionTimeout = const Duration(seconds: 10);
      
      _log('SSE Start: Opening connection to $url...');
      request = await httpClient!.getUrl(url);
      request!.headers.set('Accept', 'text/event-stream');
      request!.headers.set('Cache-Control', 'no-cache');
      request!.headers.set('Connection', 'keep-alive');
      
      final response = await request!.close();
      
      // Step 3: Verify handshake
      final handshakeOk = await _verifyHandshake(response);
      if (!handshakeOk) {
        _log('SSE Start: Handshake verification failed, retrying...');
        await response.drain();
        if (retryCount < maxRetries && !isClosed) {
          retryCount++;
          await Future.delayed(retryDelay);
          unawaited(start());
        } else {
          _log('SSE Start: Max retries ($maxRetries) reached, giving up');
        }
        return;
      }

      // Step 4: Connection established, start listening to events
      _log('SSE Connected: Successfully connected to $url (client_id=$clientId)');
      _log('SSE Connected: Waiting for first byte from stream...');
      
      // Parse SSE stream
      final StringBuffer buffer = StringBuffer();
      streamSubscription = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (isClosed) return;
              
              // Signal first byte received (any line, including comments/keepalives)
              if (!firstByteReceived) {
                firstByteReceived = true;
                _log('SSE First Byte: Received first line from stream - server is flowing');
                onFirstByte();
              }
              
              if (line.startsWith('data: ')) {
                final data = line.substring(6).trim();
                if (data.isNotEmpty) {
                  try {
                    final decoded = jsonFromString(data);
                    onMessage(decoded);
                  } catch (e) {
                    _log('SSE Data: Failed to decode event - $e');
                  }
                }
              } else if (line.isEmpty && buffer.isNotEmpty) {
                // Empty line marks end of event
                buffer.clear();
              }
            },
            onError: (error) {
              if (!isClosed) {
                _log('SSE Error: $error');
                // Attempt reconnection on error
                if (retryCount < maxRetries) {
                  retryCount++;
                  _log('SSE Error: Reconnecting (attempt $retryCount/$maxRetries)...');
                  Future.delayed(retryDelay, start);
                }
              }
            },
            onDone: () {
              if (!isClosed) {
                _log('SSE Done: Connection closed by server');
                // Attempt reconnection if not manually closed
                if (retryCount < maxRetries) {
                  retryCount++;
                  _log('SSE Done: Reconnecting (attempt $retryCount/$maxRetries)...');
                  Future.delayed(retryDelay, start);
                }
              }
            },
            cancelOnError: false,
          );
      
      // Reset retry count on successful connection
      retryCount = 0;
      
    } catch (e) {
      if (!isClosed) {
        _log('SSE Start: Exception - $e');
        if (retryCount < maxRetries) {
          retryCount++;
          _log('SSE Start: Retrying (attempt $retryCount/$maxRetries)...');
          await Future.delayed(retryDelay);
          unawaited(start());
        } else {
          _log('SSE Start: Max retries ($maxRetries) reached, giving up');
        }
      }
    }
  }

  // Start connection asynchronously
  unawaited(start());

  return () async {
    if (isClosed) return;
    isClosed = true;
    _log('SSE Disconnect: Closing connection (client_id=$clientId)');
    try {
      await streamSubscription?.cancel();
      httpClient?.close(force: true);
    } catch (e) {
      _log('SSE Disconnect: Error during cleanup - $e');
    }
  };
}
