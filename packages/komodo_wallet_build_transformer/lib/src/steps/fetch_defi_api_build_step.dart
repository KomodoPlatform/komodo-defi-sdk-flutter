import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:komodo_wallet_build_transformer/src/build_step.dart';
import 'package:komodo_wallet_build_transformer/src/steps/github/github_api_provider.dart';
import 'package:komodo_wallet_build_transformer/src/steps/models/api/api_build_platform_config.dart';
import 'package:komodo_wallet_build_transformer/src/steps/models/build_config.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

class FetchDefiApiStep extends BuildStep {
  FetchDefiApiStep({
    // required this.projectRoot,
    required this.apiCommitHash,
    required this.platformsConfig,
    required this.sourceUrls,
    required this.apiBranch,
    required this.artifactOutputPath,
    required this.buildConfigFile,
    required this.githubApiProvider,
    this.selectedPlatform,
    this.forceUpdate = false,
    this.enabled = true,
    this.concurrent = true,
  });

  factory FetchDefiApiStep.withBuildConfig(
    BuildConfig buildConfig,
    Directory artifactOutputPath,
    File buildConfigFile, {
    String? githubToken,
  }) {
    // Assumption here is that the first uri will always be the GitHub API.
    final apiProvider = GithubApiProvider.withBaseUrl(
      baseUrl: buildConfig.apiConfig.sourceUrls.first,
      branch: buildConfig.apiConfig.branch,
      token: githubToken,
    );

    return FetchDefiApiStep(
      // projectRoot: Directory.current.path,
      apiCommitHash: buildConfig.apiConfig.apiCommitHash,
      platformsConfig: buildConfig.apiConfig.platforms,
      sourceUrls: buildConfig.apiConfig.sourceUrls,
      apiBranch: buildConfig.apiConfig.branch,
      // TODO: Change type to Directory?
      artifactOutputPath: artifactOutputPath.path,
      enabled: buildConfig.apiConfig.fetchAtBuildEnabled,
      buildConfigFile: buildConfigFile,
      githubApiProvider: apiProvider,
      concurrent: buildConfig.coinCIConfig.concurrentDownloadsEnabled,
    );
  }
  @override
  final String id = idStatic;
  static const idStatic = 'fetch_defi_api';
  static const String _overrideEnvName = 'OVERRIDE_DEFI_API_DOWNLOAD';

  final _log = Logger('FetchDefiApiStep');

  // final String projectRoot;
  final String apiCommitHash;
  final Map<String, ApiBuildPlatformConfig> platformsConfig;
  final List<String> sourceUrls;
  final String apiBranch;
  final String artifactOutputPath;
  final File buildConfigFile;
  final GithubApiProvider githubApiProvider;
  String? selectedPlatform;
  bool forceUpdate;
  bool enabled;
  final bool concurrent;

  List<String> get platformsToUpdate =>
      selectedPlatform != null && platformsConfig.containsKey(selectedPlatform)
          ? [selectedPlatform!]
          : platformsConfig.keys.toList();

  @override
  Future<void> build() async {
    if (!enabled) {
      _log.info('API update is not enabled in the configuration.');
      return;
    }
    try {
      await updateAPI();
    } catch (e, s) {
      _log.severe('Error updating API', e, s);
      rethrow;
    }
  }

  @override
  Future<bool> canSkip() => Future.value(!enabled);

  @override
  Future<void> revert([Exception? e]) async {
    _log.warning('Reverting changes made by UpdateAPIStep...');
  }

  Future<void> updateAPI() async {
    if (!enabled) {
      _log.info('API update is not enabled in the configuration.');
      return;
    }

    _log.info('=====================');
    if (concurrent) {
      await Future.wait(platformsToUpdate.map(updatePlatformWithProgress));
    } else {
      await Future.forEach(platformsToUpdate, updatePlatformWithProgress);
    }
    _log.info('=====================');
    _updateDocumentationIfExists();
  }

  Future<void> updatePlatformWithProgress(String platform) async {
    if (_isTargetIphone() && platform != 'ios') {
      _log.info('Skipping build for $platform, since target is iOS');
      return;
    }

    final progressString =
        '${platformsToUpdate.indexOf(platform) + 1}/${platformsToUpdate.length}';
    _log.info('[$progressString] Updating $platform platform...');
    await _updatePlatform(platform, platformsConfig);
  }

  /// If set, the OVERRIDE_DEFI_API_DOWNLOAD environment variable will override
  /// any default behavior/configuration. e.g.
  // ignore: lines_longer_than_80_chars
  /// `flutter build web --release --dart-define=OVERRIDE_DEFI_API_DOWNLOAD=true`
  ///  or `OVERRIDE_DEFI_API_DOWNLOAD=true && flutter build web --release`
  ///
  /// If set to true/TRUE/True, the API will be fetched and downloaded on every
  /// build, even if it is already up-to-date with the configuration.
  ///
  /// If set to false/FALSE/False, the API fetching will be skipped, even if
  /// the existing API is not up-to-date with the configuration.
  ///
  /// If unset, the default behavior will be used.
  ///
  /// If both the system environment variable and the dart-defined environment
  /// variable are set, the dart-defined variable will take precedence.
  ///
  /// NB! Setting the value to false is not the same as it being unset.
  /// If the value is unset, the default behavior will be used.
  /// Bear this in mind when setting the value as a system environment variable.
  ///
  /// See `BUILD_CONFIG_README.md`  in `app_build/BUILD_CONFIG_README.md`.
  bool? get overrideDefiApiDownload =>
      const bool.hasEnvironment(_overrideEnvName)
          ? const bool.fromEnvironment(_overrideEnvName)
          : Platform.environment[_overrideEnvName] != null
              ? bool.tryParse(
                  Platform.environment[_overrideEnvName]!,
                  caseSensitive: false,
                )
              : null;

  Future<void> _updatePlatform(
    String platform,
    Map<String, ApiBuildPlatformConfig> config,
  ) async {
    final updateMessage = overrideDefiApiDownload != null
        ? '${overrideDefiApiDownload! ? 'FORCING' : 'SKIPPING'} update of '
            '$platform platform because OVERRIDE_DEFI_API_DOWNLOAD is set to '
            '$overrideDefiApiDownload'
        : null;

    if (updateMessage != null) {
      _log.info(updateMessage);
    }

    final destinationFolder = _getPlatformDestinationFolder(platform);
    final isOutdated =
        await _checkIfOutdated(platform, destinationFolder, config);

    if (!_shouldUpdate(isOutdated)) {
      _log.info('$platform platform is up to date.');
      await _postUpdateActions(platform, destinationFolder);
      return;
    }

    String? zipFilePath;
    for (final sourceUrl in sourceUrls) {
      try {
        final zipFileUrl = await _findZipFileUrl(platform, config, sourceUrl);
        zipFilePath = await _downloadFile(zipFileUrl, destinationFolder);

        if (await _verifyChecksum(zipFilePath, platform)) {
          await _extractZipFile(zipFilePath, destinationFolder);
          _updateLastUpdatedFile(platform, destinationFolder, zipFilePath);
          _log.info('$platform platform update completed.');
          break; // Exit loop if update is successful
        } else {
          _log.warning('SHA256 Checksum verification failed for $zipFilePath');
          if (sourceUrl == sourceUrls.last) {
            throw Exception(
              'API fetch failed for all source URLs: $sourceUrls',
            );
          }
        }
      } catch (e) {
        _log.severe('Error updating from source $sourceUrl: $e');
        if (sourceUrl == sourceUrls.last) {
          rethrow;
        }
      } finally {
        if (zipFilePath != null) {
          try {
            File(zipFilePath).deleteSync();
            _log.info('Deleted zip file $zipFilePath');
          } catch (e) {
            _log.severe('Error deleting zip file', e);
          }
        }
      }
    }

    await _postUpdateActions(platform, destinationFolder);
  }

  bool _shouldUpdate(bool isOutdated) {
    return overrideDefiApiDownload ?? (forceUpdate || isOutdated);
  }

  Future<String> _downloadFile(String url, String destinationFolder) async {
    _log.info('Downloading $url...');
    final response = await http.get(Uri.parse(url));
    _checkResponseSuccess(response);

    final zipFileName = path.basename(url);
    final zipFilePath = path.join(destinationFolder, zipFileName);

    final directory = Directory(destinationFolder);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    final zipFile = File(zipFilePath);
    try {
      await zipFile.writeAsBytes(response.bodyBytes);
    } catch (e) {
      _log.info('Error writing file', e);
      rethrow;
    }

    _log.info('Downloaded $zipFileName');
    return zipFilePath;
  }

  Future<bool> _verifyChecksum(String filePath, String platform) async {
    final validChecksums = List<String>.from(
      platformsConfig[platform]!.validZipSha256Checksums,
    );

    _log.info('validChecksums: $validChecksums');

    final fileBytes = await File(filePath).readAsBytes();
    final fileSha256Checksum = sha256.convert(fileBytes).toString();

    if (validChecksums.contains(fileSha256Checksum)) {
      _log.info('Checksum validated for $filePath');
      return true;
    } else {
      _log.severe(
        'SHA256 Checksum mismatch for $filePath: expected any of '
        '$validChecksums, got $fileSha256Checksum',
      );
      return false;
    }
  }

  void _updateLastUpdatedFile(
    String platform,
    String destinationFolder,
    String zipFilePath,
  ) {
    final lastUpdatedFile =
        File(path.join(destinationFolder, '.api_last_updated_$platform'));
    final currentTimestamp = DateTime.now().toIso8601String();
    final fileChecksum =
        sha256.convert(File(zipFilePath).readAsBytesSync()).toString();
    lastUpdatedFile.writeAsStringSync(
      json.encode({
        'api_commit_hash': apiCommitHash,
        'timestamp': currentTimestamp,
        'checksums': [fileChecksum],
      }),
    );
    _log.info('Updated last updated file for $platform.');
  }

  Future<bool> _checkIfOutdated(
    String platform,
    String destinationFolder,
    Map<String, ApiBuildPlatformConfig> config,
  ) async {
    final lastUpdatedFilePath =
        path.join(destinationFolder, '.api_last_updated_$platform');
    final lastUpdatedFile = File(lastUpdatedFilePath);

    if (!lastUpdatedFile.existsSync()) {
      return true;
    }

    try {
      final lastUpdatedData = json.decode(lastUpdatedFile.readAsStringSync())
              as Map<String, dynamic>? ??
          {};
      if (lastUpdatedData['api_commit_hash'] == apiCommitHash) {
        final storedChecksums =
            List<String>.from(lastUpdatedData['checksums'] as List? ?? []);
        final targetChecksums =
            List<String>.from(config[platform]!.validZipSha256Checksums);

        if (storedChecksums.toSet().containsAll(targetChecksums)) {
          _log.info('version: $apiCommitHash and SHA256 checksum match.');
          return false;
        }
      }
    } catch (e, s) {
      _log.severe('Error reading or parsing .api_last_updated_$platform', e, s);
      lastUpdatedFile.deleteSync();
      rethrow;
    }

    return true;
  }

  Future<void> _updateWebPackages() async {
    // First check for a `package.json` file in the root of the project
    final packageJsonFile = File(path.join(artifactOutputPath, 'package.json'));
    if (!packageJsonFile.existsSync()) {
      _log.info('No package.json file found in $artifactOutputPath');
      return;
    }

    _log
      ..info('Updating Web platform...')
      ..fine('Running npm install in $artifactOutputPath');
    final npmPath = findNode();
    final installResult = await Process.run(
      npmPath,
      ['install'],
      workingDirectory: artifactOutputPath,
    );
    if (installResult.exitCode != 0) {
      throw Exception('npm install failed: ${installResult.stderr}');
    }

    _log.fine('Running npm run build in $artifactOutputPath');
    final buildResult = await Process.run(
      npmPath,
      ['run', 'build'],
      workingDirectory: artifactOutputPath,
    );
    if (buildResult.exitCode != 0) {
      throw Exception('npm run build failed: ${buildResult.stderr}');
    }

    _log.info('Web platform updated successfully.');
  }

  void setFilePermissions(File file) {
    if (Platform.isWindows) {
      Process.runSync('attrib', ['+x', file.path]);
    } else {
      Process.runSync('chmod', ['+x', file.path]);
    }
  }

  void _setExecutablePermissions(String destinationFolder) {
    _log.info('Setting executable permissions for $destinationFolder...');
    // Update the file permissions to make it executable. As part of the
    // transition from mm2 naming to kdf, update whichever file is present.
    // ignore: unused_local_variable
    final binaryNames = ['mm2', 'kdf']
        .map((e) => File(path.join(destinationFolder, e)))
        .where((filePath) => filePath.existsSync());

    if (!Platform.isWindows) {
      for (final filePath in binaryNames) {
        Process.run('chmod', ['+x', filePath.path]);
      }
    }
  }

  String _getPlatformDestinationFolder(String platform) {
    if (platformsConfig.containsKey(platform)) {
      return path.join(artifactOutputPath, platformsConfig[platform]!.path);
    } else {
      throw ArgumentError('Invalid platform: $platform');
    }
  }

  Future<String> _findZipFileUrl(
    String platform,
    Map<String, ApiBuildPlatformConfig> config,
    String sourceUrl,
  ) async {
    if (sourceUrl.startsWith('https://api.github.com/repos/')) {
      return _fetchFromGitHub(platform, config, sourceUrl);
    } else {
      return _fetchFromBaseUrl(platform, config, sourceUrl);
    }
  }

  Future<String> _fetchFromGitHub(
    String platform,
    Map<String, ApiBuildPlatformConfig> config,
    String sourceUrl,
  ) async {
    final releases = await githubApiProvider.getReleases();
    final apiVersionShortHash = apiCommitHash.substring(0, 7);
    final matchingKeyword = config[platform]!.matchingKeyword;

    for (final release in releases) {
      for (final asset in release.assets) {
        final url = asset.browserDownloadUrl;

        if (url.contains(matchingKeyword) &&
            url.contains(apiVersionShortHash)) {
          final commitHash = await githubApiProvider.getLatestCommitHash(
            branch: release.tagName,
          );
          if (commitHash == apiCommitHash) {
            return url;
          }
        }
      }
    }

    throw Exception(
      'Zip file not found for platform $platform in GitHub releases',
    );
  }

  Future<String> _fetchFromBaseUrl(
    String platform,
    Map<String, ApiBuildPlatformConfig> config,
    String sourceUrl,
  ) async {
    if (!config.containsKey(platform)) {
      throw ArgumentError('Invalid platform: $platform');
    }

    final url = '$sourceUrl/$apiBranch/';
    final response = await http.get(Uri.parse(url));
    _checkResponseSuccess(response);

    final document = parser.parse(response.body);
    final matchingKeyword = config[platform]!.matchingKeyword;
    final extensions = ['.zip'];
    final apiVersionShortHash = apiCommitHash.substring(0, 7);

    for (final element in document.querySelectorAll('a')) {
      final href = element.attributes['href'];
      if (href != null &&
          href.contains(matchingKeyword) &&
          extensions.any(href.endsWith) &&
          href.contains(apiVersionShortHash)) {
        return '$sourceUrl/$apiBranch/$href';
      }
    }

    throw Exception('Zip file not found for platform $platform');
  }

  void _checkResponseSuccess(http.Response response) {
    if (response.statusCode != 200) {
      throw HttpException(
        'Failed to fetch data: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
  }

  // TODO: Dynamically determine if the platform is using an executable file
  // or static/dynamic library.
  bool _isBinaryExecutable(String platform) {
    return platform == 'linux' || platform == 'macos' || platform == 'windows';
  }

  Future<void> _postUpdateActions(String platform, String destinationFolder) {
    if (platform == 'web') {
      return _updateWebPackages();
      // TODO: Consider adding npm if it makes a significant difference to
      // file build size or if it is required for cache-busting.
    }
    if (_isBinaryExecutable(platform)) {
      _setExecutablePermissions(destinationFolder);
    }
    return Future.value();
  }

  Future<void> _extractZipFile(
    String zipFilePath,
    String destinationFolder,
  ) async {
    try {
      // Determine the platform to use the appropriate extraction command
      if (Platform.isMacOS || Platform.isLinux) {
        // For macOS and Linux, use the `unzip` command with overwrite option
        final result = await Process.run(
          'unzip',
          ['-o', zipFilePath, '-d', destinationFolder],
        );
        if (result.exitCode != 0) {
          throw Exception('Error extracting zip file: ${result.stderr}');
        }
      } else if (Platform.isWindows) {
        // For Windows, use PowerShell's Expand-Archive command
        final result = await Process.run('powershell', [
          'Expand-Archive',
          '-Path',
          zipFilePath,
          '-DestinationPath',
          destinationFolder,
        ]);
        if (result.exitCode != 0) {
          throw Exception('Error extracting zip file: ${result.stderr}');
        }
      } else {
        _log.severe('Unsupported platform: ${Platform.operatingSystem}');
        throw UnsupportedError('Unsupported platform');
      }
      _log.info('Extraction completed.');
    } catch (e) {
      _log.shout('Failed to extract zip file: $e');
      rethrow;
    }
  }

  void _updateDocumentationIfExists() {
    //   final documentationFile = File('$projectRoot/docs/UPDATE_API_MODULE.md');
    //   if (!documentationFile.existsSync()) {
    //     return;
    //   }

    //   final content = documentationFile.readAsStringSync().replaceAllMapped(
    //         RegExp(r'(Current api module version is) `([^`]+)`'),
    //         (match) => '${match[1]} `$apiCommitHash`',
    //       );
    //   documentationFile.writeAsStringSync(content);
    //   _logMessage('Updated API version in documentation.');
    // }
  }

  bool _isTargetIphone() {
    return Platform.environment['TARGET_DEVICE_PLATFORM_NAME'] == 'iphoneos' ||
        Platform.environment['TARGET_DEVICE_PLATFORM_NAME'] ==
            'iphonesimulator' ||
        Platform.environment['SWIFT_PLATFORM_TARGET_PREFIX'] == 'ios';
  }

  String findNode() {
    if (Platform.isWindows) {
      return findNodeWindows();
    } else if (Platform.isLinux || Platform.isMacOS) {
      return findNodeUnix();
    } else {
      return 'npm';
    }
  }

  String findNodeUnix() {
    // Common npm locations on macOS
    final commonLocations = [
      '/usr/local/bin/npm',
      '/usr/bin/npm',
      '/opt/homebrew/bin/npm',
    ];

    // Check common locations
    for (final location in commonLocations) {
      if (File(location).existsSync()) {
        return location;
      }
    }

    // Check PATH environment variable
    final pathEnv = Platform.environment['PATH'];
    if (pathEnv != null) {
      final paths = pathEnv.split(':');
      for (final path in paths) {
        final npmPath = '$path/npm';
        if (File(npmPath).existsSync()) {
          return npmPath;
        }
      }
    }

    // Check NVM_BIN environment variable
    final nvmBin = Platform.environment['NVM_BIN'];
    if (nvmBin != null) {
      final npmPath = '$nvmBin/npm';
      if (File(npmPath).existsSync()) {
        return npmPath;
      }
    }

    // Check NODE_PATH environment variable
    final nodePath = Platform.environment['NODE_PATH'];
    if (nodePath != null) {
      final npmPath = '$nodePath/npm';
      if (File(npmPath).existsSync()) {
        return npmPath;
      }
    }

    // If npm is not found, throw an exception
    throw Exception(
      'npm not found in common locations or environment variables. '
      'Please ensure npm is installed and accessible.',
    );
  }

  String findNodeWindows() {
    final commonLocations = [
      'C:/Program Files/nodejs/npm.cmd',
      'C:/Program Files (x86)/nodejs/npm.cmd',
      'C:/Program Files/nodejs/npm',
      'C:/Program Files (x86)/nodejs/npm',
    ];

    for (final location in commonLocations) {
      if (File(location).existsSync()) {
        return location;
      }
    }

    final nodePath = Platform.environment['PATH'];
    if (nodePath != null) {
      return nodePath;
    }

    throw Exception('NODE_PATH not found in environment variables.');
  }
}
