// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:komodo_defi_framework/src/config/kdf_config.dart';
// import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
// import 'package:komodo_defi_framework/src/operations/kdf_operations_remote.dart';
// import 'package:komodo_defi_types/komodo_defi_types.dart';

// class KdfOperationsDigitalOcean implements IKdfOperations {
//   KdfOperationsDigitalOcean._({
//     required void Function(String) logCallback,
//     required DigitalOceanConfig config,
//   })  : _logCallback = logCallback,
//         _config = config;

//   factory KdfOperationsDigitalOcean.create({
//     required void Function(String) logCallback,
//     required DigitalOceanConfig config,
//   }) {
//     return KdfOperationsDigitalOcean._(
//       logCallback: logCallback,
//       config: config,
//     );
//   }

//   final void Function(String) _logCallback;
//   final DigitalOceanConfig _config;
//   String? _dropletIp;

//   void _log(String message) => _logCallback(message);

//   @override
//   String operationsName = 'DigitalOcean';

//   Future<String?> _getDropletIp(String dropletId) async {
//     final url = 'https://api.digitalocean.com/v2/droplets/$dropletId';
//     final response = await http.get(
//       Uri.parse(url),
//       headers: {
//         'Authorization': 'Bearer ${_config.apiToken}',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = jsonFromString(response.body);
//       return (data.value<JsonList?>('droplet', 'networks', 'v4')?.first
//               as JsonMap?)
//           ?.value<String>('ip_address');
//     }

//     _log('Failed to get droplet IP: ${response.body}');
//     return null;
//   }

//   KdfOperationsRemote? get _remoteOperations => _dropletIp == null
//       ? null
//       : KdfOperationsRemote.create(
//           logCallback: _log,
//           userpass: _config.rpcPassword,
//           ipAddress: _dropletIp!,
//           port: 7783,
//         );

//   Future<void> _createDroplet() async {
//     const url = 'https://api.digitalocean.com/v2/droplets';
//     final body = json.encode({
//       'name': 'komodo-defi-framework',
//       'region': _config.dropletRegion,
//       'size': _config.dropletSize,
//       'image': _config.image,
//       'ssh_keys': _config.sshKeyId != null ? [_config.sshKeyId] : [],
//     });

//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Authorization': 'Bearer ${_config.apiToken}',
//         'Content-Type': 'application/json',
//       },
//       body: body,
//     );

//     if (response.statusCode == 202) {
//       final data = json.decode(response.body);
//       _log('Droplet created with ID: ${data.value('droplet', 'id')}');
//       _dropletIp =
//           await _getDropletIp(data.value<String>('droplet', 'id').toString());
//     } else {
//       _log('Failed to create droplet: ${response.body}');
//       throw Exception('Failed to create droplet');
//     }
//   }

//   Future<void> _destroyDroplet() async {
//     if (_config.dropletId == null) return;

//     final url = 'https://api.digitalocean.com/v2/droplets/${_config.dropletId}';
//     final response = await http.delete(
//       Uri.parse(url),
//       headers: {
//         'Authorization': 'Bearer ${_config.apiToken}',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 204) {
//       _log('Droplet ${_config.dropletId} destroyed.');
//     } else {
//       _log('Failed to destroy droplet: ${response.body}');
//     }
//   }

//   Future<void> _runDockerContainer(String startParamsJson) async {
//     if (_dropletIp == null) {
//       throw Exception('Droplet IP not found, cannot run Docker container.');
//     }

//     final url =
//         'https://api.digitalocean.com/v2/droplets/${_config.dropletId}/actions';
//     final body = json.encode({
//       'type': 'run_command',
//       'command':
//           'docker run -d -p 7783:7783 -e MM2_JSON=\'$startParamsJson\' komodoofficial/komodo-defi-framework',
//       'user': 'root',
//     });

//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Authorization': 'Bearer ${_config.apiToken}',
//         'Content-Type': 'application/json',
//       },
//       body: body,
//     );

//     if (response.statusCode != 202) {
//       _log('Failed to run Docker container: ${response.body}');
//       throw Exception('Failed to run Docker container');
//     }

//     _log('Docker container started successfully.');
//   }

//   @override
//   Future<KdfStartupResult> kdfMain(String startParamsJson) async {
//     await _createDroplet();
//     if (_dropletIp != null) {
//       await _runDockerContainer(startParamsJson);
//       return KdfStartupResult.ok;
//     }
//     return KdfStartupResult.invalidParams;
//   }

//   @override
//   Future<MainStatus> kdfMainStatus() async {
//     if (_dropletIp == null) {
//       return MainStatus.notRunning;
//     }
//     final version = await this.version();
//     return version != null ? MainStatus.rpcIsUp : MainStatus.noRpc;
//   }

//   @override
//   Future<StopStatus> kdfStop() async {
//     await _destroyDroplet();
//     return StopStatus.ok;
//   }

//   @override
//   Future<bool> isRunning() async {
//     return await kdfMainStatus() == MainStatus.rpcIsUp;
//   }

//   @override
//   Future<String?> version() async {
//     return _remoteOperations?.version();
//   }

//   @override
//   Future<Map<String, dynamic>> mm2Rpc(Map<String, dynamic> request) async {
//     if (_dropletIp == null) {
//       throw Exception('KDF API is not running.');
//     }

//     return _remoteOperations!.mm2Rpc(request);
//   }

//   @override
//   Future<void> validateSetup() async {
//     final version = await this.version();
//     if (version == null) {
//       throw Exception('Failed to validate DigitalOcean KDF setup');
//     }
//   }
// }
