@TestOn('vm')
@Tags(['kdf-process'])
library;

import 'dart:io';

import 'package:test/test.dart';

void main() {
  final binary = Platform.environment['KDF_EXPORT_TEST_BINARY'];
  test(
    'pinned KDF active TRON export contract at indices zero and seven',
    () async {
      final process = await Process.run('python3', [
        'tool/verify_tron_export_contract.py',
        '--binary',
        binary!,
      ]);
      // The fixture deliberately emits only safe assertion labels, never RPC
      // responses or keys; logs and wallet files are confined to temporary data.
      expect(process.exitCode, 0, reason: '${process.stdout}${process.stderr}');
    },
    skip: binary == null
        ? 'Set KDF_EXPORT_TEST_BINARY to the reviewed KDF binary'
        : false,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
