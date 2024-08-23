import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

/// Returns the absolute directory of a project's dependency.
///
/// [projectPath] is the directory of the specified project.
/// [dependencyName] is the name of the dependency to look up.
Directory? getDependencyDirectory(String projectPath, String dependencyName) {
  final log = Logger('komodo_wallet_build_transformer');
  final packageConfigFile =
      File(path.join(projectPath, '.dart_tool', 'package_config.json'))
          .absolute;

  final projectDir = Directory(projectPath).absolute;

  if (!packageConfigFile.existsSync()) {
    throw Exception(
      'package_config.json not found in $projectPath/.dart_tool/',
    );
  }

  final packageConfigContent = packageConfigFile.readAsStringSync();
  final packageConfig = jsonDecode(packageConfigContent);

  if (packageConfig['configVersion'] != 2) {
    throw Exception('Unsupported package_config.json version.');
  }

  final packages = packageConfig['packages'] as List;

  Directory? projectPackageDir;
  String? packageRootUri;

  for (final package in packages) {
    final rootUri = package['rootUri'] as String;

    final packageRoot = path.join(packageConfigFile.parent.path, rootUri);

    // Check if packageConfigFile + rootUri is the same as the projectDir
    if (path.equals(packageRoot, projectDir.path)) {
      projectPackageDir = Directory(
        path.normalize(path.join(packageRoot, package['packageUri'])),
      );

      log.info('Found package $dependencyName at $projectPackageDir');
    }

    if (package['name'] == dependencyName) {
      if (rootUri.startsWith('file:///')) {
        return Directory(path.fromUri(Uri.parse(rootUri)));
      }

      packageRootUri = package['rootUri'] as String;
      log.info('Found package $dependencyName at $packageRootUri');
    }

    if (projectPackageDir != null && packageRootUri != null) {
      break;
    }
  }

  if (packageRootUri != null && projectPackageDir != null) {
    return resolvePackageDirectory(projectPackageDir, packageRootUri);
  }

  log.warning('Dependency $dependencyName not found in package_config.json');
  return null;
}
