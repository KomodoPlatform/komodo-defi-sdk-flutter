import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Exception types specifically related to KDF operations
enum KdfExceptionType {
  /// KDF executable not found
  executableNotFound,

  /// Failed to start KDF
  startupFailed,

  /// Error in KDF configuration
  configurationError,

  /// KDF executable permission error
  permissionError,

  /// KDF is not running when it should be
  notRunning,

  /// KDF process exited unexpectedly
  unexpectedExit,

  /// General KDF error
  generalError,
}

/// Exception thrown when there is an issue with KDF operations
class KdfException implements Exception {
  /// Creates a new KDF exception with the specified message and type
  KdfException(
    this.message, {
    required this.type,
    this.details = const {},
    StackTrace? stackTrace,
  }) : stackTrace = stackTrace ?? StackTrace.current;

  /// The error message
  final String message;

  /// The type of KDF exception
  final KdfExceptionType type;

  /// Additional details about the exception
  final JsonMap details;

  /// Stack trace where the exception occurred
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'KdfException{type: $type, message: $message, details: $details}\n$stackTrace';
  }
}
