class LogPerformanceMetrics {
  LogPerformanceMetrics._();

  // ignore: unused_field
  static final _instance = LogPerformanceMetrics._();

  static Duration _totalLogWriteTime = Duration.zero;

  static int _logCalls = 0;

  static Duration get averageLogWriteTime =>
      _logCalls > 0 ? _totalLogWriteTime ~/ _logCalls : Duration.zero;

  static String get summary => '${'=-' * 20}\n'
      'StoredLogs Performance Metrics\n'
      'Total log calls: $_logCalls\n'
      'Total log write time: $_totalLogWriteTime\n'
      'Average log write time: '
      '$averageLogWriteTime (${averageLogWriteTime.inMilliseconds}ms) \n'
      '${'=-' * 20}';

  static void recordLogTimeWaited(int microseconds) {
    _totalLogWriteTime += Duration(microseconds: microseconds);
    _logCalls++;
  }

  @override
  String toString() {
    return 'PerformanceMetrics{averageLogWriteTime: $averageLogWriteTime, '
        'logCalls: $_logCalls, _totalLogWriteTime: $_totalLogWriteTime}';
  }
}
