import 'dart:io';

import 'package:args/args.dart';

// TODO: Reference as a package.
import '../../komodo_wallet_build_transformer/bin/komodo_wallet_build_transformer.dart'
    as build_transformer;

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
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
    ..addFlag('version', negatable: false, help: 'Print the tool version.');
}

void printUsage(ArgParser argParser) {
  stdout.writeln('Usage: dart komodo_wallet_cli.dart <flags> [arguments]');
  stdout.writeln(argParser.usage);
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser()
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addCommand('get');
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = results.flag('verbose');

    if (results.command != null) {
      switch (results.command!.name) {
        case 'get':
          return build_transformer.main(results.command!.rest);
        default:
          printUsage(argParser);
      }
      return;
    }

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      stdout.writeln('komodo_wallet_cli version: $version');
      return;
    }
    if (results.wasParsed('verbose')) {
      verbose = true;
    }

    // Act on the arguments provided.
    stdout.writeln('Positional arguments: ${results.rest}');
    if (verbose) {
      stdout.writeln('[VERBOSE] All arguments: ${results.arguments}');
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    stderr.writeln(e.message);
    stderr.writeln('');
    printUsage(argParser);
  }
}
