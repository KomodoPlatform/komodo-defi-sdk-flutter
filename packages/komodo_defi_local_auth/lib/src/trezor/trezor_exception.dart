/// Exception thrown when Trezor operations fail
class TrezorException implements Exception {
  /// Creates a new TrezorException with the given message and optional details
  const TrezorException(this.message, [this.details]);

  /// Human-readable error message
  final String message;

  /// Optional additional error details
  final String? details;

  @override
  String toString() =>
      'TrezorException: $message${details != null ? ' ($details)' : ''}';
}
