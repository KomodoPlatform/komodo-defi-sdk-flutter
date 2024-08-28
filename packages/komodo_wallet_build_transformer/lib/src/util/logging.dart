import 'dart:io';

import 'package:logging/logging.dart';

/// A list of supported log levels that can be converted to the logging [Level]
/// object using the [logLevelFromString] function.
const allowedLogLevels = [
  'warning',
  'info',
  'debug',
  'finest',
  'severe',
  'error',
  'fatal',
  'trace',
  'shout',
  'all',
  'off',
];

/// Converts a string to a logging [Level] object.
Level logLevelFromString(String level) {
  switch (level.toLowerCase()) {
    case 'warning':
      return Level.WARNING;
    case 'info':
      return Level.INFO;
    case 'debug':
      return Level.FINE;
    case 'finest':
      return Level.FINEST;
    case 'severe':
      return Level.SEVERE;
    case 'error':
      return Level.SEVERE;
    case 'fatal':
      return Level.SHOUT;
    case 'trace':
      return Level.FINEST;
    case 'shout':
      return Level.SHOUT;
    case 'all':
      return Level.ALL;
    case 'off':
      return Level.OFF;
    default:
      return Level.INFO;
  }
}

/// Configures the root (default) logger to log to the console.
/// The [loggingLevel] is the minimum level of log messages that will be printed.
/// The [allowStackTracesFromLevel] is the minimum level of log messages that
/// will have their stack traces printed.
/// By default, stack traces are only printed for log messages at the
/// [Level.WARNING] level or higher.
/// If [allowStackTracesFromLevel] is set to [Level.ALL], stack traces will
/// be printed for all log messages.
/// If [allowStackTracesFromLevel] is set to [Level.OFF], stack traces will
/// not be printed for any log messages.
void configureLogToConsole(
  String loggingLevel, {
  Level allowStackTracesFromLevel = Level.WARNING,
}) {
  recordStackTraceAtLevel = allowStackTracesFromLevel;
  Logger.root.level = logLevelFromString(loggingLevel);
  Logger.root.onRecord.listen(logToConsole);
}

/// Prints the [LogRecord] to the console using [stdout] for messages at or
/// below [Level.SEVERE] and [stderr] for messages at [Level.SEVERE] or higher.
/// If the log record has an error, it will be printed.
/// If the log record has a stack trace and the log level is at or above
/// [recordStackTraceAtLevel], the stack trace will be printed.
void logToConsole(LogRecord record) {
  final isError = record.level <= Level.SEVERE;
  final output = isError ? stderr : stdout;
  output.writeln('${record.level.name}: ${record.time}: ${record.message}');
  if (record.error != null) {
    output.writeln(record.error);
  }
  if (record.level >= recordStackTraceAtLevel && record.stackTrace != null) {
    output.writeln(record.stackTrace);
  }
}
