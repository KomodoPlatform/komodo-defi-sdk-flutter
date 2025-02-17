import 'dart:io';

import 'package:komodo_wallet_build_transformer/src/steps/fetch_defi_api_build_step.dart';

extension NodePath on FetchDefiApiStep {
  @Deprecated('Node was removed from the build requirements, so this will no '
      'longer be needed')
  String findNode() {
    if (Platform.isWindows) {
      return _findNodeWindows();
    } else if (Platform.isLinux || Platform.isMacOS) {
      return _findNodeUnix();
    } else {
      return 'npm';
    }
  }

  String _findNodeUnix() {
    // Common npm locations on macOS
    final commonLocations = [
      '/usr/local/bin/npm',
      '/usr/bin/npm',
      '/opt/homebrew/bin/npm',
    ];

    // Check common locations
    for (final location in commonLocations) {
      if (File(location).existsSync()) {
        return location;
      }
    }

    // Check PATH environment variable
    final pathEnv = Platform.environment['PATH'];
    if (pathEnv != null) {
      final paths = pathEnv.split(':');
      for (final path in paths) {
        final npmPath = '$path/npm';
        if (File(npmPath).existsSync()) {
          return npmPath;
        }
      }
    }

    // Check NVM_BIN environment variable
    final nvmBin = Platform.environment['NVM_BIN'];
    if (nvmBin != null) {
      final npmPath = '$nvmBin/npm';
      if (File(npmPath).existsSync()) {
        return npmPath;
      }
    }

    // Check NODE_PATH environment variable
    final nodePath = Platform.environment['NODE_PATH'];
    if (nodePath != null) {
      final npmPath = '$nodePath/npm';
      if (File(npmPath).existsSync()) {
        return npmPath;
      }
    }

    // If npm is not found, throw an exception
    throw Exception(
      'npm not found in common locations or environment variables. '
      'Please ensure npm is installed and accessible.',
    );
  }

  String _findNodeWindows() {
    final commonLocations = [
      'C:/Program Files/nodejs/npm.cmd',
      'C:/Program Files (x86)/nodejs/npm.cmd',
      'C:/Program Files/nodejs/npm',
      'C:/Program Files (x86)/nodejs/npm',
    ];

    for (final location in commonLocations) {
      if (File(location).existsSync()) {
        return location;
      }
    }

    final nodePath = Platform.environment['PATH'];
    if (nodePath != null) {
      return nodePath;
    }

    throw Exception('NODE_PATH not found in environment variables.');
  }
}
