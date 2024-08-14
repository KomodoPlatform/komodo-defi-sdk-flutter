import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
import 'package:komodo_defi_framework/src/startup_config_manager.dart';

class KdfOperationsRemote implements IKdfOperations {
  factory KdfOperationsRemote.create({
    required void Function(String) logCallback,
    required IKdfStartupConfig configManager,
    required String ipAddress,
    required int port,
    required String userpass,
  }) {
    return KdfOperationsRemote._(
      logCallback,
      configManager,
      ipAddress,
      port,
      userpass,
    );
  }

  KdfOperationsRemote._(
    this._logCallback,
    this._configManager,
    this._ipAddress,
    this._port,
    this._userpass,
  );
  final void Function(String) _logCallback;
  final IKdfStartupConfig _configManager;
  final String _ipAddress;
  final int _port;
  final String _userpass;

// If IP address does not have a protocol, it will default to http
// TODO: Clean up
  // Uri get _baseUrl => _safeRpcUrl(_ipAddress, _port);
  Uri get _baseUrl => Uri.parse(
        _ipAddress.contains('http')
            ? '$_ipAddress:$_port'
            : 'http://$_ipAddress:$_port',
      );

  static const String _forwardProxy = 'https://209.38.97.255/?target=';

  Uri _safeRpcUrl(String host, int port) {
    var url = Uri.parse('$host:$port');
    // If the scheme is not provided, default to http
    url = url.scheme.isEmpty ? url.replace(scheme: 'http') : url;

    if (!kIsWeb) {
      return url;
    }

    // If on the web, check if the cors preflight succeeds
    // TODO:

    // If the cors preflight fails, return a url that will be proxied by the
    // forward proxy 134.122.60.102
    // TODO:

    return Uri.parse('$_forwardProxy$url');
  }

  void _log(String message) => _logCallback(message);

  @override
  Future<bool> isRunning() async {
    return await kdfMainStatus() == MainStatus.rpcIsUp;
  }

  @override
  Future<KdfStartupResult> kdfMain(String passphrase) async {
    const message = 'KDF cannot be started using Remote client. '
        'Please start the KDF on the remote server manually.';
    _log(message);
    // return KdfStartupResult.invalidParams;
    throw Exception(message);
  }

  @override
  Future<MainStatus> kdfMainStatus() async {
    final versionResult = await version();
    return versionResult != null ? MainStatus.rpcIsUp : MainStatus.noRpc;
  }

  @override
  Future<StopStatus> kdfStop() async {
    // _log('kdfStop is not supported in remote mode.');
    // return StopStatus.notRunning;

    try {
      final stopResultResponse = await mm2Rpc({
        'method': 'stop',
      });

      _log('stopResultResponse: $stopResultResponse');

      return _parseStopResult(stopResultResponse);
    } on Exception catch (e) {
      _log('Error stopping KDF: $e');
      return StopStatus.errorStopping;
    }
  }

  // Could be shared with other implementations?
  StopStatus _parseStopResult(dynamic stopResponse) {
    if (stopResponse['error'] != null) {
      return StopStatus.errorStopping;
    }

    switch (stopResponse['result']) {
      case 'already_stopped':
        return StopStatus.stoppingAlready;
      case 'success':
        return StopStatus.ok;
      default:
        final maybeResultCode = stopResponse is int?
            ? stopResponse
            : int.tryParse(stopResponse.toString());

        return maybeResultCode != null
            ? StopStatus.fromDefaultInt(maybeResultCode)
            : StopStatus.errorStopping;
    }
  }

  @override
  Future<Map<String, dynamic>> mm2Rpc(Map<String, dynamic> request) async {
    request['userpass'] = _userpass;

    final response = await http.post(
      _baseUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(request),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to perform RPC call');
    }
  }

  @override
  Future<void> validateSetup() async {
    final version = await this.version();
    if (version == null) {
      throw Exception('Failed to validate remote KDF setup');
    }
  }

  @override
  Future<String?> version() async {
    final response = await http.post(
      _baseUrl,
      headers: {
        'Content-Type': 'application/json',
        // 'Access-Control-Allow-Origin': '*',
      },
      body: json.encode({
        'method': 'version',
        'userpass': _userpass,
      }),
    );

    if (response.statusCode == 200) {
      final result =
          (json.decode(response.body) as Map).cast<String, dynamic>();
      return result['result'] as String?;
    }

    return null;
  }
}
