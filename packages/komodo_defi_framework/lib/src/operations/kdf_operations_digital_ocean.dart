import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_remote.dart';
import 'package:komodo_defi_framework/src/startup_config_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// NB: This class is not complete and may still need significant work.
/// The current approach of when to set vs when to get the RPC userpass
/// may be flawed.
class KdfOperationsDigitalOcean implements IKdfOperations {
  KdfOperationsDigitalOcean._({
    required void Function(String) logCallback,
    required IKdfStartupConfig configManager,
    required String apiToken,
    required String dropletRegion,
    required String dropletSize,
    required String? dropletId,
    required String? sshKeyId,
    required String image,
  })  : _logCallback = logCallback,
        _configManager = configManager,
        _apiToken = apiToken,
        _dropletId = dropletId,
        _dropletRegion = dropletRegion,
        _dropletSize = dropletSize,
        _sshKeyId = sshKeyId,
        _image = image;

  factory KdfOperationsDigitalOcean.create({
    required void Function(String) logCallback,
    required IKdfStartupConfig configManager,
    required DigitalOceanConfig config,
  }) {
    return KdfOperationsDigitalOcean._(
      logCallback: logCallback,
      configManager: configManager,
      apiToken: config.apiToken,
      dropletRegion: config.dropletRegion,
      dropletSize: config.dropletSize,
      dropletId: config.dropletId,
      sshKeyId: config.sshKeyId,
      image: config.image,
    );
  }
  final void Function(String) _logCallback;
  final IKdfStartupConfig _configManager;
  final String _apiToken;
  final String? _dropletId;
  final String _dropletRegion;
  final String _dropletSize;
  final String? _sshKeyId;
  final String _image;
  String? _dropletIp;
  String? userpass;

  void _log(String message) => _logCallback(message);

  @override
  String operationsName = 'DigitalOcean';

  Future<String?> _getDropletIp(String dropletId) async {
    final url = 'https://api.digitalocean.com/v2/droplets/$dropletId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_apiToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonFromString(response.body);
      return (data.value<JsonList?>('droplet', 'networks', 'v4')?.first
              as JsonMap?)
          ?.value<String>('ip_address');
    }

    _log('Failed to get droplet IP: ${response.body}');
    return null;
  }

  KdfOperationsRemote? get _remoteOperations =>
      [_dropletIp, _apiToken, userpass].contains(null)
          ? null
          : KdfOperationsRemote.create(
              logCallback: _log,
              configManager: _configManager,
              ipAddress: _dropletIp!,
              port: 7783,
              userpass: userpass!,
            );

  Future<void> _createDroplet() async {
    const url = 'https://api.digitalocean.com/v2/droplets';
    final body = json.encode({
      'name': 'komodo-defi-framework',
      'region': _dropletRegion,
      'size': _dropletSize,
      'image': _image,
      'ssh_keys': _sshKeyId != null ? [_sshKeyId] : [],
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_apiToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 202) {
      final data = json.decode(response.body);
      _log('Droplet created with ID: ${data.value('droplet', 'id')}');
      _dropletIp =
          await _getDropletIp(data.value<String>('droplet', 'id').toString());
    } else {
      _log('Failed to create droplet: ${response.body}');
      throw Exception('Failed to create droplet');
    }
  }

  Future<void> _destroyDroplet() async {
    if (_dropletId == null) return;

    final url = 'https://api.digitalocean.com/v2/droplets/$_dropletId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_apiToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 204) {
      _log('Droplet $_dropletId destroyed.');
    } else {
      _log('Failed to destroy droplet: ${response.body}');
    }
  }

  Future<void> _runDockerContainer() async {
    if (_dropletIp == null) {
      throw Exception('Droplet IP not found, cannot run Docker container.');
    }

    final url = 'https://api.digitalocean.com/v2/droplets/$_dropletId/actions';
    final body = json.encode({
      'type': 'run_command',
      'command':
          'docker run -d -p 7783:7783 komodoofficial/komodo-defi-framework',
      'user': 'root',
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_apiToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 202) {
      _log('Failed to run Docker container: ${response.body}');
      throw Exception('Failed to run Docker container');
    }

    _log('Docker container started successfully.');
  }

  @override
  Future<KdfStartupResult> kdfMain(String passphrase) async {
    await _createDroplet();
    if (_dropletIp != null) {
      await _runDockerContainer();
      return KdfStartupResult.ok;
    }
    return KdfStartupResult.invalidParams;
  }

  @override
  Future<MainStatus> kdfMainStatus() async {
    if (_dropletIp == null) {
      return MainStatus.notRunning;
    }
    final version = await this.version();
    return version != null ? MainStatus.rpcIsUp : MainStatus.noRpc;
  }

  @override
  Future<StopStatus> kdfStop() async {
    await _destroyDroplet();
    return StopStatus.ok;
  }

  @override
  Future<bool> isRunning() async {
    return await kdfMainStatus() == MainStatus.rpcIsUp;
  }

  @override
  Future<String?> version() async {
    if (_dropletIp == null) return null;

    final url = 'http://$_dropletIp:7783';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'method': 'version',
        'userpass': 'RPC_UserP@SSW0RD',
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonFromString(response.body);
      return result.value<String?>('result');
    }

    return null;
  }

  @override
  Future<Map<String, dynamic>> mm2Rpc(Map<String, dynamic> request) async {
    if (_dropletIp == null) {
      throw Exception('KDF API is not running.');
    }

    final url = 'http://$_dropletIp:7783';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
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
      throw Exception('Failed to validate DigitalOcean KDF setup');
    }
  }
}
