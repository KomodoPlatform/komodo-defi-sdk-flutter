# Dragon Logs

A Flutter-compatible logging package with support for Web WebAssembly (Wasm). Dragon Logs provides flexible logging capabilities across all Flutter platforms while ensuring compatibility with modern web standards.

## Features

- ✅ **Wasm Compatible**: Uses `package:web` instead of deprecated `dart:html` and `file_system_access_api`
- 🚀 **Cross-Platform**: Works on Android, iOS, Web, Windows, macOS, and Linux
- 📊 **Multiple Storage Options**: Memory, file-based, and web storage
- 🎨 **Flexible Formatting**: Simple text and JSON formatters included
- 🔧 **Configurable**: Easy setup with sensible defaults
- 📱 **Platform-Aware**: Automatically chooses the best storage for each platform
- 🧪 **Well Tested**: Comprehensive test coverage

## Migration from file_system_access_api

This package replaces the deprecated `file_system_access_api` with modern, Wasm-compatible alternatives:

- **Web Storage**: Uses `localStorage` via `package:web` for browser compatibility
- **File Storage**: Uses `path_provider` for mobile and desktop platforms
- **Memory Storage**: Fallback option that works everywhere

## Installation

Add dragon_logs to your `pubspec.yaml`:

```yaml
dependencies:
  dragon_logs: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:dragon_logs/dragon_logs.dart';

void main() async {
  // Initialize with platform-appropriate storage
  await DragonLogsConfig.initialize(
    globalLevel: LogLevel.info,
    enableConsoleLogging: true,
    enablePersistentLogging: true,
  );

  // Create a logger
  final logger = Logger.getLogger('MyApp');

  // Start logging
  logger.info('Application started');
  logger.debug('Debug information', null, null, {'userId': '12345'});
  
  // Error logging with stack trace
  try {
    throw Exception('Something went wrong');
  } catch (error, stackTrace) {
    logger.error('An error occurred', error, stackTrace);
  }
}
```

## Configuration

### Basic Configuration

```dart
await DragonLogsConfig.initialize(
  globalLevel: LogLevel.debug,
  enableConsoleLogging: true,
  enablePersistentLogging: true,
  maxMemoryEntries: 5000,
  storageKey: 'my_app_logs', // For web storage
);
```

### Custom Storage

```dart
// Use custom storage
await DragonLogsConfig.initialize(
  customStorage: MyCustomStorage(),
  formatter: JsonLogFormatter(prettyPrint: true),
);
```

### Platform Detection

```dart
// Check platform capabilities
final platformInfo = DragonLogsConfig.platformInfo;
print('Running on Web: ${platformInfo['isWeb']}');
print('Using Wasm: ${platformInfo['isWasm']}');
print('Web storage supported: ${platformInfo['webStorageSupported']}');
```

## Usage Examples

### Basic Logging

```dart
final logger = Logger.getLogger('NetworkService');

logger.trace('Entering method');
logger.debug('Processing request');
logger.info('Request completed successfully');
logger.warn('Slow response time detected');
logger.error('Request failed');
logger.fatal('Service unavailable');
```

### Structured Logging

```dart
logger.info('User action', null, null, {
  'action': 'login',
  'userId': '12345',
  'timestamp': DateTime.now().millisecondsSinceEpoch,
  'userAgent': 'Mozilla/5.0...',
});
```

### Custom Log Writers

```dart
// Create a custom writer that sends logs to a remote server
class RemoteLogWriter implements LogWriter {
  @override
  Future<void> write(LogEntry entry) async {
    // Send to your logging service
    await httpClient.post('/logs', body: jsonEncode({
      'level': entry.level.name,
      'message': entry.message,
      'timestamp': entry.timestamp.toIso8601String(),
      'extra': entry.extra,
    }));
  }
}

// Add to a specific logger
final logger = Logger.getLogger('Analytics');
logger.addWriter(RemoteLogWriter());
```

### Buffered Logging

```dart
// Buffer logs and flush periodically for better performance
final bufferedWriter = BufferedLogWriter(
  RemoteLogWriter(),
  bufferSize: 100,
  flushInterval: Duration(seconds: 30),
);

logger.addWriter(bufferedWriter);
```

### Multiple Writers

```dart
// Send logs to multiple destinations
final multiWriter = MultiLogWriter([
  ConsoleLogWriter(),
  BufferedLogWriter(FileLogWriter(), bufferSize: 50),
  RemoteLogWriter(),
]);

logger.addWriter(multiWriter);
```

## Storage Options

### Web Storage (Browser)

Uses `localStorage` for persistent storage on web platforms:

```dart
final webStorage = WebLogStorage(
  storageKey: 'app_logs',
  maxEntries: 5000,
);
```

### File Storage (Mobile/Desktop)

Uses local files for mobile and desktop platforms:

```dart
final fileStorage = FileLogStorage(
  fileName: 'app_logs.json',
  maxEntries: 10000,
  maxFileSize: 10 * 1024 * 1024, // 10MB
);
```

### Memory Storage

In-memory storage for temporary logs:

```dart
final memoryStorage = MemoryLogStorage(
  maxEntries: 1000,
);
```

## Formatters

### Simple Text Formatter

```dart
final formatter = SimpleLogFormatter(
  includeTimestamp: true,
  includeLevel: true,
  includeLoggerName: true,
  timestampFormat: 'iso8601',
);
```

### JSON Formatter

```dart
final formatter = JsonLogFormatter(
  prettyPrint: false,
  includeStackTrace: true,
);
```

## Retrieving Logs

```dart
final storage = DragonLogsConfig.instance.defaultStorage;

// Get recent logs
final recentLogs = await storage?.retrieve(limit: 100);

// Filter by time range
final todayLogs = await storage?.retrieve(
  startTime: DateTime.now().subtract(Duration(days: 1)),
  endTime: DateTime.now(),
);

// Filter by logger
final networkLogs = await storage?.retrieve(
  loggerName: 'NetworkService',
  limit: 50,
);
```

## Wasm Compatibility

Dragon Logs is designed from the ground up to be compatible with Flutter Web Wasm:

- Uses `package:web` instead of `dart:html`
- Avoids `file_system_access_api` and other deprecated web APIs
- Uses modern JavaScript interop (`dart:js_interop`)
- Gracefully handles platform differences

### Building for Wasm

```bash
flutter build web --wasm
```

The package automatically detects Wasm compilation and adapts accordingly.

## Best Practices

1. **Initialize Early**: Call `DragonLogsConfig.initialize()` in your `main()` function
2. **Use Appropriate Log Levels**: Don't use `debug` and `trace` in production
3. **Structure Your Logs**: Use the `extra` parameter for structured data
4. **Handle Errors Gracefully**: The package is designed to fail silently to avoid breaking your app
5. **Monitor Storage Usage**: Set appropriate limits for your use case

## Performance

- **Memory Efficient**: Automatic log rotation and size limits
- **Async Operations**: All storage operations are non-blocking
- **Platform Optimized**: Uses the best storage method for each platform
- **Wasm Optimized**: Designed for optimal performance with WebAssembly

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to the main repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.