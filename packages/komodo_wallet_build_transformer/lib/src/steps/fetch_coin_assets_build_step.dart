// ignore_for_file: avoid_print
// TODO(Francois): Change print statements to Log statements

import 'dart:async';
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
import 'package:path/path.dart' as path;

/// Entry point used if invoked as a CLI script.
const String defaultBuildConfigPath = 'app_build/build_config.json';

class FetchCoinAssetsBuildStep extends BuildStep {
  FetchCoinAssetsBuildStep({
    required this.projectDir,
    required this.config,
    required this.downloader,
    required this.originalBuildConfig,
    this.receivePort,
  }) {
    receivePort?.listen(
      (dynamic message) => onProgressData(message, receivePort),
      onError: onProgressError,
    );
  }

  factory FetchCoinAssetsBuildStep.withBuildConfig(
      Map<String, dynamic> buildConfig,
      [ReceivePort? receivePort]) {
    final CoinCIConfig config = CoinCIConfig.fromJson(buildConfig['coins']);
    final GitHubFileDownloader downloader = GitHubFileDownloader(
      repoApiUrl: config.coinsRepoApiUrl,
      repoContentUrl: config.coinsRepoContentUrl,
    );

    return FetchCoinAssetsBuildStep(
      projectDir: Directory.current.path,
      config: config,
      downloader: downloader,
      originalBuildConfig: buildConfig,
    );
  }

  @override
  final String id = idStatic;
  static const idStatic = 'fetch_coin_assets';
  final Map<String, dynamic>? originalBuildConfig;
  final String projectDir;
  final CoinCIConfig config;
  final GitHubFileDownloader downloader;
  final ReceivePort? receivePort;

  @override
  Future<void> build() async {
    final alreadyHadCoinAssets = File('assets/config/coins.json').existsSync();
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
        assetPath: defaultBuildConfigPath,
        originalBuildConfig: originalBuildConfig,
      );
    }

    await downloader.download(
      configWithUpdatedCommit.bundledCoinsRepoCommit,
      configWithUpdatedCommit.mappedFiles,
      configWithUpdatedCommit.mappedFolders,
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
        stderr.writeln(errorMessage);
        receivePort?.close();
        throw StepCompletedWithChangesException(errorMessage);
      }

      stdout.writeln('\n[WARN] $errorMessage\n');
    }

    receivePort?.close();
    stdout.writeln('\nCoin assets fetched successfully');
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
    if (e is StepCompletedWithChangesException) {
      print(
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
      final GitHubFile remoteFile = await _fetchRemoteFileContent(mappedFile);
      final Result canSkipFile = await _canSkipFile(
        mappedFile.key,
        remoteFile,
      );
      if (!canSkipFile.success) {
        print('Cannot skip build step: ${canSkipFile.error}');
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
        mappedFolder.key,
        remoteFolderContents,
      );

      if (!canSkipFolder.success) {
        print('Cannot skip build step: ${canSkipFolder.error}');
        return false;
      }
    }
    return true;
  }

  Future<GitHubFile> _fetchRemoteFileContent(
    MapEntry<String, String> mappedFile,
  ) async {
    final Uri fileContentUrl = Uri.parse(
      '${config.coinsRepoApiUrl}/contents/${mappedFile.value}?ref=${config.bundledCoinsRepoCommit}',
    );
    final http.Response fileContentResponse = await http.get(fileContentUrl);
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
}

void onProgressError(dynamic error) {
  print('\nError: $error');

  // throw Exception('An error occurred during the coin fetch build step');
}

void onProgressData(dynamic message, ReceivePort? recevePort) {
  if (message is BuildProgressMessage) {
    stdout.write(
      '\r${message.message} - Progress: ${message.progress.toStringAsFixed(2)}% \x1b[K',
    );

    if (message.progress == 100 && message.finished) {
      recevePort?.close();
    }
  }
}

class StepCompletedWithChangesException implements Exception {
  StepCompletedWithChangesException(this.message);

  final String message;

  @override
  String toString() => message;
}
