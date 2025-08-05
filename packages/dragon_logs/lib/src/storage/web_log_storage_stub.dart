import 'dart:async';

import 'log_storage.dart';
import '../log_entry.dart';

/// Stub implementation for non-web platforms
class WebLogStorage implements LogStorage {
  WebLogStorage({String storageKey = 'dragon_logs', int maxEntries = 5000});

  /// Always returns false on non-web platforms
  static bool get isSupported => false;

  @override
  Future<void> store(LogEntry entry) async {
    // Do nothing on non-web platforms
  }

  @override
  Future<List<LogEntry>> retrieve({
    DateTime? startTime,
    DateTime? endTime,
    String? loggerName,
    int? limit,
  }) async {
    // Return empty list on non-web platforms
    return [];
  }

  @override
  Future<void> clear() async {
    // Do nothing on non-web platforms
  }

  @override
  Future<int> count() async {
    // Return 0 on non-web platforms
    return 0;
  }

  @override
  Future<void> storeAll(List<LogEntry> entries) async {
    // Do nothing on non-web platforms
  }

  @override
  Future<void> close() async {
    // Do nothing on non-web platforms
  }
}
