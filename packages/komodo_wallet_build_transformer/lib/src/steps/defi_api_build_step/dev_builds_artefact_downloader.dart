import 'dart:io';

import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:komodo_wallet_build_transformer/src/steps/defi_api_build_step/artefact_downloader.dart';
import 'package:komodo_wallet_build_transformer/src/steps/models/api/api_file_matching_config.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

class DevBuildsArtefactDownloader implements ArtefactDownloader {
  DevBuildsArtefactDownloader({
    required this.apiBranch,
    required this.apiCommitHash,
    required this.sourceUrl,
  });

  final _log = Logger('DevBuildsArtefactDownloader');

  @override
  final String apiBranch;

  @override
  final String apiCommitHash;

  @override
  final String sourceUrl;

  @override
  Future<String> fetchDownloadUrl(
    ApiFileMatchingConfig matchingConfig,
    String platform,
  ) async {
    final url = '$sourceUrl/$apiBranch/';
    final response = await http.get(Uri.parse(url));
    response.throwIfNotSuccessResponse();

    final document = parser.parse(response.body);
    final extensions = ['.zip'];

    // Support both full and short hash variants
    final fullHash = apiCommitHash;
    final shortHash = apiCommitHash.substring(0, 7);
    _log.info('Looking for files with hash $fullHash or $shortHash');

    // Look for files with either hash length
    final attemptedFiles = <String>[];
    for (final element in document.querySelectorAll('a')) {
      final href = element.attributes['href'];
      if (href != null) attemptedFiles.add(href);
      if (href != null &&
          matchingConfig.matches(href) &&
          extensions.any(href.endsWith)) {
        if (href.contains(fullHash) || href.contains(shortHash)) {
          _log.info('Found matching file: $href');
          return '$sourceUrl/$apiBranch/$href';
        }
      }
    }

    final availableAssets = attemptedFiles.join('\n');
    _log.fine(
      'No matching files found in $sourceUrl. '
      '\nPattern: ${matchingConfig.matchingPattern}, '
      '\nHashes tried: [$fullHash, $shortHash]'
      '\nAvailable assets: $availableAssets',
    );

    throw Exception('Zip file not found for platform $platform');
  }

  @override
  Future<String> downloadArtefact({
    required String url,
    required String destinationPath,
  }) async {
    _log.info('Downloading $url...');
    final response = await http.get(Uri.parse(url));
    response.throwIfNotSuccessResponse();

    final zipFileName = path.basename(url);
    final zipFilePath = path.join(destinationPath, zipFileName);

    final directory = Directory(destinationPath);
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

  @override
  Future<void> extractArtefact({
    required String filePath,
    required String destinationFolder,
  }) async {
    try {
      // Determine the platform to use the appropriate extraction command
      if (Platform.isMacOS || Platform.isLinux) {
        // For macOS and Linux, use the `unzip` command with overwrite option
        final result = await Process.run(
          'unzip',
          ['-o', filePath, '-d', destinationFolder],
        );
        if (result.exitCode != 0) {
          throw Exception('Error extracting zip file: ${result.stderr}');
        }
      } else if (Platform.isWindows) {
        // For Windows, use PowerShell's Expand-Archive command
        final result = await Process.run('powershell', [
          'Expand-Archive',
          '-Path',
          filePath,
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
}
