import '../log_entry.dart';
import 'log_formatter.dart';

/// A simple text-based log formatter.
class SimpleLogFormatter implements LogFormatter {
  /// Creates a new simple log formatter
  const SimpleLogFormatter({
    this.includeTimestamp = true,
    this.includeLevel = true,
    this.includeLoggerName = true,
    this.timestampFormat = 'iso8601',
  });

  /// Whether to include timestamp in the output
  final bool includeTimestamp;
  
  /// Whether to include log level in the output
  final bool includeLevel;
  
  /// Whether to include logger name in the output
  final bool includeLoggerName;
  
  /// Format for timestamps ('iso8601' or 'custom')
  final String timestampFormat;

  @override
  String format(LogEntry entry) {
    final buffer = StringBuffer();

    if (includeTimestamp) {
      final timestamp = timestampFormat == 'iso8601'
          ? entry.timestamp.toIso8601String()
          : _formatCustomTimestamp(entry.timestamp);
      buffer.write('[$timestamp] ');
    }

    if (includeLevel) {
      buffer.write('[${entry.level.name}] ');
    }

    if (includeLoggerName) {
      buffer.write('${entry.loggerName}: ');
    }

    buffer.write(entry.message);

    if (entry.error != null) {
      buffer.write('\nError: ${entry.error}');
    }

    if (entry.stackTrace != null) {
      buffer.write('\nStack trace:\n${entry.stackTrace}');
    }

    if (entry.extra != null && entry.extra!.isNotEmpty) {
      buffer.write('\nExtra: ${entry.extra}');
    }

    return buffer.toString();
  }

  /// Format timestamp in a custom readable format
  String _formatCustomTimestamp(DateTime timestamp) {
    return '${timestamp.year}-${_pad(timestamp.month)}-${_pad(timestamp.day)} '
           '${_pad(timestamp.hour)}:${_pad(timestamp.minute)}:${_pad(timestamp.second)}';
  }

  /// Pad single digits with leading zero
  String _pad(int value) => value.toString().padLeft(2, '0');
}