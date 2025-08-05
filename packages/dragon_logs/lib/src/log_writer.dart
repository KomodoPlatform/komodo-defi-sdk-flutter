import 'dart:async';
import 'log_entry.dart';

/// Abstract interface for writing log entries to different destinations.
/// 
/// Implementations can write to files, network endpoints, console, or any
/// other destination. This interface is designed to be Wasm-compatible.
abstract class LogWriter {
  /// Write a log entry to the destination
  Future<void> write(LogEntry entry);

  /// Close the writer and release any resources
  Future<void> close() async {
    // Default implementation does nothing
  }

  /// Flush any buffered log entries
  Future<void> flush() async {
    // Default implementation does nothing
  }
}

/// A simple console log writer that outputs to the developer console
class ConsoleLogWriter implements LogWriter {
  /// Creates a new console log writer
  const ConsoleLogWriter();

  @override
  Future<void> write(LogEntry entry) async {
    // Use print for simplicity and Wasm compatibility
    print('${entry.timestamp.toIso8601String()} [${entry.level.name}] ${entry.loggerName}: ${entry.message}');
    
    if (entry.error != null) {
      print('Error: ${entry.error}');
    }
    
    if (entry.stackTrace != null) {
      print('Stack trace:\n${entry.stackTrace}');
    }
    
    if (entry.extra != null && entry.extra!.isNotEmpty) {
      print('Extra data: ${entry.extra}');
    }
  }
}

/// A buffered log writer that batches log entries for efficiency
class BufferedLogWriter implements LogWriter {
  /// Creates a new buffered log writer
  BufferedLogWriter(this._delegate, {this.bufferSize = 100, this.flushInterval = const Duration(seconds: 5)}) {
    _timer = Timer.periodic(flushInterval, (_) => flush());
  }

  final LogWriter _delegate;
  final int bufferSize;
  final Duration flushInterval;
  final List<LogEntry> _buffer = [];
  late final Timer _timer;

  @override
  Future<void> write(LogEntry entry) async {
    _buffer.add(entry);
    
    if (_buffer.length >= bufferSize) {
      await flush();
    }
  }

  @override
  Future<void> flush() async {
    if (_buffer.isEmpty) return;
    
    final entries = List<LogEntry>.from(_buffer);
    _buffer.clear();
    
    for (final entry in entries) {
      await _delegate.write(entry);
    }
    await _delegate.flush();
  }

  @override
  Future<void> close() async {
    _timer.cancel();
    await flush();
    await _delegate.close();
  }
}

/// A log writer that forwards to multiple other writers
class MultiLogWriter implements LogWriter {
  /// Creates a new multi log writer
  MultiLogWriter(this._writers);

  final List<LogWriter> _writers;

  @override
  Future<void> write(LogEntry entry) async {
    await Future.wait(_writers.map((writer) => writer.write(entry)));
  }

  @override
  Future<void> flush() async {
    await Future.wait(_writers.map((writer) => writer.flush()));
  }

  @override
  Future<void> close() async {
    await Future.wait(_writers.map((writer) => writer.close()));
  }
}