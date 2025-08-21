/// Unit tests for the CoinConfigStorage interface contract and implementations.
///
/// **Purpose**: Tests the storage interface contract that defines the core operations
/// for coin configuration persistence, ensuring consistent behavior across different
/// storage implementations and proper contract compliance.
///
/// **Test Cases**:
/// - Basic save and read operations flow
/// - Asset filtering with exclusion lists
/// - Single asset deletion and cleanup
/// - Bulk asset deletion and storage reset
/// - Latest commit validation and checking
/// - Storage existence and state validation
///
/// **Functionality Tested**:
/// - CRUD operations contract compliance
/// - Asset filtering and querying
/// - Commit tracking and validation
/// - Storage state management
/// - Cleanup and reset operations
/// - Interface contract validation
///
/// **Edge Cases**:
/// - Empty storage states
/// - Asset exclusion filtering
/// - Commit state transitions
/// - Storage cleanup scenarios
/// - Interface contract edge cases
///
/// **Dependencies**: Tests the storage interface contract that defines how coin
/// configurations are persisted and retrieved, using a fake implementation to
/// validate contract compliance and behavior consistency.
library;

import 'package:komodo_coin_updates/src/coins_config/coin_config_storage.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

import 'helpers/asset_test_extensions.dart';
import 'helpers/asset_test_helpers.dart';

class _FakeStorage implements CoinConfigStorage {
  Map<String, Asset> store = {};
  String? commit;
  bool _latest = false;

  @override
  Future<bool> updatedAssetStorageExists() async =>
      store.isNotEmpty && commit != null;

  @override
  Future<Asset?> getAsset(AssetId assetId) async => store[assetId.id];

  @override
  Future<List<Asset>> getAssets({
    List<String> excludedAssets = const [],
  }) async =>
      store.values.where((a) => !excludedAssets.contains(a.id.id)).toList();

  @override
  Future<String?> getCurrentCommit() async => commit;

  @override
  Future<bool> isLatestCommit({String? latestCommit}) async => _latest;

  // Helper for tests to toggle latest commit state
  void setIsLatest(bool value) => _latest = value;

  @override
  Future<void> upsertAssets(List<Asset> assets, String commit) async {
    for (final a in assets) {
      store[a.id.id] = a;
    }
    this.commit = commit;
  }

  @override
  Future<void> upsertRawAssets(
    Map<String, dynamic> coinConfigsBySymbol,
    String commit,
  ) async {
    // For the fake storage, we only need to track the commit persistence
    // to keep getCurrentCommit in sync with other upsert operations.
    this.commit = commit;
  }

  @override
  Future<void> deleteAsset(AssetId assetId) async {
    store.remove(assetId.id);
  }

  @override
  Future<void> deleteAllAssets() async {
    store.clear();
    commit = null;
  }
}

void main() {
  group('CoinConfigStorage Contract Tests', () {
    test('basic save and read flow', () async {
      final s = _FakeStorage();
      final asset = buildKmdTestAsset();
      await s.upsertAssets([asset], 'HEAD');

      expect(await s.getAssets(), isNotEmpty);
      expect(
        (await s.getAsset('KMD'.toTestAssetId(name: 'Komodo')))?.id.id,
        'KMD',
      );
      expect(await s.getCurrentCommit(), 'HEAD');
      expect(await s.updatedAssetStorageExists(), isTrue);
    });

    test('getAssets supports excludedAssets filtering', () async {
      final s = _FakeStorage();
      final kmd = buildKmdTestAsset();
      final btc = buildBtcTestAsset();
      await s.upsertAssets([kmd, btc], 'HEAD');

      final all = await s.getAssets();
      expect(all.map((a) => a.id.id).toSet(), containsAll(['KMD', 'BTC']));

      final filtered = await s.getAssets(excludedAssets: ['KMD']);
      expect(filtered.map((a) => a.id.id).toSet(), contains('BTC'));
      expect(filtered.any((a) => a.id.id == 'KMD'), isFalse);
    });

    test('deleteAsset removes a single asset and keeps commit', () async {
      final s = _FakeStorage();
      final kmd = buildKmdTestAsset();
      final btc = buildBtcTestAsset();
      await s.upsertAssets([kmd, btc], 'HEAD1');

      await s.deleteAsset('BTC'.toTestAssetId(name: 'Bitcoin'));

      expect(await s.getAsset('BTC'.toTestAssetId(name: 'Bitcoin')), isNull);
      expect(
        (await s.getAsset('KMD'.toTestAssetId(name: 'Komodo')))?.id.id,
        'KMD',
      );
      expect(await s.getCurrentCommit(), 'HEAD1');
    });

    test('deleteAllAssets clears store and resets commit', () async {
      final s = _FakeStorage();
      await s.upsertAssets([buildKmdTestAsset()], 'HEAD2');

      await s.deleteAllAssets();

      expect(await s.getAssets(), isEmpty);
      expect(await s.getCurrentCommit(), isNull);
      expect(await s.updatedAssetStorageExists(), isFalse);
    });

    test('isLatestCommit can assert both true and false branches', () async {
      final s = _FakeStorage();

      // default false
      expect(await s.isLatestCommit(latestCommit: 'HEAD'), isFalse);

      s.setIsLatest(true);
      expect(await s.isLatestCommit(latestCommit: 'HEAD'), isTrue);
    });

    test('upsertRawAssets updates commit without affecting assets', () async {
      final s = _FakeStorage();
      final kmd = buildKmdTestAsset();
      await s.upsertAssets([kmd], 'HEAD1');

      await s.upsertRawAssets({'BTC': AssetTestHelpers.utxoJson()}, 'HEAD2');

      // Assets should remain unchanged
      expect(await s.getAssets(), hasLength(1));
      expect(await s.getCurrentCommit(), 'HEAD2');
    });

    test('storage existence check works correctly', () async {
      final s = _FakeStorage();

      // Initially false
      expect(await s.updatedAssetStorageExists(), isFalse);

      // After adding assets
      await s.upsertAssets([buildKmdTestAsset()], 'HEAD');
      expect(await s.updatedAssetStorageExists(), isTrue);

      // After clearing assets but keeping commit
      await s.deleteAllAssets();
      expect(await s.updatedAssetStorageExists(), isFalse);
    });

    test('getAsset returns null for non-existent asset', () async {
      final s = _FakeStorage();
      final nonExistentId = 'BTC'.toTestAssetId(name: 'Bitcoin');

      expect(await s.getAsset(nonExistentId), isNull);
    });

    test('getAssets with empty exclusion list returns all assets', () async {
      final s = _FakeStorage();
      final kmd = buildKmdTestAsset();
      final btc = buildBtcTestAsset();
      await s.upsertAssets([kmd, btc], 'HEAD');

      final all = await s.getAssets(excludedAssets: []);
      expect(all, hasLength(2));
      expect(all.map((a) => a.id.id).toSet(), containsAll(['KMD', 'BTC']));
    });
  });
}
