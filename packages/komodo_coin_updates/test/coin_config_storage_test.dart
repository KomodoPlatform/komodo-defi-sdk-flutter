import 'package:komodo_coin_updates/src/coins_config/coin_config_storage.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

import 'helpers/asset_test_extensions.dart';

class _FakeStorage implements CoinConfigStorage {
  Map<String, Asset> store = {};
  String? commit;
  bool _latest = false;

  @override
  Future<bool> coinConfigExists() async => store.isNotEmpty && commit != null;

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

  // Deprecated methods removed from interface; using new API below

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
  group('CoinConfigStorage (contract)', () {
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
      expect(await s.coinConfigExists(), isTrue);
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
      expect(await s.coinConfigExists(), isFalse);
    });

    test('isLatestCommit can assert both true and false branches', () async {
      final s = _FakeStorage();

      // default false
      expect(await s.isLatestCommit(latestCommit: 'HEAD'), isFalse);

      s.setIsLatest(true);
      expect(await s.isLatestCommit(latestCommit: 'HEAD'), isTrue);
    });
  });
}
