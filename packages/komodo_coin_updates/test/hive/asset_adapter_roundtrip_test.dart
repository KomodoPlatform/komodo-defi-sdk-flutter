import 'package:hive_ce/hive.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

import '../helpers/asset_test_helpers.dart';
import 'test_harness.dart';

void main() {
  group('AssetAdapter roundtrip', () {
    final env = HiveTestEnv();

    setUp(() async {
      await env.setup();
    });

    tearDown(() async {
      await env.dispose();
    });

    test('put/get returns equivalent Asset', () async {
      final box = await Hive.openLazyBox<Asset>('assets');

      final asset = AssetTestHelpers.utxoAsset(walletOnly: false);

      await box.put(asset.id.id, asset);

      final readBack = await box.get(asset.id.id);
      expect(readBack, isNotNull);
      expect(readBack!.id.id, equals(asset.id.id));
      expect(readBack.id.name, equals(asset.id.name));
      expect(readBack.id.subClass, equals(asset.id.subClass));
      expect(readBack.id.subClass, equals(asset.id.subClass));
      expect(readBack.protocol.subClass, equals(asset.protocol.subClass));
      expect(readBack.isWalletOnly, equals(asset.isWalletOnly));
      expect(readBack.signMessagePrefix, equals(asset.signMessagePrefix));
    });

    test('persists across restart', () async {
      const key = 'KMD';
      final box = await Hive.openLazyBox<Asset>('assets');
      await box.put(key, AssetTestHelpers.utxoAsset());

      await env.restart();

      final reopened = await Hive.openLazyBox<Asset>('assets');
      final readBack = await reopened.get(key);
      expect(readBack, isNotNull);
      expect(readBack!.id.id, equals(key));
      expect(readBack.id.name, equals('Komodo'));
      expect(readBack.id.subClass, equals(CoinSubClass.utxo));
      expect(readBack.protocol.subClass, equals(CoinSubClass.utxo));
      expect(readBack.isWalletOnly, isFalse);
      expect(readBack.signMessagePrefix, isNull);
    });
  });
}
