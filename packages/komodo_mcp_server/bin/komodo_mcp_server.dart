import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart'
    show KeyExportMode;
import 'package:decimal/decimal.dart';
import 'package:mcp_dart/mcp_dart.dart' as mcp;

// This entry can run as a stdio server if Flutter environment supports running Dart entrypoints.
// For full support, use the Flutter app main in lib/app.dart which embeds the server with UI.

class KomodoMcpServer {
  KomodoMcpServer();

  KomodoDefiSdk _sdk = KomodoDefiSdk();
  bool _initialized = false;

  Future<void> initialize([Map<String, Object?>? params]) async {
    if (_initialized) return;
    if (params != null) {
      final host = params['host'];
      if (host is Map<String, Object?> && host['type'] == 'remote') {
        final ip = host['ip'] as String?;
        final port = (host['port'] as num?)?.toInt();
        final https = host['https'] as bool? ?? false;
        final userpass = host['userpass'] as String?;
        if (ip != null && port != null && userpass != null) {
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

  // Tool implementations are invoked by MCP tool callbacks
  Future<mcp.CallToolResult> callTool(
      String name, Map<String, Object?> args) async {
    switch (name) {
      case 'sdk.call':
        {
          final method = args['method'] as String?;
          final methodParams =
              (args['params'] as Map<String, Object?>?) ?? <String, Object?>{};
          if (method == null) throw ArgumentError('method required');
          final request = <String, Object?>{'method': method, ...methodParams};
          final response = await _sdk.client.executeRpc(request);
          return mcp.CallToolResult(
            content: [mcp.TextContent(text: jsonEncode(response))],
          );
        }
      case 'sdk.version':
        {
          // Call version directly over RPC
          String version = 'unknown';
          try {
            final res = await _sdk.client.executeRpc({'method': 'version'});
            version = (res['result'] as String?) ?? 'unknown';
          } catch (_) {}
          return mcp.CallToolResult(content: [mcp.TextContent(text: version)]);
        }
      case 'auth.signIn':
        {
          final walletName = args['walletName'] as String?;
          final password = args['password'] as String?;
          if (walletName == null || password == null)
            throw ArgumentError('walletName/password required');
          final user = await _sdk.auth
              .signIn(walletName: walletName, password: password);
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(user.toJson()))]);
        }
      case 'auth.register':
        {
          final walletName = args['walletName'] as String?;
          final password = args['password'] as String?;
          final mnemonic = args['mnemonic'] as String?;
          if (walletName == null || password == null)
            throw ArgumentError('walletName/password required');
          final user = await _sdk.auth.register(
            walletName: walletName,
            password: password,
            mnemonic: mnemonic == null ? null : Mnemonic.plaintext(mnemonic),
          );
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(user.toJson()))]);
        }
      case 'auth.currentUser':
        {
          final user = await _sdk.auth.currentUser;
          return mcp.CallToolResult(
            content: [
              user == null
                  ? const mcp.TextContent(text: 'null')
                  : mcp.TextContent(text: jsonEncode(user.toJson())),
            ],
          );
        }
      case 'auth.signOut':
        {
          await _sdk.auth.signOut();
          return mcp.CallToolResult(
              content: const [mcp.TextContent(text: 'signed out')]);
        }
      case 'auth.users':
        {
          final users = await _sdk.auth.getUsers();
          return mcp.CallToolResult(
            content: [
              mcp.TextContent(
                  text: jsonEncode(users.map((u) => u.toJson()).toList()))
            ],
          );
        }
      case 'assets.listAvailable':
        {
          final assets = _sdk.assets.available.values
              .map((a) => a.toJson())
              .toList(growable: false);
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(assets))]);
        }
      case 'assets.findByTicker':
        {
          final ticker = args['ticker'] as String?;
          if (ticker == null) throw ArgumentError('ticker required');
          final matches = _sdk.assets
              .findAssetsByConfigId(ticker)
              .map((a) => a.toJson())
              .toList(growable: false);
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(matches))]);
        }
      case 'assets.activate':
        {
          final ticker = args['ticker'] as String?;
          if (ticker == null) throw ArgumentError('ticker required');
          final assets = _sdk.assets.findAssetsByConfigId(ticker).toList();
          if (assets.isEmpty) throw ArgumentError('Unknown asset ticker');
          await _sdk.assets.activateAsset(assets.first).last;
          return mcp.CallToolResult(
              content: const [mcp.TextContent(text: 'activated')]);
        }
      case 'assets.enabledTickers':
        {
          final tickers = await _sdk.assets.getEnabledCoins();
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(tickers.toList()))]);
        }
      case 'pubkeys.get':
        {
          final ticker = args['ticker'] as String?;
          if (ticker == null) throw ArgumentError('ticker required');
          final candidates = _sdk.assets.findAssetsByConfigId(ticker).toList();
          if (candidates.isEmpty) throw ArgumentError('Unknown asset ticker');
          final pubkeys = await _sdk.pubkeys.getPubkeys(candidates.first);
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(pubkeys.toJson()))]);
        }
      case 'pubkeys.new':
        {
          final ticker = args['ticker'] as String?;
          if (ticker == null) throw ArgumentError('ticker required');
          final candidates = _sdk.assets.findAssetsByConfigId(ticker).toList();
          if (candidates.isEmpty) throw ArgumentError('Unknown asset ticker');
          final newKey = await _sdk.pubkeys.createNewPubkey(candidates.first);
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(newKey.toJson()))]);
        }
      case 'addresses.validate':
        {
          final ticker = args['ticker'] as String?;
          final address = args['address'] as String?;
          if (ticker == null || address == null)
            throw ArgumentError('ticker/address required');
          final candidates = _sdk.assets.findAssetsByConfigId(ticker).toList();
          if (candidates.isEmpty) throw ArgumentError('Unknown asset ticker');
          final validation = await _sdk.addresses
              .validateAddress(asset: candidates.first, address: address);
          final validationJson = {
            'isValid': validation.isValid,
            'address': validation.address,
            'asset': validation.asset.toJson(),
            if (validation.invalidReason != null)
              'invalidReason': validation.invalidReason,
          };
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(validationJson))]);
        }
      case 'balances.get':
        {
          final ticker = args['ticker'] as String?;
          if (ticker == null) throw ArgumentError('ticker required');
          final candidates = _sdk.assets.findAssetsByConfigId(ticker).toList();
          if (candidates.isEmpty) throw ArgumentError('Unknown asset ticker');
          final bal = await _sdk.balances.getBalance(candidates.first.id);
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(bal.toJson()))]);
        }
      case 'tx.history':
        {
          final ticker = args['ticker'] as String?;
          final pageNumber = (args['pageNumber'] as num?)?.toInt();
          final itemsPerPage = (args['itemsPerPage'] as num?)?.toInt();
          if (ticker == null) throw ArgumentError('ticker required');
          final candidates = _sdk.assets.findAssetsByConfigId(ticker).toList();
          if (candidates.isEmpty) throw ArgumentError('Unknown asset ticker');
          final page = await _sdk.transactions.getTransactionHistory(
            candidates.first,
            pagination: pageNumber != null && itemsPerPage != null
                ? PagePagination(
                    pageNumber: pageNumber, itemsPerPage: itemsPerPage)
                : null,
          );
          final jsonObj = {
            'transactions': page.transactions.map((t) => t.toJson()).toList(),
            'total': page.total,
            'nextPageId': page.nextPageId,
            'currentPage': page.currentPage,
            'totalPages': page.totalPages,
          };
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(jsonObj))]);
        }
      case 'signing.signMessage':
        {
          final coin = args['coin'] as String?;
          final message = args['message'] as String?;
          final address = args['address'] as String?;
          if (coin == null || message == null || address == null) {
            throw ArgumentError('coin/message/address required');
          }
          final sig = await _sdk.messageSigning
              .signMessage(coin: coin, message: message, address: address);
          return mcp.CallToolResult(content: [mcp.TextContent(text: sig)]);
        }
      case 'signing.verifyMessage':
        {
          final coin = args['coin'] as String?;
          final message = args['message'] as String?;
          final signature = args['signature'] as String?;
          final address = args['address'] as String?;
          if (coin == null ||
              message == null ||
              signature == null ||
              address == null) {
            throw ArgumentError('coin/message/signature/address required');
          }
          final ok = await _sdk.messageSigning.verifyMessage(
              coin: coin,
              message: message,
              signature: signature,
              address: address);
          return mcp.CallToolResult(content: [
            mcp.TextContent(text: jsonEncode({'valid': ok}))
          ]);
        }
      case 'security.getPrivateKeys':
        {
          final tickers = (args['tickers'] as List?)?.cast<String>();
          final modeStr = args['mode'] as String?;
          final startIndex = (args['startIndex'] as num?)?.toInt();
          final endIndex = (args['endIndex'] as num?)?.toInt();
          final accountIndex = (args['accountIndex'] as num?)?.toInt();
          final ids = tickers == null
              ? null
              : tickers
                  .expand((t) =>
                      _sdk.assets.findAssetsByConfigId(t).map((a) => a.id))
                  .toList();
          final mode = modeStr == null
              ? null
              : (modeStr.toLowerCase() == 'hd'
                  ? KeyExportMode.hd
                  : KeyExportMode.iguana);
          final result = await _sdk.security.getPrivateKeys(
            assets: ids,
            mode: mode,
            startIndex: startIndex,
            endIndex: endIndex,
            accountIndex: accountIndex,
          );
          final jsonMap = result.map((k, v) =>
              MapEntry(k.toJson(), v.map((e) => e.toJson()).toList()));
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(jsonMap))]);
        }
      case 'market.price':
        {
          final ticker = args['ticker'] as String?;
          final dateMs = (args['dateMs'] as num?)?.toInt();
          final fiatCurrency = (args['fiatCurrency'] as String?) ?? 'usdt';
          if (ticker == null) throw ArgumentError('ticker required');
          final candidates = _sdk.assets.findAssetsByConfigId(ticker).toList();
          if (candidates.isEmpty) throw ArgumentError('Unknown asset ticker');
          final date = dateMs == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(dateMs);
          final price = await _sdk.marketData.fiatPrice(candidates.first.id,
              priceDate: date, fiatCurrency: fiatCurrency);
          return mcp.CallToolResult(content: [
            mcp.TextContent(text: jsonEncode({'price': price.toString()}))
          ]);
        }
      case 'fees.utxoEstimate':
        {
          final ticker = args['ticker'] as String?;
          if (ticker == null) throw ArgumentError('ticker required');
          final est = await _sdk.fees.getUtxoEstimatedFee(ticker);
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(est.toJson()))]);
        }
      case 'fees.ethEstimate':
        {
          final ticker = args['ticker'] as String?;
          if (ticker == null) throw ArgumentError('ticker required');
          final est = await _sdk.fees.getEthEstimatedFeePerGas(ticker);
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(est.toJson()))]);
        }
      case 'withdraw.preview':
        {
          final ticker = args['ticker'] as String?;
          final toAddress = args['toAddress'] as String?;
          final amountStr = args['amount'] as String?;
          if (ticker == null || toAddress == null || amountStr == null) {
            throw ArgumentError('ticker/toAddress/amount required');
          }
          final params = WithdrawParameters(
              asset: ticker,
              toAddress: toAddress,
              amount: Decimal.parse(amountStr));
          final preview = await _sdk.withdrawals.previewWithdrawal(params);
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(preview.toJson()))]);
        }
      case 'withdraw.execute':
        {
          final ticker = args['ticker'] as String?;
          final toAddress = args['toAddress'] as String?;
          final amountStr = args['amount'] as String?;
          final feePriorityStr = args['feePriority'] as String?;
          if (ticker == null || toAddress == null || amountStr == null) {
            throw ArgumentError('ticker/toAddress/amount required');
          }
          final feePriority = feePriorityStr == null
              ? null
              : switch (feePriorityStr.toLowerCase()) {
                  'low' => WithdrawalFeeLevel.low,
                  'medium' => WithdrawalFeeLevel.medium,
                  'high' => WithdrawalFeeLevel.high,
                  _ => null,
                };
          final paramsW = WithdrawParameters(
            asset: ticker,
            toAddress: toAddress,
            amount: Decimal.parse(amountStr),
            feePriority: feePriority,
          );
          WithdrawalProgress? last;
          await for (final p in _sdk.withdrawals.withdraw(paramsW)) {
            last = p;
          }
          final jsonObj = {
            'status': last?.status.toString(),
            'message': last?.message,
            if (last?.withdrawalResult != null)
              'result': {
                'txHash': last!.withdrawalResult!.txHash,
                'balanceChanges':
                    last.withdrawalResult!.balanceChanges.toJson(),
                'coin': last.withdrawalResult!.coin,
                'toAddress': last.withdrawalResult!.toAddress,
                'fee': last.withdrawalResult!.fee.toJson(),
                'kmdRewardsEligible': last.withdrawalResult!.kmdRewardsEligible,
              },
            if (last?.errorCode != null)
              'errorCode': last!.errorCode.toString(),
            if (last?.errorMessage != null) 'errorMessage': last!.errorMessage,
            if (last?.taskId != null) 'taskId': last!.taskId,
          };
          return mcp.CallToolResult(
              content: [mcp.TextContent(text: jsonEncode(jsonObj))]);
        }
      default:
        throw ArgumentError('Unknown tool: $name');
    }
  }
}

Future<int> _run(List<String> args) async {
  final parser = ArgParser()
    ..addFlag('stdio', help: 'Run as stdio MCP server', defaultsTo: true)
    ..addFlag('help', abbr: 'h', negatable: false);

  final results = parser.parse(args);
  if (results['help'] == true) {
    stdout.writeln('komodo_mcp_server [--stdio]');
    return 0;
  }

  final server = KomodoMcpServer();
  await server.initialize();

  // Build mcp_dart server
  final mcpServer = mcp.McpServer(
    const mcp.Implementation(name: 'komodo-mcp', version: '0.1.0'),
    options: const mcp.ServerOptions(
      capabilities: mcp.ServerCapabilities(
        tools: mcp.ServerCapabilitiesTools(),
      ),
    ),
  );

  // Register tools
  void registerTool(
      String name, String description, Map<String, Object?> schema) {
    mcpServer.tool(
      name,
      description: description,
      toolInputSchema: mcp.ToolInputSchema(
          properties: schema['properties'] as Map<String, dynamic>?),
      callback: ({args, extra}) async =>
          server.callTool(name, Map<String, Object?>.from(args ?? {})),
    );
  }

  // Define schemas and register (same list as tools/list)
  registerTool('sdk.call', 'Call raw KDF method', {
    'type': 'object',
    'required': ['method'],
    'properties': {
      'method': {'type': 'string'},
      'params': {'type': 'object'}
    },
  });
  registerTool(
      'sdk.version', 'Get KDF version', {'type': 'object', 'properties': {}});

  registerTool('auth.signIn', 'Sign in', {
    'type': 'object',
    'required': ['walletName', 'password'],
    'properties': {
      'walletName': {'type': 'string'},
      'password': {'type': 'string'}
    },
  });
  registerTool('auth.register', 'Register', {
    'type': 'object',
    'required': ['walletName', 'password'],
    'properties': {
      'walletName': {'type': 'string'},
      'password': {'type': 'string'},
      'mnemonic': {'type': 'string'}
    },
  });
  registerTool('auth.currentUser', 'Get current user',
      {'type': 'object', 'properties': {}});
  registerTool(
      'auth.signOut', 'Sign out', {'type': 'object', 'properties': {}});
  registerTool(
      'auth.users', 'List users', {'type': 'object', 'properties': {}});

  registerTool('assets.listAvailable', 'List assets',
      {'type': 'object', 'properties': {}});
  registerTool('assets.findByTicker', 'Find assets by ticker', {
    'type': 'object',
    'required': ['ticker'],
    'properties': {
      'ticker': {'type': 'string'}
    },
  });
  registerTool('assets.activate', 'Activate asset', {
    'type': 'object',
    'required': ['ticker'],
    'properties': {
      'ticker': {'type': 'string'}
    },
  });
  registerTool('assets.enabledTickers', 'Enabled tickers',
      {'type': 'object', 'properties': {}});

  registerTool('pubkeys.get', 'Get pubkeys', {
    'type': 'object',
    'required': ['ticker'],
    'properties': {
      'ticker': {'type': 'string'}
    },
  });
  registerTool('pubkeys.new', 'Create new pubkey', {
    'type': 'object',
    'required': ['ticker'],
    'properties': {
      'ticker': {'type': 'string'}
    },
  });
  registerTool('addresses.validate', 'Validate address', {
    'type': 'object',
    'required': ['ticker', 'address'],
    'properties': {
      'ticker': {'type': 'string'},
      'address': {'type': 'string'}
    },
  });

  registerTool('balances.get', 'Get balance', {
    'type': 'object',
    'required': ['ticker'],
    'properties': {
      'ticker': {'type': 'string'}
    },
  });

  registerTool('tx.history', 'Get transaction history', {
    'type': 'object',
    'required': ['ticker'],
    'properties': {
      'ticker': {'type': 'string'},
      'pageNumber': {'type': 'integer'},
      'itemsPerPage': {'type': 'integer'}
    },
  });

  registerTool('signing.signMessage', 'Sign message', {
    'type': 'object',
    'required': ['coin', 'message', 'address'],
    'properties': {
      'coin': {'type': 'string'},
      'message': {'type': 'string'},
      'address': {'type': 'string'}
    },
  });
  registerTool('signing.verifyMessage', 'Verify message', {
    'type': 'object',
    'required': ['coin', 'message', 'signature', 'address'],
    'properties': {
      'coin': {'type': 'string'},
      'message': {'type': 'string'},
      'signature': {'type': 'string'},
      'address': {'type': 'string'}
    },
  });

  registerTool('security.getPrivateKeys', 'Export private keys', {
    'type': 'object',
    'properties': {
      'tickers': {
        'type': 'array',
        'items': {'type': 'string'}
      },
      'mode': {
        'type': 'string',
        'enum': ['hd', 'iguana']
      },
      'startIndex': {'type': 'integer'},
      'endIndex': {'type': 'integer'},
      'accountIndex': {'type': 'integer'}
    },
  });

  registerTool('market.price', 'Get fiat price', {
    'type': 'object',
    'required': ['ticker'],
    'properties': {
      'ticker': {'type': 'string'},
      'fiatCurrency': {'type': 'string'},
      'dateMs': {'type': 'integer'}
    },
  });

  registerTool('fees.utxoEstimate', 'Get UTXO fee estimates', {
    'type': 'object',
    'required': ['ticker'],
    'properties': {
      'ticker': {'type': 'string'}
    },
  });
  registerTool('fees.ethEstimate', 'Get ETH gas estimates', {
    'type': 'object',
    'required': ['ticker'],
    'properties': {
      'ticker': {'type': 'string'}
    },
  });

  registerTool('withdraw.preview', 'Preview withdrawal', {
    'type': 'object',
    'required': ['ticker', 'toAddress', 'amount'],
    'properties': {
      'ticker': {'type': 'string'},
      'toAddress': {'type': 'string'},
      'amount': {'type': 'string'}
    },
  });
  registerTool('withdraw.execute', 'Execute withdrawal', {
    'type': 'object',
    'required': ['ticker', 'toAddress', 'amount'],
    'properties': {
      'ticker': {'type': 'string'},
      'toAddress': {'type': 'string'},
      'amount': {'type': 'string'},
      'feePriority': {
        'type': 'string',
        'enum': ['low', 'medium', 'high']
      }
    },
  });

  // Start stdio transport
  final transport = mcp.StdioServerTransport(stdin: stdin, stdout: stdout);
  await mcpServer.connect(transport);
  return 0;
}

void main(List<String> args) {
  _run(args).then((code) => exit(code));
}
