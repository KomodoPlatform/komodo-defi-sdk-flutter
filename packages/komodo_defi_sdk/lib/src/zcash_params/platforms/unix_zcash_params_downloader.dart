import 'dart:async';
import 'dart:io';

import 'package:komodo_defi_sdk/src/_internal_exports.dart'
    show ZcashParamsConfig;
import 'package:komodo_defi_sdk/src/zcash_params/models/download_progress.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/download_result.dart';
import 'package:komodo_defi_sdk/src/zcash_params/services/zcash_params_download_service.dart';
import 'package:komodo_defi_sdk/src/zcash_params/zcash_params_downloader.dart';
import 'package:path/path.dart' as path;

/// Unix platform implementation of ZCash parameters downloader.
///
/// Downloads ZCash parameters to platform-specific directories:
/// - macOS: `$HOME/Library/Application Support/ZcashParams`
/// - Linux: `$HOME/.zcash-params`
///
/// This implementation handles Unix-specific path resolution and
/// delegates downloading logic to the injected download service.
class UnixZcashParamsDownloader extends ZcashParamsDownloader {
  /// Creates a Unix ZCash parameters downloader.
  ///
  /// [downloadService] can be provided for custom download logic, otherwise
  /// a default implementation is used.
  /// [directoryFactory] and [fileFactory] can be provided for
  /// custom file system operations, useful for testing.
  /// [config] allows overriding the default ZCash parameters configuration.
  /// If not provided, a default configuration with known parameter files
  /// and their hashes is used.
  /// See [ZcashParamsConfig] for details.
  UnixZcashParamsDownloader({
    ZcashParamsDownloadService? downloadService,
    Directory Function(String)? directoryFactory,
    File Function(String)? fileFactory,
    bool enableHashValidation = true,
    super.config,
  }) : _downloadService =
           downloadService ??
           DefaultZcashParamsDownloadService(
             enableHashValidation: enableHashValidation,
           ),
       _directoryFactory = directoryFactory ?? Directory.new,
       _fileFactory = fileFactory ?? File.new;

  final ZcashParamsDownloadService _downloadService;
  final Directory Function(String) _directoryFactory;
  final File Function(String) _fileFactory;

  final StreamController<DownloadProgress> _progressController =
      StreamController<DownloadProgress>.broadcast();

  bool _isDisposed = false;

  bool _isDownloading = false;
  bool _isCancelled = false;

  @override
  Future<DownloadResult> downloadParams() async {
    if (_isDownloading) {
      return const DownloadResult.failure(
        error: 'Download already in progress',
      );
    }

    _isDownloading = true;
    _isCancelled = false;

    try {
      final paramsPath = await getParamsPath();
      if (paramsPath == null) {
        return const DownloadResult.failure(
          error: 'Unable to determine parameters path',
        );
      }

      // Create directory if it doesn't exist
      await _downloadService.ensureDirectoryExists(
        paramsPath,
        _directoryFactory,
      );

      // Check which files need to be downloaded
      final missingFiles = await _downloadService.getMissingFiles(
        paramsPath,
        _fileFactory,
        config,
      );

      if (missingFiles.isEmpty) {
        return DownloadResult.success(paramsPath: paramsPath);
      }

      // Download missing files
      final downloadSuccess = await _downloadService.downloadMissingFiles(
        paramsPath,
        missingFiles,
        _progressController,
        () => _isCancelled,
        config,
      );

      if (!downloadSuccess) {
        return const DownloadResult.failure(
          error: 'Failed to download one or more parameter files',
        );
      }

      return DownloadResult.success(paramsPath: paramsPath);
    } finally {
      _isDownloading = false;
      _isCancelled = false;
    }
  }

  @override
  Future<String?> getParamsPath() async {
    final home = Platform.environment['HOME'];
    if (home == null) {
      throw StateError('HOME environment variable not found');
    }

    if (Platform.isMacOS) {
      return path.join(home, 'Library', 'Application Support', 'ZcashParams');
    } else {
      // Linux and other Unix-like systems
      return path.join(home, '.zcash-params');
    }
  }

  @override
  Future<bool> areParamsAvailable() async {
    final paramsPath = await getParamsPath();
    if (paramsPath == null) return false;

    final missingFiles = await _downloadService.getMissingFiles(
      paramsPath,
      _fileFactory,
      config,
    );

    return missingFiles.isEmpty;
  }

  @override
  Stream<DownloadProgress> get downloadProgress => _progressController.stream;

  @override
  Future<bool> cancelDownload() async {
    if (_isDownloading) {
      _isCancelled = true;
      return true;
    }
    return false;
  }

  @override
  Future<bool> validateParams() async {
    final paramsPath = await getParamsPath();
    if (paramsPath == null) return false;

    return _downloadService.validateFiles(paramsPath, _fileFactory, config);
  }

  @override
  Future<bool> validateFileHash(String filePath, String expectedHash) async {
    return _downloadService.validateFileHash(
      filePath,
      expectedHash,
      _fileFactory,
    );
  }

  @override
  Future<String?> getFileHash(String filePath) async {
    return _downloadService.getFileHash(filePath, _fileFactory);
  }

  @override
  Future<bool> clearParams() async {
    final paramsPath = await getParamsPath();
    if (paramsPath == null) return false;

    return _downloadService.clearFiles(paramsPath, _directoryFactory);
  }

  /// Disposes of resources used by this downloader.
  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;

    try {
      _downloadService.dispose();
    } catch (_) {
      // Ignore errors from download service disposal
    }

    try {
      if (!_progressController.isClosed) {
        _progressController.close();
      }
    } catch (_) {
      // Ignore errors from closing progress controller
    }
  }
}
