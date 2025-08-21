/// Unit tests for coin configuration transformation pipeline and individual transforms.
///
/// **Purpose**: Tests the configuration transformation system that modifies coin
/// configurations based on platform requirements, business rules, and runtime
/// conditions, ensuring consistent and correct transformation behavior.
///
/// **Test Cases**:
/// - Transformation idempotency (applying twice yields same result)
/// - Platform-specific filtering (WSS vs TCP protocols)
/// - Parent coin remapping and transformation
/// - Transform pipeline consistency and ordering
/// - Platform detection and conditional logic
///
/// **Functionality Tested**:
/// - Configuration transformation pipeline
/// - Platform-specific protocol filtering
/// - Parent coin relationship mapping
/// - Transform application and validation
/// - Platform detection and conditional transforms
/// - Configuration modification workflows
///
/// **Edge Cases**:
/// - Platform-specific behavior differences
/// - Transform idempotency validation
/// - Parent coin mapping edge cases
/// - Protocol filtering edge cases
/// - Configuration modification consistency
///
/// **Dependencies**: Tests the transformation system that adapts coin configurations
/// for different platforms and requirements, including WSS filtering for web platforms
/// and parent coin relationship mapping.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coin_updates/src/coins_config/config_transform.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

void main() {
  group('CoinConfigTransformer', () {
    test('idempotency: applying twice yields same result', () {
      const transformer = CoinConfigTransformer();
      final input = JsonMap.of({
        'coin': 'KMD',
        'type': 'UTXO',
        'protocol': {'type': 'UTXO'},
        'electrum': [
          {'url': 'wss://example.com', 'protocol': 'WSS'},
        ],
      });
      final once = transformer.apply(JsonMap.of(input));
      final twice = transformer.apply(JsonMap.of(once));
      expect(twice, equals(once));
    });
  });

  group('WssWebsocketTransform', () {
    test('filters WSS or non-WSS correctly by platform', () {
      const t = WssWebsocketTransform();
      final config = JsonMap.of({
        'coin': 'KMD',
        'electrum': [
          {'url': 'wss://wss.example', 'protocol': 'WSS'},
          {'url': 'tcp://tcp.example', 'protocol': 'TCP'},
        ],
      });

      if (kIsWeb) {
        final out = t.transform(JsonMap.of(config));
        final list = JsonList.of(
          List<Map<String, dynamic>>.from(out['electrum'] as List),
        );
        expect(list.length, 1);
        expect(list.first['protocol'], 'WSS');
        expect(list.first['ws_url'], isNotNull);
      } else {
        final out = t.transform(JsonMap.of(config));
        final list = JsonList.of(
          List<Map<String, dynamic>>.from(out['electrum'] as List),
        );
        expect(list.length, 1);
        expect(list.first['protocol'] != 'WSS', isTrue);
      }
    });
  });

  group('ParentCoinTransform', () {
    test('SLP remaps to BCH', () {
      const t = ParentCoinTransform();
      final config = JsonMap.of({'coin': 'ANY', 'parent_coin': 'SLP'});
      final out = t.transform(JsonMap.of(config));
      expect(out['parent_coin'], 'BCH');
    });

    test('Unmapped parent is a no-op', () {
      const t = ParentCoinTransform();
      final config = JsonMap.of({'coin': 'ANY', 'parent_coin': 'XYZ'});
      final out = t.transform(JsonMap.of(config));
      expect(out['parent_coin'], 'XYZ');
    });
  });
}
