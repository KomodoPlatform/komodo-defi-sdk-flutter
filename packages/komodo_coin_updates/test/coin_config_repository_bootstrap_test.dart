import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, ByteData;
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';

import 'hive/test_harness.dart';

class _FakeBundle extends AssetBundle {
  _FakeBundle(this.map);
  final Map<String, String> map;
  @override
  Future<ByteData> load(String key) => throw UnimplementedError();
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      map[key] ?? (throw StateError('Asset not found: $key'));
  @override
  void evict(String key) {}
}

void main() {
  group('Bootstrap sequence', () {
    final env = HiveTestEnv();

    setUp(() async {
      await env.setup();
    });

    tearDown(() async {
      await env.dispose();
    });

    RuntimeUpdateConfig config() => const RuntimeUpdateConfig(
      fetchAtBuildEnabled: false,
      updateCommitOnBuild: false,
      bundledCoinsRepoCommit: 'local-commit',
      runtimeUpdatesEnabled: false,
      mappedFiles: {
        'assets/config/coins_config.json': 'utils/coins_config_unfiltered.json',
        'assets/config/coins.json': 'coins',
      },
      mappedFolders: {},
      cdnBranchMirrors: {},
    );

    test('LocalAssetCoinConfigProvider loads from asset path', () async {
      const key =
          'packages/komodo_defi_framework/assets/config/coins_config.json';
      final fakeBundle = _FakeBundle({
        key: jsonEncode({
          'KMD': {
            'coin': 'KMD',
            'fname': 'Komodo',
            'type': 'UTXO',
            'chain_id': 777,
            'is_testnet': false,
          },
        }),
      });

      final local = LocalAssetCoinConfigProvider.fromConfig(
        config(),
        bundle: fakeBundle,
      );

      final assets = await local.getAssets();
      expect(assets.length, 1);
      expect(assets.first.id.id, 'KMD');
    });
  });
}
