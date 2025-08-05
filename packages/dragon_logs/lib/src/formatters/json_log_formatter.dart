import 'dart:convert';
import '../log_entry.dart';
import 'log_formatter.dart';

/// A JSON-based log formatter that outputs structured log data.
class JsonLogFormatter implements LogFormatter {
  /// Creates a new JSON log formatter
  const JsonLogFormatter({
    this.prettyPrint = false,
    this.includeStackTrace = true,
  });

  /// Whether to format JSON with indentation
  final bool prettyPrint;
  
  /// Whether to include stack traces in the output
  final bool includeStackTrace;

  @override
  String format(LogEntry entry) {
    final data = <String, dynamic>{
      'timestamp': entry.timestamp.toIso8601String(),
      'level': entry.level.name,
      'logger': entry.loggerName,
      'message': entry.message,
    };

    if (entry.error != null) {
      data['error'] = entry.error.toString();
    }

    if (includeStackTrace && entry.stackTrace != null) {
      data['stackTrace'] = entry.stackTrace.toString();
    }

    if (entry.extra != null && entry.extra!.isNotEmpty) {
      data['extra'] = entry.extra;
    }

    if (prettyPrint) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } else {
      return jsonEncode(data);
    }
  }
}