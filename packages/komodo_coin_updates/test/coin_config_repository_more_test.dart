import 'package:hive_ce/hive.dart';
import 'package:komodo_coin_updates/src/coins_config/coin_config_provider.dart';
import 'package:komodo_coin_updates/src/coins_config/coin_config_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'helpers/asset_test_helpers.dart';
import 'hive/test_harness.dart';

class _MockCoinConfigProvider extends Mock implements CoinConfigProvider {}

void main() {
  group('CoinConfigRepository (more)', () {
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

    test(
      'updateCoinConfig propagates failures and does not partially write',
      () async {
        when(
          () => provider.getLatestCommit(),
        ).thenAnswer((_) async => 'C0MM1T');
        when(
          () => provider.getAssetsForCommit('C0MM1T'),
        ).thenThrow(Exception('boom'));

        await expectLater(repo.updateCoinConfig(), throwsA(isA<Exception>()));

        expect(await Hive.boxExists('assets'), isFalse);
        expect(await Hive.boxExists('coins_settings'), isFalse);
      },
    );

    test('isLatestCommit returns false when no stored commit', () async {
      expect(await repo.isLatestCommit(), isFalse);
    });

    test('isLatestCommit compares stored vs latest', () async {
      final kmd = AssetTestHelpers.utxoAsset();
      await repo.upsertAssets([kmd], 'HEAD');
      when(() => provider.getLatestCommit()).thenAnswer((_) async => 'HEAD');
      expect(await repo.isLatestCommit(), isTrue);
      when(() => provider.getLatestCommit()).thenAnswer((_) async => 'NEXT');
      expect(await repo.isLatestCommit(), isFalse);
    });

    test('getAssets respects excluded list', () async {
      final kmd = AssetTestHelpers.utxoAsset();
      final btc = AssetTestHelpers.utxoAsset(coin: 'BTC');
      await repo.upsertAssets([kmd, btc], 'HEAD');
      final res = await repo.getAssets(excludedAssets: const ['BTC']);
      expect(res.map((a) => a.id.id), contains('KMD'));
      expect(res.map((a) => a.id.id), isNot(contains('BTC')));
    });

    test('deleteAsset and deleteAllAssets work', () async {
      final kmd = AssetTestHelpers.utxoAsset();
      await repo.upsertAssets([kmd], 'HEAD');
      await repo.deleteAsset(kmd.id);
      final a = await repo.getAsset(kmd.id);
      expect(a, isNull);

      await repo.upsertAssets([kmd], 'HEAD');
      await repo.deleteAllAssets();
      final boxExists = await Hive.boxExists('assets');
      // Box still exists, but should be cleared and commit removed
      expect(boxExists, isTrue);
      final settings = await Hive.openBox<String>('coins_settings');
      expect(settings.get('coins_commit'), isNull);
    });
  });
}
