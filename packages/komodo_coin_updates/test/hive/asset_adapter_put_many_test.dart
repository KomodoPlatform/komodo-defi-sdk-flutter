import 'dart:math';

import 'package:hive_ce/hive.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

import '../helpers/asset_test_helpers.dart';
import 'test_harness.dart';

void main() {
  group('AssetAdapter put many (concurrent)', () {
    final env = HiveTestEnv();

    setUp(() async {
      await env.setup();
    });

    tearDown(() async {
      await env.dispose();
    });

    test('concurrent puts then read all', () async {
      final box = await Hive.openLazyBox<Asset>('assets');

      const total = 100;
      final assets = List.generate(total, (i) {
        final id = 'ASSET_${i + 1}';
        return AssetTestHelpers.utxoAsset(
          coin: id,
          fname: 'Asset $i',
          chainId: 700 + (i % 50),
        );
      });

      await Future.wait(assets.map((a) => box.put(a.id.id, a)));

      expect(box.length, equals(total));
      final keys = box.keys.cast<String>().toList();
      expect(keys.length, equals(total));

      final rand = Random(42);
      final sampleKeys = List.generate(
        10,
        (_) => keys[rand.nextInt(keys.length)],
      );
      final sampled = await Future.wait(sampleKeys.map(box.get));
      for (final s in sampled) {
        expect(s, isA<Asset>());
      }
      for (var i = 0; i < sampled.length; i++) {
        final asset = sampled[i]!;
        expect(asset.id.id, equals(sampleKeys[i]));
      }
    });
  });
}
