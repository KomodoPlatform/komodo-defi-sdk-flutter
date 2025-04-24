// ignore_for_file: unnecessary_string_escapes

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

/// CLI script to fetch the latest commit for a branch, fetch the URL and checksum for binaries,
/// and update the build config. Can also perform automatic detection and rolling of updates.
void main(List<String> arguments) async {
  final log = Logger('kdf-fetch-cli');

  // Setup logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      // ignore: avoid_print
      print(record.error);
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print(record.stackTrace);
    }
  });

  // Parse arguments
  final parser =
      ArgParser()
        ..addOption(
          'branch',
          abbr: 'b',
          help: 'Branch to fetch commit from',
          defaultsTo: 'master',
        )
        ..addOption(
          'repo',
          help: 'GitHub repository in format owner/repo',
          defaultsTo: 'KomodoPlatform/komodo-defi-framework',
        )
        ..addOption(
          'config',
          abbr: 'c',
          help: 'Path to build config file',
          defaultsTo: 'build_config.json',
        )
        ..addOption(
          'output-dir',
          abbr: 'o',
          help: 'Output directory for temporary downloads',
          defaultsTo: 'temp_downloads',
        )
        ..addOption('token', abbr: 't', help: 'GitHub token for API access')
        ..addOption(
          'platform',
          abbr: 'p',
          help: 'Platform to update (e.g., web, macos, windows, linux)',
          defaultsTo: 'all',
        )
        ..addOption(
          'source',
          abbr: 's',
          help: 'Source to fetch from (github or mirror)',
          defaultsTo: 'github',
        )
        ..addOption(
          'mirror-url',
          help: 'Mirror URL if using mirror source',
          defaultsTo: 'https://sdk.devbuilds.komodo.earth',
        )
        ..addFlag(
          'auto-roll',
          help: 'Automatically detect and process updates',
          negatable: false,
        )
        ..addFlag(
          'validate',
          help: 'Validate configuration by building example app',
          defaultsTo: true,
        )
        ..addFlag(
          'help',
          abbr: 'h',
          negatable: false,
          help: 'Show usage information',
        )
        ..addFlag(
          'verbose',
          abbr: 'v',
          negatable: false,
          help: 'Enable verbose logging',
        );

  ArgResults args;
  try {
    args = parser.parse(arguments);
  } catch (e) {
    log.severe('Error parsing arguments: $e');
    printUsage(parser);
    exit(1);
  }

  if (args['help'] as bool) {
    printUsage(parser);
    return;
  }

  if (args['verbose'] as bool) {
    Logger.root.level = Level.ALL;
    log.info('Verbose logging enabled');
  }

  final branch = args['branch'] as String;
  final repo = args['repo'] as String;
  final configPath = args['config'] as String;
  final outputDir = args['output-dir'] as String;
  final token = args['token'] as String?;
  final platform = args['platform'] as String;
  final source = args['source'] as String;
  final mirrorUrl = args['mirror-url'] as String;
  final verbose = args['verbose'] as bool;

  try {
    final autoRoll = args['auto-roll'] as bool;
    final shouldValidate = args['validate'] as bool;
    
    final fetcher = KdfFetcher(
      branch: branch,
      repo: repo,
      configPath: configPath,
      outputDir: outputDir,
      token: token,
      source: source,
      mirrorUrl: mirrorUrl,
      verbose: verbose,
    );
    
    if (autoRoll) {
      log.info('Running in auto-roll mode. Will check for updates and process if found...');
      final success = await fetcher.performCompleteRoll(validate: shouldValidate);
      
      if (!success) {
        log.info('Auto-roll process completed without updates or encountered errors.');
        exit(1); // Exit with error code if no updates or process failed
      }
      
      log.info('Auto-roll process completed successfully.');
    } else {
      // Original flow for manual updates
      await fetcher.loadBuildConfig();
  
      log.info('Fetching latest commit for branch: $branch');
      final commitHash = await fetcher.fetchLatestCommit();
      log.info('Latest commit: $commitHash');
  
      if (platform == 'all') {
        final platforms = fetcher.getSupportedPlatforms();
        log.info('Updating config for all platforms: ${platforms.join(', ')}');
  
        for (final plat in platforms) {
          await fetcher.updatePlatformConfig(plat, commitHash);
        }
      } else {
        log.info('Updating config for platform: $platform');
        await fetcher.updatePlatformConfig(platform, commitHash);
      }
  
      await fetcher.updateBuildConfig(commitHash);
      log.info('Build config updated successfully');
    }

    // Clean up temporary directory
    final tempDir = Directory(outputDir);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
      log.info('Cleaned up temporary directory');
    }
  } catch (e, stackTrace) {
    log.severe('Error: $e', e, stackTrace);
    exit(1);
  }
}

void printUsage(ArgParser parser) {
  // ignore: avoid_print
  print('''
KDF Fetch CLI Tool

This script fetches the latest commit for a specified branch, locates available binaries,
calculates their checksums, and updates the build config with this information. It does not
extract or set up the files - that is the responsibility of the build step.

It supports both GitHub releases and the internal mirror site at:
https://sdk.devbuilds.komodo.earth/

Usage:
  dart run komodo_wallet_cli:update_api_config [options]

If you've activated the package globally, you can also use:
  komodo_wallet_cli update_api_config --branch dev --source mirror --config path/to/build_config.json

Options:
${parser.usage}

Examples:
  # Basic command to update the config for all platforms with the latest dev branch from mirror
  dart run komodo_wallet_cli:update_api_config \
    --branch dev \
    --source mirror \
    --config packages/komodo_defi_framework/app_build/build_config.json \
    --output-dir packages/komodo_defi_framework/app_build/temp_downloads \
    --verbose

  # Update only the web platform
  dart run komodo_wallet_cli:update_api_config \
    --branch dev \
    --source mirror \
    --platform web \
    --config packages/komodo_defi_framework/app_build/build_config.json \
    --output-dir packages/komodo_defi_framework/app_build/temp_downloads

  # Update using GitHub as the source
  dart run komodo_wallet_cli:update_api_config \
    --branch master \
    --source github \
    --config packages/komodo_defi_framework/app_build/build_config.json \
    --output-dir packages/komodo_defi_framework/app_build/temp_downloads

  # Using a custom mirror URL
  dart run komodo_wallet_cli:update_api_config \
    --branch dev \
    --source mirror \
    --mirror-url https://custom-mirror.example.com \
    --config packages/komodo_defi_framework/app_build/build_config.json \
    --output-dir packages/komodo_defi_framework/app_build/temp_downloads

  # Automatic update detection and roll (for CI)
  dart run komodo_wallet_cli:update_api_config \
    --auto-roll \
    --branch dev \
    --config packages/komodo_defi_framework/app_build/build_config.json \
    --output-dir packages/komodo_defi_framework/app_build/temp_downloads \
    --verbose
''');
}

/// Main class for handling the KDF fetch operations
class KdfFetcher {
  KdfFetcher({
    required this.branch,
    required this.repo,
    required this.configPath,
    required this.outputDir,
    required this.verbose,
    this.token,
    this.source = 'github',
    this.mirrorUrl = 'https://sdk.devbuilds.komodo.earth',
  }) {
    final parts = repo.split('/');
    if (parts.length != 2) {
      throw ArgumentError('Repository should be in format owner/repo');
    }
    owner = parts[0];
    repository = parts[1];

    // Create output directory if it doesn't exist
    final outputDirObj = Directory(outputDir);
    if (!outputDirObj.existsSync()) {
      outputDirObj.createSync(recursive: true);
    }

    if (source != 'github' && source != 'mirror') {
      throw ArgumentError('Source must be either "github" or "mirror"');
    }
  }

  final String branch;
  final String repo;
  final String configPath;
  final String outputDir;
  final String? token;
  final String source;
  final String mirrorUrl;
  late final String owner;
  late final String repository;
  final bool verbose;
  final log = Logger('KdfFetcher');

  Map<String, dynamic>? _configData;

  /// Headers to use for GitHub API requests
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Get the GitHub API URL for this repo
  String get _apiBaseUrl => 'https://api.github.com/repos/$owner/$repository';

  /// Fetches the latest commit hash for the specified branch
  Future<String> fetchLatestCommit() async {
    final url = '$_apiBaseUrl/commits/$branch';
    log.fine('Fetching latest commit from: $url');

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch latest commit: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['sha'] as String;
  }

  /// Loads the build config file
  Future<Map<String, dynamic>> loadBuildConfig() async {
    if (_configData != null) {
      return _configData!;
    }

    final configFile = File(configPath);
    if (!configFile.existsSync()) {
      throw FileSystemException('Build config file not found', configPath);
    }

    final configContent = await configFile.readAsString();
    _configData = jsonDecode(configContent) as Map<String, dynamic>;

    if (verbose) {
      log.info('Loaded build config: $_configData');
    }

    return _configData!;
  }

  /// Gets the list of supported platforms from the build config
  List<String> getSupportedPlatforms() {
    final config = _configData?['api'] as Map<String, dynamic>?;
    if (config == null) {
      throw StateError('Build config not loaded or missing api section');
    }

    final platforms = config['platforms'] as Map<String, dynamic>?;
    if (platforms == null) {
      throw StateError('Build config missing platforms section');
    }

    return platforms.keys.toList();
  }

  /// Locates and verifies download URL for a platform
  Future<void> updatePlatformConfig(String platform, String commitHash) async {
    log.info(
      'Updating config for platform: $platform with commit: $commitHash',
    );

    final config = await loadBuildConfig();
    final apiConfig = config['api'] as Map<String, dynamic>;

    final platforms = apiConfig['platforms'] as Map<String, dynamic>;
    if (!platforms.containsKey(platform)) {
      throw ArgumentError('Platform $platform not found in config');
    }

    final platformConfig = platforms[platform] as Map<String, dynamic>;

    try {
      // Get download URL
      final downloadUrl = await fetchDownloadUrl(platform, commitHash);
      log.info('Located binary at: $downloadUrl');

      // Download binary to calculate checksum
      final zipFilePath = await downloadBinary(downloadUrl, platform);

      // Calculate checksum
      final checksum = await calculateChecksum(zipFilePath);
      log.info('Calculated checksum: $checksum');

      // Update platform config with new checksum
      final checksums =
          platformConfig['valid_zip_sha256_checksums'] as List<dynamic>;
      if (!listEquals(checksums, [checksum])) {
        log.info('Added new checksum to platform config: $checksum');
        platformConfig['valid_zip_sha256_checksums'] = [checksum];
      } else {
        log.info('Checksum already exists in platform config');
      }
    } catch (e) {
      log.severe('Error updating platform config for $platform: $e');
      throw Exception('Failed to update platform $platform: $e');
    }
  }

  /// Fetches the download URL for a release asset matching the given platform
  Future<String> fetchDownloadUrl(String platform, String commitHash) async {
    final config = await loadBuildConfig();
    final apiConfig = config['api'] as Map<String, dynamic>;
    final platformConfig =
        (apiConfig['platforms'] as Map<String, dynamic>)[platform]
            as Map<String, dynamic>;

    // Get the matching pattern/keyword
    final matchingPattern = platformConfig['matching_pattern'] as String?;
    final matchingKeyword = platformConfig['matching_keyword'] as String?;

    if (matchingPattern == null && matchingKeyword == null) {
      throw StateError(
        'Platform config missing matching_pattern or matching_keyword',
      );
    }

    if (source == 'github') {
      return _fetchGithubDownloadUrl(
        platform,
        commitHash,
        matchingPattern,
        matchingKeyword,
      );
    } else {
      return _fetchMirrorDownloadUrl(
        platform,
        commitHash,
        matchingPattern,
        matchingKeyword,
      );
    }
  }

  /// Fetches download URL from GitHub releases
  Future<String> _fetchGithubDownloadUrl(
    String platform,
    String commitHash,
    String? matchingPattern,
    String? matchingKeyword,
  ) async {
    // Get releases
    final releasesUrl = '$_apiBaseUrl/releases';
    log.fine('Fetching releases from: $releasesUrl');

    final response = await http.get(Uri.parse(releasesUrl), headers: _headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch releases: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final releases = jsonDecode(response.body) as List<dynamic>;

    // Look for the asset with the matching pattern/keyword and commit hash
    final shortHash = commitHash.substring(0, 7);

    for (final release in releases) {
      final assets = release['assets'] as List<dynamic>;

      for (final asset in assets) {
        final fileName = asset['name'] as String;

        var matches = false;
        if (matchingPattern != null) {
          try {
            final regex = RegExp(matchingPattern);
            matches = regex.hasMatch(fileName);
          } catch (e) {
            log.warning('Invalid regex pattern: $matchingPattern');
          }
        } else if (matchingKeyword != null) {
          matches = fileName.contains(matchingKeyword);
        }

        if (matches &&
            (fileName.contains(commitHash) || fileName.contains(shortHash))) {
          return asset['browser_download_url'] as String;
        }
      }
    }

    // If we couldn't find an exact match, try just matching the platform pattern
    for (final release in releases) {
      final assets = release['assets'] as List<dynamic>;

      for (final asset in assets) {
        final fileName = asset['name'] as String;

        var matches = false;
        if (matchingPattern != null) {
          try {
            final regex = RegExp(matchingPattern);
            matches = regex.hasMatch(fileName);
          } catch (e) {
            log.warning('Invalid regex pattern: $matchingPattern');
          }
        } else if (matchingKeyword != null) {
          matches = fileName.contains(matchingKeyword);
        }

        if (matches) {
          log.warning(
            'Could not find exact commit match. Using latest matching asset: $fileName',
          );
          return asset['browser_download_url'] as String;
        }
      }
    }

    throw Exception(
      'No matching asset found for platform $platform and commit $commitHash',
    );
  }

  /// Fetches download URL from mirror site
  Future<String> _fetchMirrorDownloadUrl(
    String platform,
    String commitHash,
    String? matchingPattern,
    String? matchingKeyword,
  ) async {
    final url = '$mirrorUrl/$branch/';
    log.fine('Fetching files from mirror: $url');

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch files from mirror: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final document = parser.parse(response.body);
    final extensions = ['.zip'];

    // Support both full and short hash variants
    final fullHash = commitHash;
    final shortHash = commitHash.substring(0, 7);
    log.info('Looking for files with hash $fullHash or $shortHash');

    // Look for files with either hash length
    final attemptedFiles = <String>[];
    for (final element in document.querySelectorAll('a')) {
      final href = element.attributes['href'];
      if (href != null) attemptedFiles.add(href);

      if (href != null && extensions.any(href.endsWith)) {
        var matches = false;
        if (matchingPattern != null) {
          try {
            final regex = RegExp(matchingPattern);
            matches = regex.hasMatch(href);
          } catch (e) {
            log.warning('Invalid regex pattern: $matchingPattern');
          }
        } else if (matchingKeyword != null) {
          matches = href.contains(matchingKeyword);
        }

        if (matches && (href.contains(fullHash) || href.contains(shortHash))) {
          log.info('Found matching file: $href');
          return '$url$href';
        }
      }
    }

    // If we couldn't find an exact match, try just matching the platform pattern
    for (final element in document.querySelectorAll('a')) {
      final href = element.attributes['href'];

      if (href != null && extensions.any(href.endsWith)) {
        var matches = false;
        if (matchingPattern != null) {
          try {
            final regex = RegExp(matchingPattern);
            matches = regex.hasMatch(href);
          } catch (e) {
            log.warning('Invalid regex pattern: $matchingPattern');
          }
        } else if (matchingKeyword != null) {
          matches = href.contains(matchingKeyword);
        }

        if (matches) {
          log.warning(
            'Could not find exact commit match. Using latest matching asset: $href',
          );
          return '$url$href';
        }
      }
    }

    final availableAssets = attemptedFiles.join('\n');
    log.fine(
      'No matching files found in $url. '
      '\nPattern: $matchingPattern, '
      '\nKeyword: $matchingKeyword, '
      '\nHashes tried: [$fullHash, $shortHash]'
      '\nAvailable assets: $availableAssets',
    );

    throw Exception(
      'No matching asset found for platform $platform and commit $commitHash',
    );
  }

  /// Downloads a binary from the given URL
  Future<String> downloadBinary(String url, String platform) async {
    log.info('Downloading from: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to download binary: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final fileName = path.basename(url);
    final filePath = path.join(outputDir, fileName);

    await File(filePath).writeAsBytes(response.bodyBytes);
    log.info('Downloaded to: $filePath');

    return filePath;
  }

  /// Calculates the SHA-256 checksum of a file
  Future<String> calculateChecksum(String filePath) async {
    final file = File(filePath);

    if (!file.existsSync()) {
      throw FileSystemException('File not found', filePath);
    }

    final bytes = await file.readAsBytes();
    final checksum = sha256.convert(bytes).toString();

    log.info('Calculated checksum: $checksum for $filePath');

    return checksum;
  }

  /// Updates the build config with the new commit hash and writes it back to disk
  Future<void> updateBuildConfig(String commitHash) async {
    final config = await loadBuildConfig();
    final apiConfig = config['api'] as Map<String, dynamic>;

    // Update commit hash
    apiConfig['api_commit_hash'] = commitHash;

    // Write config back to disk
    final configFile = File(configPath);
    const encoder = JsonEncoder.withIndent('    ');
    await configFile.writeAsString(encoder.convert(config));

    log.info('Updated build config with commit hash: $commitHash');
  }

  /// Checks if there's a new commit available compared to what's in the config file
  Future<Map<String, dynamic>> checkForNewCommit() async {
    final currentConfig = await loadBuildConfig();
    final apiConfig = currentConfig['api'] as Map<String, dynamic>;
    final currentCommit = apiConfig['api_commit_hash'] as String;
    
    final latestCommit = await fetchLatestCommit();
    
    log.info('Current commit: $currentCommit');
    log.info('Latest commit: $latestCommit');
    
    return {
      'current_commit': currentCommit,
      'latest_commit': latestCommit,
      'has_updates': currentCommit != latestCommit,
    };
  }

  /// Attempts to update using all available source URLs
  Future<bool> tryAllSources(String commitHash) async {
    final config = await loadBuildConfig();
    final apiConfig = config['api'] as Map<String, dynamic>;
    final sourceUrls = List<String>.from(apiConfig['source_urls'] as List);
    
    for (final sourceUrl in sourceUrls) {
      try {
        final isGithubSource = sourceUrl.contains('api.github.com');
        final sourceType = isGithubSource ? 'github' : 'mirror';
        final mirrorUrlToUse = isGithubSource ? mirrorUrl : sourceUrl;
        
        log.info('Trying source URL: $sourceUrl (${sourceType})');
        
        // Create a new fetcher with these parameters
        final fetcher = KdfFetcher(
          branch: this.branch,
          repo: this.repo,
          configPath: this.configPath,
          outputDir: this.outputDir,
          token: this.token,
          source: sourceType,
          mirrorUrl: mirrorUrlToUse,
          verbose: this.verbose,
        );
        
        await fetcher.loadBuildConfig();
        
        // Update all platforms
        final platforms = fetcher.getSupportedPlatforms();
        for (final platform in platforms) {
          await fetcher.updatePlatformConfig(platform, commitHash);
        }
        
        await fetcher.updateBuildConfig(commitHash);
        log.info('Successfully updated using $sourceUrl');
        return true;
      } catch (e) {
        log.warning('Failed to update using $sourceUrl: $e');
      }
    }
    
    return false; // All sources failed
  }

  /// Validates the configuration by building the example app
  Future<bool> validateConfig() async {
    log.info('Validating configuration by building example app...');
    
    try {
      // Find the example path relative to the config path
      final configDir = path.dirname(configPath);
      final examplePath = path.join(configDir, '..', '..', 'komodo_defi_sdk', 'example');
      
      log.info('Using example path: $examplePath');
      
      // Check if the directory exists
      if (!Directory(examplePath).existsSync()) {
        log.severe('Example directory not found: $examplePath');
        return false;
      }
      
      // Run flutter commands
      final pubGetResult = await Process.run('flutter', ['pub', 'get'], 
          workingDirectory: examplePath);
      
      if (pubGetResult.exitCode != 0) {
        log.severe('Flutter pub get failed: ${pubGetResult.stderr}');
        return false;
      }
      
      final buildResult = await Process.run('flutter', ['build', 'web', '--release'],
          workingDirectory: examplePath);
      
      if (buildResult.exitCode != 0) {
        log.severe('Flutter build failed: ${buildResult.stderr}');
        return false;
      }
      
      log.info('Validation successful');
      return true;
    } catch (e) {
      log.severe('Validation failed: $e');
      return false;
    }
  }

  /// Performs the complete roll process (check for updates, update, validate)
  Future<bool> performCompleteRoll({bool validate = true}) async {
    await loadBuildConfig();
    
    // Check if there's a new commit
    final updateInfo = await checkForNewCommit();
    final currentCommit = updateInfo['current_commit'] as String;
    final latestCommit = updateInfo['latest_commit'] as String;
    final hasUpdates = updateInfo['has_updates'] as bool;
    
    if (!hasUpdates) {
      log.info('No updates available.');
      return false;
    }
    
    log.info('New commit found, updating configuration...');
    
    // Try all sources
    final success = await tryAllSources(latestCommit);
    if (!success) {
      log.severe('All sources failed. Update failed.');
      return false;
    }
    
    // Validate the configuration if requested
    if (validate) {
      final isValid = await validateConfig();
      if (!isValid) {
        log.severe('Validation failed. Update rolled back.');
        // Restore the previous configuration
        await updateBuildConfig(currentCommit);
        return false;
      }
    }
    
    log.info('Update completed successfully.');
    return true;
  }
}

// ================ Credit to Flutter team: ================
// https://api.flutter.dev/flutter/foundation/listEquals.html
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  if (identical(a, b)) {
    return true;
  }
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}
// =========================================