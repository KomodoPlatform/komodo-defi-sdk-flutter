import 'dart:async';
import 'dart:io';

import 'package:komodo_defi_sdk/src/zcash_params/models/download_progress.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/download_result.dart';
import 'package:komodo_defi_sdk/src/zcash_params/services/zcash_params_download_service.dart';
import 'package:komodo_defi_sdk/src/zcash_params/zcash_params_downloader.dart';
import 'package:path/path.dart' as path;

/// Windows platform implementation of ZCash parameters downloader.
///
/// Downloads ZCash parameters to the Windows APPDATA directory:
/// `%APPDATA%\ZcashParams`
///
/// This implementation handles Windows-specific path resolution and
/// delegates downloading logic to the injected download service.
class WindowsZcashParamsDownloader extends ZcashParamsDownloader {
  /// Creates a Windows ZCash parameters downloader.
  ///
  /// [downloadService] can be provided for custom download logic, otherwise
  /// a default implementation is used.
  /// [directoryFactory] and [fileFactory] can be provided for
  /// custom file system operations, useful for testing.
  /// [config] allows overriding the default ZCash parameters configuration.
  /// If not provided, a default configuration with known parameter files
  /// and their hashes is used.
  WindowsZcashParamsDownloader({
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

    final paramsPath = await getParamsPath();
    if (paramsPath == null) {
      _isDownloading = false;
      _isCancelled = false;
      return const DownloadResult.failure(
        error: 'Unable to determine parameters path',
      );
    }

    // Create directory if it doesn't exist
    await _downloadService.ensureDirectoryExists(paramsPath, _directoryFactory);

    // Check which files need to be downloaded
    final missingFiles = await _downloadService.getMissingFiles(
      paramsPath,
      _fileFactory,
      config,
    );

    if (missingFiles.isEmpty) {
      _isDownloading = false;
      _isCancelled = false;
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

    _isDownloading = false;
    _isCancelled = false;

    if (!downloadSuccess) {
      return const DownloadResult.failure(
        error: 'Failed to download one or more parameter files',
      );
    }

    return DownloadResult.success(paramsPath: paramsPath);
  }

  @override
  Future<String?> getParamsPath() async {
    final appData = Platform.environment['APPDATA'];
    if (appData == null) {
      return null;
    }
    return path.join(appData, 'ZcashParams');
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
  Future<bool> clearParams() async {
    final paramsPath = await getParamsPath();
    if (paramsPath == null) return false;

    return _downloadService.clearFiles(paramsPath, _directoryFactory);
  }

  /// Disposes of resources used by this downloader.
  @override
  void dispose() {
    _downloadService.dispose();
    _progressController.close();
  }
}
