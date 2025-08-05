import 'dart:async';
import 'dart:developer' as developer;

import 'package:meta/meta.dart';

import 'log_level.dart';
import 'log_entry.dart';
import 'log_writer.dart';

/// A logger instance that can log messages at different levels.
/// 
/// This logger is designed to be Wasm-compatible and avoids dependencies
/// on deprecated web APIs like dart:html or file_system_access_api.
class Logger {
  /// Creates a new logger with the given name.
  Logger(this.name, {LogLevel? level}) : _level = level ?? LogLevel.info;

  /// The name of this logger
  final String name;

  LogLevel _level;

  /// The minimum log level for this logger
  LogLevel get level => _level;

  /// Set the minimum log level for this logger
  set level(LogLevel level) => _level = level;

  /// List of log writers that will receive log entries
  final List<LogWriter> _writers = [];

  /// Add a log writer to this logger
  void addWriter(LogWriter writer) {
    _writers.add(writer);
  }

  /// Remove a log writer from this logger
  void removeWriter(LogWriter writer) {
    _writers.remove(writer);
  }

  /// Clear all log writers
  void clearWriters() {
    _writers.clear();
  }

  /// Log a message at trace level
  void trace(String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra]) {
    log(LogLevel.trace, message, error, stackTrace, extra);
  }

  /// Log a message at debug level
  void debug(String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra]) {
    log(LogLevel.debug, message, error, stackTrace, extra);
  }

  /// Log a message at info level
  void info(String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra]) {
    log(LogLevel.info, message, error, stackTrace, extra);
  }

  /// Log a message at warning level
  void warn(String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra]) {
    log(LogLevel.warn, message, error, stackTrace, extra);
  }

  /// Log a message at error level
  void error(String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra]) {
    log(LogLevel.error, message, error, stackTrace, extra);
  }

  /// Log a message at fatal level
  void fatal(String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra]) {
    log(LogLevel.fatal, message, error, stackTrace, extra);
  }

  /// Log a message at the specified level
  void log(LogLevel level, String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra]) {
    if (!level.isEnabledFor(_level)) {
      return;
    }

    final entry = LogEntry(
      level: level,
      message: message,
      timestamp: DateTime.now(),
      loggerName: name,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );

    // Send to Dart developer tools
    developer.log(
      message,
      time: entry.timestamp,
      level: level.value,
      name: name,
      error: error,
      stackTrace: stackTrace,
    );

    // Send to all registered writers
    for (final writer in _writers) {
      unawaited(_writeToWriter(writer, entry));
    }
  }

  /// Write a log entry to a writer, handling errors gracefully
  Future<void> _writeToWriter(LogWriter writer, LogEntry entry) async {
    try {
      await writer.write(entry);
    } catch (e, stackTrace) {
      // If writing fails, fall back to developer log
      developer.log(
        'Failed to write log entry: $e',
        time: DateTime.now(),
        level: LogLevel.error.value,
        name: 'dragon_logs.Logger',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check if a log level is enabled for this logger
  bool isEnabledFor(LogLevel level) {
    return level.isEnabledFor(_level);
  }

  /// Global registry of loggers
  static final Map<String, Logger> _loggers = {};

  /// Get or create a logger with the given name
  static Logger getLogger(String name) {
    return _loggers.putIfAbsent(name, () => Logger(name));
  }

  /// Set the global log level for all loggers
  static void setGlobalLevel(LogLevel level) {
    for (final logger in _loggers.values) {
      logger.level = level;
    }
  }

  /// Get all registered loggers
  static Iterable<Logger> get allLoggers => _loggers.values;
}

/// Helper function to prevent unawaited future warnings
void unawaited(Future<void> future) {
  // Intentionally ignore the future
}