// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import 'package:komodo_wallet_build_transformer/src/build_step.dart';
import 'package:komodo_wallet_build_transformer/src/steps/copy_platform_assets_build_step.dart';
import 'package:komodo_wallet_build_transformer/src/steps/fetch_coin_assets_build_step.dart';
import 'package:komodo_wallet_build_transformer/src/steps/fetch_defi_api_build_step.dart';

const String version = '0.0.1';
const inputOptionName = 'input';
const outputOptionName = 'output';

late final ArgResults _argResults;
final String _projectRoot = Directory.current.path;

/// Defines the build steps that should be executed. Only the build steps that
/// pass the command line flags will be executed. For Flutter transformers,
/// this is configured in the root project's `pubspec.yaml` file.
/// The steps are executed in the order they are defined in this list.
List<BuildStep> _buildStepBootstrapper(Map<String, dynamic> buildConfig) => [
      // TODO: Refactor to use data model classes instead of Map<String, dynamic>

      FetchDefiApiStep.withBuildConfig(buildConfig),
      FetchCoinAssetsBuildStep.withBuildConfig(buildConfig),
      CopyPlatformAssetsBuildStep(projectRoot: _projectRoot),
    ];

const List<String> _knownBuildStepIds = [
  FetchDefiApiStep.idStatic,
  FetchCoinAssetsBuildStep.idStatic,
  CopyPlatformAssetsBuildStep.idStatic,
];

ArgParser buildParser() {
  final parser = ArgParser()
    ..addOption(inputOptionName, mandatory: true, abbr: 'i')
    ..addOption(outputOptionName, mandatory: true, abbr: 'o')
    ..addFlag('concurrent',
        abbr: 'c',
        negatable: false,
        help: 'Run build steps concurrently if possible.')
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Print this usage information.')
    ..addFlag('verbose',
        abbr: 'v', negatable: false, help: 'Show additional command output.')
    ..addFlag('version', negatable: false, help: 'Print the tool version.')
    ..addFlag('all', abbr: 'a', negatable: false, help: 'Run all build steps.');

  for (final id in _knownBuildStepIds) {
    parser.addFlag(
      id,
      negatable: false,
      help:
          'Run the $id build step. Must provide at least one build step flag or specify -all.',
    );
  }

  return parser;
}

void printUsage(ArgParser argParser) {
  print('Usage: dart komodo_wallet_build_transformer.dart <flags> [arguments]');
  print(argParser.usage);
}

Map<String, dynamic> loadJsonFile(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    _logMessage('Json file not found: $path', error: true);
    throw Exception('Json file not found: $path');
  }
  final content = file.readAsStringSync();
  return jsonDecode(content);
}

void main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    _argResults = argParser.parse(arguments);

    if (_argResults.flag('help')) {
      printUsage(argParser);
      return;
    }
    if (_argResults.flag('version')) {
      _logMessage('komodo_wallet_build_transformer version: $version');
      return;
    }

    final canRunConcurrent = _argResults.flag('concurrent');
    // final configFile = File('$_projectRoot/app_build/build_config.json');
    final configFile = File(_argResults.option('input')!);
    if (!configFile.existsSync()) {
      throw Exception(
          'Config file not found: ${configFile.path}. Trying project asset folder...');
    }
    final config = json.decode(configFile.readAsStringSync());

    final steps = _buildStepBootstrapper(config);

    if (steps.length != _knownBuildStepIds.length) {
      throw Exception('Mismatch between build steps and known build step ids');
    }

    final buildStepFutures = steps
        .where((step) => _argResults.flag('all') || _argResults.flag(step.id))
        .map((step) => _runStep(step, config));

    _logMessage('${buildStepFutures.length} build steps to run');

    if (canRunConcurrent) {
      await Future.wait(buildStepFutures);
    } else {
      for (final future in buildStepFutures) {
        await future;
      }
    }

    _writeSuccessStatus();
    _logMessage('Build steps completed');
    exit(0);
  } on FormatException catch (e) {
    _logMessage(e.message, error: true);
    _logMessage('');
    printUsage(argParser);
    exit(64);
  } catch (e) {
    _logMessage('Error running build steps: ${e.toString()}', error: true);
    exit(1);
  }
}

Future<void> _runStep(BuildStep step, Map<String, dynamic> config) async {
  final stepName = step.runtimeType.toString();

  if (await step.canSkip()) {
    _logMessage('$stepName: Skipping build step');
    return;
  }

  try {
    _logMessage('$stepName: Running build step');
    final timer = Stopwatch()..start();

    await step.build();

    _logMessage(
        '$stepName: Build step completed in ${timer.elapsedMilliseconds}ms');
  } catch (e) {
    _logMessage('$stepName: Error running build step: ${e.toString()}',
        error: true);

    await step
        .revert((e is Exception) ? e : null)
        .catchError((revertError) => _logMessage(
              '$stepName: Error reverting build step: $revertError',
            ));

    rethrow;
  }
}

/// A function that signals the Flutter asset transformer completed
/// successfully by copying the input file to the output file.
///
/// This is used because Flutter's asset transformers require an output file
/// to be created in order for the step to be considered successful.
///
/// NB! The input and output file paths do not refer to the file in our
/// project's assets directory, but rather the a copy that is created by
/// Flutter's asset transformer.
///
void _writeSuccessStatus() {
  final input = File(_argResults.option(inputOptionName)!);
  final output = File(_argResults.option(outputOptionName)!);
  input.copySync(output.path);
}

// TODO: Consider how the verbose flag should influence logging
void _logMessage(String message, {bool error = false}) {
  final prefix = error ? 'ERROR' : 'INFO';
  final output = error ? stderr : stdout;
  output.writeln('[$prefix] $message');
}
