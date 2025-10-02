import 'dart:async';

import 'package:komodo_defi_sdk/src/zcash_params/models/download_progress.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/download_result.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/zcash_params_config.dart';

/// Abstract base class for platform-specific ZCash parameters downloaders.
///
/// This class defines the contract that all platform implementations must follow.
/// Each platform (Windows, Unix, Web) has its own specific implementation that
/// handles the platform's unique requirements for ZCash parameter management.
abstract class ZcashParamsDownloader {
  /// Creates a ZCash parameters downloader with the given configuration.
  const ZcashParamsDownloader({ZcashParamsConfig? config})
    : config = config ?? _defaultConfig;

  /// Configuration for ZCash parameter downloads.
  final ZcashParamsConfig config;

  /// Default configuration with known ZCash parameter files and their hashes.
  static const ZcashParamsConfig _defaultConfig =
      ZcashParamsConfig.defaultConfig;

  /// Downloads ZCash parameters if they are not already available.
  ///
  /// Returns a [DownloadResult] indicating whether the operation was successful.
  /// For platforms that don't require ZCash parameters (like Web), this should
  /// return a successful result immediately.
  ///
  /// The implementation should:
  /// - Check if parameters already exist locally
  /// - Create necessary directories if they don't exist
  /// - Download missing parameter files from configured URLs
  /// - Report progress through the [downloadProgress] stream
  /// - Handle network failures gracefully with retries and fallback URLs
  /// - Return the path to the parameters directory on success
  ///
  /// Throws:
  /// - [StateError] if required environment variables are missing (APPDATA on Windows, HOME on Unix)
  /// - [FileSystemException] if directory creation or file operations fail
  /// - [IOException] if file I/O operations fail
  /// - [SocketException] for network connectivity issues
  /// - [TimeoutException] if download operations timeout
  /// - [HttpException] for HTTP-related errors
  /// - [ArgumentError] for invalid path operations
  Future<DownloadResult> downloadParams();

  /// Gets the platform-specific path where ZCash parameters should be stored.
  ///
  /// Returns null for platforms that don't use local ZCash parameters (like Web).
  /// For other platforms, returns the full path to the directory where
  /// parameter files are stored.
  ///
  /// Examples:
  /// - Windows: `C:\Users\Username\AppData\Roaming\ZcashParams`
  /// - macOS: `/Users/Username/Library/Application Support/ZcashParams`
  /// - Linux: `/home/username/.zcash-params`
  /// - Web: `null`
  ///
  /// Throws:
  /// - [StateError] if required environment variables are missing (APPDATA on Windows, HOME on Unix)
  /// - [ArgumentError] for invalid path operations
  Future<String?> getParamsPath();

  /// Checks if all required ZCash parameters are available locally.
  ///
  /// Returns true if all parameter files exist and are valid, false otherwise.
  /// For platforms that don't require parameters (like Web), this should
  /// always return true.
  ///
  /// The implementation should verify that:
  /// - The parameters directory exists
  /// - All required parameter files are present
  /// - Files are not corrupted (optional, basic size check)
  ///
  /// Throws:
  /// - [StateError] if required environment variables are missing
  /// - [FileSystemException] if file system operations fail
  /// - [IOException] if file access operations fail
  /// - [ArgumentError] for invalid path operations
  Future<bool> areParamsAvailable();

  /// Stream that reports download progress for parameter files.
  ///
  /// Emits [DownloadProgress] events during the download process to allow
  /// UI components to display progress to the user. The stream should emit:
  /// - Progress updates during file downloads
  /// - Completion events when files finish downloading
  ///
  /// The stream should be broadcast to allow multiple listeners.
  Stream<DownloadProgress> get downloadProgress;

  /// Cancels any ongoing download operation.
  ///
  /// This method should gracefully stop any in-progress downloads and clean up
  /// temporary files. After cancellation, subsequent calls to [downloadParams]
  /// should start fresh.
  ///
  /// Returns true if a download was cancelled, false if no download was in progress.
  Future<bool> cancelDownload();

  /// Validates the integrity of downloaded parameter files.
  ///
  /// This method verifies that downloaded files are valid and not corrupted by:
  /// - Checking file sizes against expected values
  /// - Verifying SHA256 checksums against expected hashes
  /// - Ensuring all required files are present
  ///
  /// Returns true if all files are valid, false if any issues are detected.
  ///
  /// Throws:
  /// - [StateError] if required environment variables are missing
  /// - [FileSystemException] if file system operations fail
  /// - [IOException] if file access or hashing operations fail
  /// - [ArgumentError] for invalid path operations
  Future<bool> validateParams();

  /// Validates the SHA256 hash of a specific parameter file.
  ///
  /// [filePath] is the full path to the file to validate.
  /// [expectedHash] is the expected SHA256 hash in hexadecimal format.
  ///
  /// Returns true if the file's hash matches the expected hash, false otherwise.
  /// Returns false if the file doesn't exist or cannot be read.
  ///
  /// Throws:
  /// - [FileSystemException] if file system operations fail
  /// - [IOException] if file access or hashing operations fail
  /// - [ArgumentError] for invalid file paths
  Future<bool> validateFileHash(String filePath, String expectedHash);

  /// Gets the SHA256 hash of a file.
  ///
  /// [filePath] is the full path to the file to hash.
  ///
  /// Returns the SHA256 hash in hexadecimal format, or null if the file
  /// doesn't exist or cannot be read.
  ///
  /// Throws:
  /// - [FileSystemException] if file system operations fail
  /// - [IOException] if file access or hashing operations fail
  /// - [ArgumentError] for invalid file paths
  Future<String?> getFileHash(String filePath);

  /// Clears all downloaded parameter files.
  ///
  /// This method removes all parameter files from the local storage directory.
  /// Useful for troubleshooting or forcing a fresh download.
  ///
  /// Returns true if files were successfully cleared, false if there was an error.
  ///
  /// Throws:
  /// - [StateError] if required environment variables are missing
  /// - [FileSystemException] if directory deletion operations fail
  /// - [IOException] if file system operations fail
  /// - [ArgumentError] for invalid path operations
  Future<bool> clearParams();

  /// Disposes of the downloader.
  ///
  /// This method should be called to release any resources used by the downloader.
  void dispose();
}
