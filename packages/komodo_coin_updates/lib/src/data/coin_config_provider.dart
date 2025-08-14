import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:http/http.dart' as http;
import 'package:komodo_coin_updates/src/config_transform.dart';
import 'package:komodo_coin_updates/src/models/runtime_update_config.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// Abstract interface for providing coin configuration data.
abstract class CoinConfigProvider {
  /// Fetches the assets for a specific [commit].
  Future<List<Asset>> getAssetsForCommit(String commit);

  /// Fetches the assets for the provider's default branch or reference.
  Future<List<Asset>> getAssets({String? branch});

  /// Retrieves the latest commit hash for the configured branch.
  /// Optional overrides allow targeting a different branch, API base URL,
  /// or GitHub token for this call only.
  Future<String> getLatestCommit({
    String? branch,
    String? apiBaseUrl,
    String? githubToken,
  });
}

/// GitHub-backed implementation of [CoinConfigProvider].
///
/// Fetches the coins and coin configs from the Komodo `coins` repository
/// hosted on GitHub (or a configured CDN mirror).
class GithubCoinConfigProvider implements CoinConfigProvider {
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
  GithubCoinConfigProvider({
    this.branch = 'master',
    this.coinsGithubContentUrl =
        'https://raw.githubusercontent.com/KomodoPlatform/coins',
    this.coinsGithubApiUrl =
        'https://api.github.com/repos/KomodoPlatform/coins',
    this.coinsPath = 'coins',
    this.coinsConfigPath = 'utils/coins_config_unfiltered.json',
    this.cdnBranchMirrors,
    this.githubToken,
    CoinConfigTransformer? transformer,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client(),
       _transformer = transformer ?? const CoinConfigTransformer();

  /// Creates a provider from a runtime configuration.
  ///
  /// Derives provider settings from the given [config]. Optionally provide
  /// a [githubToken] for authenticated GitHub API requests.
  factory GithubCoinConfigProvider.fromConfig(
    RuntimeUpdateConfig config, {
    String? githubToken,
    http.Client? httpClient,
    CoinConfigTransformer? transformer,
  }) {
    // Derive URLs and paths from build_config `coins` section.
    // We expect the following mapped files in the config:
    // - 'assets/config/coins_config.json' → path to unfiltered config JSON in repo
    // - 'assets/config/coins.json' → path to the coins folder in repo
    final coinsConfigPath =
        config.mappedFiles['assets/config/coins_config.json'] ??
        'utils/coins_config_unfiltered.json';
    final coinsPath = config.mappedFiles['assets/config/coins.json'] ?? 'coins';

    return GithubCoinConfigProvider(
      branch: config.coinsRepoBranch,
      coinsGithubContentUrl: config.coinsRepoContentUrl,
      coinsGithubApiUrl: config.coinsRepoApiUrl,
      coinsConfigPath: coinsConfigPath,
      coinsPath: coinsPath,
      cdnBranchMirrors: config.cdnBranchMirrors,
      githubToken: githubToken,
      transformer: transformer,
      httpClient: httpClient,
    );
  }
  static final Logger _log = Logger('GithubCoinConfigProvider');

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

  /// Optional mapping of branch name to CDN base URL that directly hosts
  /// the repository contents for that branch (without an extra branch
  /// segment in the path). When present and the current [branch] is found
  /// in this mapping, requests will be made against that base URL without
  /// including the branch in the path.
  final Map<String, String>? cdnBranchMirrors;

  final http.Client _client;

  /// Optional transform pipeline applied to each raw coin config JSON before parsing.
  final CoinConfigTransformer _transformer;

  @override
  Future<List<Asset>> getAssetsForCommit(String commit) async {
    final url = _contentUri(coinsConfigPath, branchOrCommit: commit);
    final response = await _client.get(url);
    final items = jsonDecode(response.body) as Map<String, dynamic>;

    // Optionally transform each coin JSON before parsing
    final transformedItems = <String, Map<String, dynamic>>{
      for (final entry in items.entries)
        entry.key: _transformer.apply(
          Map<String, dynamic>.from(entry.value as Map<String, dynamic>),
        ),
    };

    // First pass: collect known AssetId for parent-child resolution
    final knownIds = <AssetId>{
      for (final entry in transformedItems.entries)
        AssetId.parse(entry.value, knownIds: const {}),
    };

    // Second pass: create Asset from config with resolved AssetId
    final assets = <Asset>[
      for (final entry in transformedItems.entries)
        Asset.fromJsonWithId(
          entry.value,
          assetId: AssetId.parse(entry.value, knownIds: knownIds),
        ),
    ];
    return assets;
  }

  @override
  Future<List<Asset>> getAssets({String? branch}) async {
    return getAssetsForCommit(branch ?? this.branch);
  }

  @override
  Future<String> getLatestCommit({
    String? branch,
    String? apiBaseUrl,
    String? githubToken,
  }) async {
    final effectiveBranch = branch ?? this.branch;
    final effectiveApiBaseUrl = apiBaseUrl ?? coinsGithubApiUrl;
    final effectiveToken = githubToken ?? this.githubToken;

    final url = Uri.parse('$effectiveApiBaseUrl/branches/$effectiveBranch');
    final header = <String, String>{'Accept': 'application/vnd.github+json'};

    if (effectiveToken != null) {
      header['Authorization'] = 'Bearer $effectiveToken';
      _log.fine('Using authentication for GitHub API request');
    }

    _log.fine('Fetching latest commit for branch $effectiveBranch');
    final response = await _client.get(url, headers: header);

    if (response.statusCode != 200) {
      _log.warning(
        'GitHub API request failed [${response.statusCode} ${response.reasonPhrase}] for $effectiveBranch',
      );
      throw Exception(
        'Failed to retrieve latest commit hash: $effectiveBranch'
        ' [${response.statusCode}]: ${response.reasonPhrase}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final commit = json['commit'] as Map<String, dynamic>;
    final latestCommitHash = commit['sha'] as String;
    return latestCommitHash;
  }

  /// Helper to construct a content URI for a [path].
  Uri buildContentUri(String path, {String? branchOrCommit}) =>
      _contentUri(path, branchOrCommit: branchOrCommit);

  /// Helper to construct a content URI for a [path].
  Uri _contentUri(String path, {String? branchOrCommit}) {
    branchOrCommit ??= branch;
    final cdnBase = cdnBranchMirrors?[branchOrCommit];
    if (cdnBase != null && cdnBase.isNotEmpty) {
      return Uri.parse('$cdnBase/$path');
    }
    return Uri.parse('$coinsGithubContentUrl/$branchOrCommit/$path');
  }
}

/// Local asset-backed implementation of [CoinConfigProvider].
///
/// Loads the coins configuration from an asset bundled with the app, typically
/// produced by the build transformer according to `build_config.json` mappings.
class LocalAssetCoinConfigProvider implements CoinConfigProvider {
  /// Creates a provider from a runtime configuration.
  ///
  /// - [packageName]: the name of the package containing the coins config asset.
  /// - [coinsConfigAssetPath]: the path to the coins config asset.
  /// - [bundledCommit]: the commit hash of the bundled coins repo.
  /// - [transformer]: the transformer to apply to the coins config.
  /// - [bundle]: the asset bundle to load the coins config from.
  LocalAssetCoinConfigProvider({
    required this.packageName,
    required this.coinsConfigAssetPath,
    required this.bundledCommit,
    CoinConfigTransformer? transformer,
    AssetBundle? bundle,
  }) : _transformer = transformer ?? const CoinConfigTransformer(),
       _bundle = bundle ?? rootBundle;

  /// Convenience ctor deriving the asset path from [RuntimeUpdateConfig].
  factory LocalAssetCoinConfigProvider.fromConfig(
    RuntimeUpdateConfig config, {
    String packageName = 'komodo_defi_framework',
    CoinConfigTransformer? transformer,
    AssetBundle? bundle,
  }) {
    final coinsConfigAsset =
        config.mappedFiles['assets/config/coins_config.json'] != null
            ? 'assets/config/coins_config.json'
            : 'assets/config/coins_config.json';
    return LocalAssetCoinConfigProvider(
      packageName: packageName,
      coinsConfigAssetPath: coinsConfigAsset,
      bundledCommit: config.bundledCoinsRepoCommit,
      transformer: transformer,
      bundle: bundle,
    );
  }

  /// Creates a provider from a runtime configuration.
  final String packageName;

  /// The path to the coins config asset.
  final String coinsConfigAssetPath;

  /// The commit hash of the bundled coins repo.
  final String bundledCommit;

  /// The transformer to apply to the coins config.
  final CoinConfigTransformer _transformer;

  /// The asset bundle to load the coins config from.
  final AssetBundle _bundle;

  @override
  Future<List<Asset>> getAssetsForCommit(String commit) => _loadAssets();

  @override
  Future<List<Asset>> getAssets({String? branch}) => _loadAssets();

  @override
  Future<String> getLatestCommit({
    String? branch,
    String? apiBaseUrl,
    String? githubToken,
  }) async => bundledCommit;

  Future<List<Asset>> _loadAssets() async {
    final key = 'packages/$packageName/$coinsConfigAssetPath';
    final content = await _bundle.loadString(key);
    final items = jsonDecode(content) as Map<String, dynamic>;

    final transformedItems = <String, Map<String, dynamic>>{
      for (final entry in items.entries)
        entry.key: _transformer.apply(
          Map<String, dynamic>.from(entry.value as Map<String, dynamic>),
        ),
    };

    final knownIds = <AssetId>{
      for (final entry in transformedItems.entries)
        AssetId.parse(entry.value, knownIds: const {}),
    };

    final assets = <Asset>[
      for (final entry in transformedItems.entries)
        Asset.fromJsonWithId(
          entry.value,
          assetId: AssetId.parse(entry.value, knownIds: knownIds),
        ),
    ];
    return assets;
  }
}
