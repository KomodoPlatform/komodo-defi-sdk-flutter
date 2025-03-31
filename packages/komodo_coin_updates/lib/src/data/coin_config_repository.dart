import 'package:komodo_coin_updates/src/persistence/hive/hive.dart';
import 'package:komodo_coin_updates/src/persistence/persisted_types.dart';
import 'package:komodo_coin_updates/src/persistence/persistence_provider.dart';

import '../../komodo_coin_updates.dart';
import '../models/coin_info.dart';

/// A repository that fetches the coins and coin configs from the provider and
/// stores them in the storage provider.
class CoinConfigRepository implements CoinConfigStorage {
  /// Creates a coin config repository.
  /// [coinConfigProvider] is the provider that fetches the coins and coin configs.
  /// [coinsDatabase] is the database that stores the coins and their configs.
  /// [coinSettingsDatabase] is the database that stores the coin settings
  /// (i.e. current commit hash).
  CoinConfigRepository({
    required this.coinConfigProvider,
    required this.coinsDatabase,
    required this.coinSettingsDatabase,
  });

  /// Creates a coin config storage provider with default databases.
  /// The default databases are HiveLazyBoxProvider.
  /// The default databases are named 'coins' and 'coins_settings'.
  CoinConfigRepository.withDefaults(RuntimeUpdateConfig config)
      : coinConfigProvider = CoinConfigProvider.fromConfig(config),
        coinsDatabase = HiveLazyBoxProvider<String, CoinInfo>(
          name: 'coins',
        ),
        coinSettingsDatabase = HiveBoxProvider<String, PersistedString>(
          name: 'coins_settings',
        );

  /// The provider that fetches the coins and coin configs.
  final CoinConfigProvider coinConfigProvider;

  /// The database that stores the coins. The key is the coin id.
  final PersistenceProvider<String, CoinInfo> coinsDatabase;

  /// The database that stores the coin settings. The key is the coin settings key.
  final PersistenceProvider<String, PersistedString> coinSettingsDatabase;

  /// The key for the coins commit. The value is the commit hash.
  final String coinsCommitKey = 'coins_commit';

  String? _latestCommit;

  /// Updates the coin configs from the provider and stores them in the storage provider.
  /// Throws an [Exception] if the request fails.
  Future<void> updateCoinConfig({
    List<String> excludedAssets = const <String>[],
  }) async {
    final List<Coin> coins = await coinConfigProvider.getLatestCoins();
    final Map<String, CoinConfig> coinConfig =
        await coinConfigProvider.getLatestCoinConfigs();

    await saveCoinData(coins, coinConfig, _latestCommit ?? '');
  }

  @override
  Future<bool> isLatestCommit() async {
    final String? commit = await getCurrentCommit();
    if (commit != null) {
      _latestCommit = await coinConfigProvider.getLatestCommit();
      return commit == _latestCommit;
    }
    return false;
  }

  @override
  Future<List<Coin>?> getCoins({
    List<String> excludedAssets = const <String>[],
  }) async {
    final List<CoinInfo?> result = await coinsDatabase.getAll();
    return result
        .where(
          (CoinInfo? coin) =>
              coin != null && !excludedAssets.contains(coin.coin.coin),
        )
        .map((CoinInfo? coin) => coin!.coin)
        .toList();
  }

  @override
  Future<Coin?> getCoin(String coinId) async {
    return (await coinsDatabase.get(coinId))!.coin;
  }

  @override
  Future<Map<String, CoinConfig>?> getCoinConfigs({
    List<String> excludedAssets = const <String>[],
  }) async {
    final List<CoinConfig> coinConfigs = (await coinsDatabase.getAll())
        .where((CoinInfo? e) => e != null && e.coinConfig != null)
        .cast<CoinInfo>()
        .map((CoinInfo e) => e.coinConfig)
        .cast<CoinConfig>()
        .toList();

    return <String, CoinConfig>{
      for (final CoinConfig coinConfig in coinConfigs)
        coinConfig.primaryKey: coinConfig,
    };
  }

  @override
  Future<CoinConfig?> getCoinConfig(String coinId) async {
    return (await coinsDatabase.get(coinId))!.coinConfig;
  }

  @override
  Future<String?> getCurrentCommit() async {
    return coinSettingsDatabase
        .get(coinsCommitKey)
        .then((PersistedString? persistedString) {
      return persistedString?.value;
    });
  }

  @override
  Future<void> saveCoinData(
    List<Coin> coins,
    Map<String, CoinConfig> coinConfig,
    String commit,
  ) async {
    final Map<String, CoinInfo> combinedCoins = <String, CoinInfo>{};
    for (final Coin coin in coins) {
      combinedCoins[coin.coin] = CoinInfo(
        coin: coin,
        coinConfig: coinConfig[coin.coin],
      );
    }

    await coinsDatabase.insertAll(combinedCoins.values.toList());
    await coinSettingsDatabase.insert(PersistedString(coinsCommitKey, commit));
    _latestCommit = _latestCommit ?? await coinConfigProvider.getLatestCommit();
  }

  @override
  Future<bool> coinConfigExists() async {
    return await coinsDatabase.exists() && await coinSettingsDatabase.exists();
  }

  @override
  Future<void> saveRawCoinData(
    List<dynamic> coins,
    Map<String, dynamic> coinConfig,
    String commit,
  ) async {
    final Map<String, CoinInfo> combinedCoins = <String, CoinInfo>{};
    for (final dynamic coin in coins) {
      // ignore: avoid_dynamic_calls
      final String coinAbbr = coin['coin'] as String;
      final CoinConfig? config = coinConfig[coinAbbr] != null
          ? CoinConfig.fromJson(coinConfig[coinAbbr] as Map<String, dynamic>)
          : null;
      combinedCoins[coinAbbr] = CoinInfo(
        coin: Coin.fromJson(coin as Map<String, dynamic>),
        coinConfig: config,
      );
    }

    await coinsDatabase.insertAll(combinedCoins.values.toList());
    await coinSettingsDatabase.insert(PersistedString(coinsCommitKey, commit));
  }
}
