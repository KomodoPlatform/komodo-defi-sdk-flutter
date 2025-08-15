import 'package:komodo_coin_updates/src/coins_config/coin_config_storage.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

import 'helpers/asset_test_extensions.dart';

class _FakeStorage implements CoinConfigStorage {
  Map<String, Asset> store = {};
  String? commit;

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
  Future<bool> isLatestCommit({String? latestCommit}) async => false;

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
  });
}
