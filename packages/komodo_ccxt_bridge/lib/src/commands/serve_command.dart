import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

class ServeCommand extends Command<int> {
  ServeCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addOption(
        'host',
        defaultsTo: '0.0.0.0',
        help: 'Host to bind the HTTP server to.',
      )
      ..addOption(
        'port',
        defaultsTo: '8080',
        help: 'Port to bind the HTTP server to.',
      );
  }

  final Logger _logger;

  @override
  String get description => 'Start the CCXT bridge HTTP server.';

  @override
  String get name => 'serve';

  @override
  Future<int> run() async {
    final host = argResults?.option('host') ?? '0.0.0.0';
    final portStr = argResults?.option('port') ?? '8080';
    final port = int.tryParse(portStr) ?? 8080;

    final router = Router()
      ..get('/health', _health)
      ..get('/markets', _notImplemented)
      ..get('/orderbook', _notImplemented)
      ..get('/balance', _notImplemented)
      ..post('/orders', _notImplemented)
      ..delete('/orders/<id>', _notImplemented)
      ..get('/orders/open', _notImplemented)
      ..get('/orders/<id>', _notImplemented)
      ..get('/trades/my', _notImplemented);

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(corsHeaders())
        .addHandler(router);

    final server = await serve(handler, InternetAddress(host), port);
    _logger.info(
      'CCXT bridge listening on http://${server.address.host}:${server.port}',
    );

    // Prevent exit.
    final completer = Completer<int>();
    ProcessSignal.sigint.watch().listen((_) async {
      _logger.info('Shutting down server...');
      await server.close(force: true);
      completer.complete(0);
    });
    return completer.future;
  }

  Response _health(Request req) => Response.ok('ok');

  Future<Response> _notImplemented(Request req) async {
    return Response(501, body: 'Not implemented');
  }
}
