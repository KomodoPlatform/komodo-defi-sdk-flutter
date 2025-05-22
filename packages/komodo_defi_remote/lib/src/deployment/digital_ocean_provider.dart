import 'dart:convert';

import 'package:http/http.dart' as http;

import 'remote_deployment_manager.dart';

/// Server provider that uses the DigitalOcean API to provision droplets.
class DigitalOceanServerProvider implements IServerProvider {
  DigitalOceanServerProvider({required this.apiToken});

  /// DigitalOcean API token used for authentication.
  final String apiToken;

  /// HTTP client used for making API requests.
  final http.Client _client = http.Client();

  @override
  Future<RemoteServer> provisionServer() async {
    final response = await _client.post(
      Uri.parse('https://api.digitalocean.com/v2/droplets'),
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'name': 'kdf-instance',
        'region': 'nyc1',
        'size': 's-1vcpu-1gb',
        'image': 'ubuntu-20-04-x64',
      }),
    );

    if (response.statusCode != 202) {
      throw Exception('Failed to provision droplet: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final id = data['droplet']['id'].toString();
    final ip = await _getDropletIp(id);
    return RemoteServer(id, ip: ip);
  }

  @override
  Future<void> destroyServer(String serverId) async {
    final response = await _client.delete(
      Uri.parse('https://api.digitalocean.com/v2/droplets/$serverId'),
      headers: {'Authorization': 'Bearer $apiToken'},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to destroy droplet: ${response.body}');
    }
  }

  Future<String?> _getDropletIp(String dropletId) async {
    final response = await _client.get(
      Uri.parse('https://api.digitalocean.com/v2/droplets/$dropletId'),
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final networks = data['droplet']['networks'] as Map<String, dynamic>;
    final v4 = networks['v4'] as List<dynamic>;
    if (v4.isNotEmpty) {
      final ip = (v4.first as Map<String, dynamic>)['ip_address'] as String?;
      return ip;
    }
    return null;
  }
}
