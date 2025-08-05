import 'package:flutter_test/flutter_test.dart';
import 'package:dragon_logs/dragon_logs.dart';

void main() {
  group('DragonLogs', () {
    setUp(() {
      // Reset state before each test
    });

    group('LogLevel', () {
      test('should parse log levels from strings', () {
        expect(LogLevel.fromString('trace'), LogLevel.trace);
        expect(LogLevel.fromString('DEBUG'), LogLevel.debug);
        expect(LogLevel.fromString('Info'), LogLevel.info);
        expect(LogLevel.fromString('WARN'), LogLevel.warn);
        expect(LogLevel.fromString('warning'), LogLevel.warn);
        expect(LogLevel.fromString('error'), LogLevel.error);
        expect(LogLevel.fromString('FATAL'), LogLevel.fatal);
      });

      test('should throw on invalid log level', () {
        expect(() => LogLevel.fromString('invalid'), throwsArgumentError);
      });

      test('should check if level is enabled', () {
        expect(LogLevel.error.isEnabledFor(LogLevel.info), isTrue);
        expect(LogLevel.debug.isEnabledFor(LogLevel.info), isFalse);
        expect(LogLevel.info.isEnabledFor(LogLevel.info), isTrue);
      });
    });

    group('LogEntry', () {
      test('should create log entry with required fields', () {
        final entry = LogEntry(
          level: LogLevel.info,
          message: 'Test message',
          timestamp: DateTime.now(),
          loggerName: 'test',
        );

        expect(entry.level, LogLevel.info);
        expect(entry.message, 'Test message');
        expect(entry.loggerName, 'test');
        expect(entry.error, isNull);
        expect(entry.stackTrace, isNull);
        expect(entry.extra, isNull);
      });

      test('should create log entry with optional fields', () {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;
        final extra = {'key': 'value'};
        final timestamp = DateTime.now();

        final entry = LogEntry(
          level: LogLevel.error,
          message: 'Error message',
          timestamp: timestamp,
          loggerName: 'test',
          error: error,
          stackTrace: stackTrace,
          extra: extra,
        );

        expect(entry.error, error);
        expect(entry.stackTrace, stackTrace);
        expect(entry.extra, extra);
      });

      test('should support copyWith', () {
        final original = LogEntry(
          level: LogLevel.info,
          message: 'Original',
          timestamp: DateTime.now(),
          loggerName: 'test',
        );

        final copy = original.copyWith(
          level: LogLevel.error,
          message: 'Modified',
        );

        expect(copy.level, LogLevel.error);
        expect(copy.message, 'Modified');
        expect(copy.timestamp, original.timestamp);
        expect(copy.loggerName, original.loggerName);
      });
    });

    group('Logger', () {
      test('should create logger with name', () {
        final logger = Logger('test');
        expect(logger.name, 'test');
        expect(logger.level, LogLevel.info);
      });

      test('should respect log level filtering', () {
        final logger = Logger('test', level: LogLevel.warn);
        final entries = <LogEntry>[];
        
        logger.addWriter(TestLogWriter(entries));

        logger.debug('Debug message');
        logger.info('Info message');
        logger.warn('Warning message');
        logger.error('Error message');

        expect(entries.length, 2);
        expect(entries[0].level, LogLevel.warn);
        expect(entries[1].level, LogLevel.error);
      });

      test('should get or create logger by name', () {
        final logger1 = Logger.getLogger('test');
        final logger2 = Logger.getLogger('test');
        final logger3 = Logger.getLogger('other');

        expect(identical(logger1, logger2), isTrue);
        expect(identical(logger1, logger3), isFalse);
      });
    });

    group('MemoryLogStorage', () {
      test('should store and retrieve log entries', () async {
        final storage = MemoryLogStorage(maxEntries: 5);
        final entry = LogEntry(
          level: LogLevel.info,
          message: 'Test',
          timestamp: DateTime.now(),
          loggerName: 'test',
        );

        await storage.store(entry);
        final retrieved = await storage.retrieve();

        expect(retrieved.length, 1);
        expect(retrieved.first.message, 'Test');
      });

      test('should enforce maximum entries limit', () async {
        final storage = MemoryLogStorage(maxEntries: 3);

        for (int i = 0; i < 5; i++) {
          await storage.store(LogEntry(
            level: LogLevel.info,
            message: 'Entry $i',
            timestamp: DateTime.now(),
            loggerName: 'test',
          ));
        }

        final count = await storage.count();
        expect(count, 3);

        final entries = await storage.retrieve();
        expect(entries.length, 3);
        // Should keep the newest entries
        expect(entries.map((e) => e.message), contains('Entry 4'));
        expect(entries.map((e) => e.message), contains('Entry 3'));
        expect(entries.map((e) => e.message), contains('Entry 2'));
      });

      test('should filter entries by criteria', () async {
        final storage = MemoryLogStorage();
        final now = DateTime.now();
        final earlier = now.subtract(Duration(hours: 1));

        await storage.store(LogEntry(
          level: LogLevel.info,
          message: 'Old entry',
          timestamp: earlier,
          loggerName: 'logger1',
        ));

        await storage.store(LogEntry(
          level: LogLevel.error,
          message: 'New entry',
          timestamp: now,
          loggerName: 'logger2',
        ));

        // Filter by logger name
        final logger1Entries = await storage.retrieve(loggerName: 'logger1');
        expect(logger1Entries.length, 1);
        expect(logger1Entries.first.message, 'Old entry');

        // Filter by time range
        final recentEntries = await storage.retrieve(
          startTime: now.subtract(Duration(minutes: 30)),
        );
        expect(recentEntries.length, 1);
        expect(recentEntries.first.message, 'New entry');

        // Filter with limit
        final limitedEntries = await storage.retrieve(limit: 1);
        expect(limitedEntries.length, 1);
      });
    });

    group('Formatters', () {
      test('SimpleLogFormatter should format entries correctly', () {
        final formatter = SimpleLogFormatter();
        final entry = LogEntry(
          level: LogLevel.info,
          message: 'Test message',
          timestamp: DateTime.parse('2023-01-01T12:00:00Z'),
          loggerName: 'test',
        );

        final formatted = formatter.format(entry);
        expect(formatted, contains('2023-01-01T12:00:00.000Z'));
        expect(formatted, contains('[INFO]'));
        expect(formatted, contains('test:'));
        expect(formatted, contains('Test message'));
      });

      test('JsonLogFormatter should format entries as JSON', () {
        final formatter = JsonLogFormatter();
        final entry = LogEntry(
          level: LogLevel.error,
          message: 'Error message',
          timestamp: DateTime.parse('2023-01-01T12:00:00Z'),
          loggerName: 'test',
          error: Exception('Test error'),
        );

        final formatted = formatter.format(entry);
        expect(formatted, contains('"level":"ERROR"'));
        expect(formatted, contains('"message":"Error message"'));
        expect(formatted, contains('"logger":"test"'));
        expect(formatted, contains('"error"'));
      });
    });
  });
}

/// Test implementation of LogWriter for testing purposes
class TestLogWriter implements LogWriter {
  TestLogWriter(this.entries);
  
  final List<LogEntry> entries;

  @override
  Future<void> write(LogEntry entry) async {
    entries.add(entry);
  }
}