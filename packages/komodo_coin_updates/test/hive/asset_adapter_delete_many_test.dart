/// Unit tests for AssetAdapter bulk deletion operations in Hive database.
///
/// **Purpose**: Tests the bulk deletion functionality of the AssetAdapter when
/// working with Hive databases, ensuring that multiple assets can be deleted
/// efficiently while preserving other assets in the database.
///
/// **Test Cases**:
/// - Bulk deletion of multiple assets by key
/// - Preservation of non-deleted assets
/// - Database state consistency after deletion
/// - Key validation and deletion verification
/// - Database length and key tracking
///
/// **Functionality Tested**:
/// - Bulk asset deletion operations
/// - Database state management
/// - Asset key tracking and validation
/// - Hive lazy box operations
/// - Database consistency maintenance
/// - Key set management
///
/// **Edge Cases**:
/// - Partial deletion scenarios
/// - Database state transitions
/// - Key validation edge cases
/// - Database length consistency
/// - Asset preservation verification
///
/// **Dependencies**: Tests the AssetAdapter's bulk deletion capabilities in Hive
/// databases, using HiveTestEnv for isolated testing and validating that bulk
/// operations maintain database consistency and state.
library;

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
      expect(box.length, equals(2));
      final remainingKeys = box.keys.cast<String>().toSet();
      expect(remainingKeys, equals({'A', 'C'}));
    });
  });
}
