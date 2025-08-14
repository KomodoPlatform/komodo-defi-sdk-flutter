import 'package:komodo_coin_updates/src/data/coin_config_provider.dart';
import 'package:komodo_coin_updates/src/data/coin_config_repository.dart';
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

    test('saveAssetData writes to boxes and can be read back', () async {
      final kmd = buildKmdTestAsset();

      when(() => provider.getLatestCommit()).thenAnswer((_) async => 'HEAD');

      await repo.saveAssetData([kmd], 'HEAD');

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
    });

    test('saveRawAssetData persists raw json correctly', () async {
      when(() => provider.getLatestCommit()).thenAnswer((_) async => 'HEAD');

      await repo.saveRawAssetData({
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

    test(
      'coinConfigExists returns false before write then true after',
      () async {
        expect(await repo.coinConfigExists(), isFalse);
        when(() => provider.getLatestCommit()).thenAnswer((_) async => 'HEAD');
        final kmd = buildKmdTestAsset();
        await repo.saveAssetData([kmd], 'HEAD');
        expect(await repo.coinConfigExists(), isTrue);
      },
    );
  });
}
