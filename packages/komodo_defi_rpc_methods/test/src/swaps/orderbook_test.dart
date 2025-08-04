import 'dart:convert';
import 'dart:io';

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:test/test.dart';

void main() {
  group('OrderbookRequest.toJson', () {
    test('produces expected map', () {
      final request = OrderbookRequest(rpcPass: 'pass', base: 'BTC', rel: 'KMD');

      expect(request.toJson(), {
        'method': 'orderbook',
        'mmrpc': '2.0',
        'rpc_pass': 'pass',
        'params': {'base': 'BTC', 'rel': 'KMD'},
      });
    });
  });

  group('OrderbookResponse', () {
    test('parses fixture and round trips', () {
      final fixture = File('test/fixtures/swaps/orderbook.json').readAsStringSync();
      final json = jsonDecode(fixture) as Map<String, dynamic>;

      final response = OrderbookResponse.parse(json);

      expect(response.base, 'BTC');
      expect(response.rel, 'KMD');
      expect(response.asks.length, 1);
      expect(response.bids.length, 1);
      expect(response.toJson(), json['result']);
    });
  });
}
