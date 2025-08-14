import 'helpers/asset_test_extensions.dart';
import 'dart:io';

import 'package:hive_ce/hive.dart' as hive;
import 'package:komodo_coin_updates/hive/hive_registrar.g.dart';
import 'package:komodo_coin_updates/src/data/coin_config_provider.dart';
import 'package:komodo_coin_updates/src/data/coin_config_repository.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockCoinConfigProvider extends Mock implements CoinConfigProvider {}

void main() {
  group('CoinConfigRepository', () {
    late _MockCoinConfigProvider provider;
    late CoinConfigRepository repo;

    setUp(() async {
      final dir = await Directory.systemTemp.createTemp('kcu_test_');
      hive.Hive.init(dir.path);
      if (!hive.Hive.isAdapterRegistered(0)) {
        hive.Hive.registerAdapters();
      }
      provider = _MockCoinConfigProvider();
      repo = CoinConfigRepository(coinConfigProvider: provider);
    });

    tearDown(() async {
      await hive.Hive.deleteFromDisk();
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
        'BTC': buildBtcTestAsset().toJson(),
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
