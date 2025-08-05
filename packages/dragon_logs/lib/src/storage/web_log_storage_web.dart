import 'dart:async';
import 'dart:convert';

import 'package:web/web.dart' as web;

import 'log_storage.dart';
import '../log_entry.dart';

/// Web-specific implementation using localStorage
class WebLogStorage implements LogStorage {
  WebLogStorage({this.storageKey = 'dragon_logs', this.maxEntries = 5000});

  /// Key used for localStorage
  final String storageKey;

  /// Maximum number of entries to keep
  final int maxEntries;

  /// Check if web storage is available
  static bool get isSupported {
    try {
      // Check if we're running in a web environment with localStorage
      web.window.localStorage.getItem('_test');
      return true;
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
      var filtered =
          entries.where((entry) {
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

      // Sort by timestamp descending (newest first)
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (limit != null && limit > 0) {
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
      // Silently fail if storage is not available
    }
  }

  Future<List<LogEntry>> _loadEntries() async {
    try {
      final jsonString = web.window.localStorage.getItem(storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => LogEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveEntries(List<LogEntry> entries) async {
    try {
      final jsonString = jsonEncode(entries.map((e) => e.toJson()).toList());
      web.window.localStorage.setItem(storageKey, jsonString);
    } catch (e) {
      // Silently fail if storage is not available or quota exceeded
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
    // Web storage doesn't require closing
  }
}
