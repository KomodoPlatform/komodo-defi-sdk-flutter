#!/usr/bin/env dart

import 'package:komodo_defi_remote/cli.dart';

Future<void> main(List<String> arguments) async {
  final runner = KdfRemoteCommandRunner();
  await runner.run(arguments);
}
