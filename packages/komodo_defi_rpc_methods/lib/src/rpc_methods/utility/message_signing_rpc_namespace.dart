import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// Namespace for message signing and verification methods
class MessageSigningMethodsNamespace extends BaseRpcMethodNamespace {
  /// Creates a new message signing methods namespace
  MessageSigningMethodsNamespace(super.client);

  /// Signs a message with a coin's signing key
  ///
  /// For non-HD wallets, only [coin] and [message] are required.
  /// For HD wallets, provide [addressPath] using either:
  /// - `AddressPath.derivationPath("m/84'/141'/0'/0/1")`
  /// - `AddressPath.components(accountId: 0, chain: 'External', addressId: 1)`
  ///
  /// Example (non-HD):
  /// ```dart
  /// final response = await signMessage(
  ///   coin: 'DOC',
  ///   message: 'Hello, world!',
  /// );
  /// ```
  ///
  /// Example (HD with AddressPath):
  /// ```dart
  /// final response = await signMessage(
  ///   coin: 'KMD',
  ///   message: 'Hello, world!',
  ///   addressPath: AddressPath.derivationPath("m/84'/141'/0'/0/1"),
  /// );
  /// ```
  Future<SignMessageResponse> signMessage({
    required String coin,
    required String message,
    AddressPath? addressPath,
  }) {
    return execute(
      SignMessageRequest(
        rpcPass: rpcPass ?? '',
        coin: coin,
        message: message,
        addressPath: addressPath,
      ),
    );
  }

  /// Verifies a message signature
  Future<VerifyMessageResponse> verifyMessage({
    required String coin,
    required String message,
    required String signature,
    required String address,
  }) {
    return execute(
      VerifyMessageRequest(
        rpcPass: rpcPass ?? '',
        coin: coin,
        message: message,
        signature: signature,
        address: address,
      ),
    );
  }
}
