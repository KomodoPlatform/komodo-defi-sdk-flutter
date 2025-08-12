/// Utilities for extracting error codes and messages from dartified JS values.
///
/// Provides functions to extract numeric error codes and human-readable messages
/// from dartified JavaScript error objects, as well as heuristics for common
/// error patterns.
library;

bool _isFiniteNum(num value) => value.isFinite;

/// Attempts to extract a numeric error code from a dartified JS error/value.
///
/// Supported shapes:
/// - int or num (finite)
/// - String containing an integer
/// - Map with `code` or `result` as int/num/stringified-int
int? extractNumericCodeFromDartError(dynamic value) {
  if (value is int) return value;
  if (value is num) return _isFiniteNum(value) ? value.toInt() : null;

  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }

  if (value is Map) {
    final dynamic code = value['code'] ?? value['result'];
    if (code is int) return code;
    if (code is num) return _isFiniteNum(code) ? code.toInt() : null;
    if (code is String) {
      final parsed = int.tryParse(code);
      if (parsed != null) return parsed;
    }
  }

  return null;
}

/// Attempts to extract a human-readable message from a dartified JS error/value.
///
/// Supported shapes:
/// - String
/// - Map with `message` or `error` as String
String? extractMessageFromDartError(dynamic value) {
  if (value is String) return value;
  if (value is Map) {
    final dynamic message = value['message'] ?? value['error'];
    if (message is String && message.isNotEmpty) return message;
  }
  return null;
}

// TODO: generalise to a log/string-based watcher for other KDF errors
/// Heuristic matcher for common "already running" messages.
bool messageIndicatesAlreadyRunning(String message) {
  final lower = message.toLowerCase();
  return lower.contains('already running') || lower.contains('already_running');
}
