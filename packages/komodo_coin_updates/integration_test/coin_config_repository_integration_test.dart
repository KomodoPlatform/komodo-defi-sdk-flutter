/// Integration tests for CoinConfigRepository with Hive database persistence.
///
/// **Purpose**: Tests the full integration between CoinConfigRepository and Hive
/// database storage, ensuring that repository operations properly persist data
/// and maintain consistency across database restarts and operations.
///
/// **Test Cases**:
/// - Full CRUD operations with Hive persistence
/// - Database restart and data recovery scenarios
/// - Raw asset JSON parsing and storage
/// - Asset filtering with exclusion lists
/// - Commit tracking and persistence
/// - Cross-restart data consistency
///
/// **Functionality Tested**:
/// - Hive database integration and persistence
/// - Repository operation persistence
/// - Data recovery after database restarts
/// - Asset parsing and storage workflows
/// - Commit hash tracking and persistence
/// - Database state consistency
///
/// **Edge Cases**:
/// - Database restart scenarios
/// - Data persistence across operations
/// - Asset filtering edge cases
/// - Commit tracking consistency
/// - Cross-restart data integrity
///
/// **Dependencies**: Tests the full integration between CoinConfigRepository and
/// Hive database storage, using HiveTestEnv for isolated database testing and
/// validating that repository operations properly persist and recover data.
///
/// **Note**: This is an integration test that requires actual Hive database
/// operations and should be run separately from unit tests.
library;

import 'package:komodo_coin_updates/src/coins_config/coin_config_repository.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

import '../test/helpers/asset_test_helpers.dart';
import '../test/hive/test_harness.dart';

void main() {
  group('CoinConfigRepository + Hive Integration', () {
    final env = HiveTestEnv();

    setUp(() async {
      await env.setup();
    });

    tearDown(() async {
      await env.dispose();
    });

    AssetRuntimeUpdateConfig config() => const AssetRuntimeUpdateConfig(
      fetchAtBuildEnabled: false,
      updateCommitOnBuild: false,
      bundledCoinsRepoCommit: 'local',
      runtimeUpdatesEnabled: false,
      mappedFiles: {},
      mappedFolders: {},
      cdnBranchMirrors: {},
    );

    test(
      'upsertAssets/getAssets/getAsset/getCurrentCommit/coinConfigExists',
      () async {
        final repo = CoinConfigRepository.withDefaults(config());

        final assets = <Asset>[
          AssetTestHelpers.utxoAsset(),
          AssetTestHelpers.utxoAsset(coin: 'BTC', fname: 'Bitcoin', chainId: 0),
        ];
        const commit = 'abc123';

        await repo.upsertAssets(assets, commit);

        final exists = await repo.updatedAssetStorageExists();
        expect(exists, isTrue);

        final all = await repo.getAssets();
        expect(all.map((a) => a.id.id).toSet(), equals({'KMD', 'BTC'}));

        final kmd = await repo.getAsset(
          AssetId.parse(const {
            'coin': 'KMD',
            'fname': 'Komodo',
            'type': 'UTXO',
            'chain_id': 777,
          }, knownIds: const {}),
        );
        expect(kmd, isNotNull);
        expect(kmd!.id.id, equals('KMD'));

        final storedCommit = await repo.getCurrentCommit();
        expect(storedCommit, equals(commit));

        // Validate persistence after restart
        await env.restart();
        final repo2 = CoinConfigRepository.withDefaults(config());
        final all2 = await repo2.getAssets();
        expect(all2.map((a) => a.id.id).toSet(), equals({'KMD', 'BTC'}));
        final commitAfterRestart = await repo2.getCurrentCommit();
        expect(commitAfterRestart, equals(commit));
      },
    );

    test('upsertRawAssets parses and persists', () async {
      final repo = CoinConfigRepository.withDefaults(config());

      final raw = <String, dynamic>{
        'KMD': AssetTestHelpers.utxoJson(),
        'BTC': AssetTestHelpers.utxoJson(
          coin: 'BTC',
          fname: 'Bitcoin',
          chainId: 0,
        ),
      };

      await repo.upsertRawAssets(raw, 'def456');

      final all = await repo.getAssets();
      expect(all.length, equals(2));
      expect(all.map((a) => a.id.id).toSet(), equals({'KMD', 'BTC'}));
      final storedCommit = await repo.getCurrentCommit();
      expect(storedCommit, equals('def456'));
    });

    test('excludedAssets filter works', () async {
      final repo = CoinConfigRepository.withDefaults(config());
      final assets = <Asset>[
        AssetTestHelpers.utxoAsset(),
        AssetTestHelpers.utxoAsset(coin: 'BTC', fname: 'Bitcoin', chainId: 0),
      ];
      await repo.upsertAssets(assets, 'ghi789');

      final all = await repo.getAssets(excludedAssets: const ['BTC']);
      expect(all.map((a) => a.id.id).toSet(), equals({'KMD'}));
    });

    test('deleteAsset removes asset and maintains commit', () async {
      final repo = CoinConfigRepository.withDefaults(config());
      final assets = <Asset>[
        AssetTestHelpers.utxoAsset(),
        AssetTestHelpers.utxoAsset(coin: 'BTC', fname: 'Bitcoin', chainId: 0),
      ];
      await repo.upsertAssets(assets, 'jkl012');

      await repo.deleteAsset(AssetTestHelpers.utxoAsset(coin: 'BTC').id);

      final remaining = await repo.getAssets();
      expect(remaining.map((a) => a.id.id).toSet(), equals({'KMD'}));

      final commit = await repo.getCurrentCommit();
      expect(commit, equals('jkl012'));
    });

    test('deleteAllAssets clears all assets and resets commit', () async {
      final repo = CoinConfigRepository.withDefaults(config());
      final assets = <Asset>[
        AssetTestHelpers.utxoAsset(),
        AssetTestHelpers.utxoAsset(coin: 'BTC', fname: 'Bitcoin', chainId: 0),
      ];
      await repo.upsertAssets(assets, 'mno345');

      await repo.deleteAllAssets();

      final remaining = await repo.getAssets();
      expect(remaining, isEmpty);

      final commit = await repo.getCurrentCommit();
      expect(commit, isNull);

      final exists = await repo.updatedAssetStorageExists();
      expect(exists, isFalse);
    });
  });
}
