import 'dart:async';

import 'package:komodo_defi_sdk/src/zcash_params/models/download_progress.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/download_result.dart';
import 'package:komodo_defi_sdk/src/zcash_params/zcash_params_downloader.dart';

/// Web platform implementation of ZCash parameters downloader.
///
/// The Web platform doesn't require ZCash parameters to be downloaded locally
/// since it cannot access the local file system in the same way as native platforms.
/// This implementation provides a no-op interface that always indicates success.
class WebZcashParamsDownloader extends ZcashParamsDownloader {
  /// Creates a new [WebZcashParamsDownloader] instance.
  WebZcashParamsDownloader({super.config});

  final StreamController<DownloadProgress> _progressController =
      StreamController<DownloadProgress>.broadcast();

  @override
  Future<DownloadResult> downloadParams() async {
    // Web platform doesn't need to download ZCash parameters
    return const DownloadResult.success(paramsPath: 'web-virtual-path');
  }

  @override
  Future<String?> getParamsPath() async {
    // Web platform doesn't use local file paths for ZCash parameters
    return null;
  }

  @override
  Future<bool> areParamsAvailable() async {
    // Web platform always considers parameters "available" since
    // they're not needed
    return true;
  }

  @override
  Stream<DownloadProgress> get downloadProgress => _progressController.stream;

  @override
  Future<bool> cancelDownload() async {
    // No downloads to cancel on web platform
    return false;
  }

  @override
  Future<bool> validateParams() async {
    // No parameters to validate on web platform
    return true;
  }

  @override
  Future<bool> clearParams() async {
    // No parameters to clear on web platform
    return true;
  }

  @override
  Future<bool> validateFileHash(String filePath, String expectedHash) async {
    // No file hash validation needed on web platform
    return true;
  }

  @override
  Future<String?> getFileHash(String filePath) async {
    // No file hash computation needed on web platform
    return null;
  }

  /// Disposes of resources used by this downloader.
  void dispose() {
    _progressController.close();
  }
}
