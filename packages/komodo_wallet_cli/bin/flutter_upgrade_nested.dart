/// A command-line tool to recursively find and upgrade Flutter projects.
///
/// This tool searches through directories to find Flutter projects (identified by their
/// pubspec.yaml files) and runs `flutter pub upgrade` on each one. It can optionally
/// allow major version upgrades and provides detailed statistics about the upgrade process.
///
/// Usage:
/// ```bash
/// # Regular upgrade in current directory
/// flutter_upgrade_nested
///
/// # Regular upgrade in specific directory
/// flutter_upgrade_nested -d /path/to/projects
///
/// # Allow major version upgrades
/// flutter_upgrade_nested --major-versions
///
/// # Allow upgrading transitive dependencies
/// flutter_upgrade_nested --unlock-transitive
///
/// # Combine multiple upgrade options
/// flutter_upgrade_nested --major-versions --unlock-transitive
///
/// # Show help
/// flutter_upgrade_nested --help
/// ```
library;

import 'dart:developer';
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// Tracks statistics for the upgrade process across all found projects.
class ProjectStats {
  /// Number of Flutter projects found
  int found = 0;

  /// Number of projects successfully upgraded
  int upgraded = 0;

  /// Number of projects that failed to upgrade
  int failed = 0;
}

/// Entry point for the CLI application.
///
/// Parses command-line arguments and initiates the upgrade process.
/// Handles errors and displays usage information when needed.
void main(List<String> arguments) async {
  final parser =
      ArgParser()
        ..addOption(
          'dir',
          abbr: 'd',
          help: 'Directory path to search for Flutter projects',
          defaultsTo: Directory.current.path,
        )
        ..addFlag(
          'major-versions',
          abbr: 'm',
          help: 'Allow major version upgrades',
          defaultsTo: false,
          negatable: false,
        )
        ..addFlag(
          'unlock-transitive',
          abbr: 't',
          help:
              'Allow upgrading transitive dependencies beyond direct dependency constraints',
          defaultsTo: false,
          negatable: false,
        )
        ..addFlag(
          'help',
          abbr: 'h',
          help: 'Show this help message',
          negatable: false,
        );

  try {
    final results = parser.parse(arguments);

    if (results['help']) {
      printUsage(parser);
      exit(0);
    }

    final directory = Directory(results['dir']);
    if (!directory.existsSync()) {
      throw Exception('Directory does not exist: ${results['dir']}');
    }

    await upgradeFlutterProjects(
      directory,
      allowMajorVersions: results['major-versions'],
      unlockTransitive: results['unlock-transitive'],
    );
  } catch (e) {
    log('Error: $e');
    printUsage(parser);
    exit(1);
  }
}

/// Prints usage information for the CLI tool.
///
/// Displays available options and their descriptions.
void printUsage(ArgParser parser) {
  log('Usage: flutter_upgrade_nested [options]');
  log(parser.usage);
}

/// Recursively searches for and upgrades Flutter projects.
///
/// This function walks through the directory tree starting from [searchDir],
/// identifies Flutter projects by their pubspec.yaml files, and attempts to
/// upgrade their dependencies.
///
/// Parameters:
/// - [searchDir]: The root directory to start searching from
/// - [allowMajorVersions]: Whether to allow major version upgrades (defaults to false)
///
/// The function maintains statistics about the upgrade process and prints
/// a summary when complete.
Future<void> upgradeFlutterProjects(
  Directory searchDir, {
  bool allowMajorVersions = false,
  bool unlockTransitive = false,
}) async {
  final stats = ProjectStats();
  log('Searching for Flutter projects in: ${searchDir.path}');
  log(
    'Upgrade mode: ${allowMajorVersions ? 'Major versions allowed' : 'Regular upgrade'}',
  );
  log('----------------------------------------');

  try {
    await for (final entity in searchDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File && path.basename(entity.path) == 'pubspec.yaml') {
        final isFlutterProject = await checkIfFlutterProject(entity);
        if (isFlutterProject) {
          stats.found++;
          final projectDir = entity.parent;
          log('\nFound Flutter project: ${projectDir.path}');

          final success = await upgradeDependencies(
            projectDir,
            allowMajorVersions: allowMajorVersions,
            unlockTransitive: unlockTransitive,
          );
          if (success) {
            stats.upgraded++;
          } else {
            stats.failed++;
          }
          log('----------------------------------------');
        }
      }
    }

    printSummary(stats);
  } catch (e) {
    log('Error while searching for projects: $e');
    exit(1);
  }
}

/// Checks if a given pubspec.yaml file belongs to a Flutter project.
///
/// This function parses the pubspec.yaml file and looks for the Flutter SDK
/// dependency to determine if it's a Flutter project.
///
/// Parameters:
/// - [pubspecFile]: The pubspec.yaml file to check
///
/// Returns:
/// - `true` if the project is a Flutter project
/// - `false` otherwise or if there's an error parsing the file
Future<bool> checkIfFlutterProject(File pubspecFile) async {
  try {
    final content = await pubspecFile.readAsString();
    final yaml = loadYaml(content);

    // Check if it's a Flutter project by looking for the SDK dependency
    if (yaml['dependencies'] is Map) {
      return true;
      // final deps = yaml['dependencies'] as Map;
      // return deps.containsKey('flutter') &&
      //     deps['flutter'] is Map &&
      //     (deps['flutter'] as Map).containsKey('sdk') &&
      //     (deps['flutter'] as Map)['sdk'] == 'flutter';
    }
    return false;
  } catch (e) {
    log('Warning: Could not parse ${pubspecFile.path}: $e');
    return false;
  }
}

/// Runs the flutter pub upgrade command for a project.
///
/// This function executes the upgrade command in the specified project directory,
/// optionally allowing major version upgrades.
///
/// Parameters:
/// - [projectDir]: The Flutter project directory containing pubspec.yaml
/// - [allowMajorVersions]: Whether to allow major version upgrades
///
/// Returns:
/// - `true` if the upgrade was successful
/// - `false` if there was an error or the command failed
Future<bool> upgradeDependencies(
  Directory projectDir, {
  bool allowMajorVersions = false,
  bool unlockTransitive = false,
}) async {
  try {
    log(
      'Running flutter pub upgrade${allowMajorVersions ? ' --major-versions' : ''} in ${projectDir.path}...',
    );

    log('Folder exists: ${projectDir.existsSync()}');

    final args = ['pub', 'upgrade'];
    if (allowMajorVersions) {
      args.add('--major-versions');
    }
    if (unlockTransitive) {
      args.add('--unlock-transitive');
    }

    final result = await Process.run(
      'flutter',
      args,
      workingDirectory: projectDir.path,
      runInShell: true,
    );

    if (result.exitCode == 0) {
      log('✓ Successfully upgraded dependencies');
      return true;
    } else {
      log('✗ Failed to upgrade dependencies');
      log('Error: ${result.stderr}');
      return false;
    }
  } catch (e) {
    log('✗ Failed to execute flutter pub upgrade: $e');
    return false;
  }
}

/// Prints a summary of the upgrade process.
///
/// Displays the total number of projects found, successfully upgraded,
/// and failed upgrades.
///
/// Parameters:
/// - [stats]: The [ProjectStats] object containing the statistics to display
void printSummary(ProjectStats stats) {
  log('\nSummary:');
  log('Found: ${stats.found} Flutter projects');
  log('Successfully upgraded: ${stats.upgraded} projects');
  log('Failed to upgrade: ${stats.failed} projects');
}
