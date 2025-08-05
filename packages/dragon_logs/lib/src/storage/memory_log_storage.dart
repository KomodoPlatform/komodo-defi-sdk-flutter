import 'dart:async';
import '../log_entry.dart';
import 'log_storage.dart';

/// In-memory log storage that keeps log entries in RAM.
/// 
/// This is useful for temporary storage and is fully Wasm-compatible.
/// Note that logs will be lost when the application is closed.
class MemoryLogStorage implements LogStorage {
  /// Creates a new memory log storage with optional size limit
  MemoryLogStorage({this.maxEntries = 10000});

  /// Maximum number of entries to keep in memory
  final int maxEntries;
  
  final List<LogEntry> _entries = [];

  @override
  Future<void> store(LogEntry entry) async {
    _entries.add(entry);
    
    // Remove old entries if we exceed the limit
    while (_entries.length > maxEntries) {
      _entries.removeAt(0);
    }
  }

  @override
  Future<List<LogEntry>> retrieve({
    DateTime? startTime,
    DateTime? endTime,
    String? loggerName,
    int? limit,
  }) async {
    var filtered = _entries.where((entry) {
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
  }

  @override
  Future<void> clear() async {
    _entries.clear();
  }

  @override
  Future<int> count() async {
    return _entries.length;
  }

  /// Get all entries (for testing purposes)
  List<LogEntry> get allEntries => List.unmodifiable(_entries);
}