import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// Namespace for message signing and verification methods
class MessageSigningMethodsNamespace extends BaseRpcMethodNamespace {
  /// Creates a new message signing methods namespace
  MessageSigningMethodsNamespace(super.client);

  /// Signs a message with a coin's signing key
  Future<SignMessageResponse> signMessage({
    required String coin,
    required String message,
  }) {
    return execute(
      SignMessageRequest(rpcPass: rpcPass ?? '', coin: coin, message: message),
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
