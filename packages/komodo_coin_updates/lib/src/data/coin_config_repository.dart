import 'package:hive_ce/hive.dart';
import 'package:komodo_coin_updates/src/data/coin_config_provider.dart';
import 'package:komodo_coin_updates/src/data/coin_config_storage.dart';
import 'package:komodo_coin_updates/src/models/coin.dart';
import 'package:komodo_coin_updates/src/models/coin_config.dart';
import 'package:komodo_coin_updates/src/models/coin_info.dart';
import 'package:komodo_coin_updates/src/models/runtime_update_config.dart';

/// A repository that fetches the coins and coin configs from the provider and
/// stores them in the storage provider.
class CoinConfigRepository implements CoinConfigStorage {
  /// Creates a coin config repository.
  /// [coinConfigProvider] is the provider that fetches the coins and coin configs.
  /// [coinsDatabase] is the database that stores the coins and their configs.
  /// [coinSettingsDatabase] is the database that stores the coin settings
  /// (i.e. current commit hash).
  CoinConfigRepository({required this.coinConfigProvider});

  /// Creates a coin config storage provider with default databases.
  /// The default databases are HiveLazyBoxProvider.
  /// The default databases are named 'coins' and 'coins_settings'.
  CoinConfigRepository.withDefaults(
    RuntimeUpdateConfig config, {
    String? githubToken,
  }) : coinConfigProvider = CoinConfigProvider.fromConfig(
         config,
         githubToken: githubToken,
       );

  /// The provider that fetches the coins and coin configs.
  final CoinConfigProvider coinConfigProvider;

  LazyBox<CoinInfo>? _coinsBox;
  Box<String>? _settingsBox;

  /// The key for the coins commit. The value is the commit hash.
  final String coinsCommitKey = 'coins_commit';

  String? _latestCommit;

  /// Updates the coin configs from the provider and stores them in the storage provider.
  /// Throws an [Exception] if the request fails.
  Future<void> updateCoinConfig({
    List<String> excludedAssets = const <String>[],
  }) async {
    final coins = await coinConfigProvider.getLatestCoins();
    final coinConfig = await coinConfigProvider.getLatestCoinConfigs();

    await saveCoinData(coins, coinConfig, _latestCommit ?? '');
  }

  @override
  /// Returns whether the currently stored commit matches the latest
  /// commit on the configured branch. Also caches the latest commit hash
  /// in memory for subsequent calls.
  Future<bool> isLatestCommit() async {
    final commit = await getCurrentCommit();
    if (commit != null) {
      _latestCommit = await coinConfigProvider.getLatestCommit();
      return commit == _latestCommit;
    }
    return false;
  }

  @override
  /// Retrieves all coins from storage, excluding any whose symbol appears
  /// in [excludedAssets]. Returns `null` if storage is empty.
  Future<List<Coin>?> getCoins({
    List<String> excludedAssets = const <String>[],
  }) async {
    final box = await _openCoinsBox();
    final keys = box.keys;
    final values = await Future.wait(
      keys.map((dynamic key) => box.get(key as String)),
    );
    return values
        .whereType<CoinInfo>()
        .where((ci) => !excludedAssets.contains(ci.coin.coin))
        .map((ci) => ci.coin)
        .toList();
  }

  @override
  /// Retrieves a single [Coin] by its [coinId] from storage.
  Future<Coin?> getCoin(String coinId) async {
    final ci = await (await _openCoinsBox()).get(coinId);
    return ci?.coin;
  }

  @override
  /// Retrieves all available [CoinConfig] entries from storage as a map
  /// keyed by coin symbol, excluding entries for which configuration is null.
  Future<Map<String, CoinConfig>?> getCoinConfigs({
    List<String> excludedAssets = const <String>[],
  }) async {
    final box = await _openCoinsBox();
    final keys = box.keys;
    final values = await Future.wait(
      keys.map((dynamic key) => box.get(key as String)),
    );
    final coinConfigs =
        values
            .whereType<CoinInfo>()
            .map((ci) => ci.coinConfig)
            .whereType<CoinConfig>()
            .toList();

    return <String, CoinConfig>{
      for (final CoinConfig cfg in coinConfigs) cfg.coin: cfg,
    };
  }

  @override
  /// Retrieves a single [CoinConfig] by its [coinId] from storage.
  Future<CoinConfig?> getCoinConfig(String coinId) async {
    final ci = await (await _openCoinsBox()).get(coinId);
    return ci?.coinConfig;
  }

  @override
  /// Returns the commit hash currently persisted in the settings storage
  /// for the coin data, or `null` if not present.
  Future<String?> getCurrentCommit() async {
    final box = await _openSettingsBox();
    return box.get(coinsCommitKey);
  }

  @override
  /// Persists coin list and configuration map to storage and records the
  /// associated repository [commit]. Also updates the in-memory cached
  /// latest commit if it has not yet been set.
  Future<void> saveCoinData(
    List<Coin> coins,
    Map<String, CoinConfig> coinConfig,
    String commit,
  ) async {
    final combinedCoins = <String, CoinInfo>{};
    for (final coin in coins) {
      combinedCoins[coin.coin] = CoinInfo(
        coin: coin,
        coinConfig: coinConfig[coin.coin],
      );
    }

    final coinsBox = await _openCoinsBox();
    final putMap = <String, CoinInfo>{
      for (final ci in combinedCoins.values) ci.coin.coin: ci,
    };
    await coinsBox.putAll(putMap);

    final settings = await _openSettingsBox();
    await settings.put(coinsCommitKey, commit);
    _latestCommit = _latestCommit ?? await coinConfigProvider.getLatestCommit();
  }

  @override
  /// Returns `true` when both the coins database and the coin settings
  /// database have been initialized and contain data.
  Future<bool> coinConfigExists() async {
    return await Hive.boxExists('coins') &&
        await Hive.boxExists('coins_settings');
  }

  @override
  /// Persists raw JSON coin data and configuration map to storage without
  /// requiring prior deserialization by the caller.
  Future<void> saveRawCoinData(
    List<dynamic> coins,
    Map<String, dynamic> coinConfig,
    String commit,
  ) async {
    final combinedCoins = <String, CoinInfo>{};
    for (final dynamic coin in coins) {
      // ignore: avoid_dynamic_calls
      final coinAbbr = coin['coin'] as String;
      final config =
          coinConfig[coinAbbr] != null
              ? CoinConfig.fromJson(
                coinConfig[coinAbbr] as Map<String, dynamic>,
              )
              : null;
      combinedCoins[coinAbbr] = CoinInfo(
        coin: Coin.fromJson(coin as Map<String, dynamic>),
        coinConfig: config,
      );
    }

    final coinsBox = await _openCoinsBox();
    final putMap = <String, CoinInfo>{
      for (final ci in combinedCoins.values) ci.coin.coin: ci,
    };
    await coinsBox.putAll(putMap);

    final settings = await _openSettingsBox();
    await settings.put(coinsCommitKey, commit);
  }

  Future<LazyBox<CoinInfo>> _openCoinsBox() async {
    _coinsBox ??= await Hive.openLazyBox<CoinInfo>('coins');
    return _coinsBox!;
  }

  Future<Box<String>> _openSettingsBox() async {
    _settingsBox ??= await Hive.openBox<String>('coins_settings');
    return _settingsBox!;
  }
}
