import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:http/http.dart' as http;
import 'package:komodo_defi_sdk/src/zcash_params/models/download_progress.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/zcash_params_config.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart'
    show ExponentialBackoff, retry;
import 'package:logging/logging.dart';
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
  DefaultZcashParamsDownloadService({
    http.Client? httpClient,
    this.enableHashValidation = true,
  }) : _httpClient = httpClient ?? http.Client();

  static final Logger _logger = Logger('ZcashParamsDownloadService');
  final http.Client _httpClient;

  /// Whether hash validation is enabled for this service instance.
  final bool enableHashValidation;

  @override
  Future<bool> downloadMissingFiles(
    String destinationDirectory,
    List<String> missingFiles,
    StreamController<DownloadProgress> progressController,
    bool Function() isCancelled,
    ZcashParamsConfig config,
  ) async {
    _logger.info(
      'Starting download of ${missingFiles.length} missing files '
      'to $destinationDirectory',
    );

    try {
      for (final fileName in missingFiles) {
        if (isCancelled()) {
          _logger.warning('Download cancelled for file: $fileName');
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
          _logger.severe('Failed to download file: $fileName');
          return false;
        }

        _logger.fine('Successfully downloaded file: $fileName');
      }

      _logger.info('Successfully downloaded all ${missingFiles.length} files');
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Error during download process', e, stackTrace);
      return false;
    }
  }

  @override
  Future<List<String>> getMissingFiles(
    String destinationDirectory,
    File Function(String) fileFactory,
    ZcashParamsConfig config,
  ) async {
    _logger.fine(
      'Checking for missing files in directory: $destinationDirectory',
    );

    try {
      final missingFiles = <String>[];

      for (final fileName in config.fileNames) {
        final file = fileFactory(path.join(destinationDirectory, fileName));
        if (!file.existsSync()) {
          _logger.fine('File not found: $fileName');
          missingFiles.add(fileName);
        } else if (enableHashValidation) {
          // Check if file hash is valid only if validation is enabled
          final paramFile = config.getParamFile(fileName);
          if (paramFile != null) {
            final isValid = await validateFileHash(
              file.path,
              paramFile.sha256Hash,
              fileFactory,
            );
            if (!isValid) {
              _logger.warning('File hash validation failed for: $fileName');
              missingFiles.add(fileName);
            }
          }
        }
      }

      _logger.info(
        'Found ${missingFiles.length} missing files: ${missingFiles.join(', ')}',
      );
      return missingFiles;
    } catch (e, stackTrace) {
      _logger.severe('Error checking for missing files', e, stackTrace);
      return config.fileNames;
    }
  }

  @override
  Future<void> ensureDirectoryExists(
    String directoryPath,
    Directory Function(String) directoryFactory,
  ) async {
    _logger.fine('Ensuring directory exists: $directoryPath');

    try {
      final directory = directoryFactory(directoryPath);
      if (!directory.existsSync()) {
        _logger.info('Creating directory: $directoryPath');
        await directory.create(recursive: true);
      }
    } catch (e, stackTrace) {
      _logger.severe('Error creating directory: $directoryPath', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> validateFiles(
    String directoryPath,
    File Function(String) fileFactory,
    ZcashParamsConfig config,
  ) async {
    _logger.fine('Validating all files in directory: $directoryPath');

    try {
      for (final paramFile in config.paramFiles) {
        final file = fileFactory(path.join(directoryPath, paramFile.fileName));

        if (!file.existsSync()) {
          _logger.warning(
            'File does not exist during validation: ${paramFile.fileName}',
          );
          return false;
        }

        if (enableHashValidation) {
          final isValid = await validateFileHash(
            file.path,
            paramFile.sha256Hash,
            fileFactory,
          );
          if (!isValid) {
            _logger.warning(
              'File hash validation failed: ${paramFile.fileName}',
            );
            return false;
          }
        }
      }

      _logger.info('All files validated successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Error during file validation', e, stackTrace);
      return false;
    }
  }

  @override
  Future<bool> validateFileHash(
    String filePath,
    String expectedHash,
    File Function(String) fileFactory,
  ) async {
    _logger.fine('Validating hash for file: $filePath');

    try {
      final actualHash = await getFileHash(filePath, fileFactory);
      if (actualHash == null) {
        _logger.warning('Could not calculate hash for file: $filePath');
        return false;
      }

      final isValid = actualHash.toLowerCase() == expectedHash.toLowerCase();
      if (!isValid) {
        _logger.warning(
          'Hash mismatch for $filePath. Expected: $expectedHash, Actual: $actualHash',
        );
      } else {
        _logger.fine('Hash validation successful for: $filePath');
      }

      return isValid;
    } catch (e, stackTrace) {
      _logger.severe(
        'Error validating file hash for: $filePath',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<String?> getFileHash(
    String filePath,
    File Function(String) fileFactory,
  ) async {
    _logger.fine('Calculating hash for file: $filePath');

    try {
      final file = fileFactory(filePath);
      if (!file.existsSync()) {
        _logger.fine('File does not exist for hash calculation: $filePath');
        return null;
      }

      final stream = file.openRead();
      final digest = await sha256.bind(stream).first;

      // Ensure lowercase hex string to match Rust format!("{:x}", hasher.finalize())
      final hash = digest.toString().toLowerCase();
      _logger.fine('Hash calculated for $filePath: $hash');
      return hash;
    } catch (e, stackTrace) {
      _logger.severe(
        'Error calculating file hash for: $filePath',
        e,
        stackTrace,
      );
      return null;
    }
  }

  @override
  Future<int?> getRemoteFileSize(String url) async {
    _logger.fine('Getting remote file size for: $url');

    try {
      final response = await _httpClient.head(Uri.parse(url));
      if (response.statusCode == 200) {
        final contentLength = response.headers['content-length'];
        if (contentLength != null) {
          final size = int.tryParse(contentLength);
          _logger.fine('Remote file size for $url: $size bytes');
          return size;
        }
      }
      _logger.warning(
        'Could not get remote file size for $url, status: ${response.statusCode}',
      );
    } catch (e, stackTrace) {
      _logger.warning(
        'Error getting remote file size for: $url',
        e,
        stackTrace,
      );
    }
    return null;
  }

  @override
  Future<bool> clearFiles(
    String directoryPath,
    Directory Function(String) directoryFactory,
  ) async {
    _logger.info('Clearing files from directory: $directoryPath');

    try {
      final directory = directoryFactory(directoryPath);
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
        _logger.info('Successfully cleared directory: $directoryPath');
      } else {
        _logger.fine(
          'Directory does not exist, nothing to clear: $directoryPath',
        );
      }
      return true;
    } catch (e, stackTrace) {
      _logger.severe(
        'Error clearing files from directory: $directoryPath',
        e,
        stackTrace,
      );
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

    _logger.info('Starting download of file: $fileName');

    // Try primary URL first, then backup URLs
    for (final baseUrl in config.downloadUrls) {
      if (isCancelled()) {
        _logger.warning('Download cancelled for file: $fileName');
        return false;
      }

      final fileUrl = config.getFileUrl(baseUrl, fileName);
      _logger.info('Attempting download from URL: $fileUrl');

      try {
        // Get file size dynamically
        _logger.fine('Getting remote file size for: $fileUrl');
        final remoteSize = await getRemoteFileSize(fileUrl);
        final expectedSize = remoteSize ?? paramFile?.expectedSize;
        _logger
          ..fine('Remote file size: $remoteSize, expected size: $expectedSize')
          ..info('Starting download from URL with retry: $fileUrl');

        final success = await retry(
          () => _downloadFromUrl(
            fileUrl,
            destinationPath,
            fileName,
            expectedSize,
            progressController,
            isCancelled,
            config,
          ),
          maxAttempts: 3,
          backoffStrategy: ExponentialBackoff(
            initialDelay: const Duration(seconds: 1),
            maxDelay: const Duration(seconds: 30),
            withJitter: true,
          ),
          onRetry: (attempt, error, delay) {
            _logger.warning(
              'Retry attempt $attempt for $fileName from $fileUrl after '
              '$delay due to: $error',
            );
          },
        );
        _logger.info(
          'Download from URL completed: $fileUrl, success: $success',
        );

        if (success) {
          // Validate downloaded file hash if enabled
          if (enableHashValidation && paramFile != null) {
            final isValid = await validateFileHash(
              destinationPath,
              paramFile.sha256Hash,
              File.new,
            );
            if (!isValid) {
              _logger.warning(
                'Downloaded file hash validation failed for $fileName, '
                'trying next URL',
              );
              // Delete invalid file and try next URL
              final file = File(destinationPath);
              if (file.existsSync()) {
                await file.delete();
              }
              continue;
            }
            _logger.info(
              'Successfully downloaded and validated file: $fileName',
            );
          } else {
            _logger.info(
              'Successfully downloaded file: $fileName (hash validation '
              '${enableHashValidation ? 'passed' : 'disabled'})',
            );
          }
          return true;
        }
      } catch (e, stackTrace) {
        _logger.warning(
          'Error downloading from $fileUrl for file $fileName',
          e,
          stackTrace,
        );
        continue;
      }
    }

    _logger.severe(
      'Failed to download file from all available URLs: $fileName',
    );
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
    IOSink? sink;
    bool success = false;
    final file = File(destinationPath);

    _logger.info('Starting HTTP download from URL: $url to $destinationPath');

    try {
      final request = http.Request('GET', Uri.parse(url));
      request.headers['User-Agent'] = 'ZcashParamsDownloader/1.0';

      response = await _httpClient
          .send(request)
          .timeout(config.downloadTimeout);

      if (response.statusCode != 200) {
        _logger.warning('HTTP error ${response.statusCode} for URL: $url');
        return false;
      }

      sink = file.openWrite();

      int downloaded = 0;
      final total = expectedSize ?? response.contentLength ?? 0;
      _logger.fine('Downloading $fileName: $total bytes expected');

      _logger.info('Starting to process download stream for: $fileName');
      var chunkCount = 0;
      await for (final chunk in response.stream) {
        chunkCount++;
        if (chunkCount % 100 == 0) {
          _logger.finer(
            'Processed $chunkCount chunks for $fileName, '
            'downloaded: $downloaded bytes',
          );
        }

        if (isCancelled()) {
          _logger.warning(
            'Download cancelled for $fileName at $downloaded bytes',
          );
          return false;
        }

        // Write chunk directly to avoid corruption
        sink.add(chunk);
        downloaded += chunk.length;

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
      _logger.info(
        'Finished processing download stream for: $fileName, '
        'total chunks: $chunkCount',
      );

      // Final progress update
      progressController.add(
        DownloadProgress(
          fileName: fileName,
          downloaded: downloaded,
          total: downloaded,
        ),
      );

      _logger.fine('Successfully downloaded $fileName: $downloaded bytes');
      success = true;
      return true;
    } on TimeoutException catch (e, stackTrace) {
      _logger.warning(
        'Download timeout for $fileName from $url',
        e,
        stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      _logger.severe('Error downloading $fileName from $url', e, stackTrace);
      return false;
    } finally {
      // Close sink if it's open
      if (sink != null) {
        try {
          _logger.fine('Closing file sink for: $fileName');
          await sink.close();
          _logger.fine('File sink closed successfully for: $fileName');
        } catch (e) {
          _logger.warning('Error closing sink for $fileName: $e');
        }
      }

      // Clean up partial file on failure
      if (!success && file.existsSync()) {
        try {
          await file.delete();
          _logger.fine('Deleted partial file: $destinationPath');
        } catch (e) {
          _logger.warning('Failed to delete partial file $destinationPath: $e');
        }
      }

      // Clean up response stream
      try {
        await response?.stream.listen(null).cancel();
      } catch (e) {
        _logger.fine('Error cancelling response stream: $e');
      }
    }
  }

  /// Disposes of resources used by this service.
  @override
  void dispose() {
    _logger.fine('Disposing ZcashParamsDownloadService');
    _httpClient.close();
  }
}
