import 'dart:async';
import '../log_entry.dart';

/// Abstract interface for storing and retrieving log entries.
/// 
/// This interface is designed to be Wasm-compatible and platform-agnostic.
abstract class LogStorage {
  /// Store a log entry
  Future<void> store(LogEntry entry);

  /// Store multiple log entries
  Future<void> storeAll(List<LogEntry> entries) async {
    for (final entry in entries) {
      await store(entry);
    }
  }

  /// Retrieve log entries based on criteria
  Future<List<LogEntry>> retrieve({
    DateTime? startTime,
    DateTime? endTime,
    String? loggerName,
    int? limit,
  });

  /// Clear all stored log entries
  Future<void> clear();

  /// Get the total number of stored log entries
  Future<int> count();

  /// Close the storage and release any resources
  Future<void> close() async {
    // Default implementation does nothing
  }
}