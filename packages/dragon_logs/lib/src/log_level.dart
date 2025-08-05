/// Represents the severity level of a log entry.
enum LogLevel {
  /// Trace level - most verbose logging level
  trace(0, 'TRACE'),
  
  /// Debug level - detailed information for diagnosing problems
  debug(1, 'DEBUG'),
  
  /// Info level - general information about program execution
  info(2, 'INFO'),
  
  /// Warning level - indicates potential problems
  warn(3, 'WARN'),
  
  /// Error level - indicates error conditions
  error(4, 'ERROR'),
  
  /// Fatal level - indicates very severe error events
  fatal(5, 'FATAL');

  const LogLevel(this.value, this.name);

  /// Numeric value for comparison
  final int value;
  
  /// String representation of the log level
  final String name;

  /// Check if this level is enabled for the given minimum level
  bool isEnabledFor(LogLevel minimumLevel) {
    return value >= minimumLevel.value;
  }

  /// Parse log level from string (case insensitive)
  static LogLevel fromString(String level) {
    switch (level.toLowerCase()) {
      case 'trace':
        return LogLevel.trace;
      case 'debug':
        return LogLevel.debug;
      case 'info':
        return LogLevel.info;
      case 'warn':
      case 'warning':
        return LogLevel.warn;
      case 'error':
        return LogLevel.error;
      case 'fatal':
        return LogLevel.fatal;
      default:
        throw ArgumentError('Unknown log level: $level');
    }
  }
}