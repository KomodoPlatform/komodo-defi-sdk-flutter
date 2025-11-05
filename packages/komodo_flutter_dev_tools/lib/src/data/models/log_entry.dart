import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

enum LogLevel { trace, debug, info, warn, error, fatal }

extension LogLevelX on LogLevel {
  String get label => switch (this) {
    LogLevel.trace => 'TRACE',
    LogLevel.debug => 'DEBUG',
    LogLevel.info => 'INFO',
    LogLevel.warn => 'WARN',
    LogLevel.error => 'ERROR',
    LogLevel.fatal => 'FATAL',
  };

  static LogLevel parse(String? raw) {
    final normalized = raw?.toLowerCase().trim();
    return LogLevel.values.firstWhere(
      (level) => level.name == normalized,
      orElse: () {
        switch (normalized) {
          case 'warning':
            return LogLevel.warn;
          case 'err':
          case 'severe':
            return LogLevel.error;
          case 'wtf':
          case 'critical':
            return LogLevel.fatal;
          default:
            return LogLevel.info;
        }
      },
    );
  }

  bool get isError => this == LogLevel.error || this == LogLevel.fatal;
}

class LogEntry extends Equatable {
  const LogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.category,
    required this.message,
    this.metadata = const {},
    this.sequence,
    this.requestDuration,
    this.appLifetime,
    this.isolateId,
    this.tags = const <String>[],
  });

  factory LogEntry.fromExtensionData(Map<String, dynamic> data) {
    final timestamp = _parseTimestamp(data['timestamp']) ?? DateTime.now();
    final level = LogLevelX.parse(data['level'] as String?);
    final category = (data['category'] ?? data['tag'] ?? 'log').toString();
    final message = (data['message'] ?? data['msg'] ?? '').toString();
    final metadata = _parseMetadata(data);
    final durationMs =
        _parseDouble(data['durationMs']) ??
        _parseDouble(metadata['durationMs']);
    final appLifetimeMs =
        _parseDouble(data['appLifetimeMs']) ??
        _parseDouble(metadata['uptimeMs']);
    final tags =
        _parseStringList(data['tags']) ??
        _parseStringList(metadata['tags']) ??
        const <String>[];

    return LogEntry(
      id:
          data['id']?.toString() ??
          _stableId(timestamp, level, category, message, metadata),
      timestamp: timestamp,
      level: level,
      category: category,
      message: message,
      metadata: metadata,
      sequence: _parseInt(data['sequence'] ?? data['seq']),
      requestDuration: durationMs != null
          ? Duration(milliseconds: durationMs.round())
          : null,
      appLifetime: appLifetimeMs != null
          ? Duration(milliseconds: appLifetimeMs.round())
          : null,
      isolateId:
          data['isolateId']?.toString() ?? metadata['isolateId']?.toString(),
      tags: tags,
    );
  }

  final String id;
  final DateTime timestamp;
  final LogLevel level;
  final String category;
  final String message;
  final Map<String, Object?> metadata;
  final int? sequence;
  final Duration? requestDuration;
  final Duration? appLifetime;
  final String? isolateId;
  final List<String> tags;

  bool get hasMetadata => metadata.isNotEmpty;

  bool get isError => level.isError;

  LogEntry copyWith({Map<String, Object?>? metadata}) {
    return LogEntry(
      id: id,
      timestamp: timestamp,
      level: level,
      category: category,
      message: message,
      metadata: metadata ?? this.metadata,
      sequence: sequence,
      requestDuration: requestDuration,
      appLifetime: appLifetime,
      isolateId: isolateId,
      tags: tags,
    );
  }

  @override
  List<Object?> get props => [
    id,
    timestamp,
    level,
    category,
    message,
    const DeepCollectionEquality().hash(metadata),
    sequence,
    requestDuration,
    appLifetime,
    isolateId,
    const ListEquality<String>().hash(tags),
  ];

  static DateTime? _parseTimestamp(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final raw = value.toString();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw) ??
        DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(raw) ?? DateTime.now().millisecondsSinceEpoch,
        );
  }

  static int? _parseInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString());
  }

  static double? _parseDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static Map<String, Object?> _parseMetadata(Map<String, dynamic> data) {
    final metadata = <String, Object?>{};
    final raw = data['metadata'] ?? data['meta'];
    if (raw is Map) {
      raw.forEach((key, value) {
        metadata[key.toString()] = value;
      });
    }
    // Promote known fields if they live alongside metadata.
    for (final key in data.keys) {
      if (key.startsWith('meta.')) {
        metadata[key.substring(5)] = data[key];
      }
    }
    return Map.unmodifiable(metadata);
  }

  static List<String>? _parseStringList(Object? value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList(growable: false);
    }
    if (value is String && value.isNotEmpty) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return null;
  }

  static String _stableId(
    DateTime timestamp,
    LogLevel level,
    String category,
    String message,
    Map<String, Object?> metadata,
  ) {
    final metaHash = const DeepCollectionEquality().hash(metadata);
    return '${timestamp.microsecondsSinceEpoch}:${level.name}:$category:$metaHash:${message.hashCode}';
  }
}
