import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

/// A provider that fetches the coins and coin configs from the repository.
/// The repository is hosted on GitHub.
/// The repository contains a list of coins and a map of coin configs.
class CoinConfigProvider {
  CoinConfigProvider({
    this.branch = 'master',
    this.coinsGithubContentUrl =
        'https://raw.githubusercontent.com/KomodoPlatform/coins',
    this.coinsGithubApiUrl =
        'https://api.github.com/repos/KomodoPlatform/coins',
    this.coinsPath = 'coins',
    this.coinsConfigPath = 'utils/coins_config_unfiltered.json',
  });

  factory CoinConfigProvider.fromConfig(RuntimeUpdateConfig config) {
    // TODO(Francois): derive all the values from the config
    return CoinConfigProvider(
      branch: config.coinsRepoBranch,
    );
  }

  final String branch;
  final String coinsGithubContentUrl;
  final String coinsGithubApiUrl;
  final String coinsPath;
  final String coinsConfigPath;

  /// Fetches the coins from the repository.
  /// [commit] is the commit hash to fetch the coins from.
  /// If [commit] is not provided, it will fetch the coins from the latest commit.
  /// Returns a list of [Coin] objects.
  /// Throws an [Exception] if the request fails.
  Future<List<Coin>> getCoins(String commit) async {
    final Uri url = _contentUri(coinsPath, branchOrCommit: commit);
    final http.Response response = await http.get(url);
    final List<dynamic> items = jsonDecode(response.body) as List<dynamic>;
    return items
        .map((dynamic e) => Coin.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the coins from the repository.
  /// Returns a list of [Coin] objects.
  /// Throws an [Exception] if the request fails.
  Future<List<Coin>> getLatestCoins() async {
    return getCoins(branch);
  }

  /// Fetches the coin configs from the repository.
  /// [commit] is the commit hash to fetch the coin configs from.
  /// If [commit] is not provided, it will fetch the coin configs
  /// from the latest commit.
  /// Returns a map of [CoinConfig] objects.
  /// Throws an [Exception] if the request fails.
  /// The key of the map is the coin symbol.
  Future<Map<String, CoinConfig>> getCoinConfigs(String commit) async {
    final Uri url = _contentUri(coinsConfigPath, branchOrCommit: commit);
    final http.Response response = await http.get(url);
    final Map<String, dynamic> items =
        jsonDecode(response.body) as Map<String, dynamic>;
    return <String, CoinConfig>{
      for (final String key in items.keys)
        key: CoinConfig.fromJson(items[key] as Map<String, dynamic>),
    };
  }

  /// Fetches the latest coin configs from the repository.
  /// Returns a map of [CoinConfig] objects.
  /// Throws an [Exception] if the request fails.
  Future<Map<String, CoinConfig>> getLatestCoinConfigs() async {
    return getCoinConfigs(branch);
  }

  /// Fetches the latest commit hash from the repository.
  /// Returns the latest commit hash.
  /// Throws an [Exception] if the request fails.
  Future<String> getLatestCommit() async {
    final http.Client client = http.Client();
    final Uri url = Uri.parse('$coinsGithubApiUrl/branches/$branch');
    final Map<String, String> header = <String, String>{
      'Accept': 'application/vnd.github+json',
    };
    final http.Response response = await client.get(url, headers: header);

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    final Map<String, dynamic> commit = json['commit'] as Map<String, dynamic>;
    final String latestCommitHash = commit['sha'] as String;
    return latestCommitHash;
  }

  Uri _contentUri(String path, {String? branchOrCommit}) {
    branchOrCommit ??= branch;
    return Uri.parse('$coinsGithubContentUrl/$branch/$path');
  }
}
