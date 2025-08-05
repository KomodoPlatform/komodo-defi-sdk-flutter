import '../log_entry.dart';

/// Abstract interface for formatting log entries into strings.
abstract class LogFormatter {
  /// Format a log entry into a string representation
  String format(LogEntry entry);
}