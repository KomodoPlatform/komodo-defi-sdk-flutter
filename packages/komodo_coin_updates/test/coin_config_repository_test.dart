import 'package:hive_ce/hive.dart';
import 'package:komodo_coin_updates/src/coins_config/coin_config_provider.dart';
import 'package:komodo_coin_updates/src/coins_config/coin_config_repository.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'helpers/asset_test_extensions.dart';
import 'helpers/asset_test_helpers.dart';
import 'hive/test_harness.dart';

class _MockCoinConfigProvider extends Mock implements CoinConfigProvider {}

void main() {
  group('CoinConfigRepository', () {
    late _MockCoinConfigProvider provider;
    late CoinConfigRepository repo;
    final env = HiveTestEnv();

    setUp(() async {
      await env.setup();
      provider = _MockCoinConfigProvider();
      repo = CoinConfigRepository(coinConfigProvider: provider);
    });

    tearDown(() async {
      await env.dispose();
    });

    test('upsertAssets writes to boxes and can be read back', () async {
      final kmd = buildKmdTestAsset();

      // No need to stub getLatestCommit() here since we pass the commit explicitly.

      await repo.upsertAssets([kmd], 'HEAD');

      final asset = await repo.getAsset(
        AssetId(
          id: 'KMD',
          name: 'Komodo',
          symbol: AssetSymbol(assetConfigId: 'KMD'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        ),
      );
      expect(asset?.id.id, 'KMD');

      final commit = await repo.getCurrentCommit();
      expect(commit, 'HEAD');

      // Simulate process restart and ensure data persists
      await env.restart();
      final repo2 = CoinConfigRepository(coinConfigProvider: provider);
      final kmdAfterRestart = await repo2.getAsset(
        AssetId.parse(const {
          'coin': 'KMD',
          'fname': 'Komodo',
          'type': 'UTXO',
          'chain_id': 777,
        }, knownIds: const {}),
      );
      expect(kmdAfterRestart, isNotNull);
      expect(kmdAfterRestart!.id.id, equals('KMD'));
      final commitAfterRestart = await repo2.getCurrentCommit();
      expect(commitAfterRestart, equals('HEAD'));
    });

    test('upsertRawAssets persists raw json correctly', () async {
      // No need to stub getLatestCommit() here since we pass the commit explicitly.

      await repo.upsertRawAssets({
        'BTC': AssetTestHelpers.utxoJson(
          coin: 'BTC',
          fname: 'Bitcoin',
          chainId: 0,
        ),
      }, 'HEAD');

      final a = await repo.getAsset(
        AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        ),
      );
      expect(a?.id.id, 'BTC');
    });

    test('coinConfigExists returns false before write then true after', () async {
      expect(await repo.updatedAssetStorageExists(), isFalse);
      // No need to stub getLatestCommit() here since we pass the commit explicitly.
      final kmd = buildKmdTestAsset();
      await repo.upsertAssets([kmd], 'HEAD');
      expect(await repo.updatedAssetStorageExists(), isTrue);
    });

    test('respects custom box names and commit key', () async {
      final customRepo = CoinConfigRepository(
        coinConfigProvider: provider,
        assetsBoxName: 'custom_assets',
        settingsBoxName: 'custom_settings',
        coinsCommitKey: 'custom_commit',
      );

      // No need to stub getLatestCommit() here since we pass the commit explicitly.

      // Write an asset and commit using custom repo
      await customRepo.upsertAssets([buildKmdTestAsset()], 'C0MM1T');

      // Verify boxes exist with custom names
      expect(await Hive.boxExists('custom_assets'), isTrue);
      expect(await Hive.boxExists('custom_settings'), isTrue);

      // Verify commit is stored with custom key
      final settings = await Hive.openBox<String>('custom_settings');
      expect(settings.get('custom_commit'), equals('C0MM1T'));

      // Verify via repository API as well
      expect(await customRepo.getCurrentCommit(), equals('C0MM1T'));

      // Verify read works using same repo
      final asset = await customRepo.getAsset(
        AssetId(
          id: 'KMD',
          name: 'Komodo',
          symbol: AssetSymbol(assetConfigId: 'KMD'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        ),
      );
      expect(asset?.id.id, 'KMD');
    });
  });
}
