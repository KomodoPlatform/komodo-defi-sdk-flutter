import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

/// Represents the status of a running KDF process.
class KdfStatus {
  /// Whether the process is currently running.
  final bool isRunning;

  KdfStatus(this.isRunning);

  Map<String, dynamic> toJson() => {'running': isRunning};
}

/// Update event from the daemon indicating health or log data.
class KdfHealthUpdate {
  /// Message describing the health update.
  final String message;

  KdfHealthUpdate(this.message);
}

/// Lightweight daemon that manages the lifecycle of a KDF process and exposes a
/// simple REST API for remote control.
class RemoteKdfDaemon {
  RemoteKdfDaemon({
    required this.binaryPath,
    this.args = const [],
    this.port = 8000,
  });

  /// Path to the KDF binary that should be executed.
  final String binaryPath;

  /// Arguments passed to the KDF binary when started.
  final List<String> args;

  /// Port the daemon REST API will listen on.
  final int port;

  Process? _process;
  HttpServer? _server;
  final _healthController = StreamController<KdfHealthUpdate>.broadcast();

  /// Starts the daemon REST API server.
  Future<void> start() async {
    final router =
        Router()
          ..post('/start', _handleStart)
          ..post('/stop', _handleStop)
          ..get('/status', _handleStatus);

    _server = await shelf_io.serve(
      logRequests().addHandler(router),
      InternetAddress.anyIPv4,
      port,
    );
  }

  /// Stops the daemon REST API server and running KDF process.
  Future<void> stop() async {
    await _stopProcess();
    await _server?.close(force: true);
    await _healthController.close();
  }

  Future<Response> _handleStart(Request request) async {
    await _startProcess();
    return Response.ok(
      jsonEncode({'status': 'started'}),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> _handleStop(Request request) async {
    await _stopProcess();
    return Response.ok(
      jsonEncode({'status': 'stopped'}),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> _handleStatus(Request request) async {
    final status = await getStatus();
    return Response.ok(
      jsonEncode(status.toJson()),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<void> _startProcess() async {
    if (_process != null) return;
    _process = await Process.start(binaryPath, args);
    _process!.stdout.transform(utf8.decoder).listen((data) {
      _healthController.add(KdfHealthUpdate(data));
    });
    _process!.stderr.transform(utf8.decoder).listen((data) {
      _healthController.add(KdfHealthUpdate(data));
    });
    _process!.exitCode.then((_) => _process = null);
  }

  Future<void> _stopProcess() async {
    final process = _process;
    if (process != null) {
      process.kill();
      await process.exitCode;
      _process = null;
    }
  }

  /// Returns the current status of the managed KDF process.
  Future<KdfStatus> getStatus() async => KdfStatus(_process != null);

  /// Stream of health or log updates from the KDF process.
  Stream<KdfHealthUpdate> watchHealth() => _healthController.stream;

  /// Restarts the managed KDF process.
  Future<void> restartKdf() async {
    await _stopProcess();
    await _startProcess();
  }

  /// Placeholder for updating the KDF binary. Not implemented.
  Future<void> updateKdf() async {
    // Implementation pending
  }
}
