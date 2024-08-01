// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:komodo_wallet_build_transformer/src/steps/coin_assets/github_file_downloader.dart';
import 'package:path/path.dart' as path;

/// Represents the build configuration for fetching coin assets.
class CoinCIConfig {
  /// Creates a new instance of [CoinCIConfig].
  CoinCIConfig({
    required this.bundledCoinsRepoCommit,
    required this.updateCommitOnBuild,
    required this.coinsRepoApiUrl,
    required this.coinsRepoContentUrl,
    required this.coinsRepoBranch,
    required this.runtimeUpdatesEnabled,
    required this.mappedFiles,
    required this.mappedFolders,
  });

  /// Creates a new instance of [CoinCIConfig] from a JSON object.
  factory CoinCIConfig.fromJson(Map<String, dynamic> json) {
    return CoinCIConfig(
      updateCommitOnBuild: json['update_commit_on_build'] as bool,
      bundledCoinsRepoCommit: json['bundled_coins_repo_commit'].toString(),
      coinsRepoApiUrl: json['coins_repo_api_url'].toString(),
      coinsRepoContentUrl: json['coins_repo_content_url'].toString(),
      coinsRepoBranch: json['coins_repo_branch'].toString(),
      runtimeUpdatesEnabled: json['runtime_updates_enabled'] as bool,
      mappedFiles: Map<String, String>.from(
        json['mapped_files'] as Map<String, dynamic>,
      ),
      mappedFolders: Map<String, String>.from(
        json['mapped_folders'] as Map<String, dynamic>,
      ),
    );
  }

  /// The commit hash or branch coins repository to use when fetching coin
  /// assets.
  final String bundledCoinsRepoCommit;

  /// Indicates whether the commit hash should be updated on build. If `true`,
  /// the commit hash will be updated and saved to the build configuration file.
  /// If `false`, the commit hash will not be updated and the configured commit
  /// hash will be used.
  final bool updateCommitOnBuild;

  /// The GitHub API of the coins repository used to fetch directory contents
  /// with SHA hashes from the GitHub API.
  final String coinsRepoApiUrl;

  /// The raw content GitHub URL of the coins repository used to fetch assets.
  final String coinsRepoContentUrl;

  /// The branch of the coins repository to use for fetching assets.
  final String coinsRepoBranch;

  /// Indicates whether runtime updates of the coins assets are enabled.
  ///
  /// NB: This does not affect the build process.
  final bool runtimeUpdatesEnabled;

  /// A map of mapped files to download.
  /// The keys represent the local paths where the files will be saved,
  /// and the values represent the relative paths of the files in the repository
  final Map<String, String> mappedFiles;

  /// A map of mapped folders to download. The keys represent the local paths
  /// where the folders will be saved, and the values represent the
  /// corresponding paths in the GitHub repository.
  final Map<String, String> mappedFolders;

  CoinCIConfig copyWith({
    String? bundledCoinsRepoCommit,
    bool? updateCommitOnBuild,
    String? coinsRepoApiUrl,
    String? coinsRepoContentUrl,
    String? coinsRepoBranch,
    bool? runtimeUpdatesEnabled,
    Map<String, String>? mappedFiles,
    Map<String, String>? mappedFolders,
  }) {
    return CoinCIConfig(
      updateCommitOnBuild: updateCommitOnBuild ?? this.updateCommitOnBuild,
      bundledCoinsRepoCommit:
          bundledCoinsRepoCommit ?? this.bundledCoinsRepoCommit,
      coinsRepoApiUrl: coinsRepoApiUrl ?? this.coinsRepoApiUrl,
      coinsRepoContentUrl: coinsRepoContentUrl ?? this.coinsRepoContentUrl,
      coinsRepoBranch: coinsRepoBranch ?? this.coinsRepoBranch,
      runtimeUpdatesEnabled:
          runtimeUpdatesEnabled ?? this.runtimeUpdatesEnabled,
      mappedFiles: mappedFiles ?? this.mappedFiles,
      mappedFolders: mappedFolders ?? this.mappedFolders,
    );
  }

  /// Converts the [CoinCIConfig] instance to a JSON object.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'update_commit_on_build': updateCommitOnBuild,
        'bundled_coins_repo_commit': bundledCoinsRepoCommit,
        'coins_repo_api_url': coinsRepoApiUrl,
        'coins_repo_content_url': coinsRepoContentUrl,
        'coins_repo_branch': coinsRepoBranch,
        'runtime_updates_enabled': runtimeUpdatesEnabled,
        'mapped_files': mappedFiles,
        'mapped_folders': mappedFolders,
      };

  /// Loads the coins runtime update configuration synchronously from the specified [path].
  ///
  /// Prints the path from which the configuration is being loaded.
  /// Reads the contents of the file at the specified path and decodes it as JSON.
  /// If the 'coins' key is not present in the decoded data, prints an error message and exits with code 1.
  /// Returns a [CoinCIConfig] object created from the decoded 'coins' data.
  static CoinCIConfig loadSync(String path) {
    print('Loading coins updates config from $path');

    try {
      final File file = File(path);
      final String contents = file.readAsStringSync();
      final Map<String, dynamic> data =
          jsonDecode(contents) as Map<String, dynamic>;

      return CoinCIConfig.fromJson(data['coins']);
    } catch (e) {
      print('Error loading coins updates config: $e');
      throw Exception('Error loading coins update config');
    }
  }

  /// Saves the coins configuration to the specified asset path and optionally updates the build configuration file.
  ///
  /// The [assetPath] parameter specifies the path where the coins configuration will be saved.
  /// The [updateBuildConfig] parameter indicates whether to update the build configuration file or not.
  ///
  /// If [updateBuildConfig] is `true`, the coins configuration will also be saved to the build configuration file specified by [buildConfigPath].
  ///
  /// If [originalBuildConfig] is provided, the coins configuration will be merged with the original build configuration before saving.
  ///
  /// Throws an exception if any error occurs during the saving process.
  Future<void> save({
    required String assetPath,
    Map<String, dynamic>? originalBuildConfig,
  }) async {
    final List<String> foldersToCreate = <String>[
      path.dirname(assetPath),
    ];
    createFolders(foldersToCreate);

    final mergedConfig = (originalBuildConfig ?? {})
      ..addAll({'coins': toJson()});

    print('Saving coin assets config to $assetPath');
    const encoder = JsonEncoder.withIndent("    ");

    final String data = encoder.convert(mergedConfig);
    await File(assetPath).writeAsString(data, flush: true);
  }
}
