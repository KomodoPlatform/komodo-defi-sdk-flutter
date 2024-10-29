import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:komodo_wallet_build_transformer/src/build_step.dart';
import 'package:komodo_wallet_build_transformer/src/steps/copy_platform_assets_build_step.dart';
import 'package:komodo_wallet_build_transformer/src/steps/fetch_coin_assets_build_step.dart';
import 'package:komodo_wallet_build_transformer/src/steps/fetch_defi_api_build_step.dart';
import 'package:komodo_wallet_build_transformer/src/steps/models/build_config.dart';
import 'package:komodo_wallet_build_transformer/src/util/cli_util.dart';
import 'package:komodo_wallet_build_transformer/src/util/logging.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

// TODO! Get dynamically
const String version = '0.0.1';
const inputOptionName = 'input';
const outputOptionName = 'output';
const githubTokenEnvName = 'GITHUB_API_PUBLIC_READONLY_TOKEN';

late final ArgResults _argResults;
final Directory _projectRoot = Directory.current.absolute;
final log = Logger('komodo_wallet_build_transformer');

/// Defines the build steps that should be executed. Only the build steps that
/// pass the command line flags will be executed. For Flutter transformers,
/// this is configured in the root project's `pubspec.yaml` file.
/// The steps are executed in the order they are defined in this list.
List<BuildStep> _buildStepBootstrapper(
  BuildConfig buildConfig,
  Directory artifactOutputDirectory,
  File buildConfigFile,
  String? githubToken,
) =>
    [
      FetchDefiApiStep.withBuildConfig(
        buildConfig,
        artifactOutputDirectory,
        buildConfigFile,
        githubToken: githubToken,
      ),
      FetchCoinAssetsBuildStep.withBuildConfig(
        buildConfig,
        buildConfigFile,
        artifactOutputDirectory: artifactOutputDirectory,
        githubToken: githubToken,
      ),
      CopyPlatformAssetsBuildStep(
        projectRoot: _projectRoot,
        buildConfig: buildConfig,
        artifactOutputDirectory: artifactOutputDirectory,
      ),
    ];

const List<String> _knownBuildStepIds = [
  FetchDefiApiStep.idStatic,
  FetchCoinAssetsBuildStep.idStatic,
  CopyPlatformAssetsBuildStep.idStatic,
];

ArgParser buildParser() {
  final parser = ArgParser()
    ..addOption(
      'config_output_path',
      mandatory: true,
      abbr: 'c',
      help: 'Path to the build config file relative to the artifact '
          'output package.',
    )
    ..addOption(
      'artifact_output_package',
      mandatory: true,
      help: 'Name of the package where the artifacts will be stored.',
    )
    ..addOption(inputOptionName, mandatory: true, abbr: 'i')
    ..addOption(outputOptionName, mandatory: true, abbr: 'o')
    ..addOption(
      'log_level',
      abbr: 'l',
      help: 'Set log level. E.g. --log_level=info',
      defaultsTo: 'info',
      allowed: allowedLogLevels,
    )
    ..addFlag(
      'concurrent',
      negatable: false,
      help: 'Run build steps concurrently.',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag('version', negatable: false, help: 'Print the tool version.')
    ..addFlag('all', abbr: 'a', negatable: false, help: 'Run all build steps.');

  for (final id in _knownBuildStepIds) {
    parser.addFlag(
      id,
      negatable: false,
      help: 'Run the $id build step. Must provide at least one build step flag '
          'or specify -all.',
    );
  }

  return parser;
}

void printUsage(ArgParser argParser) {
  log
    ..info(
      'Usage: dart komodo_wallet_build_transformer.dart <flags> [arguments]',
    )
    ..info(argParser.usage);
}

void main(List<String> arguments) async {
  final argParser = buildParser();
  try {
    _argResults = argParser.parse(arguments);

    configureLogToConsole(_argResults.option('log_level')!);

    if (_argResults.flag('help')) {
      printUsage(argParser);
      return;
    }
    if (_argResults.flag('version')) {
      log.info('komodo_wallet_build_transformer version: $version');
      return;
    }

    final githubToken = Platform.environment[githubTokenEnvName];
    if (githubToken == null) {
      log.warning(
        'GitHub token not set. Some build steps may fail. '
        'Set the $githubTokenEnvName environment variable to fix this.',
      );
    }

    final canRunConcurrent = _argResults.flag('concurrent');

    final artifactOutputPackage = getDependencyDirectory(
          _projectRoot.path,
          _argResults.option('artifact_output_package')!,
        )?.absolute ??
        (throw Exception('Artifact output package not found'));
    log.info('Artifact output package: ${artifactOutputPackage.path}');

    final configOutputPath = _argResults.option('config_output_path')!;

    final configFile = File(
      path.normalize(path.join(artifactOutputPackage.path, configOutputPath)),
    );

    if (!configFile.existsSync()) {
      throwMissingConfigException(configFile);
    }
    log.info('Build config found at ${configFile.absolute.path}');

    final config = BuildConfig.fromJson(
      // The [BuildConfig] fromJson methods throw exceptions if the input is
      // invalid, so we can safely pass an empty map as the default value.
      jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>? ?? {},
    );

    final steps = _buildStepBootstrapper(
      config,
      artifactOutputPackage,
      configFile,
      githubToken,
    );

    if (steps.length != _knownBuildStepIds.length) {
      throw Exception('Mismatch between build steps and known build step ids');
    }

    final buildStepFutures = steps
        .where((step) => _argResults.flag('all') || _argResults.flag(step.id))
        .map(_runStep);

    log.info('${buildStepFutures.length} build steps to run');

    if (canRunConcurrent) {
      await Future.wait(buildStepFutures);
    } else {
      for (final future in buildStepFutures) {
        await future;
      }
    }

    _writeSuccessStatus();

    log.info('SUCCESS: Build steps completed successfully');
    exit(0);
  } on FormatException catch (e, s) {
    log.severe('Error parsing arguments', e, s);
    printUsage(argParser);
    exit(64);
  } catch (e, s) {
    log.shout('Error running build steps', e, s);
    exit(1);
  }
}

void throwMissingConfigException(File configFile) {
  final files = _projectRoot
      .listSync(recursive: true)
      .where(
        (file) => file is File && file.path.endsWith('build_config.json'),
      )
      .map((file) => '${file.path}\n');
  throw Exception(
    'Config file not found in ${configFile.path} '
    '(abs: ${configFile.absolute.path}). \nProject root abs '
    '(${_projectRoot.absolute.path}).\n Did you mean one of these? \n$files',
  );
}

Future<void> _runStep(BuildStep step) async {
  final stepName = step.runtimeType.toString();

  if (await step.canSkip()) {
    log.info('$stepName: Skipping build step');
    return;
  }

  try {
    log.info('$stepName: Running build step');
    final timer = Stopwatch()..start();

    await step.build();

    log.info(
      '$stepName: Build step completed in ${timer.elapsedMilliseconds}ms',
    );
  } catch (e) {
    log.severe(
      '$stepName: Error running build step $stepName: $e',
      e,
    );

    if (e is! BuildStepWithoutRevertException) {
      await step.revert((e is Exception) ? e : null).catchError(
            (Object revertError) => log.severe(
              '$stepName: Error reverting build step',
              revertError,
            ),
          );
    }

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
  final inputFile = File(_argResults.option(inputOptionName)!);
  log.info(
    'Writing success status to ${_argResults.option(outputOptionName)}',
  );

  final updatedInput = _prependLastRunTimestampToFile(inputFile);
  File(_argResults.option(outputOptionName)!)
      .writeAsStringSync(updatedInput, flush: true);
}

String _prependLastRunTimestampToFile(
  File inputFile, {
  DateTime? timestamp,
}) {
  final inputFileContent = inputFile.readAsStringSync();
  final lastRun = 'LAST_RUN: ${timestamp ?? DateTime.now().toIso8601String()}';

  if (_isJsonFile(inputFile)) {
    try {
      final updatedJson = _updateJsonWithLastRun(inputFileContent, lastRun);
      log.info('Updated JSON with LAST_RUN: $lastRun');
      return updatedJson;
    } catch (e) {
      log.severe(
        'Warning: Failed to parse or update JSON. '
        'Falling back to default behavior.',
        e,
      );
    }
  }

  if (inputFile.path.toLowerCase().endsWith('.json')) {
    log.severe(
      'File extension is .json, but content is not JSON. '
      'Skipping LAST_RUN update',
    );
    return inputFileContent;
  }

  // Default behavior: prepend or replace the LAST_RUN comment
  return inputFileContent.contains('LAST_RUN:')
      ? inputFileContent.replaceFirst(RegExp('LAST_RUN:.*'), lastRun)
      : '$lastRun\n$inputFileContent';
}

bool _isJsonFile(File file) {
  if (!file.path.toLowerCase().endsWith('.json')) {
    return false;
  }

  try {
    final content = file.readAsStringSync().trim();
    json.decode(content);
    return true;
  } on FormatException catch (e) {
    log.warning('Invalid JSON format in file: ${file.path}', e);
    return false;
  } on FileSystemException catch (e, s) {
    log.warning('Error reading file: ${file.path}', e, s);
    return false;
  } catch (e, s) {
    log.warning('Unexpected error processing file: ${file.path}', e, s);
    return false;
  }
}

String _updateJsonWithLastRun(String jsonContent, String lastRun) {
  final json = jsonDecode(jsonContent);
  if (json is Map<String, dynamic>) {
    json['LAST_RUN'] = lastRun;
    return jsonEncode(json);
  }
  throw const FormatException('JSON content is not an object');
}
