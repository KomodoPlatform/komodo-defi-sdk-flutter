import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:mcp_dart/mcp_dart.dart' as mcp;

class KomodoMcpApp extends StatefulWidget {
  const KomodoMcpApp({super.key});

  @override
  State<KomodoMcpApp> createState() => _KomodoMcpAppState();
}

class _KomodoMcpAppState extends State<KomodoMcpApp> {
  bool running = false;
  String hostIp = '127.0.0.1';
  String hostPort = '7783';
  String rpcPass = '';
  bool https = false;
  String status = 'Idle';

  KomodoDefiSdk? _sdk;
  mcp.McpServer? _server;
  mcp.Transport? _transport;
  StreamSubscription? _logSub;

  Future<void> _start() async {
    if (running) return;
    setState(() => status = 'Starting...');

    // Initialize SDK with chosen host
    _sdk?.dispose();
    _sdk = KomodoDefiSdk(
      host: RemoteConfig(
        ipAddress: hostIp,
        port: int.tryParse(hostPort) ?? 7783,
        rpcPassword: rpcPass,
        https: https,
      ),
    );
    await _sdk!.initialize();

    // Create MCP server and register a simple health tool
    _server = mcp.McpServer(
      const mcp.Implementation(name: 'komodo-mcp', version: '0.1.0'),
      options: const mcp.ServerOptions(
        capabilities: mcp.ServerCapabilities(
          tools: mcp.ServerCapabilitiesTools(),
        ),
      ),
    );

    _server!.tool(
      'health.ping',
      description: 'Ping the server',
      toolInputSchema: const mcp.ToolInputSchema(properties: {}),
      callback: ({args, extra}) async => mcp.CallToolResult(
        content: const [mcp.TextContent(text: 'pong')],
      ),
    );

    // UI demo transport: no stdio here; keep server idle for external transports
    // In a real app, you could add SSE/HTTP or platform channel transport.

    setState(() {
      running = true;
      status = 'Running (SDK initialized)';
    });
  }

  Future<void> _stop() async {
    if (!running) return;
    setState(() => status = 'Stopping...');
    await _transport?.close();
    _transport = null;
    _server = null;
    await _sdk?.dispose();
    _sdk = null;
    await _logSub?.cancel();
    _logSub = null;
    setState(() {
      running = false;
      status = 'Stopped';
    });
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Komodo MCP Server')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: $status'),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Host IP'),
                controller: TextEditingController(text: hostIp),
                onChanged: (v) => hostIp = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Port'),
                controller: TextEditingController(text: hostPort),
                keyboardType: TextInputType.number,
                onChanged: (v) => hostPort = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'RPC Password'),
                controller: TextEditingController(text: rpcPass),
                obscureText: true,
                onChanged: (v) => rpcPass = v,
              ),
              Row(
                children: [
                  Checkbox(
                      value: https,
                      onChanged: (v) => setState(() => https = v ?? false)),
                  const Text('HTTPS')
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: running ? null : _start,
                      child: const Text('Start')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                      onPressed: running ? _stop : null,
                      child: const Text('Stop')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
