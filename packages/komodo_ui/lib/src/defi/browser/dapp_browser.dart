import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

/// A lightweight in-app browser widget that injects [EvmProvider]
/// and [KomodoProvider] into the WebView.
class DappBrowser extends StatefulWidget {
  const DappBrowser({
    required this.initialUrl,
    required this.evmProvider,
    required this.komodoProvider,
    super.key,
  });

  /// The initial URL to load.
  final String initialUrl;

  /// Provider used to handle `window.ethereum` requests.
  final EvmProvider evmProvider;

  /// Provider used to handle `window.komodo` requests.
  final KomodoProvider komodoProvider;

  @override
  State<DappBrowser> createState() => _DappBrowserState();
}

class _DappBrowserState extends State<DappBrowser> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(NavigationDelegate())
          ..loadRequest(Uri.parse(widget.initialUrl));
    _setupHandlers();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }

  Future<void> _setupHandlers() async {
    await _injectProviders();
    _controller.addJavaScriptChannel(
      'evmProvider',
      onMessageReceived: (message) async {
        final data = message.message;
        final map = Map<String, dynamic>.from(
          jsonDecode(data) as Map<String, dynamic>,
        );
        final result = await widget.evmProvider.request(
          method: map['method'] as String,
          params: map['params'],
        );
        _controller.runJavaScript(
          'window._resolveEvmRequest(${jsonEncode(result)})',
        );
      },
    );
    _controller.addJavaScriptChannel(
      'komodoProvider',
      onMessageReceived: (message) async {
        final data = message.message;
        final map = Map<String, dynamic>.from(
          jsonDecode(data) as Map<String, dynamic>,
        );
        final result = await widget.komodoProvider.request(
          method: map['method'] as String,
          params: map['params'],
        );
        _controller.runJavaScript(
          'window._resolveKomodoRequest(${jsonEncode(result)})',
        );
      },
    );
  }

  Future<void> _injectProviders() async {
    const js = '''
      window.ethereum = {
        request: function(args) {
          return new Promise((resolve) => {
            window._resolveEvmRequest = resolve;
            window.evmProvider.postMessage(JSON.stringify(args));
          });
        }
      };
      window.komodo = {
        request: function(args) {
          return new Promise((resolve) => {
            window._resolveKomodoRequest = resolve;
            window.komodoProvider.postMessage(JSON.stringify(args));
          });
        }
      };
    ''';
    await _controller.runJavaScript(js);
  }
}
