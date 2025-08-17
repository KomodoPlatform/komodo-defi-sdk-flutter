import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

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
      )
      ..addOption(
        'kdf-url',
        help: 'Remote KDF RPC base URL, e.g. http://127.0.0.1:7783',
        defaultsTo: 'http://127.0.0.1:7783',
      )
      ..addOption(
        'kdf-pass',
        help: 'Remote KDF RPC password (userpass).',
        defaultsTo: 'pass',
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

    final kdfUrl = Uri.parse(argResults?.option('kdf-url') ?? 'http://127.0.0.1:7783');
    final kdfPass = argResults?.option('kdf-pass') ?? '';

    final rpc = _RemoteApiClient(kdfUrl, kdfPass);
    final rpcLib = KomodoDefiRpcMethods(rpc);

    final router = Router()
      ..get('/health', _health)
      ..get('/markets', (req) => _markets(req, rpcLib))
      ..get('/orderbook', (req) => _orderbook(req, rpcLib))
      ..get('/balance', (req) => _balance(req, rpcLib))
      ..post('/orders', (req) => _createOrder(req, rpcLib))
      ..delete('/orders/<id>', (req, String id) => _cancelOrder(req, rpcLib, id))
      ..get('/orders/open', (req) => _openOrders(req, rpcLib))
      ..get('/orders/<id>', (req, String id) => _orderById(req, rpcLib, id))
      ..get('/trades/my', (req) => _myTrades(req, rpcLib));

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

  // GET /markets?quote=USDT
  Future<Response> _markets(Request req, KomodoDefiRpcMethods rpcLib) async {
    try {
      // We don't have a direct coin list on the node. Use enabled coins as a minimal list.
      final enabled = await rpcLib.generalActivation.getEnabledCoins();
      final coins = enabled.result.map((e) => e.ticker).toList();
      return Response.ok(
        jsonEncode({
          'symbols': coins,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return _error(e);
    }
  }

  // GET /orderbook?base=KMD&rel=BTC
  Future<Response> _orderbook(Request req, KomodoDefiRpcMethods rpcLib) async {
    try {
      final params = req.requestedUri.queryParameters;
      final base = params['base'];
      final rel = params['rel'];
      if (base == null || rel == null) {
        return Response(400, body: 'Missing base or rel');
      }
      final ob = await rpcLib.orderbook.orderbook(
        base: base,
        rel: rel,
      );
      final body = {
        'symbol': '$base/$rel',
        'bids': ob.bids
            .map((o) => [o.price, o.maxVolume])
            .toList(),
        'asks': ob.asks
            .map((o) => [o.price, o.maxVolume])
            .toList(),
        'timestamp': ob.timestamp,
      };
      return Response.ok(jsonEncode(body), headers: {'content-type': 'application/json'});
    } catch (e) {
      return _error(e);
    }
  }

  // GET /balance?coin=KMD
  Future<Response> _balance(Request req, KomodoDefiRpcMethods rpcLib) async {
    try {
      final params = req.requestedUri.queryParameters;
      final coin = params['coin'];
      if (coin == null) {
        return Response(400, body: 'Missing coin');
      }
      final res = await rpcLib.wallet.myBalance(coin: coin);
      final body = {
        'coin': res.coin,
        'address': res.address,
        'balance': res.balance.total.toString(),
        'unspendable': res.balance.unspendable.toString(),
      };
      return Response.ok(jsonEncode(body), headers: {'content-type': 'application/json'});
    } catch (e) {
      return _error(e);
    }
  }

  // POST /orders
  // body: { base, rel, price, volume, minVolume?, baseConfs?, baseNota?, relConfs?, relNota? }
  Future<Response> _createOrder(Request req, KomodoDefiRpcMethods rpcLib) async {
    try {
      final json = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final base = (json['base'] ?? json['symbol']?.toString().split('/').first) as String?;
      final rel = (json['rel'] ?? json['symbol']?.toString().split('/').last) as String?;
      final price = json['price']?.toString();
      final volume = json['volume']?.toString();
      if (base == null || rel == null || price == null || volume == null) {
        return Response(400, body: 'Missing base, rel, price or volume');
      }
      final resp = await rpcLib.orderbook.setOrder(
        base: base,
        rel: rel,
        price: price,
        volume: volume,
        minVolume: json['minVolume']?.toString(),
        baseConfs: (json['baseConfs'] as num?)?.toInt(),
        baseNota: json['baseNota'] as bool?,
        relConfs: (json['relConfs'] as num?)?.toInt(),
        relNota: json['relNota'] as bool?,
      );
      return Response.ok(
        jsonEncode(resp.orderInfo.toJson()),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return _error(e);
    }
  }

  // DELETE /orders/<id>
  Future<Response> _cancelOrder(
    Request req,
    KomodoDefiRpcMethods rpcLib,
    String id,
  ) async {
    try {
      final resp = await rpcLib.orderbook.cancelOrder(uuid: id);
      return Response.ok(
        jsonEncode({'cancelled': resp.cancelled}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return _error(e);
    }
  }

  // GET /orders/open
  Future<Response> _openOrders(Request req, KomodoDefiRpcMethods rpcLib) async {
    try {
      final resp = await rpcLib.orderbook.myOrders();
      return Response.ok(
        jsonEncode({
          'orders': resp.orders.map((o) => o.toJson()).toList(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return _error(e);
    }
  }

  // GET /orders/<id>
  Future<Response> _orderById(
    Request req,
    KomodoDefiRpcMethods rpcLib,
    String id,
  ) async {
    try {
      // No direct RPC for single order by id; fetch all and filter minimalistically
      final resp = await rpcLib.orderbook.myOrders();
      final order = resp.orders.firstWhere(
        (o) => o.uuid == id,
        orElse: () => throw StateError('Order not found'),
      );
      return Response.ok(
        jsonEncode(order.toJson()),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return _error(e);
    }
  }

  // GET /trades/my?limit=50&fromUuid=...&myCoin=KMD&otherCoin=BTC
  Future<Response> _myTrades(Request req, KomodoDefiRpcMethods rpcLib) async {
    try {
      final qp = req.requestedUri.queryParameters;
      final filter = RecentSwapsFilter(
        limit: int.tryParse(qp['limit'] ?? ''),
        pageNumber: int.tryParse(qp['page'] ?? ''),
        fromUuid: qp['fromUuid'],
        myCoin: qp['myCoin'],
        otherCoin: qp['otherCoin'],
        fromTimestamp: int.tryParse(qp['fromTs'] ?? ''),
        toTimestamp: int.tryParse(qp['toTs'] ?? ''),
      );
      final resp = await rpcLib.trading.recentSwaps(filter: filter);
      return Response.ok(
        jsonEncode({
          'swaps': resp.swaps.map((s) => s.toJson()).toList(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return _error(e);
    }
  }

  Response _error(Object e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
      headers: {'content-type': 'application/json'},
    );
  }
}

class _RemoteApiClient implements ApiClient {
  _RemoteApiClient(this._baseUrl, this._userpass);

  final Uri _baseUrl;
  final String _userpass;

  @override
  Future<JsonMap> executeRpc(JsonMap request) async {
    final corrected = <String, dynamic>{
      ...request,
      'userpass': request['userpass'] ?? _userpass,
    };
    final res = await http.post(
      _baseUrl,
      headers: {'content-type': 'application/json'},
      body: jsonEncode(corrected),
    );
    if (res.statusCode != 200) {
      return {
        'error': 'HTTP ${res.statusCode}',
        'result': res.body,
      };
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
