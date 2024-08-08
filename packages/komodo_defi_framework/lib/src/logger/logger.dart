import 'dart:async';

abstract class ILogger {
  void log(String message);
  Stream<String> get logStream;
  void dispose();
}

class ConsoleLogger implements ILogger {
  final void Function(String)? _externalLogger;
  final _logController = StreamController<String>.broadcast();

  ConsoleLogger({void Function(String)? externalLogger})
      : _externalLogger = externalLogger;

  @override
  void log(String message) {
    _logController.add(message);
    _externalLogger?.call(message);
  }

  @override
  Stream<String> get logStream => _logController.stream;

  @override
  void dispose() {
    _logController.close();
  }
}
