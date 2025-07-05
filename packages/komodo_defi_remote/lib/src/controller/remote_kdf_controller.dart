import 'dart:convert';

import 'package:http/http.dart' as http;

import '../daemon/remote_kdf_daemon.dart';

/// Configuration for connecting to a remote daemon.
class RemoteConnectionConfig {
  RemoteConnectionConfig({required this.host, this.port = 8000});

  /// Hostname or IP address of the daemon.
  final String host;

  /// Daemon port.
  final int port;

  Uri get baseUri => Uri.parse('http://$host:$port/');
}

/// Client-side controller for managing remote KDF daemon instances.
class RemoteKdfController {
  RemoteKdfController(this.config, {http.Client? client})
    : _client = client ?? http.Client();

  final RemoteConnectionConfig config;
  final http.Client _client;

  /// Connect to the daemon. Currently a no-op but provided for future expansion.
  Future<void> connect() async {}

  /// Starts the remote KDF process.
  Future<void> startKdf() async {
    await _client.post(config.baseUri.resolve('start'));
  }

  /// Stops the remote KDF process.
  Future<void> stopKdf() async {
    await _client.post(config.baseUri.resolve('stop'));
  }

  /// Fetches the current status of the daemon.
  Future<KdfStatus> status() async {
    final res = await _client.get(config.baseUri.resolve('status'));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return KdfStatus(data['running'] as bool);
  }
}
