import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// WalletConnect hardware wallet methods namespace
class WalletConnectMethodsNamespace extends BaseRpcMethodNamespace {
  WalletConnectMethodsNamespace(super.client);

  /// Create a new WalletConnect connection with required namespaces
  ///
  /// This method generates a WalletConnect URI that can be converted to a QR code
  /// for mobile wallet scanning. The required namespaces parameter specifies
  /// which blockchain networks and methods the connection should support.
  ///
  /// Returns a response containing the WalletConnect URI.
  Future<WcNewConnectionResponse> newConnection({
    required WcRequiredNamespaces requiredNamespaces,
  }) {
    return execute(
      WcNewConnectionRequest(
        rpcPass: rpcPass ?? '',
        requiredNamespaces: requiredNamespaces,
      ),
    );
  }

  /// Get all active WalletConnect sessions
  ///
  /// Returns a list of all currently active WalletConnect sessions
  /// that have been established with mobile wallets.
  Future<WcGetSessionsResponse> getSessions() {
    return execute(WcGetSessionsRequest(rpcPass: rpcPass ?? ''));
  }

  /// Get details for a specific WalletConnect session
  ///
  /// Retrieves detailed information about a specific session identified
  /// by its topic. Optionally includes pairing topic information.
  ///
  /// Parameters:
  /// - [topic]: The session topic identifier
  /// - [withPairingTopic]: Whether to include pairing topic in response
  Future<WcGetSessionResponse> getSession({
    required String topic,
    bool withPairingTopic = false,
  }) {
    return execute(
      WcGetSessionRequest(
        rpcPass: rpcPass ?? '',
        topic: topic,
        withPairingTopic: withPairingTopic,
      ),
    );
  }

  /// Ping a WalletConnect session to test connectivity
  ///
  /// Sends a ping to the specified session to verify that the connection
  /// is still active and responsive.
  ///
  /// Parameters:
  /// - [topic]: The session topic identifier to ping
  Future<WcPingSessionResponse> pingSession({required String topic}) {
    return execute(WcPingSessionRequest(rpcPass: rpcPass ?? '', topic: topic));
  }

  /// Delete/terminate a WalletConnect session
  ///
  /// Closes the specified WalletConnect session and cleans up
  /// associated resources.
  ///
  /// Parameters:
  /// - [topic]: The session topic identifier to delete
  Future<WcDeleteSessionResponse> deleteSession({required String topic}) {
    return execute(
      WcDeleteSessionRequest(rpcPass: rpcPass ?? '', topic: topic),
    );
  }
}
