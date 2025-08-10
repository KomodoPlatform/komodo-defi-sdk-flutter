import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

// Minimal MCP constants
class Mcp {
  static const String jsonrpc = '2.0';
  // Methods
  static const String initialize = 'initialize';
  static const String ping = 'ping';
  static const String shutdown = 'shutdown';
  static const String toolsList = 'tools/list';
  static const String toolsCall = 'tools/call';
  static const String resourcesList = 'resources/list';
  static const String resourcesRead = 'resources/read';
  static const String promptsList = 'prompts/list';
  static const String promptsGet = 'prompts/get';
  static const String loggingSetLevel = 'logging/setLevel';
}

class JsonRpcError implements Exception {
  JsonRpcError(this.code, this.message, [this.data]);
  final int code;
  final String message;
  final Object? data;

  Map<String, Object?> toJson() => {
        'code': code,
        'message': message,
        if (data != null) 'data': data,
      };
}

class JsonRpcRequest {
  JsonRpcRequest(this.id, this.method, this.params);
  final Object? id;
  final String method;
  final Object? params;
}

class StdioJsonRpcServer {
  StdioJsonRpcServer(this._handler);
  final FutureOr<Object?> Function(JsonRpcRequest) _handler;

  Future<void> serve() async {
    // MCP stdio framing: Content-Length header + \r\n\r\n + body
    final input = stdin;
    final output = stdout;
    final buffered = <int>[];

    Future<void> writeResponse(Object? id, Object? result, {JsonRpcError? error}) async {
      final payload = <String, Object?>{
        'jsonrpc': Mcp.jsonrpc,
        if (id != null) 'id': id,
        if (error != null) 'error': error.toJson() else 'result': result,
      };
      final bytes = utf8.encode(json.encode(payload));
      final header = utf8.encode('Content-Length: ${bytes.length}\r\n\r\n');
      output.add(header);
      output.add(bytes);
      await output.flush();
    }

    while (true) {
      // Read headers
      String? contentLengthStr;
      while (true) {
        final line = await _readHeaderLine(input, buffered);
        if (line == null) return; // EOF
        if (line.isEmpty) break; // end of headers
        final lower = line.toLowerCase();
        if (lower.startsWith('content-length:')) {
          contentLengthStr = line.split(':').last.trim();
        }
      }
      if (contentLengthStr == null) {
        // Invalid framing; ignore
        continue;
      }
      final contentLength = int.tryParse(contentLengthStr);
      if (contentLength == null || contentLength < 0) continue;

      final body = await _readBody(input, buffered, contentLength);
      if (body == null) return;

      Object? decoded;
      try {
        decoded = json.decode(utf8.decode(body));
      } catch (e) {
        await writeResponse(null, null, error: JsonRpcError(-32700, 'Parse error', e.toString()));
        continue;
      }

      if (decoded is! Map<String, Object?>) {
        await writeResponse(null, null, error: JsonRpcError(-32600, 'Invalid Request'));
        continue;
      }
      final id = decoded['id'];
      final method = decoded['method'];
      final params = decoded['params'];
      if (method is! String) {
        await writeResponse(id, null, error: JsonRpcError(-32600, 'Invalid Request'));
        continue;
      }

      try {
        final result = await _handler(JsonRpcRequest(id, method, params));
        await writeResponse(id, result);
      } on JsonRpcError catch (e) {
        await writeResponse(id, null, error: e);
      } catch (e, st) {
        await writeResponse(id, null, error: JsonRpcError(-32603, 'Internal error', {'error': e.toString(), 'stack': st.toString()}));
      }
    }
  }

  Future<String?> _readHeaderLine(Stdin input, List<int> buffered) async {
    while (true) {
      // Look for CRLF
      for (int i = 0; i + 1 < buffered.length; i++) {
        if (buffered[i] == 13 && buffered[i + 1] == 10) {
          final lineBytes = buffered.sublist(0, i);
          buffered.removeRange(0, i + 2);
          return utf8.decode(lineBytes);
        }
      }
      final chunk = await _readChunk(input);
      if (chunk == null) return null;
      buffered.addAll(chunk);
    }
  }

  Future<List<int>?> _readBody(Stdin input, List<int> buffered, int length) async {
    while (buffered.length < length) {
      final chunk = await _readChunk(input);
      if (chunk == null) return null;
      buffered.addAll(chunk);
    }
    final body = buffered.sublist(0, length);
    buffered.removeRange(0, length);
    return body;
  }

  Future<List<int>?> _readChunk(Stdin input) async {
    try {
      final completer = Completer<List<int>?>();
      late StreamSubscription<List<int>> sub;
      sub = input.listen((event) {
        completer.complete(event);
        sub.cancel();
      }, onDone: () => completer.complete(null), onError: (Object _) => completer.complete(null));
      return await completer.future;
    } catch (_) {
      return null;
    }
  }
}

// SDK-backed MCP tools implementation
class KomodoMcpServer {
  KomodoMcpServer();

  KomodoDefiSdk _sdk = KomodoDefiSdk();
  bool _initialized = false;

  Future<Object?> handle(JsonRpcRequest req) async {
    switch (req.method) {
      case Mcp.initialize:
        return _initialize(req.params);
      case Mcp.ping:
        return {};
      case Mcp.shutdown:
        await _shutdown();
        return {};
      case Mcp.toolsList:
        return _toolsList();
      case Mcp.toolsCall:
        return _toolsCall(req.params);
      case Mcp.resourcesList:
        return _resourcesList();
      case Mcp.resourcesRead:
        return _resourcesRead(req.params);
      case Mcp.promptsList:
        return _promptsList();
      case Mcp.promptsGet:
        return _promptsGet(req.params);
      default:
        throw JsonRpcError(-32601, 'Method not found', {'method': req.method});
    }
  }

  Future<Object?> _initialize(Object? params) async {
    if (!_initialized) {
      // Optionally accept remote host via params
      if (params is Map<String, Object?>) {
        final host = params['host'];
        if (host is Map<String, Object?> && host['type'] == 'remote') {
          final ip = host['ip'] as String?;
          final port = (host['port'] as num?)?.toInt();
          final https = host['https'] as bool? ?? false;
          final userpass = host['userpass'] as String?;
          if (ip != null && port != null && userpass != null) {
            // Dispose existing instance if it was initialized
            try {
              await _sdk.dispose();
            } catch (_) {}
            _sdk = KomodoDefiSdk(
              host: RemoteConfig(
                ipAddress: ip,
                port: port,
                rpcPassword: userpass,
                https: https,
              ),
            );
          }
        }
      }
      await _sdk.initialize();
      _initialized = true;
    }
    return {
      'protocolVersion': '2024-11-05',
      'capabilities': {
        'tools': true,
        'resources': true,
        'prompts': true,
        'sampling': false,
        'logging': {'levels': ['debug', 'info', 'warn', 'error']},
      },
      'serverInfo': {'name': 'komodo-mcp', 'version': '0.1.0'},
    };
  }

  Future<void> _shutdown() async {
    await _sdk.dispose();
  }

  Future<Object?> _toolsList() async {
    // Expose a minimal but powerful surface; more can be added incrementally
    return {
      'tools': [
        {
          'name': 'sdk.call',
          'description': 'Call a raw KDF/mm2 RPC method via the Komodo DeFi Framework (mm2). Params: {method, params}',
          'inputSchema': {
            'type': 'object',
            'required': ['method'],
            'properties': {
              'method': {'type': 'string'},
              'params': {'type': 'object'}
            }
          }
        },
        {
          'name': 'sdk.version',
          'description': 'Get KDF version',
          'inputSchema': {'type': 'object', 'properties': {}}
        },
        {
          'name': 'assets.listAvailable',
          'description': 'List all available assets known to the SDK',
          'inputSchema': {'type': 'object', 'properties': {}}
        },
        {
          'name': 'assets.findByTicker',
          'description': 'Find assets by ticker/config id',
          'inputSchema': {
            'type': 'object',
            'required': ['ticker'],
            'properties': {'ticker': {'type': 'string'}}
          }
        },
        {
          'name': 'assets.activate',
          'description': 'Activate an asset by ticker/config id (streams suppressed; waits to complete)',
          'inputSchema': {
            'type': 'object',
            'required': ['ticker'],
            'properties': {'ticker': {'type': 'string'}}
          }
        },
        {
          'name': 'addresses.validate',
          'description': 'Validate an address for a given asset ticker',
          'inputSchema': {
            'type': 'object',
            'required': ['ticker', 'address'],
            'properties': {
              'ticker': {'type': 'string'},
              'address': {'type': 'string'}
            }
          }
        },
        {
          'name': 'auth.signIn',
          'description': 'Sign in to a wallet. Args: {walletName, password}',
          'inputSchema': {
            'type': 'object',
            'required': ['walletName', 'password'],
            'properties': {
              'walletName': {'type': 'string'},
              'password': {'type': 'string'}
            }
          }
        },
        {
          'name': 'auth.register',
          'description': 'Register a new wallet. Args: {walletName, password, mnemonic?}',
          'inputSchema': {
            'type': 'object',
            'required': ['walletName', 'password'],
            'properties': {
              'walletName': {'type': 'string'},
              'password': {'type': 'string'},
              'mnemonic': {'type': 'string'}
            }
          }
        },
        {
          'name': 'auth.currentUser',
          'description': 'Get current authenticated user if any',
          'inputSchema': {'type': 'object', 'properties': {}}
        },
      ]
    };
  }

  Future<Object?> _toolsCall(Object? params) async {
    if (params is! Map<String, Object?>) {
      throw JsonRpcError(-32602, 'Invalid params');
    }
    final name = params['name'];
    final arguments = params['arguments'];
    if (name is! String) {
      throw JsonRpcError(-32602, 'Invalid params: name');
    }

    switch (name) {
      case 'sdk.call':
        if (arguments is! Map<String, Object?>) {
          throw JsonRpcError(-32602, 'Invalid params: arguments');
        }
        final method = arguments['method'];
        final methodParams = (arguments['params'] as Map<String, Object?>?) ?? <String, Object?>{};
        if (method is! String) {
          throw JsonRpcError(-32602, 'Invalid params: method');
        }
        final request = <String, Object?>{'method': method, ...methodParams};
        final response = await _sdk.client.executeRpc(request);
        return {'content': [{'type': 'json', 'json': response}]};
      case 'sdk.version':
        final version = await _sdk.client.rpc.version();
        return {'content': [{'type': 'text', 'text': version ?? 'unknown'}]};
      case 'assets.listAvailable': {
        final assets = _sdk.assets.available.values
            .map((a) => a.toJson())
            .toList(growable: false);
        return {'content': [{'type': 'json', 'json': assets}]};
      }
      case 'assets.findByTicker': {
        if (arguments is! Map<String, Object?>) {
          throw JsonRpcError(-32602, 'Invalid params: arguments');
        }
        final ticker = arguments['ticker'];
        if (ticker is! String) {
          throw JsonRpcError(-32602, 'Invalid params: ticker');
        }
        final matches = _sdk.assets.findAssetsByConfigId(ticker)
            .map((a) => a.toJson())
            .toList(growable: false);
        return {'content': [{'type': 'json', 'json': matches}]};
      }
      case 'assets.activate': {
        if (arguments is! Map<String, Object?>) {
          throw JsonRpcError(-32602, 'Invalid params: arguments');
        }
        final ticker = arguments['ticker'];
        if (ticker is! String) {
          throw JsonRpcError(-32602, 'Invalid params: ticker');
        }
        final assets = _sdk.assets.findAssetsByConfigId(ticker).toList();
        if (assets.isEmpty) {
          throw JsonRpcError(-32602, 'Unknown asset ticker', {'ticker': ticker});
        }
        // Consume the activation stream until complete
        await _sdk.assets.activateAsset(assets.first).last;
        return {'content': [{'type': 'text', 'text': 'activated'}]};
      }
      case 'addresses.validate': {
        if (arguments is! Map<String, Object?>) {
          throw JsonRpcError(-32602, 'Invalid params: arguments');
        }
        final ticker = arguments['ticker'];
        final address = arguments['address'];
        if (ticker is! String || address is! String) {
          throw JsonRpcError(-32602, 'Invalid params: ticker/address');
        }
        final candidates = _sdk.assets.findAssetsByConfigId(ticker).toList();
        final asset = candidates.isEmpty ? null : candidates.first;
        if (asset == null) {
          throw JsonRpcError(-32602, 'Unknown asset ticker', {'ticker': ticker});
        }
        final validation = await _sdk.addresses.validateAddress(
          asset: asset,
          address: address,
        );
        final validationJson = {
          'isValid': validation.isValid,
          'address': validation.address,
          'asset': validation.asset.toJson(),
          if (validation.invalidReason != null)
            'invalidReason': validation.invalidReason,
        };
        return {'content': [{'type': 'json', 'json': validationJson}]};
      }
      case 'auth.signIn': {
        if (arguments is! Map<String, Object?>) {
          throw JsonRpcError(-32602, 'Invalid params: arguments');
        }
        final walletName = arguments['walletName'];
        final password = arguments['password'];
        if (walletName is! String || password is! String) {
          throw JsonRpcError(-32602, 'Invalid params: walletName/password');
        }
        final user = await _sdk.auth.signIn(walletName: walletName, password: password);
        return {'content': [{'type': 'json', 'json': user.toJson()}]};
      }
      case 'auth.register': {
        if (arguments is! Map<String, Object?>) {
          throw JsonRpcError(-32602, 'Invalid params: arguments');
        }
        final walletName = arguments['walletName'];
        final password = arguments['password'];
        final mnemonic = arguments['mnemonic'] as String?;
        if (walletName is! String || password is! String) {
          throw JsonRpcError(-32602, 'Invalid params: walletName/password');
        }
        final user = await _sdk.auth.register(
          walletName: walletName,
          password: password,
          mnemonic: mnemonic == null ? null : Mnemonic.fromPhrase(mnemonic),
        );
        return {'content': [{'type': 'json', 'json': user.toJson()}]};
      }
      case 'auth.currentUser': {
        final user = await _sdk.auth.currentUser;
        return {'content': [
          if (user == null)
            {'type': 'text', 'text': 'null'}
          else
            {'type': 'json', 'json': user.toJson()}
        ]};
      }
      default:
        throw JsonRpcError(-32601, 'Tool not found', {'name': name});
    }
  }

  Future<Object?> _resourcesList() async {
    return {'resources': []};
  }

  Future<Object?> _resourcesRead(Object? _params) async {
    throw JsonRpcError(-32601, 'No resources available');
  }

  Future<Object?> _promptsList() async {
    return {'prompts': []};
  }

  Future<Object?> _promptsGet(Object? _params) async {
    throw JsonRpcError(-32601, 'No prompts available');
  }
}

Future<int> _run(List<String> args) async {
  final parser = ArgParser()
    ..addOption('rpc-url', help: 'Remote RPC URL, e.g., http://localhost:7783')
    ..addOption('userpass', help: 'RPC password')
    ..addFlag('help', abbr: 'h', negatable: false);

  final results = parser.parse(args);
  if (results['help'] == true) {
    stdout.writeln('komodo_mcp_server [--rpc-url URL] [--userpass PASS]');
    return 0;
  }

  // Optionally we could pass RemoteConfig into SDK bootstrap in future.
  final server = KomodoMcpServer();
  final rpcServer = StdioJsonRpcServer(server.handle);
  await rpcServer.serve();
  return 0;
}

void main(List<String> args) {
  _run(args).then((code) => exit(code));
}