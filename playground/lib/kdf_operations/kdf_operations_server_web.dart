import 'dart:async';
import 'dart:convert';
import 'dart:io';
// this warning is pointless, since `web` and `js_interop` fail to compile on
// native platforms, so they aren't safe to import without conditional
// imports either (yet)
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
// ignore: depend_on_referenced_packages
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';

class KdfHttpServerOperations implements IKdfOperations {
  late HeadlessInAppWebView _webView;
  late HttpServer _server;
  bool _isInitialized = false;
  final void Function(String)? _logger;

  KdfHttpServerOperations(
    LocalConfig config, {
    void Function(String)? logCallback,
  }) : _logger = logCallback;

  @override
  String get operationsName => 'WASM HTTP Server Operations';

  @override
  Future<KdfStartupResult> kdfMain(JsonMap startParams, {int? logLevel}) async {
    await _ensureWebViewInitialized();
    final controller = _webView.webViewController;
    if (controller == null) {
      throw Exception('WebView controller is not available.');
    }

    final jsConfig = js_util.jsify({
      'conf': startParams,
      'log_level': logLevel ?? 3,
    });

    try {
      final result = await controller.evaluateJavascript(
        source: '''
          kdf.mm2_main(${jsonEncode(jsConfig)}).then((res) => window.postMessage(res));
        ''',
      );
      _logger?.call('kdfMain result: $result');
      return KdfStartupResult.ok;
    } catch (e) {
      _logger?.call('Error starting KDF: $e');
      return KdfStartupResult.invalidParams;
    }
  }

  @override
  Future<MainStatus> kdfMainStatus() async {
    await _ensureWebViewInitialized();
    final controller = _webView.webViewController;
    if (controller == null) {
      throw Exception('WebView controller is not available.');
    }

    final status = await controller.evaluateJavascript(
      source: 'kdf.mm2_main_status();',
    );
    return MainStatus.fromDefaultInt(int.parse(status.toString()));
  }

  @override
  Future<StopStatus> kdfStop() async {
    await _ensureWebViewInitialized();
    final controller = _webView.webViewController;
    if (controller == null) {
      throw Exception('WebView controller is not available.');
    }

    try {
      final result = await controller.evaluateJavascript(
        source: '''
          kdf.mm2_stop().then((res) => window.postMessage(res));
        ''',
      );
      return StopStatus.fromDefaultInt(int.parse(result.toString()));
    } catch (e) {
      _logger?.call('Error stopping KDF: $e');
      return StopStatus.errorStopping;
    }
  }

  @override
  Future<bool> isRunning() async {
    final status = await kdfMainStatus();
    return status == MainStatus.rpcIsUp;
  }

  @override
  Future<String?> version() async {
    await _ensureWebViewInitialized();
    final controller = _webView.webViewController;
    if (controller == null) {
      throw Exception('WebView controller is not available.');
    }

    final version = await controller.evaluateJavascript(
      source: 'kdf.version();',
    );
    return version?.toString();
  }

  @override
  Future<Map<String, dynamic>> mm2Rpc(Map<String, dynamic> request) async {
    await _ensureWebViewInitialized();
    final controller = _webView.webViewController;
    if (controller == null) {
      throw Exception('WebView controller is not available.');
    }

    try {
      final response = await controller.evaluateJavascript(
        source: '''
          kdf.mm2_rpc(${jsonEncode(request)}).then((res) => window.postMessage(JSON.stringify(res)));
        ''',
      );
      return jsonDecode(response.toString());
    } catch (e) {
      _logger?.call('Error calling mm2Rpc: $e');
      throw Exception('Error calling mm2Rpc: $e');
    }
  }

  @override
  Future<void> validateSetup() async {
    await _ensureWebViewInitialized();
    final controller = _webView.webViewController;
    if (controller != null) {
      await controller.evaluateJavascript(source: 'kdf.validateSetup();');
    } else {
      throw Exception('WebView controller is not available.');
    }
  }

  @override
  Future<bool> isAvailable(IKdfHostConfig hostConfig) async {
    try {
      await _ensureWebViewInitialized();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _ensureWebViewInitialized() async {
    if (_isInitialized) return;

    _webView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
        url: null,
      ),
      onWebViewCreated: (controller) async {
        await _injectLibrary(controller);
      },
    );

    await _webView.run();
    _isInitialized = true;

    await _startProxyServer();
  }

  Future<void> _injectLibrary(InAppWebViewController controller) async {
    try {
      // Load the JS file from assets
      String jsCode =
          await rootBundle.loadString('kdf/res/kdflib_bootstrapper.js');
      await controller.evaluateJavascript(source: jsCode);

      _logger?.call('KDF library injected successfully');
    } catch (e) {
      _logger?.call('Failed to inject the KDF library: $e');
      throw Exception('Failed to inject the KDF library: $e');
    }
  }

  Future<void> _startProxyServer() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    final handler = proxyHandler(Uri.parse('http://localhost:8080'));

    shelf_io.serve(handler, 'localhost', 8080);
    _logger?.call('HTTP server running at http://localhost:8080');
  }

  void dispose() {
    _webView.dispose();
    _server.close();
  }
}
