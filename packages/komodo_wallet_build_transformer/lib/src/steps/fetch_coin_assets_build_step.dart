import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:komodo_wallet_build_transformer/src/build_step.dart';
import 'package:komodo_wallet_build_transformer/src/steps/coin_assets/build_progress_message.dart';
import 'package:komodo_wallet_build_transformer/src/steps/coin_assets/coin_ci_config.dart';
import 'package:komodo_wallet_build_transformer/src/steps/coin_assets/github_file.dart';
import 'package:komodo_wallet_build_transformer/src/steps/coin_assets/github_file_downloader.dart';
import 'package:komodo_wallet_build_transformer/src/steps/coin_assets/result.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

/// A build step that fetches coin assets from a GitHub repository.
class FetchCoinAssetsBuildStep extends BuildStep {
  final File buildConfigOutput;
  final Map<String, dynamic>? originalBuildConfig;
  final String artifactOutputDirectory;
  final CoinCIConfig config;
  final GitHubFileDownloader downloader;
  final ReceivePort? receivePort;
  final _log = Logger('FetchCoinAssetsBuildStep');

  @override
  final String id = idStatic;
  static const idStatic = 'fetch_coin_assets';

  FetchCoinAssetsBuildStep({
    required this.artifactOutputDirectory,
    required this.config,
    required this.downloader,
    required this.originalBuildConfig,
    required this.buildConfigOutput,
    this.receivePort,
  }) {
    receivePort?.listen(
      (dynamic message) => onProgressData(message, receivePort),
      onError: onProgressError,
    );
  }

  factory FetchCoinAssetsBuildStep.withBuildConfig(
    Map<String, dynamic> buildConfig,
    File outputBuildConfigFile, {
    required Directory artifactOutputDirectory,
    ReceivePort? receivePort,
  }) {
    CoinCIConfig config = CoinCIConfig.fromJson(buildConfig['coins']);
    config = config.copyWith(
      // If the branch is `master`, use the repository mirror URL to avoid
      // rate limiting issues. Consider refactoring config to allow branch
      // specific mirror URLs to remove this workaround.
      coinsRepoContentUrl: config.coinsRepoBranch == 'master'
          ? 'https://komodoplatform.github.io/coins'
          : null,
    );

    final GitHubFileDownloader downloader = GitHubFileDownloader(
      repoApiUrl: config.coinsRepoApiUrl,
      repoContentUrl: config.coinsRepoContentUrl,
    );

    return FetchCoinAssetsBuildStep(
      artifactOutputDirectory: artifactOutputDirectory.path,
      config: config,
      downloader: downloader,
      originalBuildConfig: buildConfig,
      buildConfigOutput: outputBuildConfigFile,
    );
  }

  @override
  Future<void> build() async {
    // Check if the coin assets already exist in the artifact directory
    final alreadyHadCoinAssets =
        File('$artifactOutputDirectory/assets/config/coins.json').existsSync();

    final isDebugBuild =
        (Platform.environment['FLUTTER_BUILD_MODE'] ?? '').toLowerCase() ==
            'debug';
    final latestCommitHash = await downloader.getLatestCommitHash(
      branch: config.coinsRepoBranch,
    );
    CoinCIConfig configWithUpdatedCommit = config;

    if (config.updateCommitOnBuild) {
      configWithUpdatedCommit =
          config.copyWith(bundledCoinsRepoCommit: latestCommitHash);
      await configWithUpdatedCommit.save(
        assetPath: buildConfigOutput.path,
        originalBuildConfig: originalBuildConfig,
      );
    }

    await downloader.download(
      configWithUpdatedCommit.bundledCoinsRepoCommit,
      _adjustPaths(configWithUpdatedCommit.mappedFiles),
      _adjustPaths(configWithUpdatedCommit.mappedFolders),
    );

    final bool wasCommitHashUpdated = config.bundledCoinsRepoCommit !=
        configWithUpdatedCommit.bundledCoinsRepoCommit;

    if (wasCommitHashUpdated || !alreadyHadCoinAssets) {
      const errorMessage = 'Coin assets have been updated. '
          'Please re-run the build process for the changes to take effect.';

      // If it's not a debug build and the commit hash was updated, throw an
      // exception to indicate that the build process should be re-run. We can
      // skip this check for debug builds if we already had coin assets.
      if (!isDebugBuild || !alreadyHadCoinAssets) {
        _log.shout(errorMessage);
        receivePort?.close();
        throw BuildStepWithoutRevertException(errorMessage);
      }

      _log.warning('$errorMessage\n');
    }

    receivePort?.close();
    _log.info('Coin assets fetched successfully. Build step completed.');
  }

  @override
  Future<bool> canSkip() async {
    final String latestCommitHash = await downloader.getLatestCommitHash(
      branch: config.coinsRepoBranch,
    );

    if (latestCommitHash != config.bundledCoinsRepoCommit) {
      return false;
    }

    if (!await _canSkipMappedFiles(config.mappedFiles)) {
      return false;
    }

    if (!await _canSkipMappedFolders(config.mappedFolders)) {
      return false;
    }

    return true;
  }

  @override
  Future<void> revert([Exception? e]) async {
    if (e is BuildStepWithoutRevertException) {
      _log.warning(
        'Step not reverted because the build process was completed with changes',
      );

      return;
    }

    // Try `git checkout` to revert changes instead of deleting all files
    // because there may be mapped files/folders that are tracked by git
    final List<String> mappedFilePaths = config.mappedFiles.keys.toList();
    final List<String> mappedFolderPaths = config.mappedFolders.keys.toList();

    final Iterable<List<String>> mappedFolderFilePaths =
        mappedFolderPaths.map(_getFilesInFolder);

    final List<String> allFiles = mappedFilePaths +
        mappedFolderFilePaths.expand((List<String> x) => x).toList();

    await GitHubFileDownloader.revertOrDeleteGitFiles(allFiles);
  }

  Future<bool> _canSkipMappedFiles(Map<String, String> files) async {
    for (final MapEntry<String, String> mappedFile in files.entries) {
      final GitHubFile remoteFile = await _fetchRemoteFileMetadata(mappedFile);
      final Result canSkipFile = await _canSkipFile(
        path.join(artifactOutputDirectory, mappedFile.key),
        remoteFile,
      );
      if (!canSkipFile.success) {
        _log.info('Cannot skip build step: ${canSkipFile.error}');
        return false;
      }
    }

    return true;
  }

  Future<bool> _canSkipMappedFolders(Map<String, String> folders) async {
    for (final MapEntry<String, String> mappedFolder in folders.entries) {
      final List<GitHubFile> remoteFolderContents =
          await downloader.getGitHubDirectoryContents(
        mappedFolder.value,
        config.bundledCoinsRepoCommit,
      );
      final Result canSkipFolder = await _canSkipDirectory(
        path.join(artifactOutputDirectory, mappedFolder.key),
        remoteFolderContents,
      );

      if (!canSkipFolder.success) {
        _log.info('Cannot skip build step: ${canSkipFolder.error}');
        return false;
      }
    }
    return true;
  }

  Future<GitHubFile> _fetchRemoteFileMetadata(
    MapEntry<String, String> mappedFile,
  ) async {
    final String fileMetadataUrl =
        '${config.coinsRepoApiUrl}/contents/${mappedFile.value}?ref=${config.bundledCoinsRepoCommit}';

    final fileContentResponse = await http.get(Uri.parse(fileMetadataUrl));
    if (fileContentResponse.statusCode != 200) {
      throw Exception(
        'Failed to fetch remote file metadata at $fileMetadataUrl: '
        '${fileContentResponse.statusCode} ${fileContentResponse.reasonPhrase}',
      );
    }

    final GitHubFile fileContent = GitHubFile.fromJson(
      jsonDecode(fileContentResponse.body) as Map<String, dynamic>,
    );

    return fileContent;
  }

  Future<Result> _canSkipFile(
    String localFilePath,
    GitHubFile remoteFile,
  ) async {
    final File localFile = File(localFilePath);

    if (!localFile.existsSync()) {
      return Result.error(
        '$localFilePath does not exist',
      );
    }

    final int localFileSize = await localFile.length();
    if (remoteFile.size != localFileSize) {
      return Result.error(
        '$localFilePath size mismatch: '
        'remote: ${remoteFile.size}, local: $localFileSize',
      );
    }

    final String localFileSha = calculateGithubSha1(localFilePath);
    if (localFileSha != remoteFile.sha) {
      return Result.error(
        '$localFilePath sha mismatch: '
        'remote: ${remoteFile.sha}, local: $localFileSha',
      );
    }

    return Result.success();
  }

  Future<Result> _canSkipDirectory(
    String directory,
    List<GitHubFile> remoteDirectoryContents,
  ) async {
    final Directory localFolder = Directory(directory);

    if (!localFolder.existsSync()) {
      return Result.error('$directory does not exist');
    }

    for (final GitHubFile remoteFile in remoteDirectoryContents) {
      final String localFilePath = path.join(directory, remoteFile.name);
      final Result canSkipFile = await _canSkipFile(
        localFilePath,
        remoteFile,
      );
      if (!canSkipFile.success) {
        return Result.error('Cannot skip build step: ${canSkipFile.error}');
      }
    }

    return Result.success();
  }

  List<String> _getFilesInFolder(String folderPath) {
    final Directory localFolder = Directory(folderPath);
    final List<FileSystemEntity> localFolderContents =
        localFolder.listSync(recursive: true);
    return localFolderContents
        .map((FileSystemEntity file) => file.path)
        .toList();
  }

  Map<String, String> _adjustPaths(Map<String, String> paths) {
    return paths.map(
      (key, value) => MapEntry(path.join(artifactOutputDirectory, key), value),
    );
  }

  void onProgressError(dynamic error) {
    _log.severe('\nError: $error');

    // throw Exception('An error occurred during the coin fetch build step');
  }

  void onProgressData(dynamic message, ReceivePort? recevePort) {
    if (message is BuildProgressMessage) {
      _log.info(
        '\r${message.message} - Progress: ${message.progress.toStringAsFixed(2)}% \x1b[K',
      );

      if (message.progress == 100 && message.finished) {
        _log.info('Progress: 100% - Done. Closing receive port');
        recevePort?.close();
      }
    } else {
      _log.warning('Received unknown message: $message');
    }
  }
}

class BuildStepWithoutRevertException implements Exception {
  BuildStepWithoutRevertException(this.message);

  final String message;

  @override
  String toString() => message;
}
