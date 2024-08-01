// ignore_for_file: avoid_print

import 'dart:io';
import 'package:komodo_wallet_build_transformer/src/build_step.dart';
import 'package:path/path.dart' as path;

/// A build step that copies platform-specific assets to the build directory
/// which aren't copied as part of the native build configuration and Flutter's
/// asset configuration.
///
/// Prefer using the native build configurations over this build step
/// when possible.
class CopyPlatformAssetsBuildStep extends BuildStep {
  CopyPlatformAssetsBuildStep({
    required this.projectRoot,
    // required this.buildPlatform,
  });

  final String projectRoot;
  // final String buildPlatform;

  @override
  final String id = idStatic;

  static const idStatic = 'copy_platform_assets';

  @override
  Future<void> build() async {
    // TODO: add conditional logic for copying assets based on the target
    // platform if this info is made available to the Dart VM.

    // if (buildPlatform == "linux") {
    await _copyLinuxAssets();
    // }
  }

  @override
  Future<bool> canSkip() {
    return Future.value(_canSkipLinuxAssets());
  }

  @override
  Future<void> revert([Exception? e]) async {
    _revertLinuxAssets();
  }

  Future<void> _copyLinuxAssets() async {
    try {
      await Future.wait([_destDesktop, _destIcon].map((file) async {
        if (!file.parent.existsSync()) {
          file.parent.createSync(recursive: true);
        }
      }));

      _sourceIcon.copySync(_destIcon.path);
      _sourceDesktop.copySync(_destDesktop.path);

      print("Copying Linux assets completed");
    } catch (e) {
      print("Failed to copy files with error: $e");

      rethrow;
    }
  }

  void _revertLinuxAssets() async {
    try {
      // Done in parallel so that if one fails, the other can still be deleted
      await Future.wait([_destIcon, _destDesktop].map((file) => file.delete()));

      print("Copying Linux assets completed");
    } catch (e) {
      print("Failed to copy files with error: $e");

      rethrow;
    }
  }

  bool _canSkipLinuxAssets() {
    return !(_sourceIcon.existsSync() || _sourceDesktop.existsSync()) &&
        _destIcon.existsSync() &&
        _destDesktop.existsSync() &&
        _sourceIcon.lastModifiedSync().isBefore(_destIcon.lastModifiedSync()) &&
        _sourceDesktop
            .lastModifiedSync()
            .isBefore(_destDesktop.lastModifiedSync());
  }

  late final File _sourceIcon =
      File(path.joinAll([projectRoot, "linux", "KomodoWallet.svg"]));

  late final File _destIcon = File(path.joinAll([
    projectRoot,
    "build",
    "linux",
    "x64",
    "release",
    "bundle",
    "KomodoWallet.svg"
  ]));

  late final File _sourceDesktop =
      File(path.joinAll([projectRoot, "linux", "KomodoWallet.desktop"]));

  late final File _destDesktop = File(path.joinAll([
    projectRoot,
    "build",
    "linux",
    "x64",
    "release",
    "bundle",
    "KomodoWallet.desktop"
  ]));
}
