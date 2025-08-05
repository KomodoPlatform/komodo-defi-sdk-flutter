import 'package:meta/meta.dart';
import 'log_level.dart';

/// Represents a single log entry with all associated metadata.
@immutable
class LogEntry {
  /// Creates a new log entry.
  const LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    required this.loggerName,
    this.error,
    this.stackTrace,
    this.extra,
  });

  /// The severity level of this log entry
  final LogLevel level;

  /// The log message
  final String message;

  /// When this log entry was created
  final DateTime timestamp;

  /// Name of the logger that created this entry
  final String loggerName;

  /// Optional error object associated with this log entry
  final Object? error;

  /// Optional stack trace associated with this log entry
  final StackTrace? stackTrace;

  /// Optional extra data associated with this log entry
  final Map<String, dynamic>? extra;

  /// Create a copy of this log entry with optional field overrides
  LogEntry copyWith({
    LogLevel? level,
    String? message,
    DateTime? timestamp,
    String? loggerName,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    return LogEntry(
      level: level ?? this.level,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      loggerName: loggerName ?? this.loggerName,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      extra: extra ?? this.extra,
    );
  }

  @override
  String toString() {
    return 'LogEntry(level: $level, message: $message, timestamp: $timestamp, '
        'loggerName: $loggerName, error: $error, stackTrace: $stackTrace, '
        'extra: $extra)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogEntry &&
        other.level == level &&
        other.message == message &&
        other.timestamp == timestamp &&
        other.loggerName == loggerName &&
        other.error == error &&
        other.stackTrace == stackTrace &&
        _mapEquals(other.extra, extra);
  }

  @override
  int get hashCode {
    return Object.hash(
      level,
      message,
      timestamp,
      loggerName,
      error,
      stackTrace,
      extra,
    );
  }

  /// Convert this log entry to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'loggerName': loggerName,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
      'extra': extra,
    };
  }

  /// Create a log entry from a JSON map
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      level: LogLevel.fromString(json['level'] as String),
      message: json['message'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      loggerName: json['loggerName'] as String,
      error: json['error'] as String?,
      stackTrace:
          json['stackTrace'] != null
              ? StackTrace.fromString(json['stackTrace'] as String)
              : null,
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }

  /// Helper method for comparing maps
  static bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
