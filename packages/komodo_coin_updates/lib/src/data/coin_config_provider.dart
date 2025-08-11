import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:komodo_coin_updates/src/models/models.dart';

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
    this.githubToken,
  });

  factory CoinConfigProvider.fromConfig(
    RuntimeUpdateConfig config, {
    String? githubToken,
  }) {
    // TODO(Francois): derive all the values from the config
    return CoinConfigProvider(
      branch: config.coinsRepoBranch,
      githubToken: githubToken,
    );
  }

  final String branch;
  final String coinsGithubContentUrl;
  final String coinsGithubApiUrl;
  final String coinsPath;
  final String coinsConfigPath;
  final String? githubToken;

  /// Fetches the coins from the repository.
  /// [commit] is the commit hash to fetch the coins from.
  /// If [commit] is not provided, it will fetch the coins from the latest commit.
  /// Returns a list of [Coin] objects.
  /// Throws an [Exception] if the request fails.
  Future<List<Coin>> getCoins(String commit) async {
    final url = _contentUri(coinsPath, branchOrCommit: commit);
    final response = await http.get(url);
    final items = jsonDecode(response.body) as List<dynamic>;
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
    final url = _contentUri(coinsConfigPath, branchOrCommit: commit);
    final response = await http.get(url);
    final items = jsonDecode(response.body) as Map<String, dynamic>;
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
    final client = http.Client();
    final url = Uri.parse('$coinsGithubApiUrl/branches/$branch');
    final header = <String, String>{'Accept': 'application/vnd.github+json'};

    // Add authentication header if token is available
    if (githubToken != null) {
      header['Authorization'] = 'Bearer $githubToken';
      print('CoinConfigProvider: Using authentication for GitHub API request');
    } else {
      print(
        'CoinConfigProvider: No GitHub token available - making unauthenticated request',
      );
    }

    final response = await client.get(url, headers: header);

    if (response.statusCode != 200) {
      print(
        'CoinConfigProvider: GitHub API request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
      print('CoinConfigProvider: Response body: ${response.body}');
      throw Exception(
        'Failed to retrieve latest commit hash: $branch'
        '[${response.statusCode}]: ${response.reasonPhrase}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final commit = json['commit'] as Map<String, dynamic>;
    final latestCommitHash = commit['sha'] as String;
    return latestCommitHash;
  }

  Uri _contentUri(String path, {String? branchOrCommit}) {
    branchOrCommit ??= branch;
    return Uri.parse('$coinsGithubContentUrl/$branch/$path');
  }
}
