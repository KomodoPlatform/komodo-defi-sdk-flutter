enum AuthExceptionType {
  invalidWalletPassword,
  walletAlreadyRunning,
  walletStartFailed,
  generalAuthError,
}

class AuthException implements Exception {
  AuthException(
    this.message, {
    required this.type,
    this.details = const {},
  });

  /// The error message.
  final String message;

  /// The error type.
  final AuthExceptionType type;

  /// The error details.
  final Map<String, dynamic>? details;

  @override
  String toString() {
    return 'AuthException{type: $type, message: $message, details: $details}';
  }

  /// This method scans the log for matching error patterns and returns the detected exceptions.
  static List<AuthExceptionType> foundExceptions(String log) {
    return AuthExceptionType.values.where((type) {
      final patterns = AuthException.matchingPatterns[type]!;
      return patterns.any((pattern) => log.contains(pattern));
    }).toList();
  }

  static Map<AuthExceptionType, List<String>> get matchingPatterns => {
        AuthExceptionType.invalidWalletPassword: [
          'Error decrypting mnemonic: HMAC error: MAC tag mismatch',
          'Incorrect wallet password',
          'Error generating or decrypting mnemonic',
        ],
        AuthExceptionType.walletAlreadyRunning: [
          'Wallet is already running',
        ],
        AuthExceptionType.walletStartFailed: [
          'Failed to start KDF',
        ],
        AuthExceptionType.generalAuthError: [
          'An unknown authentication error occurred',
        ],
      };
}
