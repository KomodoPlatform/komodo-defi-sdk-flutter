import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/src/auth/exceptions/auth_exception.dart';

/// Specific error types for WalletConnect authentication operations
enum WalletConnectErrorType {
  /// Connection timeout while waiting for mobile wallet to connect
  connectionTimeout,

  /// WalletConnect session has expired or is invalid
  sessionExpired,

  /// The requested blockchain is not supported by the connected wallet
  unsupportedChain,

  /// User rejected the connection request in their mobile wallet
  userRejected,

  /// Failed to generate QR code or connection URI
  qrCodeGenerationFailed,

  /// Session with the specified topic was not found
  sessionNotFound,

  /// Network error during WalletConnect operations
  networkError,

  /// Invalid or malformed WalletConnect URI
  invalidUri,

  /// Session establishment failed
  sessionEstablishmentFailed,

  /// Pairing with mobile wallet failed
  pairingFailed,
}

/// Specialized exception for WalletConnect authentication errors
///
/// This exception extends [AuthException] with WalletConnect-specific
/// error types and recovery strategies.
class WalletConnectAuthException extends AuthException {
  /// Creates a WalletConnect authentication exception
  ///
  /// Parameters:
  /// - [message] - Human-readable error message
  /// - [wcErrorType] - Specific WalletConnect error type
  /// - [sessionTopic] - Optional session topic related to the error
  /// - [details] - Additional error details
  WalletConnectAuthException(
    String message, {
    required this.wcErrorType,
    this.sessionTopic,
    JsonMap? details,
  }) : super(
         message,
         type: _mapToAuthExceptionType(wcErrorType),
         details: {
           ...?details,
           'walletconnect_error_type': wcErrorType.name,
           if (sessionTopic != null) 'session_topic': sessionTopic,
         },
       );

  /// The specific WalletConnect error type
  final WalletConnectErrorType wcErrorType;

  /// The session topic associated with this error (if applicable)
  final String? sessionTopic;

  /// Factory constructor for connection timeout errors
  factory WalletConnectAuthException.connectionTimeout({
    String? sessionTopic,
    Duration? timeout,
  }) {
    final timeoutMsg = timeout != null ? ' after ${timeout.inSeconds}s' : '';
    return WalletConnectAuthException(
      'Connection timeout waiting for mobile wallet$timeoutMsg',
      wcErrorType: WalletConnectErrorType.connectionTimeout,
      sessionTopic: sessionTopic,
      details: timeout != null ? {'timeout_seconds': timeout.inSeconds} : null,
    );
  }

  /// Factory constructor for session expired errors
  factory WalletConnectAuthException.sessionExpired(String sessionTopic) {
    return WalletConnectAuthException(
      'WalletConnect session has expired or is invalid',
      wcErrorType: WalletConnectErrorType.sessionExpired,
      sessionTopic: sessionTopic,
    );
  }

  /// Factory constructor for unsupported chain errors
  factory WalletConnectAuthException.unsupportedChain(
    String chainId, {
    List<String>? supportedChains,
  }) {
    return WalletConnectAuthException(
      'Chain $chainId is not supported by the connected wallet',
      wcErrorType: WalletConnectErrorType.unsupportedChain,
      details: {
        'requested_chain': chainId,
        if (supportedChains != null) 'supported_chains': supportedChains,
      },
    );
  }

  /// Factory constructor for user rejection errors
  factory WalletConnectAuthException.userRejected({String? sessionTopic}) {
    return WalletConnectAuthException(
      'Connection request was rejected by the user',
      wcErrorType: WalletConnectErrorType.userRejected,
      sessionTopic: sessionTopic,
    );
  }

  /// Factory constructor for QR code generation errors
  factory WalletConnectAuthException.qrCodeGenerationFailed(String reason) {
    return WalletConnectAuthException(
      'Failed to generate QR code: $reason',
      wcErrorType: WalletConnectErrorType.qrCodeGenerationFailed,
      details: {'failure_reason': reason},
    );
  }

  /// Factory constructor for session not found errors
  factory WalletConnectAuthException.sessionNotFound(String sessionTopic) {
    return WalletConnectAuthException(
      'Session with topic $sessionTopic was not found',
      wcErrorType: WalletConnectErrorType.sessionNotFound,
      sessionTopic: sessionTopic,
    );
  }

  /// Factory constructor for network errors
  factory WalletConnectAuthException.networkError(String message) {
    return WalletConnectAuthException(
      'Network error during WalletConnect operation: $message',
      wcErrorType: WalletConnectErrorType.networkError,
      details: {'network_error': message},
    );
  }

  /// Factory constructor for invalid URI errors
  factory WalletConnectAuthException.invalidUri(String uri) {
    return WalletConnectAuthException(
      'Invalid WalletConnect URI: $uri',
      wcErrorType: WalletConnectErrorType.invalidUri,
      details: {'invalid_uri': uri},
    );
  }

  /// Factory constructor for session establishment failures
  factory WalletConnectAuthException.sessionEstablishmentFailed(String reason) {
    return WalletConnectAuthException(
      'Failed to establish WalletConnect session: $reason',
      wcErrorType: WalletConnectErrorType.sessionEstablishmentFailed,
      details: {'failure_reason': reason},
    );
  }

  /// Factory constructor for pairing failures
  factory WalletConnectAuthException.pairingFailed(String reason) {
    return WalletConnectAuthException(
      'Failed to pair with mobile wallet: $reason',
      wcErrorType: WalletConnectErrorType.pairingFailed,
      details: {'failure_reason': reason},
    );
  }

  /// Checks if this error is recoverable through retry
  bool get isRecoverable {
    switch (wcErrorType) {
      case WalletConnectErrorType.connectionTimeout:
      case WalletConnectErrorType.networkError:
      case WalletConnectErrorType.qrCodeGenerationFailed:
      case WalletConnectErrorType.sessionEstablishmentFailed:
      case WalletConnectErrorType.pairingFailed:
        return true;
      case WalletConnectErrorType.sessionExpired:
      case WalletConnectErrorType.unsupportedChain:
      case WalletConnectErrorType.userRejected:
      case WalletConnectErrorType.sessionNotFound:
      case WalletConnectErrorType.invalidUri:
        return false;
    }
  }

  /// Gets a suggested recovery action for this error
  String? get recoveryAction {
    switch (wcErrorType) {
      case WalletConnectErrorType.connectionTimeout:
        return 'Try generating a new QR code and scanning again';
      case WalletConnectErrorType.sessionExpired:
        return 'Start a new connection session';
      case WalletConnectErrorType.unsupportedChain:
        return 'Switch to a supported blockchain in your wallet';
      case WalletConnectErrorType.userRejected:
        return 'Accept the connection request in your mobile wallet';
      case WalletConnectErrorType.qrCodeGenerationFailed:
        return 'Check your internet connection and try again';
      case WalletConnectErrorType.sessionNotFound:
        return 'Start a new connection session';
      case WalletConnectErrorType.networkError:
        return 'Check your internet connection and try again';
      case WalletConnectErrorType.invalidUri:
        return 'Generate a new QR code';
      case WalletConnectErrorType.sessionEstablishmentFailed:
        return 'Try connecting again with a new QR code';
      case WalletConnectErrorType.pairingFailed:
        return 'Ensure your mobile wallet supports WalletConnect v2';
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer('WalletConnectAuthException{');
    buffer.write('wcErrorType: $wcErrorType, ');
    buffer.write('message: $message');
    if (sessionTopic != null) {
      buffer.write(', sessionTopic: $sessionTopic');
    }
    if (details != null && details!.isNotEmpty) {
      buffer.write(', details: $details');
    }
    buffer.write('}');
    return buffer.toString();
  }

  /// Maps WalletConnect error types to general auth exception types
  static AuthExceptionType _mapToAuthExceptionType(
    WalletConnectErrorType wcErrorType,
  ) {
    switch (wcErrorType) {
      case WalletConnectErrorType.connectionTimeout:
        return AuthExceptionType.walletConnectConnectionTimeout;
      case WalletConnectErrorType.sessionExpired:
        return AuthExceptionType.walletConnectSessionExpired;
      case WalletConnectErrorType.unsupportedChain:
        return AuthExceptionType.walletConnectUnsupportedChain;
      case WalletConnectErrorType.userRejected:
        return AuthExceptionType.walletConnectUserRejected;
      case WalletConnectErrorType.qrCodeGenerationFailed:
        return AuthExceptionType.walletConnectQrCodeGenerationFailed;
      case WalletConnectErrorType.sessionNotFound:
        return AuthExceptionType.walletConnectSessionNotFound;
      case WalletConnectErrorType.networkError:
      case WalletConnectErrorType.invalidUri:
      case WalletConnectErrorType.sessionEstablishmentFailed:
      case WalletConnectErrorType.pairingFailed:
        return AuthExceptionType.generalAuthError;
    }
  }
}
