import 'package:komodo_defi_local_auth/src/auth/strategies/authentication_strategy.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// WalletConnect authentication namespace
///
/// Provides methods for managing WalletConnect sessions and authentication
/// processes, including session lifecycle management and connection operations.
class WalletConnectAuthNamespace {
  /// Creates a new WalletConnect authentication namespace.
  ///
  /// [rpcMethods] - The RPC methods instance for WalletConnect operations
  /// [getCurrentStrategy] - Function to get the current authentication strategy
  /// [ensureInitialized] - Function to ensure the auth service is initialized
  WalletConnectAuthNamespace(
    this._rpcMethods,
    this._getCurrentStrategy,
    this._ensureInitialized,
  );

  final KomodoDefiRpcMethods? _rpcMethods;
  final AuthenticationStrategy? Function() _getCurrentStrategy;
  final Future<void> Function() _ensureInitialized;

  /// Retrieves a list of all active WalletConnect sessions.
  ///
  /// Returns a list of active WalletConnect sessions with their details.
  /// This method requires RPC methods to be configured during initialization.
  ///
  /// Throws [AuthException] if RPC methods are not available or if an error
  /// occurs during session retrieval.
  Future<List<WcSession>> getSessions() async {
    await _ensureInitialized();

    if (_rpcMethods?.walletConnect == null) {
      throw AuthException(
        'WalletConnect RPC methods are not available. '
        'Please provide RPC methods during initialization.',
        type: AuthExceptionType.generalAuthError,
      );
    }

    try {
      final response = await _rpcMethods!.walletConnect.getSessions();
      return response.sessions;
    } catch (e) {
      throw AuthException(
        'Failed to retrieve WalletConnect sessions: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  /// Retrieves details for a specific WalletConnect session.
  ///
  /// The [sessionTopic] identifies the session to retrieve.
  /// Set [withPairingTopic] to true to include pairing topic information.
  ///
  /// Returns the session details if found.
  ///
  /// Throws [AuthException] if the session is not found or if an error occurs
  /// during retrieval.
  Future<WcSession> getSession(
    String sessionTopic, {
    bool withPairingTopic = false,
  }) async {
    await _ensureInitialized();

    if (_rpcMethods?.walletConnect == null) {
      throw AuthException(
        'WalletConnect RPC methods are not available. '
        'Please provide RPC methods during initialization.',
        type: AuthExceptionType.generalAuthError,
      );
    }

    try {
      final response = await _rpcMethods!.walletConnect.getSession(
        topic: sessionTopic,
        withPairingTopic: withPairingTopic,
      );
      return response.session;
    } catch (e) {
      if (e.toString().contains('Session not found') ||
          e.toString().contains('Invalid session topic')) {
        throw AuthException(
          'WalletConnect session with topic $sessionTopic not found',
          type: AuthExceptionType.walletConnectSessionNotFound,
        );
      }
      throw AuthException(
        'Failed to retrieve WalletConnect session: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  /// Tests connectivity to a specific WalletConnect session.
  ///
  /// The [sessionTopic] identifies the session to ping.
  ///
  /// Returns true if the session is active and responsive, false otherwise.
  ///
  /// Throws [AuthException] if an error occurs during the ping operation.
  Future<bool> pingSession(String sessionTopic) async {
    await _ensureInitialized();

    if (_rpcMethods?.walletConnect == null) {
      throw AuthException(
        'WalletConnect RPC methods are not available. '
        'Please provide RPC methods during initialization.',
        type: AuthExceptionType.generalAuthError,
      );
    }

    try {
      final response = await _rpcMethods!.walletConnect.pingSession(
        topic: sessionTopic,
      );
      return response.status == 'success' || response.status == 'ok';
    } catch (e) {
      if (e.toString().contains('Session not found') ||
          e.toString().contains('Invalid session topic')) {
        throw AuthException(
          'WalletConnect session with topic $sessionTopic not found',
          type: AuthExceptionType.walletConnectSessionNotFound,
        );
      }
      // Return false for ping failures instead of throwing
      return false;
    }
  }

  /// Terminates a specific WalletConnect session.
  ///
  /// The [sessionTopic] identifies the session to delete.
  ///
  /// Returns true if the session was successfully terminated.
  ///
  /// Throws [AuthException] if the session is not found or if an error occurs
  /// during termination.
  Future<bool> deleteSession(String sessionTopic) async {
    await _ensureInitialized();

    if (_rpcMethods?.walletConnect == null) {
      throw AuthException(
        'WalletConnect RPC methods are not available. '
        'Please provide RPC methods during initialization.',
        type: AuthExceptionType.generalAuthError,
      );
    }

    try {
      final response = await _rpcMethods!.walletConnect.deleteSession(
        topic: sessionTopic,
      );
      return response.result == 'success' || response.result == 'deleted';
    } catch (e) {
      if (e.toString().contains('Session not found') ||
          e.toString().contains('Invalid session topic')) {
        throw AuthException(
          'WalletConnect session with topic $sessionTopic not found',
          type: AuthExceptionType.walletConnectSessionNotFound,
        );
      }
      throw AuthException(
        'Failed to delete WalletConnect session: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }

  /// Cancels an ongoing WalletConnect authentication process.
  ///
  /// This method can be used to cancel QR code generation, connection waiting,
  /// or session establishment processes. The [taskId] parameter is optional
  /// and maintained for compatibility with other hardware wallet cancellation methods.
  ///
  /// Throws [AuthException] if an error occurs during cancellation.
  Future<void> cancelAuthentication({int? taskId}) async {
    await _ensureInitialized();

    final currentStrategy = _getCurrentStrategy();

    if (currentStrategy == null) {
      throw AuthException(
        'No active authentication process to cancel',
        type: AuthExceptionType.generalAuthError,
      );
    }

    try {
      await currentStrategy.cancel(taskId);
    } catch (e) {
      throw AuthException(
        'Failed to cancel WalletConnect authentication: $e',
        type: AuthExceptionType.generalAuthError,
      );
    }
  }
}
