import 'dart:async';
import 'dart:convert';

// Use conditional imports to avoid compilation issues on non-web platforms
import 'log_storage.dart';
import '../log_entry.dart';
import '../log_level.dart';

// Use package:web instead of dart:html for Wasm compatibility
import 'package:web/web.dart' as web;

/// Web-compatible log storage using browser localStorage.
/// 
/// This implementation uses package:web instead of dart:html to ensure
/// compatibility with Flutter Web Wasm compilation.
class WebLogStorage implements LogStorage {
  /// Creates a new web log storage
  WebLogStorage({
    this.storageKey = 'dragon_logs',
    this.maxEntries = 5000,
  });

  /// Key used for localStorage
  final String storageKey;
  
  /// Maximum number of entries to keep
  final int maxEntries;

  /// Check if web storage is available
  static bool get isSupported {
    try {
      // Check if we're running in a web environment with localStorage
      return web.window.localStorage != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> store(LogEntry entry) async {
    if (!isSupported) return;

    try {
      final entries = await _loadEntries();
      entries.add(entry);

      // Remove old entries if we exceed the limit
      while (entries.length > maxEntries) {
        entries.removeAt(0);
      }

      await _saveEntries(entries);
    } catch (e) {
      // Silently fail if storage is not available or quota exceeded
      // This ensures the app continues to work even if logging fails
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
      web.window.localStorage.removeItem(storageKey);
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

  /// Load entries from localStorage
  Future<List<LogEntry>> _loadEntries() async {
    try {
      final data = web.window.localStorage.getItem(storageKey);
      if (data == null) return [];

      final jsonList = jsonDecode(data) as List<dynamic>;
      return jsonList.map((json) => _logEntryFromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save entries to localStorage
  Future<void> _saveEntries(List<LogEntry> entries) async {
    try {
      final jsonList = entries.map((entry) => _logEntryToJson(entry)).toList();
      final data = jsonEncode(jsonList);
      web.window.localStorage.setItem(storageKey, data);
    } catch (e) {
      // Storage quota exceeded or other error - silently fail
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
      stackTrace: json['stackTrace'] != null ? StackTrace.fromString(json['stackTrace'] as String) : null,
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }
}