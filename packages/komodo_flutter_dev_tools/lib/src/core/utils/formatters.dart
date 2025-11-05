import 'package:intl/intl.dart';

final DateFormat logTimestampFormat = DateFormat('HH:mm:ss.SSS');
final DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

String formatTimestamp(DateTime timestamp) =>
    logTimestampFormat.format(timestamp);

String formatDurationShort(Duration duration) {
  if (duration.inHours >= 1) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
  }
  if (duration.inMinutes >= 1) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return seconds == 0 ? '${minutes}m' : '${minutes}m ${seconds}s';
  }
  if (duration.inMilliseconds >= 1000) {
    final seconds = duration.inMilliseconds / 1000;
    return '${seconds.toStringAsFixed(seconds >= 10 ? 0 : 1)}s';
  }
  return '${duration.inMilliseconds}ms';
}

String formatMilliseconds(double ms) {
  if (ms >= 1000) {
    return '${(ms / 1000).toStringAsFixed(ms >= 10000 ? 1 : 2)}s';
  }
  return '${ms.toStringAsFixed(ms >= 10 ? 0 : 1)}ms';
}

String formatBytes(int bytes) {
  const units = ['B', 'KiB', 'MiB', 'GiB'];
  var value = bytes.toDouble();
  var unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }
  final precision = value >= 100 || unitIndex == 0 ? 0 : 1;
  return '${value.toStringAsFixed(precision)} ${units[unitIndex]}';
}

String formatPerMinute(double value) {
  if (value >= 100) {
    return '${value.toStringAsFixed(0)}/min';
  }
  if (value >= 10) {
    return '${value.toStringAsFixed(1)}/min';
  }
  return '${value.toStringAsFixed(2)}/min';
}

String formatPercentage(double value) {
  return '${(value * 100).toStringAsFixed(value >= 0.1 ? 1 : 2)}%';
}
