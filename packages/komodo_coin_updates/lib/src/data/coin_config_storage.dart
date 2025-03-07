import '../models/coin.dart';
import '../models/coin_config.dart';

/// A storage provider that fetches the coins and coin configs from the storage.
/// The storage provider is responsible for fetching the coins and coin configs
/// from the storage and saving the coins and coin configs to the storage.
abstract class CoinConfigStorage {
  /// Fetches the coins from the storage provider.
  /// Returns a list of [Coin] objects.
  /// Throws an [Exception] if the request fails.
  Future<List<Coin>?> getCoins();

  /// Fetches the specified coin from the storage provider.
  /// [coinId] is the coin symbol.
  /// Returns a [Coin] object.
  /// Throws an [Exception] if the request fails.
  Future<Coin?> getCoin(String coinId);

  /// Fetches the coin configs from the storage provider.
  /// Returns a map of [CoinConfig] objects.
  /// Throws an [Exception] if the request fails.
  Future<Map<String, CoinConfig>?> getCoinConfigs();

  /// Fetches the specified coin config from the storage provider.
  /// [coinId] is the coin symbol.
  /// Returns a [CoinConfig] object.
  /// Throws an [Exception] if the request fails.
  Future<CoinConfig?> getCoinConfig(String coinId);

  /// Checks if the latest commit is the same as the current commit.
  /// Returns `true` if the latest commit is the same as the current commit,
  /// otherwise `false`.
  /// Throws an [Exception] if the request fails.
  Future<bool> isLatestCommit();

  /// Fetches the current commit hash.
  /// Returns the commit hash as a [String].
  /// Throws an [Exception] if the request fails.
  Future<String?> getCurrentCommit();

  /// Checks if the coin configs are saved in the storage provider.
  /// Returns `true` if the coin configs are saved, otherwise `false`.
  /// Throws an [Exception] if the request fails.
  Future<bool> coinConfigExists();

  /// Saves the coin data to the storage provider.
  /// [coins] is a list of [Coin] objects.
  /// [coinConfig] is a map of [CoinConfig] objects.
  /// [commit] is the commit hash.
  /// Throws an [Exception] if the request fails.
  Future<void> saveCoinData(
    List<Coin> coins,
    Map<String, CoinConfig> coinConfig,
    String commit,
  );

  /// Saves the raw coin data to the storage provider.
  /// [coins] is a list of [Coin] objects in raw JSON `dynamic` form.
  /// [coinConfig] is a map of [CoinConfig] objects in raw JSON `dynamic` form.
  /// [commit] is the commit hash.
  /// Throws an [Exception] if the request fails.
  Future<void> saveRawCoinData(
    List<dynamic> coins,
    Map<String, dynamic> coinConfig,
    String commit,
  );
}
