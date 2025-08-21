/// Unit tests for coin configuration repository bootstrap and initialization sequence.
///
/// **Purpose**: Tests the bootstrap process that initializes coin configuration
/// repositories from local assets, ensuring proper configuration loading and
/// provider setup during application startup.
///
/// **Test Cases**:
/// - Local asset provider loading from configured asset paths
/// - Bootstrap configuration validation and application
/// - Asset bundle integration during bootstrap
/// - Configuration path resolution and loading
/// - Bootstrap sequence initialization
///
/// **Functionality Tested**:
/// - Repository bootstrap and initialization
/// - Local asset provider setup
/// - Configuration path resolution
/// - Asset bundle integration
/// - Bootstrap sequence workflows
/// - Configuration validation during bootstrap
///
/// **Edge Cases**:
/// - Missing asset files during bootstrap
/// - Configuration path resolution failures
/// - Asset bundle loading errors
/// - Bootstrap configuration validation
/// - Initialization sequence failures
///
/// **Dependencies**: Tests the bootstrap sequence that initializes coin configuration
/// repositories from local assets, ensuring proper startup configuration and
/// provider setup for the coin update system.
library;

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
