import 'dart:io';

import 'package:hive_ce/hive.dart' as hive;
import 'package:komodo_coin_updates/hive/hive_registrar.g.dart';
import 'package:komodo_coin_updates/src/data/coin_config_provider.dart';
import 'package:komodo_coin_updates/src/data/coin_config_repository.dart';
import 'package:komodo_coin_updates/src/models/coin.dart';
import 'package:komodo_coin_updates/src/models/coin_config.dart';
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

    test('saveCoinData writes to boxes and can be read back', () async {
      const kmd = Coin(coin: 'KMD', decimals: 8);
      const cfg = CoinConfig(coin: 'KMD', decimals: 8);

      when(() => provider.getLatestCommit()).thenAnswer((_) async => 'HEAD');

      await repo.saveCoinData([kmd], {'KMD': cfg}, 'HEAD');

      final coin = await repo.getCoin('KMD');
      expect(coin?.coin, 'KMD');

      final configs = await repo.getCoinConfigs();
      expect(configs, contains('KMD'));
      expect(configs!['KMD']!.coin, 'KMD');

      final commit = await repo.getCurrentCommit();
      expect(commit, 'HEAD');
    });

    test('saveRawCoinData persists raw json correctly', () async {
      when(() => provider.getLatestCommit()).thenAnswer((_) async => 'HEAD');

      await repo.saveRawCoinData(
        [
          {'coin': 'BTC', 'decimals': 8},
        ],
        {
          'BTC': {'coin': 'BTC', 'decimals': 8},
        },
        'HEAD',
      );

      final c = await repo.getCoin('BTC');
      expect(c?.coin, 'BTC');
      final cfgs = await repo.getCoinConfigs();
      expect(cfgs, contains('BTC'));
    });

    test(
      'coinConfigExists returns false before write then true after',
      () async {
        expect(await repo.coinConfigExists(), isFalse);
        when(() => provider.getLatestCommit()).thenAnswer((_) async => 'HEAD');
        await repo.saveCoinData(
          [const Coin(coin: 'KMD')],
          {'KMD': const CoinConfig(coin: 'KMD')},
          'HEAD',
        );
        expect(await repo.coinConfigExists(), isTrue);
      },
    );
  });
}
