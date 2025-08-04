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

      // Use a robust comparison for rational/decimal values
      final expected = Map<String, dynamic>.from(json);

      expect(
        deepEqualsWithRationalTolerance(response.toJson(), expected),
        isTrue,
        reason: 'Serialized response does not match expected fixture (with rational/decimal tolerance)',
      );
    });
  });
}

/// Recursively compares two objects, treating rational/decimal representations as equal if numerically equivalent.
bool deepEqualsWithRationalTolerance(dynamic a, dynamic b) {
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (!deepEqualsWithRationalTolerance(a[key], b[key])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!deepEqualsWithRationalTolerance(a[i], b[i])) return false;
    }
    return true;
  }
  // Handle rational/decimal representations: [int, [int]] lists as numerically equal
  if (_isRationalList(a) && _isRationalList(b)) {
    final da = _rationalListToDecimal(a as List<dynamic>);
    final db = _rationalListToDecimal(b as List<dynamic>);
    return da == db;
  }
  return a == b;
}

bool _isRationalList(dynamic x) {
  return x is List &&
      x.length == 2 &&
      x[0] is int &&
      x[1] is List &&
      (x[1] as List).every((e) => e is int);
}

Decimal _rationalListToDecimal(List<dynamic> rat) {
  final int numerator = rat[0] as int;
  final List<int> denominators = List<int>.from(rat[1] as List);
  Decimal value = Decimal.fromInt(numerator);
  for (final d in denominators) {
    value = value / Decimal.fromInt(d);
  }
  return value;
}
