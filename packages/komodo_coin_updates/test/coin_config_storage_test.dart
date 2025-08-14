import 'package:komodo_coin_updates/src/data/coin_config_storage.dart';
import 'package:komodo_coin_updates/src/models/coin.dart';
import 'package:komodo_coin_updates/src/models/coin_config.dart';
import 'package:komodo_coin_updates/src/models/coin_info.dart';
import 'package:test/test.dart';

class _FakeStorage implements CoinConfigStorage {
  Map<String, CoinInfo> store = {};
  String? commit;

  @override
  Future<bool> coinConfigExists() async => store.isNotEmpty && commit != null;

  @override
  Future<Coin?> getCoin(String coinId) async => store[coinId]?.coin;

  @override
  Future<Map<String, CoinConfig>?> getCoinConfigs() async => {
    for (final entry in store.entries)
      if (entry.value.coinConfig != null) entry.key: entry.value.coinConfig!,
  };

  @override
  Future<List<Coin>?> getCoins() async =>
      store.values.map((e) => e.coin).toList();

  @override
  Future<String?> getCurrentCommit() async => commit;

  @override
  Future<bool> isLatestCommit() async => false;

  @override
  Future<CoinConfig?> getCoinConfig(String coinId) async =>
      store[coinId]?.coinConfig;

  @override
  Future<void> saveCoinData(
    List<Coin> coins,
    Map<String, CoinConfig> coinConfig,
    String commit,
  ) async {
    for (final c in coins) {
      store[c.coin] = CoinInfo(coin: c, coinConfig: coinConfig[c.coin]);
    }
    this.commit = commit;
  }

  @override
  Future<void> saveRawCoinData(
    List<dynamic> coins,
    Map<String, dynamic> coinConfig,
    String commit,
  ) async {}
}

void main() {
  group('CoinConfigStorage (contract)', () {
    test('basic save and read flow', () async {
      final s = _FakeStorage();
      await s.saveCoinData(
        [const Coin(coin: 'KMD', decimals: 8)],
        {'KMD': const CoinConfig(coin: 'KMD', decimals: 8)},
        'HEAD',
      );

      expect(await s.getCoins(), isNotEmpty);
      expect((await s.getCoin('KMD'))?.coin, 'KMD');
      expect(await s.getCurrentCommit(), 'HEAD');
      expect(await s.coinConfigExists(), isTrue);
    });
  });
}
