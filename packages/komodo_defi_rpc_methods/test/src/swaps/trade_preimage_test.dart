import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:test/test.dart';

void main() {
  group('TradePreimageRequest.toJson', () {
    test('creates expected map with max', () {
      final request = TradePreimageRequest(
        base: 'BTC',
        rel: 'DOGE',
        swapMethod: 'buy',
        price: Decimal.parse('1'),
        max: true,
        rpcPass: 'pass',
      );

      expect(request.toJson(), {
        'method': 'trade_preimage',
        'mmrpc': '2.0',
        'rpc_pass': 'pass',
        'params': {
          'base': 'BTC',
          'rel': 'DOGE',
          'swap_method': 'buy',
          'price': [
            [
              1,
              [1],
            ],
            [
              1,
              [1],
            ],
          ],
          'max': true,
        },
      });
    });

    test('includes volume when provided', () {
      final request = TradePreimageRequest(
        base: 'BTC',
        rel: 'DOGE',
        swapMethod: 'buy',
        price: Decimal.parse('1'),
        volume: Decimal.parse('0.1'),
        rpcPass: 'pass',
      );

      expect(request.toJson(), {
        'method': 'trade_preimage',
        'mmrpc': '2.0',
        'rpc_pass': 'pass',
        'params': {
          'base': 'BTC',
          'rel': 'DOGE',
          'swap_method': 'buy',
          'price': [
            [
              1,
              [1],
            ],
            [
              1,
              [1],
            ],
          ],
          'volume': [
            [
              1,
              [1],
            ],
            [
              1,
              [10],
            ],
          ],
        },
      });
    });
  });

  group('TradePreimageResponse', () {
    test('parses fixture and round trips', () {
      final fixture = File('test/fixtures/swaps/trade_preimage.json').readAsStringSync();
      final json = jsonDecode(fixture) as Map<String, dynamic>;

      final response = TradePreimageResponse.fromJson(json);

      expect(response.mmrpc, '2.0');
      expect(response.result.totalFees.length, 2);

      // Adjust expected JSON to match serialization format
      final expected = Map<String, dynamic>.from(json);
      final fees = List<Map<String, dynamic>>.from((json['result'] as Map<String, dynamic>)['total_fees'] as List);
      fees[1]['required_balance_rat'][0] = [
        1,
        [0],
      ];
      expected['result'] = Map<String, dynamic>.from(json['result'] as Map)..['total_fees'] = fees;

      expect(response.toJson(), expected);
    });
  });
}
