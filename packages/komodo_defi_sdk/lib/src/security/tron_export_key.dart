import 'dart:typed_data';

import 'package:komodo_defi_sdk/src/transaction_history/strategies/tron_grid_address_codec.dart'
    show tronAddressForDisplay;
import 'package:pointycastle/export.dart';

/// Public metadata derived only to verify an already activated TRON key.
/// No mnemonic derivation or alternative derivation-path policy lives here.
class TronExportKey {
  TronExportKey._(this.privateKey, this.publicKey, this.address);

  /// Validates a scalar and derives its TRON owner address.
  factory TronExportKey.parse(String value) {
    final hex = value.startsWith('0x') ? value.substring(2) : value;
    if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hex)) {
      throw const FormatException('Invalid TRON private key');
    }
    final scalar = BigInt.parse(hex, radix: 16);
    final domain = ECDomainParameters('secp256k1');
    if (scalar <= BigInt.zero || scalar >= domain.n) {
      throw const FormatException('Invalid TRON private key');
    }
    final public = (domain.G * scalar)!.getEncoded(false);
    final hash = KeccakDigest(256).process(Uint8List.sublistView(public, 1));
    final payload = <int>[0x41, ...hash.sublist(12)];
    // Reuse the SDK's pure address codec, including its Base58Check checksum.
    final address = tronAddressForDisplay(_hex(payload));
    if (!address.startsWith('T')) {
      throw const FormatException('Invalid TRON derived address');
    }
    return TronExportKey._(hex.toLowerCase(), _hex(public), address);
  }

  /// Fixed-width lowercase scalar, preserving leading zero bytes.
  final String privateKey;

  /// Uncompressed SEC1 public key, including its 04 prefix.
  final String publicKey;

  /// TRON Base58Check owner address with the 0x41 prefix.
  final String address;

  static String _hex(List<int> bytes) =>
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

  @override
  String toString() => 'TronExportKey(redacted)';
}
