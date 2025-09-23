import 'dart:typed_data';

import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Strategy interface for importing wallet seeds from various sources.
///
/// Follow BLoC documentation conventions by keeping strategies immutable and
/// side-effect free beyond returning parsed/validated data.
abstract class SeedImportStrategy {
  /// Human-friendly name for display (e.g., "Legacy Desktop .seed").
  String get name;

  /// File extensions this strategy can handle (lowercase, without dot).
  List<String> get supportedFileExtensions;

  /// Quick probe to see if the input likely matches this strategy without
  /// performing expensive work.
  bool canHandle({String? fileName, Uint8List? bytes, String? text});

  /// Imports a seed and returns a `Mnemonic` representation.
  /// Implementations should throw descriptive exceptions on failure.
  Future<Mnemonic> importSeed({
    String? fileName,
    Uint8List? bytes,
    String? text,
    required String password,
  });
}

