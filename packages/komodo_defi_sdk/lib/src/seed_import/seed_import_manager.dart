import 'dart:typed_data';

import 'package:komodo_defi_sdk/src/seed_import/seed_import_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manager that selects and executes a `SeedImportStrategy`.
class SeedImportManager {
  SeedImportManager(List<SeedImportStrategy> strategies)
      : _strategies = List.unmodifiable(strategies);

  final List<SeedImportStrategy> _strategies;

  List<SeedImportStrategy> get strategies => _strategies;

  /// Attempts to import using the first strategy that reports it can handle
  /// the input. Throws if none can handle or if import fails for the chosen
  /// strategy.
  Future<Mnemonic> importAny({
    String? fileName,
    Uint8List? bytes,
    String? text,
    required String password,
  }) async {
    final candidate = _strategies.firstWhere(
      (s) => s.canHandle(fileName: fileName, bytes: bytes, text: text),
      orElse: () => throw ArgumentError('No strategy can handle the provided input'),
    );

    return candidate.importSeed(
      fileName: fileName,
      bytes: bytes,
      text: text,
      password: password,
    );
  }
}

