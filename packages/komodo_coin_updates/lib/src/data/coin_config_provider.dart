import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:komodo_coin_updates/src/models/runtime_update_config.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A provider that fetches the coins and coin configs from the repository.
/// The repository is hosted on GitHub.
/// The repository contains a list of coins and a map of coin configs.
class CoinConfigProvider {
  /// Creates a provider for fetching coins and coin configuration data
  /// from the Komodo `coins` repository.
  ///
  /// - [branch]: the branch or commit to read from (defaults to `master`).
  /// - [coinsGithubContentUrl]: base URL for fetching raw file contents.
  /// - [coinsGithubApiUrl]: base URL for GitHub API requests.
  /// - [coinsPath]: path to the coins directory in the repository.
  /// - [coinsConfigPath]: path to the JSON file containing coin configs.
  /// - [githubToken]: optional GitHub token for authenticated requests
  ///   (recommended to avoid rate limits).
  CoinConfigProvider({
    this.branch = 'master',
    this.coinsGithubContentUrl =
        'https://raw.githubusercontent.com/KomodoPlatform/coins',
    this.coinsGithubApiUrl =
        'https://api.github.com/repos/KomodoPlatform/coins',
    this.coinsPath = 'coins',
    this.coinsConfigPath = 'utils/coins_config_unfiltered.json',
    this.githubToken,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  /// Creates a provider from a runtime configuration.
  ///
  /// Derives provider settings from the given [config]. Optionally provide
  /// a [githubToken] for authenticated GitHub API requests.
  factory CoinConfigProvider.fromConfig(
    RuntimeUpdateConfig config, {
    String? githubToken,
    http.Client? httpClient,
  }) {
    // TODO(Francois): derive all the values from the config
    return CoinConfigProvider(
      branch: config.coinsRepoBranch,
      githubToken: githubToken,
      httpClient: httpClient,
    );
  }

  /// The branch or commit hash to read repository contents from.
  final String branch;

  /// Base URL used to fetch raw repository file contents (no API).
  final String coinsGithubContentUrl;

  /// Base URL used for GitHub REST API calls.
  final String coinsGithubApiUrl;

  /// Path to the directory containing coin JSON files.
  final String coinsPath;

  /// Path to the JSON file that contains the unfiltered coin configuration map.
  final String coinsConfigPath;

  /// Optional GitHub token used for authenticated requests to reduce
  /// the risk of rate limiting.
  final String? githubToken;

  final http.Client _client;

  /// Fetches the assets from the repository by reading the unified
  /// unfiltered coin configuration file and parsing it as a list of [Asset].
  Future<List<Asset>> getAssets(String commit) async {
    final url = _contentUri(coinsConfigPath, branchOrCommit: commit);
    final response = await _client.get(url);
    final items = jsonDecode(response.body) as Map<String, dynamic>;

    // First pass: collect known AssetId for parent-child resolution
    final knownIds = <AssetId>{
      for (final entry in items.entries)
        AssetId.parse(entry.value as Map<String, dynamic>, knownIds: const {}),
    };

    // Second pass: create Asset from config with resolved AssetId
    final assets = <Asset>[
      for (final entry in items.entries)
        Asset.fromJsonWithId(
          entry.value as Map<String, dynamic>,
          assetId: AssetId.parse(
            entry.value as Map<String, dynamic>,
            knownIds: knownIds,
          ),
        ),
    ];
    return assets;
  }

  /// Fetches the assets from the repository.
  /// Returns a list of [Asset] objects.
  /// Throws an [Exception] if the request fails.
  Future<List<Asset>> getLatestAssets() async {
    return getAssets(branch);
  }

  // Deprecated: explicit coin configs can be derived from Asset if needed.

  /// Fetches the latest commit hash from the repository.
  /// Returns the latest commit hash.
  /// Throws an [Exception] if the request fails.
  Future<String> getLatestCommit() async {
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

    final response = await _client.get(url, headers: header);

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
    return Uri.parse('$coinsGithubContentUrl/$branchOrCommit/$path');
  }
}
