import 'package:dragon_logs/dragon_logs.dart';
import 'package:flutter/foundation.dart';

/// Example demonstrating the use of Dragon Logs package.
/// 
/// This example shows Wasm-compatible logging across different platforms.
void main() async {
  // Initialize Dragon Logs with platform-appropriate storage
  await DragonLogsConfig.initialize(
    globalLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
    enableConsoleLogging: true,
    enablePersistentLogging: true,
  );

  // Create loggers for different parts of your application
  final appLogger = Logger.getLogger('MyApp');
  final networkLogger = Logger.getLogger('Network');
  final uiLogger = Logger.getLogger('UI');

  // Basic logging
  appLogger.info('Application started');
  appLogger.debug('Debug information', null, null, {'userId': '12345'});
  
  // Network logging with error handling
  try {
    await simulateNetworkCall();
  } catch (error, stackTrace) {
    networkLogger.error('Network request failed', error, stackTrace);
  }

  // UI event logging
  uiLogger.info('User clicked button', null, null, {
    'buttonId': 'submit',
    'screenName': 'login',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });

  // Different log levels
  appLogger.trace('Trace message - very detailed');
  appLogger.debug('Debug message - for development');
  appLogger.info('Info message - general information');
  appLogger.warn('Warning message - potential issue');
  appLogger.error('Error message - something went wrong');
  appLogger.fatal('Fatal message - critical failure');

  // Platform information
  final platformInfo = DragonLogsConfig.platformInfo;
  appLogger.info('Platform info', null, null, platformInfo);

  // Custom formatter example
  final jsonLogger = Logger.getLogger('JSON');
  final jsonFormatter = JsonLogFormatter(prettyPrint: true);
  final storageWriter = StorageLogWriter(
    DragonLogsConfig.instance.defaultStorage!,
    jsonFormatter,
  );
  jsonLogger.addWriter(storageWriter);
  jsonLogger.info('This will be formatted as JSON');

  // Demonstrate storage retrieval (if supported)
  final storage = DragonLogsConfig.instance.defaultStorage;
  if (storage != null) {
    final recentLogs = await storage.retrieve(limit: 5);
    print('Retrieved ${recentLogs.length} recent log entries');
    
    for (final entry in recentLogs) {
      print('- ${entry.level.name}: ${entry.message}');
    }
  }

  print('Example completed. Check your browser console or device logs.');
}

/// Simulate a network call that might fail
Future<void> simulateNetworkCall() async {
  await Future.delayed(Duration(milliseconds: 100));
  throw Exception('Network timeout');
}

/// Example of how to integrate with existing logging in your app
void integrateWithExistingApp() {
  // Get or create a logger for your specific module
  final authLogger = Logger.getLogger('Authentication');
  
  // Set module-specific log level
  authLogger.level = LogLevel.debug;
  
  // Add custom writer for this logger only
  authLogger.addWriter(BufferedLogWriter(
    const ConsoleLogWriter(),
    bufferSize: 50,
    flushInterval: Duration(seconds: 10),
  ));
  
  // Use throughout your authentication module
  authLogger.info('User authentication started');
  authLogger.debug('Checking credentials');
  authLogger.warn('Password complexity requirements not met');
}

/// Example of conditional compilation for different platforms
void platformSpecificLogging() {
  final logger = Logger.getLogger('Platform');
  
  if (kIsWeb) {
    if (DragonLogsConfig.isWasm) {
      logger.info('Running with WebAssembly for optimal performance!');
    } else {
      logger.info('Running with JavaScript compilation');
    }
  } else {
    logger.info('Running on native platform');
  }
}