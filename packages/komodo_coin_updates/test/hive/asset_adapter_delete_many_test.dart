import 'package:hive_ce/hive.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

import '../helpers/asset_test_helpers.dart';
import 'test_harness.dart';

void main() {
  group('AssetAdapter delete many', () {
    final env = HiveTestEnv();

    setUp(() async {
      await env.setup();
    });

    tearDown(() async {
      await env.dispose();
    });

    test('deleteAll removes subset while others remain', () async {
      final box = await Hive.openLazyBox<Asset>('assets');

      final assets = [
        AssetTestHelpers.utxoAsset(coin: 'A', fname: 'A', chainId: 1),
        AssetTestHelpers.utxoAsset(coin: 'B', fname: 'B', chainId: 2),
        AssetTestHelpers.utxoAsset(coin: 'C', fname: 'C', chainId: 3),
        AssetTestHelpers.utxoAsset(coin: 'D', fname: 'D', chainId: 4),
      ];
      await Future.wait(assets.map((a) => box.put(a.id.id, a)));

      await box.deleteAll(['B', 'D']);

      expect(await box.get('B'), isNull);
      expect(await box.get('D'), isNull);
      expect(await box.get('A'), isA<Asset>());
      expect(await box.get('C'), isA<Asset>());
    });
  });
}
