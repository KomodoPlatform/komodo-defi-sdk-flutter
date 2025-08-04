import 'dart:convert';
import 'dart:io';

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:test/test.dart';

void main() {
  group('ActiveSwapsRequest.toJson', () {
    test('with includeStatus true', () {
      const rpcPass = 'pass';
      final request = ActiveSwapsRequest(rpcPass: rpcPass, includeStatus: true);
      expect(request.toJson(), {
        'method': 'active_swaps',
        'mmrpc': '2.0',
        'rpc_pass': rpcPass,
        'params': {'include_status': true},
      });
    });

    test('with includeStatus false', () {
      const rpcPass = 'pass';
      final request = ActiveSwapsRequest(rpcPass: rpcPass);
      expect(request.toJson(), {
        'method': 'active_swaps',
        'mmrpc': '2.0',
        'rpc_pass': rpcPass,
        'params': {'include_status': false},
      });
    });
  });

  group('ActiveSwapsResponse', () {
    test('parses fixture and round trips', () {
      final fixture = File('test/fixtures/swaps/active_swaps.json').readAsStringSync();
      final json = jsonDecode(fixture) as Map<String, dynamic>;

      final response = ActiveSwapsResponse.parse(json);

      expect(response.mmrpc, '2.0');
      expect(response.uuids, ['7b60a494-f159-419c-8f41-02e10f897513']);
      expect(response.statuses, isEmpty);
      expect(response.toJson(), json['result']);
    });
  });
}
