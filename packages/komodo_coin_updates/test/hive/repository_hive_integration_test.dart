import 'package:komodo_coin_updates/src/coins_config/coin_config_repository.dart';
import 'package:komodo_coin_updates/src/runtime_update_config/runtime_update_config.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

import '../helpers/asset_test_helpers.dart';
import 'test_harness.dart';

void main() {
  group('CoinConfigRepository + Hive integration', () {
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

        final exists = await repo.coinConfigExists();
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
  });
}
