import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:http/http.dart' as http;
import 'package:komodo_defi_sdk/src/zcash_params/models/download_progress.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/zcash_params_config.dart';
import 'package:path/path.dart' as path;

/// Interface for ZCash parameters download functionality.
///
/// This service provides the common downloading logic that can be shared
/// across different platform implementations.
abstract class ZcashParamsDownloadService {
  /// Downloads missing parameter files to the specified directory.
  ///
  /// Returns true if all files were downloaded successfully, false otherwise.
  /// Progress is reported through the [progressStream].
  Future<bool> downloadMissingFiles(
    String destinationDirectory,
    List<String> missingFiles,
    StreamController<DownloadProgress> progressController,
    bool Function() isCancelled,
    ZcashParamsConfig config,
  );

  /// Checks which parameter files are missing from the destination directory.
  Future<List<String>> getMissingFiles(
    String destinationDirectory,
    File Function(String) fileFactory,
    ZcashParamsConfig config,
  );

  /// Creates the destination directory if it doesn't exist.
  Future<void> ensureDirectoryExists(
    String directoryPath,
    Directory Function(String) directoryFactory,
  );

  /// Validates that all parameter files exist and have valid hashes.
  Future<bool> validateFiles(
    String directoryPath,
    File Function(String) fileFactory,
    ZcashParamsConfig config,
  );

  /// Validates the SHA256 hash of a specific file.
  Future<bool> validateFileHash(
    String filePath,
    String expectedHash,
    File Function(String) fileFactory,
  );

  /// Gets the SHA256 hash of a file.
  Future<String?> getFileHash(
    String filePath,
    File Function(String) fileFactory,
  );

  /// Gets the file size from HTTP headers without downloading.
  Future<int?> getRemoteFileSize(String url);

  /// Clears all parameter files from the directory.
  Future<bool> clearFiles(
    String directoryPath,
    Directory Function(String) directoryFactory,
  );

  /// Disposes of resources used by this service.
  void dispose();
}

/// Default implementation of ZcashParamsDownloadService.
class DefaultZcashParamsDownloadService implements ZcashParamsDownloadService {
  /// Creates a DefaultZcashParamsDownloadService instance.
  DefaultZcashParamsDownloadService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  Future<bool> downloadMissingFiles(
    String destinationDirectory,
    List<String> missingFiles,
    StreamController<DownloadProgress> progressController,
    bool Function() isCancelled,
    ZcashParamsConfig config,
  ) async {
    for (final fileName in missingFiles) {
      if (isCancelled()) {
        return false;
      }

      final success = await _downloadFile(
        fileName,
        destinationDirectory,
        progressController,
        isCancelled,
        config,
      );

      if (!success) {
        return false;
      }
    }

    return true;
  }

  @override
  Future<List<String>> getMissingFiles(
    String destinationDirectory,
    File Function(String) fileFactory,
    ZcashParamsConfig config,
  ) async {
    final missingFiles = <String>[];

    for (final fileName in config.fileNames) {
      final file = fileFactory(path.join(destinationDirectory, fileName));
      if (!await file.exists()) {
        missingFiles.add(fileName);
      } else {
        // Check if file hash is valid
        final paramFile = config.getParamFile(fileName);
        if (paramFile != null) {
          final isValid = await validateFileHash(
            file.path,
            paramFile.sha256Hash,
            fileFactory,
          );
          if (!isValid) {
            missingFiles.add(fileName);
          }
        }
      }
    }

    return missingFiles;
  }

  @override
  Future<void> ensureDirectoryExists(
    String directoryPath,
    Directory Function(String) directoryFactory,
  ) async {
    final directory = directoryFactory(directoryPath);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
  }

  @override
  Future<bool> validateFiles(
    String directoryPath,
    File Function(String) fileFactory,
    ZcashParamsConfig config,
  ) async {
    try {
      for (final paramFile in config.paramFiles) {
        final file = fileFactory(path.join(directoryPath, paramFile.fileName));

        if (!await file.exists()) {
          return false;
        }

        // Validate file hash
        final isValid = await validateFileHash(
          file.path,
          paramFile.sha256Hash,
          fileFactory,
        );
        if (!isValid) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> validateFileHash(
    String filePath,
    String expectedHash,
    File Function(String) fileFactory,
  ) async {
    try {
      final actualHash = await getFileHash(filePath, fileFactory);
      if (actualHash == null) {
        return false;
      }
      return actualHash.toLowerCase() == expectedHash.toLowerCase();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getFileHash(
    String filePath,
    File Function(String) fileFactory,
  ) async {
    try {
      final file = fileFactory(filePath);
      if (!await file.exists()) {
        return null;
      }

      final stream = file.openRead();
      final digest = await sha256.bind(stream).first;
      return digest.toString();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int?> getRemoteFileSize(String url) async {
    try {
      final response = await _httpClient.head(Uri.parse(url));
      if (response.statusCode == 200) {
        final contentLength = response.headers['content-length'];
        if (contentLength != null) {
          return int.tryParse(contentLength);
        }
      }
    } catch (e) {
      // Ignore errors and return null
    }
    return null;
  }

  @override
  Future<bool> clearFiles(
    String directoryPath,
    Directory Function(String) directoryFactory,
  ) async {
    try {
      final directory = directoryFactory(directoryPath);
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Downloads a single parameter file.
  Future<bool> _downloadFile(
    String fileName,
    String destinationDirectory,
    StreamController<DownloadProgress> progressController,
    bool Function() isCancelled,
    ZcashParamsConfig config,
  ) async {
    final destinationPath = path.join(destinationDirectory, fileName);
    final paramFile = config.getParamFile(fileName);

    // Try primary URL first, then backup URLs
    for (final baseUrl in config.downloadUrls) {
      if (isCancelled()) return false;

      final fileUrl = config.getFileUrl(baseUrl, fileName);

      try {
        // Get file size dynamically
        final remoteSize = await getRemoteFileSize(fileUrl);
        final expectedSize = remoteSize ?? paramFile?.expectedSize;

        final success = await _downloadFromUrl(
          fileUrl,
          destinationPath,
          fileName,
          expectedSize,
          progressController,
          isCancelled,
          config,
        );

        if (success) {
          // Validate downloaded file hash
          if (paramFile != null) {
            final isValid = await validateFileHash(
              destinationPath,
              paramFile.sha256Hash,
              File.new,
            );
            if (!isValid) {
              // Delete invalid file and try next URL
              final file = File(destinationPath);
              if (await file.exists()) {
                await file.delete();
              }
              continue;
            }
          }
          return true;
        }
      } catch (e) {
        // Continue to next URL
        continue;
      }
    }

    return false;
  }

  /// Downloads a file from a specific URL.
  Future<bool> _downloadFromUrl(
    String url,
    String destinationPath,
    String fileName,
    int? expectedSize,
    StreamController<DownloadProgress> progressController,
    bool Function() isCancelled,
    ZcashParamsConfig config,
  ) async {
    http.StreamedResponse? response;

    try {
      final request = http.Request('GET', Uri.parse(url));
      request.headers['User-Agent'] = 'ZcashParamsDownloader/1.0';

      response = await _httpClient
          .send(request)
          .timeout(config.downloadTimeout);

      if (response.statusCode != 200) {
        return false;
      }

      final file = File(destinationPath);
      final sink = file.openWrite();

      int downloaded = 0;
      final total = expectedSize ?? response.contentLength ?? 0;

      // Create a buffer for chunked reading
      final buffer = <int>[];
      const bufferSize = 8192; // 8KB buffer

      await for (final chunk in response.stream) {
        if (isCancelled()) {
          await sink.close();
          if (await file.exists()) {
            await file.delete();
          }
          return false;
        }

        buffer.addAll(chunk);

        // Write in larger chunks to improve performance
        if (buffer.length >= bufferSize) {
          sink.add(buffer);
          downloaded += buffer.length;
          buffer.clear();

          // Report progress
          if (total > 0) {
            progressController.add(
              DownloadProgress(
                fileName: fileName,
                downloaded: downloaded,
                total: total,
              ),
            );
          }
        }
      }

      // Write remaining buffer
      if (buffer.isNotEmpty) {
        sink.add(buffer);
        downloaded += buffer.length;
      }

      await sink.close();

      // Final progress update
      progressController.add(
        DownloadProgress(
          fileName: fileName,
          downloaded: downloaded,
          total: downloaded,
        ),
      );

      return true;
    } on TimeoutException {
      response?.stream.listen(null).cancel();
      return false;
    } catch (e) {
      response?.stream.listen(null).cancel();
      return false;
    }
  }

  /// Disposes of resources used by this service.
  @override
  void dispose() {
    _httpClient.close();
  }
}
