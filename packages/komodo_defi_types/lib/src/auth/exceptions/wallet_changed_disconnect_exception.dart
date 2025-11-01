/// Exception thrown when wallet changes and streams need to be disconnected
class WalletChangedDisconnectException implements Exception {
  const WalletChangedDisconnectException(this.message);

  /// The error message explaining the wallet change
  final String message;

  @override
  String toString() => 'WalletChangedDisconnectException: $message';
}
