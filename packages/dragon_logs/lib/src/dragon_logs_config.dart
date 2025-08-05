import 'package:flutter/foundation.dart';

import 'log_level.dart';
import 'logger.dart';
import 'log_writer.dart';
import 'storage/log_storage.dart';
import 'storage/memory_log_storage.dart';
import 'storage/web_log_storage.dart';
import 'storage/file_log_storage.dart';
import 'formatters/log_formatter.dart';
import 'formatters/simple_log_formatter.dart';

/// Configuration class for the Dragon Logs package.
/// 
/// This class provides a centralized way to configure logging behavior
/// across all platforms with Wasm compatibility.
class DragonLogsConfig {
  /// Creates a new Dragon Logs configuration
  DragonLogsConfig._();

  static DragonLogsConfig? _instance;
  
  /// Get the singleton instance
  static DragonLogsConfig get instance {
    return _instance ??= DragonLogsConfig._();
  }

  /// Initialize Dragon Logs with the specified configuration
  static Future<void> initialize({
    LogLevel globalLevel = LogLevel.info,
    bool enableConsoleLogging = true,
    bool enablePersistentLogging = true,
    LogFormatter? formatter,
    LogStorage? customStorage,
    int maxMemoryEntries = 1000,
    String? storageKey,
  }) async {
    final config = instance;
    
    // Set global log level
    Logger.setGlobalLevel(globalLevel);
    
    // Determine the best storage option for the current platform
    LogStorage storage;
    if (customStorage != null) {
      storage = customStorage;
    } else if (kIsWeb) {
      // Use web storage for web platforms (Wasm-compatible)
      storage = WebLogStorage(
        storageKey: storageKey ?? 'dragon_logs',
        maxEntries: maxMemoryEntries,
      );
    } else if (FileLogStorage.isSupported) {
      // Use file storage for mobile/desktop platforms
      storage = FileLogStorage(maxEntries: maxMemoryEntries);
    } else {
      // Fallback to memory storage
      storage = MemoryLogStorage(maxEntries: maxMemoryEntries);
    }

    config._defaultStorage = storage;
    config._defaultFormatter = formatter ?? const SimpleLogFormatter();

    // Set up default loggers
    if (enableConsoleLogging) {
      config._setupConsoleLogging();
    }
    
    if (enablePersistentLogging) {
      config._setupPersistentLogging();
    }
  }

  LogStorage? _defaultStorage;
  LogFormatter? _defaultFormatter;
  final List<LogWriter> _globalWriters = [];

  /// Get the default storage instance
  LogStorage? get defaultStorage => _defaultStorage;

  /// Get the default formatter instance
  LogFormatter? get defaultFormatter => _defaultFormatter;

  /// Set up console logging for all loggers
  void _setupConsoleLogging() {
    const consoleWriter = ConsoleLogWriter();
    _globalWriters.add(consoleWriter);
    
    // Add console writer to all existing loggers
    for (final logger in Logger.allLoggers) {
      logger.addWriter(consoleWriter);
    }
  }

  /// Set up persistent logging for all loggers
  void _setupPersistentLogging() {
    if (_defaultStorage != null) {
      final storageWriter = StorageLogWriter(_defaultStorage!, _defaultFormatter);
      _globalWriters.add(storageWriter);
      
      // Add storage writer to all existing loggers
      for (final logger in Logger.allLoggers) {
        logger.addWriter(storageWriter);
      }
    }
  }

  /// Add a global writer that will be added to all new loggers
  void addGlobalWriter(LogWriter writer) {
    _globalWriters.add(writer);
    
    // Add to all existing loggers
    for (final logger in Logger.allLoggers) {
      logger.addWriter(writer);
    }
  }

  /// Remove a global writer
  void removeGlobalWriter(LogWriter writer) {
    _globalWriters.remove(writer);
    
    // Remove from all existing loggers
    for (final logger in Logger.allLoggers) {
      logger.removeWriter(writer);
    }
  }

  /// Get all global writers
  List<LogWriter> get globalWriters => List.unmodifiable(_globalWriters);

  /// Create a new logger and set it up with global writers
  Logger createLogger(String name, {LogLevel? level}) {
    final logger = Logger(name, level: level);
    
    // Add all global writers to the new logger
    for (final writer in _globalWriters) {
      logger.addWriter(writer);
    }
    
    return logger;
  }

  /// Check if we're running with Wasm
  static bool get isWasm {
    // This constant is set during Wasm compilation
    return const bool.fromEnvironment('dart.tool.dart2wasm', defaultValue: false);
  }

  /// Check if we're running on the web
  static bool get isWeb => kIsWeb;

  /// Check platform information for debugging
  static Map<String, dynamic> get platformInfo {
    return {
      'isWeb': isWeb,
      'isWasm': isWasm,
      'webStorageSupported': WebLogStorage.isSupported,
      'fileStorageSupported': FileLogStorage.isSupported,
      'debugMode': kDebugMode,
    };
  }
}

/// A log writer that uses a LogStorage backend with formatting
class StorageLogWriter implements LogWriter {
  /// Creates a new storage log writer
  StorageLogWriter(this._storage, this._formatter);

  final LogStorage _storage;
  final LogFormatter? _formatter;

  @override
  Future<void> write(LogEntry entry) async {
    await _storage.store(entry);
  }

  @override
  Future<void> flush() async {
    // Storage implementations handle their own flushing
  }

  @override
  Future<void> close() async {
    await _storage.close();
  }
}