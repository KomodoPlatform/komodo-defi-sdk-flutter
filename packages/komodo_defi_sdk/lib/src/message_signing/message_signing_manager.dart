import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Manager for cryptographic message signing and verification operations.
///
/// This class provides methods to sign messages using a coin's private key and
/// verify messages that have been signed with a private key.
class MessageSigningManager {
  /// Creates a new message signing manager.
  ///
  /// Requires an [ApiClient] to communicate with the Komodo DeFi Framework.
  MessageSigningManager(this._client);

  final ApiClient _client;

  /// Signs a message with the private key of the specified coin.
  ///
  /// This method creates a cryptographic signature that can be used to prove
  /// ownership of an address.
  ///
  /// The `address` parameter is not used in the signing process and will be
  /// ignored. This is in preparation for the near future when KDF will add HD
  /// wallet support.
  ///
  /// Parameters:
  /// - [coin]: The ticker of the coin to use for signing (e.g., "BTC").
  /// - [message]: The message to sign.
  /// - [address]: The address to sign the message with. The coin must be
  ///  enabled and have this address in the current wallet.
  ///
  ///
  /// Returns:
  /// A [Future] that completes with the signature as a string.
  ///
  /// Throws:
  /// - [Exception] if the signing operation fails for any reason.
  /// - [UnknownAddressException] if the address is not associated with the
  ///  specified coin.
  Future<String> signMessage({
    required String coin,
    required String message,
    required String address,
  }) async {
    final response = await _client.rpc.utility.signMessage(
      coin: coin,
      message: message,
    );
    return response.signature;
  }

  /// Verifies a cryptographic signature for a message.
  ///
  /// This method checks if a signature is valid for the given message and was
  /// created by the private key corresponding to the specified address.
  ///
  /// Parameters:
  /// - [coin]: The ticker of the coin to use for verification (e.g., "BTC").
  /// - [message]: The original message that was signed.
  /// - [signature]: The signature to verify.
  /// - [address]: The address that supposedly signed the message.
  ///
  /// Returns:
  /// A [Future] that completes with a boolean indicating whether the signature
  ///  is valid.
  ///
  /// Throws:
  /// - [Exception] if the verification operation fails for any reason.
  Future<bool> verifyMessage({
    required String coin,
    required String message,
    required String signature,
    required String address,
  }) async {
    final response = await _client.rpc.utility.verifyMessage(
      coin: coin,
      message: message,
      signature: signature,
      address: address,
    );
    return response.isValid;
  }

  /// Dispose of any resources held by this manager.
  Future<void> dispose() async {
    // No resources to clean up yet
  }
}

/// Exception thrown when an unknown address is used for signing.
class UnknownAddressException implements Exception {
  /// Exception thrown when an unknown address is used for signing.

  UnknownAddressException([
    this.message =
        'Unknown address. The specified address is not associated with the '
            'coin. Ensure the coin is enabled and the address is generated.',
  ]);

  /// The error message associated with the exception.
  final String message;

  @override
  String toString() => 'UnknownAddressException: $message';
}
