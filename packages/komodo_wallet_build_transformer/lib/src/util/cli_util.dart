// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

/// Returns the absolute directory of a project's dependency.
///
/// [projectPath] is the directory of the specified project.
/// [dependencyName] is the name of the dependency to look up.
Directory? getDependencyDirectory(
  Directory projectPath,
  String dependencyName,
) {
  final log = Logger('komodo_wallet_build_transformer');

  // Find the root .dart_tool directory by traversing up
  final dartToolDir = _findDartToolDirectory(projectPath);
  if (dartToolDir == null) {
    throw Exception(
      'Could not find .dart_tool directory in any parent directory of '
      '$projectPath',
    );
  }

  final packageConfigFile = File(
    path.join(dartToolDir.path, 'package_config.json'),
  ).absolute;

  if (!packageConfigFile.existsSync()) {
    throw Exception(
      'package_config.json not found in ${dartToolDir.path}',
    );
  }

  final packageConfigContent = packageConfigFile.readAsStringSync();
  final packageConfig = jsonDecode(packageConfigContent);

  if (packageConfig['configVersion'] != 2) {
    throw Exception('Unsupported package_config.json version.');
  }

  final packages = packageConfig['packages'] as List;

  String? packageRootUri;

  for (final package in packages) {
    final rootUri = package['rootUri'] as String;

    if (package['name'] == dependencyName) {
      if (rootUri.startsWith('file:///')) {
        return Directory(path.fromUri(Uri.parse(rootUri)));
      }

      packageRootUri = package['rootUri'] as String;
      log.info('Found package $dependencyName at $packageRootUri');
    }

    if (packageRootUri != null) {
      break;
    }
  }

  if (packageRootUri != null) {
    return resolvePackageDirectory(dartToolDir, packageRootUri);
  }

  log.warning('Dependency $dependencyName not found in package_config.json');
  return null;
}

/// Finds the .dart_tool directory by traversing up the directory tree
/// until it is found or the root directory is reached.
Directory? _findDartToolDirectory(Directory startDir) {
  Directory? currentDir = startDir.absolute;

  while (currentDir != null) {
    final dartToolDir = Directory(path.join(currentDir.path, '.dart_tool'));
    final packageConfigFile =
        File(path.join(dartToolDir.path, 'package_config.json'));

    if (dartToolDir.existsSync() && packageConfigFile.existsSync()) {
      return dartToolDir;
    }

    final parentDir = path.dirname(currentDir.path);
    if (parentDir == currentDir.path) {
      // We've reached the root directory
      return null;
    }

    currentDir = Directory(parentDir);
  }

  return null;
}

/// Resolves the package directory from the [projectPackageDir] and the
/// [packageRootUri]. If the [packageRootUri] is a relative path, it will be
/// resolved from the [projectPackageDir]. Otherwise, it will be joined with
/// the [projectPackageDir].
Directory resolvePackageDirectory(
  Directory projectPackageDir,
  String packageRootUri,
) {
  final normalizedProjectPath = path.normalize(projectPackageDir.path);
  final resolvedPath =
      path.normalize(path.join(normalizedProjectPath, packageRootUri));

  return Directory(resolvedPath).absolute;
}
