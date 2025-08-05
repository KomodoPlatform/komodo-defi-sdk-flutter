import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'log_storage.dart';
import '../log_entry.dart';
import '../log_level.dart';

/// File-based log storage for mobile and desktop platforms.
///
/// This implementation stores logs in local files and is not available
/// on web platforms (use WebLogStorage instead).
class FileLogStorage implements LogStorage {
  /// Creates a new file log storage
  FileLogStorage({
    this.fileName = 'dragon_logs.json',
    this.maxEntries = 10000,
    this.maxFileSize = 10 * 1024 * 1024, // 10MB
  });

  /// Name of the log file
  final String fileName;

  /// Maximum number of entries to keep
  final int maxEntries;

  /// Maximum file size in bytes
  final int maxFileSize;

  File? _logFile;

  /// Check if file storage is supported on this platform
  static bool get isSupported {
    try {
      // This will return false on web platforms
      return !identical(0, 0.0); // false on web, true on other platforms
    } catch (e) {
      return false;
    }
  }

  /// Get the log file
  Future<File> get _file async {
    if (_logFile != null) return _logFile!;

    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/$fileName');
    return _logFile!;
  }

  @override
  Future<void> store(LogEntry entry) async {
    if (!isSupported) return;

    try {
      final file = await _file;
      final entries = await _loadEntries();
      entries.add(entry);

      // Remove old entries if we exceed the limit
      while (entries.length > maxEntries) {
        entries.removeAt(0);
      }

      await _saveEntries(file, entries);
      await _rotateLogIfNeeded(file);
    } catch (e) {
      // Silently fail if file operations are not available
    }
  }

  @override
  Future<List<LogEntry>> retrieve({
    DateTime? startTime,
    DateTime? endTime,
    String? loggerName,
    int? limit,
  }) async {
    if (!isSupported) return [];

    try {
      final entries = await _loadEntries();

      var filtered = entries.where((entry) {
        if (startTime != null && entry.timestamp.isBefore(startTime)) {
          return false;
        }
        if (endTime != null && entry.timestamp.isAfter(endTime)) {
          return false;
        }
        if (loggerName != null && entry.loggerName != loggerName) {
          return false;
        }
        return true;
      }).toList();

      // Sort by timestamp (newest first)
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (limit != null && filtered.length > limit) {
        filtered = filtered.take(limit).toList();
      }

      return filtered;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clear() async {
    if (!isSupported) return;

    try {
      final file = await _file;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Future<int> count() async {
    if (!isSupported) return 0;

    try {
      final entries = await _loadEntries();
      return entries.length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> storeAll(List<LogEntry> entries) async {
    for (final entry in entries) {
      await store(entry);
    }
  }

  @override
  Future<void> close() async {
    // File storage doesn't require explicit closing
  }

  /// Load entries from the log file
  Future<List<LogEntry>> _loadEntries() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];

      final contents = await file.readAsString();
      if (contents.trim().isEmpty) return [];

      final jsonList = jsonDecode(contents) as List<dynamic>;
      return jsonList
          .map((json) => _logEntryFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Save entries to the log file
  Future<void> _saveEntries(File file, List<LogEntry> entries) async {
    try {
      final jsonList = entries.map((entry) => _logEntryToJson(entry)).toList();
      final data = jsonEncode(jsonList);
      await file.writeAsString(data);
    } catch (e) {
      // File write failed - silently fail
    }
  }

  /// Rotate the log file if it exceeds the maximum size
  Future<void> _rotateLogIfNeeded(File file) async {
    try {
      final stat = await file.stat();
      if (stat.size > maxFileSize) {
        // Keep only the newest half of entries
        final entries = await _loadEntries();
        final keep = entries.length ~/ 2;
        final newEntries = entries.skip(entries.length - keep).toList();
        await _saveEntries(file, newEntries);
      }
    } catch (e) {
      // Rotation failed - continue without rotation
    }
  }

  /// Convert LogEntry to JSON
  Map<String, dynamic> _logEntryToJson(LogEntry entry) {
    return {
      'level': entry.level.name,
      'message': entry.message,
      'timestamp': entry.timestamp.millisecondsSinceEpoch,
      'loggerName': entry.loggerName,
      'error': entry.error?.toString(),
      'stackTrace': entry.stackTrace?.toString(),
      'extra': entry.extra,
    };
  }

  /// Convert JSON to LogEntry
  LogEntry _logEntryFromJson(Map<String, dynamic> json) {
    return LogEntry(
      level: LogLevel.fromString(json['level'] as String),
      message: json['message'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      loggerName: json['loggerName'] as String,
      error: json['error'] as String?,
      stackTrace: json['stackTrace'] != null
          ? StackTrace.fromString(json['stackTrace'] as String)
          : null,
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }
}
