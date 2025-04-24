import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// A script to recursively upgrade all SDK packages across projects
///
/// Usage: dart run bin/upgrade_sdk_packages.dart [options]
///   --workspace-dir    Root workspace directory (default: current directory)
///   --verbose          Enable verbose output
///   --dry-run          Print changes without applying them
///   --help             Show usage information

// List of known SDK package names
const List<String> sdkPackages = [
  'komodo_defi_framework',
  'komodo_cex_market_data',
  'komodo_coin_updates',
  'komodo_defi_local_auth',
  'komodo_coins',
  'komodo_defi_types',
  'komodo_defi_sdk',
  'komodo_defi_rpc_methods',
  'komodo_defi_workers',
  'komodo_symbol_converter',
  'komodo_ui',
  'komodo_wallet_build_transformer',
];

void main(List<String> arguments) async {
  final parser =
      ArgParser()
        ..addOption(
          'workspace-dir',
          help: 'Root workspace directory',
          defaultsTo: Directory.current.path,
        )
        ..addFlag(
          'verbose',
          abbr: 'v',
          help: 'Enable verbose output',
          defaultsTo: false,
        )
        ..addFlag(
          'dry-run',
          help: 'Print changes without applying them',
          defaultsTo: false,
        )
        ..addFlag(
          'help',
          abbr: 'h',
          help: 'Show usage information',
          defaultsTo: false,
        );

  ArgResults args;
  try {
    args = parser.parse(arguments);
    if (args['help']) {
      _printUsage(parser);
      return;
    }
  } catch (e) {
    print('Error: $e');
    _printUsage(parser);
    exit(1);
  }

  final workspaceDir = args['workspace-dir'];
  final verbose = args['verbose'];
  final dryRun = args['dry-run'];

  if (dryRun) {
    print('Running in dry-run mode. No changes will be applied.');
  }

  final workspace = Directory(workspaceDir);
  if (!workspace.existsSync()) {
    print('Error: Workspace directory does not exist: $workspaceDir');
    exit(1);
  }

  print('🔍 Searching for pubspec.yaml files in $workspaceDir...');
  final pubspecFiles = await _findPubspecFiles(workspace);
  print('📋 Found ${pubspecFiles.length} pubspec.yaml files');

  int totalUpdated = 0;
  int totalSkipped = 0;
  int totalProcessed = 0;

  for (final pubspecFile in pubspecFiles) {
    totalProcessed++;
    final packageName = path.basename(path.dirname(pubspecFile));
    print('\n📦 Processing package: $packageName');

    final result = await _processPubspecFile(
      pubspecFile,
      verbose: verbose,
      dryRun: dryRun,
    );

    if (result > 0) {
      totalUpdated++;
    } else {
      totalSkipped++;
    }
  }

  print('\n✅ SDK package upgrade completed!');
  print('📊 Summary:');
  print('   - Total packages processed: $totalProcessed');
  print('   - Packages with updates: $totalUpdated');
  print('   - Packages with no updates needed: $totalSkipped');
}

/// Processes a pubspec.yaml file and upgrades SDK dependencies if needed
///
/// Returns the number of dependencies that were upgraded
Future<int> _processPubspecFile(
  String pubspecFilePath, {
  required bool verbose,
  required bool dryRun,
}) async {
  final file = File(pubspecFilePath);
  final content = await file.readAsString();

  // Parse the YAML content
  final pubspecYaml = loadYaml(content);
  final dependencies = pubspecYaml['dependencies'] as YamlMap?;

  if (dependencies == null) {
    if (verbose) {
      print('   ⚠️ No dependencies found in $pubspecFilePath');
    }
    return 0;
  }

  final packageDir = path.dirname(pubspecFilePath);
  int updatedCount = 0;

  for (final sdkPackage in sdkPackages) {
    // Check if this package depends on one of our SDK packages
    if (dependencies.containsKey(sdkPackage)) {
      final dependency = dependencies[sdkPackage];

      // Check dependency type (path, git, or hosted)
      if (dependency is YamlMap) {
        if (dependency.containsKey('path')) {
          if (verbose) {
            print(
              '   ⚠️ Path dependency found for $sdkPackage - skipping upgrade',
            );
          }
          continue;
        }

        if (dependency.containsKey('git')) {
          print(
            '   ⚠️ Git dependency found for $sdkPackage - manual update required',
          );
          continue;
        }
      }

      print('   🔄 Upgrading dependency: $sdkPackage');
      updatedCount++;

      if (!dryRun) {
        try {
          // Run flutter pub upgrade for the specific package
          final upgradeResult = await Process.run('flutter', [
            'pub',
            'upgrade',
            '--major-versions',
            sdkPackage,
          ], workingDirectory: packageDir);

          if (upgradeResult.exitCode != 0) {
            print('   ❌ Error upgrading $sdkPackage:');
            print('      ${upgradeResult.stderr}');
          } else if (verbose) {
            print('      ${upgradeResult.stdout}');
          }
        } catch (e) {
          print('   ❌ Exception while upgrading $sdkPackage: $e');
        }
      }
    }
  }

  // Run flutter pub get to ensure dependencies are in sync
  if (updatedCount > 0 && !dryRun) {
    print('   ♻️ Running pub get for ${path.basename(packageDir)}');
    try {
      final getResult = await Process.run('flutter', [
        'pub',
        'get',
      ], workingDirectory: packageDir);

      if (getResult.exitCode != 0) {
        print('   ⚠️ Error running pub get:');
        print('      ${getResult.stderr}');
      } else if (verbose) {
        print('      ${getResult.stdout}');
      }
    } catch (e) {
      print('   ⚠️ Exception while running pub get: $e');
    }
  }

  return updatedCount;
}

/// Finds all pubspec.yaml files in the workspace
Future<List<String>> _findPubspecFiles(Directory workspace) async {
  final List<String> pubspecFiles = [];

  await for (final entity in workspace.list(recursive: true)) {
    if (entity is File && path.basename(entity.path) == 'pubspec.yaml') {
      // Skip files in .dart_tool directories
      if (!entity.path.contains('/.dart_tool/')) {
        pubspecFiles.add(entity.path);
      }
    }
  }

  return pubspecFiles;
}

void _printUsage(ArgParser parser) {
  print('Upgrade SDK packages recursively across all projects');
  print('');
  print('Usage: dart run bin/upgrade_sdk_packages.dart [options]');
  print('');
  print('Options:');
  print(parser.usage);
}
