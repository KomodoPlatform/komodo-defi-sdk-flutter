import 'dart:io';
import 'package:yaml/yaml.dart';

void main() async {
  // Exit with failure for debug purposes
  // exit(1);

  final file = File('pubspec.yaml');

  stdout.writeln('Reading pubspec.yaml at ${file.absolute.path}');

  if (!file.existsSync()) {
    stderr.writeln('pubspec.yaml not found.');
    throw Exception('pubspec.yaml not found.');
  }

  final content = await file.readAsString();
  final doc = loadYaml(content);

  // Find the asset item with the komodo_wallet_build_transformer
  final assets = doc['flutter']['assets'] as List;
  final transformerAsset = assets.firstWhere(
    (asset) {
      if (asset is Map &&
          asset.containsKey('path') &&
          asset.containsKey('transformers')) {
        final transformers = asset['transformers'] as List;
        return transformers.any(
          (transformer) =>
              transformer['package'] == 'komodo_wallet_build_transformer',
        );
      }
      return false;
    },
    orElse: () => null,
  );

  if (transformerAsset == null) {
    throw Exception(
      'No asset item found with komodo_wallet_build_transformer.',
    );
  }

  final path = transformerAsset['path'];
  final transformer = (transformerAsset['transformers'] as List).firstWhere(
    (transformer) =>
        transformer['package'] == 'komodo_wallet_build_transformer',
  );
  final args = (transformer['args'] as List).cast<String>().toList()
    ..addAll([
      '-i',
      path as String,
      '-o',
      path,
    ]);

  print('Running komodo_wallet_build_transformer with args: $args');

  final result = Process.runSync(
    'dart',
    [
      'run',
      'komodo_wallet_build_transformer',
      ...args,
    ],
  );

  if (result.exitCode != 0) {
    (result.stdout as String).split('\n').forEach(stdout.writeln);
    (result.stderr as String).split('\n').forEach(stderr.writeln);

    stderr.writeln('Error running komodo_wallet_build_transformer.');
    stderr.writeln(result.stderr);
    exit(result.exitCode);
  }

  stdout.writeln('komodo_wallet_build_transformer ran successfully.');
}
