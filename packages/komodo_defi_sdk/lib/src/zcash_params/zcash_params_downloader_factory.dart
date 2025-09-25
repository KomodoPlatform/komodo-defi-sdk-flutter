import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:komodo_defi_sdk/src/zcash_params/models/zcash_params_config.dart';
import 'package:komodo_defi_sdk/src/zcash_params/platform_implementations/unix_zcash_params_downloader.dart';
import 'package:komodo_defi_sdk/src/zcash_params/platform_implementations/web_zcash_params_downloader.dart';
import 'package:komodo_defi_sdk/src/zcash_params/platform_implementations/windows_zcash_params_downloader.dart';
import 'package:komodo_defi_sdk/src/zcash_params/services/zcash_params_download_service.dart';
import 'package:komodo_defi_sdk/src/zcash_params/zcash_params_downloader.dart';

/// Factory class for creating platform-specific ZCash parameters downloaders.
///
/// This factory automatically detects the current platform and returns the
/// appropriate downloader implementation:
/// - Web: [WebZcashParamsDownloader] (no-op implementation)
/// - Windows: [WindowsZcashParamsDownloader] (downloads to %APPDATA%\ZcashParams)
/// - macOS/Linux: [UnixZcashParamsDownloader] (downloads to platform-specific paths)
class ZcashParamsDownloaderFactory {
  const ZcashParamsDownloaderFactory._();

  /// Creates a platform-specific ZCash parameters downloader.
  ///
  /// The factory automatically detects the current platform and returns
  /// the appropriate implementation. This method should be used as the
  /// primary entry point for obtaining a downloader instance.
  ///
  /// Returns:
  /// - [WebZcashParamsDownloader] for web platforms
  /// - [WindowsZcashParamsDownloader] for Windows platforms
  /// - [UnixZcashParamsDownloader] for macOS and Linux platforms
  ///
  /// Example usage:
  /// ```dart
  /// final downloader = ZcashParamsDownloaderFactory.create();
  /// final result = await downloader.downloadParams();
  /// ```
  static ZcashParamsDownloader create({
    ZcashParamsDownloadService? downloadService,
    ZcashParamsConfig? config,
    bool enableHashValidation = true,
  }) {
    if (kIsWeb) {
      return WebZcashParamsDownloader(config: config);
    }

    if (Platform.isWindows) {
      return WindowsZcashParamsDownloader(
        downloadService: downloadService,
        config: config,
        enableHashValidation: enableHashValidation,
      );
    }

    // macOS, Linux, and other Unix-like platforms
    return UnixZcashParamsDownloader(
      downloadService: downloadService,
      config: config,
      enableHashValidation: enableHashValidation,
    );
  }

  /// Creates a downloader for a specific platform type.
  ///
  /// This method is primarily useful for testing or when you need to
  /// create a downloader for a platform other than the current one.
  ///
  /// [platformType] - The target platform type
  ///
  /// Throws [ArgumentError] if an unsupported platform type is provided.
  static ZcashParamsDownloader createForPlatform(
    ZcashParamsPlatform platformType, {
    ZcashParamsDownloadService? downloadService,
    ZcashParamsConfig? config,
    bool enableHashValidation = true,
  }) {
    switch (platformType) {
      case ZcashParamsPlatform.web:
        return WebZcashParamsDownloader(config: config);
      case ZcashParamsPlatform.windows:
        return WindowsZcashParamsDownloader(
          downloadService: downloadService,
          config: config,
          enableHashValidation: enableHashValidation,
        );
      case ZcashParamsPlatform.unix:
        return UnixZcashParamsDownloader(
          downloadService: downloadService,
          config: config,
          enableHashValidation: enableHashValidation,
        );
    }
  }

  /// Detects the current platform and returns the corresponding enum value.
  ///
  /// This method can be useful for logging, debugging, or when you need to
  /// know which platform-specific implementation will be used without
  /// actually creating the downloader.
  static ZcashParamsPlatform detectPlatform() {
    if (kIsWeb) {
      return ZcashParamsPlatform.web;
    }

    if (Platform.isWindows) {
      return ZcashParamsPlatform.windows;
    }

    return ZcashParamsPlatform.unix;
  }

  /// Checks if the current platform requires ZCash parameter downloads.
  ///
  /// Returns false for web platforms (which don't need local parameters)
  /// and true for all other platforms.
  static bool get requiresDownload {
    return !kIsWeb && !kIsWasm;
  }

  /// Gets the expected parameters directory path for the current platform.
  ///
  /// This is a convenience method that creates a downloader instance and
  /// immediately gets its parameters path. For repeated operations, it's
  /// more efficient to create a single downloader instance and reuse it.
  ///
  /// Returns null for web platforms.
  static Future<String?> getDefaultParamsPath() async {
    final downloader = create();
    try {
      return await downloader.getParamsPath();
    } finally {
      // Clean up resources if the downloader supports it
      if (downloader is WebZcashParamsDownloader) {
        downloader.dispose();
      } else if (downloader is WindowsZcashParamsDownloader) {
        downloader.dispose();
      } else if (downloader is UnixZcashParamsDownloader) {
        downloader.dispose();
      }
    }
  }
}

/// Enumeration of supported platforms for ZCash parameter downloads.
enum ZcashParamsPlatform {
  /// Web platform - no local parameter downloads needed
  web,

  /// Windows platform - downloads to %APPDATA%\ZcashParams
  windows,

  /// Unix-like platforms (macOS, Linux) - downloads to platform-specific paths
  unix,
}

/// Extension methods for [ZcashParamsPlatform] enum.
extension ZcashParamsPlatformExtension on ZcashParamsPlatform {
  /// Human-readable name for the platform.
  String get displayName {
    switch (this) {
      case ZcashParamsPlatform.web:
        return 'Web';
      case ZcashParamsPlatform.windows:
        return 'Windows';
      case ZcashParamsPlatform.unix:
        return 'Unix/Linux';
    }
  }

  /// Whether this platform requires parameter downloads.
  bool get requiresDownload {
    switch (this) {
      case ZcashParamsPlatform.web:
        return false;
      case ZcashParamsPlatform.windows:
      case ZcashParamsPlatform.unix:
        return true;
    }
  }

  /// Expected parameters directory name for this platform.
  String? get defaultDirectoryName {
    switch (this) {
      case ZcashParamsPlatform.web:
        return null;
      case ZcashParamsPlatform.windows:
        return 'ZcashParams';
      case ZcashParamsPlatform.unix:
        return null; // Varies by Unix platform
    }
  }
}
