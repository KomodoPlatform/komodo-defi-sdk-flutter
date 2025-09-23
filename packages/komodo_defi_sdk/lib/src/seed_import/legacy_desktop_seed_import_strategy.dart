import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:encrypt/encrypt.dart' as enc;
import 'package:komodo_defi_sdk/src/seed_import/seed_import_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';
import 'package:scrypt/scrypt.dart' as scrypt;

/// Import strategy for legacy Komodo/Agama Desktop `.seed` backups.
///
/// Heuristics:
/// - Binary/opaque content with non-UTF8 bytes
/// - File extension `.seed`
/// - Historically used scrypt KDF + AES-256-CBC (no auth tag)
///
/// Because exact legacy parameters can vary, we attempt a small matrix of
/// commonly used scrypt N/r/p and IV/key derivations. On success, the
/// decrypted content must be a plausible BIP39 mnemonic.
class LegacyDesktopSeedImportStrategy implements SeedImportStrategy {
  LegacyDesktopSeedImportStrategy();

  static final _log = Logger('LegacyDesktopSeedImportStrategy');

  @override
  String get name => 'Legacy Desktop .seed';

  @override
  List<String> get supportedFileExtensions => const ['seed'];

  @override
  bool canHandle({String? fileName, Uint8List? bytes, String? text}) {
    if (fileName != null &&
        supportedFileExtensions.any((ext) => fileName.toLowerCase().endsWith('.$ext'))) {
      return true;
    }
    // If text is clearly binary garbage or provided as bytes, prefer bytes.
    if (bytes != null && bytes.isNotEmpty) {
      // Heuristic: high proportion of non-printable bytes
      final nonPrintable = bytes.where((b) => b < 0x09 || (b > 0x0D && b < 0x20)).length;
      return nonPrintable / bytes.length > 0.15;
    }
    return false;
  }

  @override
  Future<Mnemonic> importSeed({
    String? fileName,
    Uint8List? bytes,
    String? text,
    required String password,
  }) async {
    if ((bytes == null || bytes.isEmpty) && (text == null || text.isEmpty)) {
      throw ArgumentError('No seed file content provided');
    }

    final fileBytes = bytes ?? Uint8List.fromList(utf8.encode(text!));

    final mnemonic = await _tryDecryptAndParseMnemonic(fileBytes, password);
    if (mnemonic == null) {
      throw StateError('Failed to decrypt legacy .seed with provided password');
    }
    return Mnemonic.plaintext(mnemonic);
  }

  Future<String?> _tryDecryptAndParseMnemonic(
    Uint8List encrypted,
    String password,
  ) async {
    // Common scrypt parameter guesses used historically in various wallets.
    const nCandidates = <int>[16384, 32768, 4096];
    const rCandidates = <int>[8];
    const pCandidates = <int>[1];

    // Salt/IV derivation heuristics:
    // - Try first 16 bytes as IV, next 16 as salt (or vice versa)
    // - Try SHA256(password) as key material w/ no salt (some early formats)
    final candidates = <Future<String?> Function()>[];

    // 1) If file is at least 32 bytes, attempt [IV(16) | SALT(16) | CIPHERTEXT]
    if (encrypted.length > 32) {
      final iv = encrypted.sublist(0, 16);
      final salt = encrypted.sublist(16, 32);
      final ciphertext = encrypted.sublist(32);

      for (final n in nCandidates) {
        for (final r in rCandidates) {
          for (final p in pCandidates) {
            candidates.add(() async => _decryptScryptAesCbc(
                  ciphertext: ciphertext,
                  password: password,
                  iv: iv,
                  salt: salt,
                  n: n,
                  r: r,
                  p: p,
                ));
          }
        }
      }

      // 2) Swap IV/Salt and retry
      final iv2 = encrypted.sublist(16, 32);
      final salt2 = encrypted.sublist(0, 16);
      final ciphertext2 = encrypted.sublist(32);
      for (final n in nCandidates) {
        for (final r in rCandidates) {
          for (final p in pCandidates) {
            candidates.add(() async => _decryptScryptAesCbc(
                  ciphertext: ciphertext2,
                  password: password,
                  iv: iv2,
                  salt: salt2,
                  n: n,
                  r: r,
                  p: p,
                ));
          }
        }
      }
    }

    // 3) Fallback: Treat entire file as ciphertext, derive key from SHA256(password),
    //    IV as zeros (last resort).
    candidates.add(() async => _decryptShaPasswordAesCbc(
          ciphertext: encrypted,
          password: password,
        ));

    for (final attempt in candidates) {
      try {
        final plaintext = await attempt();
        if (plaintext == null) continue;
        final maybe = plaintext.trim();
        if (await _isValidMnemonic(maybe)) {
          return maybe;
        }
      } catch (e) {
        _log.fine('Legacy .seed attempt failed: $e');
      }
    }

    return null;
  }

  Future<bool> _isValidMnemonic(String input) async {
    try {
      final validator = MnemonicValidator();
      await validator.init();
      return validator.validateBip39(input);
    } catch (_) {
      return false;
    }
  }

  Future<String?> _decryptScryptAesCbc({
    required Uint8List ciphertext,
    required String password,
    required Uint8List iv,
    required Uint8List salt,
    required int n,
    required int r,
    required int p,
  }) async {
    try {
      final params = scrypt.ScryptParameters(n: n, r: r, p: p, desiredKeyLength: 32);
      final key = await scrypt.scrypt(utf8.encode(password), salt, params);
      final encrypter = enc.Encrypter(enc.AES(enc.Key(Uint8List.fromList(key)), mode: enc.AESMode.cbc));
      final decrypted = encrypter.decrypt(enc.Encrypted(ciphertext), iv: enc.IV(iv));
      return decrypted;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _decryptShaPasswordAesCbc({
    required Uint8List ciphertext,
    required String password,
  }) async {
    try {
      final sha = crypto.Sha256();
      final keyBytes = await sha.hash(utf8.encode(password));
      final key = enc.Key(Uint8List.fromList(keyBytes.bytes));
      final iv = enc.IV(Uint8List(16));
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decrypt(enc.Encrypted(ciphertext), iv: iv);
      return decrypted;
    } catch (e) {
      return null;
    }
  }
}

