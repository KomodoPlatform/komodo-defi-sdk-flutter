import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

enum RpcDirection { outbound, inbound }

extension RpcDirectionX on RpcDirection {
  String get label => switch (this) {
    RpcDirection.outbound => 'Outbound',
    RpcDirection.inbound => 'Inbound',
  };

  static RpcDirection parse(String? raw) {
    final normalized = raw?.toLowerCase().trim();
    return RpcDirection.values.firstWhere(
      (value) => value.name == normalized,
      orElse: () => RpcDirection.outbound,
    );
  }
}

enum RpcStatus { success, failure, timeout, cancelled, unknown }

extension RpcStatusX on RpcStatus {
  bool get isFailure => this == RpcStatus.failure || this == RpcStatus.timeout;

  String get label => switch (this) {
    RpcStatus.success => 'Success',
    RpcStatus.failure => 'Failure',
    RpcStatus.timeout => 'Timeout',
    RpcStatus.cancelled => 'Cancelled',
    RpcStatus.unknown => 'Unknown',
  };

  static RpcStatus parse(String? raw) {
    final normalized = raw?.toLowerCase().trim();
    return RpcStatus.values.firstWhere(
      (value) => value.name == normalized,
      orElse: () {
        switch (normalized) {
          case 'ok':
          case 'completed':
            return RpcStatus.success;
          case 'error':
          case 'fail':
          case 'failed':
            return RpcStatus.failure;
          case 'timeout':
          case 'timedout':
            return RpcStatus.timeout;
          case 'cancelled':
          case 'canceled':
            return RpcStatus.cancelled;
          default:
            return RpcStatus.unknown;
        }
      },
    );
  }
}

class RpcCall extends Equatable {
  const RpcCall({
    required this.id,
    required this.method,
    required this.direction,
    required this.status,
    required this.startedAt,
    required this.endedAt,
    required this.duration,
    this.requestBytes,
    this.responseBytes,
    this.payloadFingerprint,
    this.metadata = const {},
    this.errorCode,
    this.errorMessage,
    this.retryCount,
    this.isCacheHit,
  });

  factory RpcCall.fromExtensionData(Map<String, dynamic> data) {
    final startedAt = _parseTimestamp(
      data['startTimestamp'] ?? data['startedAt'],
    );
    final endedAt =
        _parseTimestamp(data['endTimestamp'] ?? data['endedAt']) ?? startedAt;
    var durationMs =
        _parseDouble(data['durationMs']) ??
        _parseDouble(data['elapsedMs']) ??
        (endedAt != null && startedAt != null
            ? endedAt.difference(startedAt).inMilliseconds.toDouble()
            : null);

    durationMs ??= 0;

    final metadata = _parseMetadata(data);

    return RpcCall(
      id:
          data['id']?.toString() ??
          _stableId(
            startedAt ?? DateTime.now(),
            data['method']?.toString() ?? 'unknown',
            metadata,
          ),
      method: data['method']?.toString() ?? 'unknown',
      direction: RpcDirectionX.parse(
        data['direction'] as String? ?? metadata['direction']?.toString(),
      ),
      status: RpcStatusX.parse(
        data['status'] as String? ?? metadata['status']?.toString(),
      ),
      startedAt: startedAt ?? DateTime.now(),
      endedAt:
          endedAt ??
          (startedAt != null
              ? startedAt.add(Duration(milliseconds: durationMs.round()))
              : DateTime.now()),
      duration: Duration(milliseconds: durationMs.round()),
      requestBytes: _parseInt(data['requestBytes'] ?? metadata['requestBytes']),
      responseBytes: _parseInt(
        data['responseBytes'] ?? metadata['responseBytes'],
      ),
      payloadFingerprint:
          metadata['fingerprint']?.toString() ??
          data['fingerprint']?.toString(),
      metadata: metadata,
      errorCode:
          data['errorCode']?.toString() ?? metadata['errorCode']?.toString(),
      errorMessage:
          data['errorMessage']?.toString() ??
          metadata['errorMessage']?.toString(),
      retryCount: _parseInt(data['retryCount'] ?? metadata['retryCount']),
      isCacheHit: _parseBool(data['cacheHit'] ?? metadata['cacheHit']),
    );
  }

  final String id;
  final String method;
  final RpcDirection direction;
  final RpcStatus status;
  final DateTime startedAt;
  final DateTime endedAt;
  final Duration duration;
  final int? requestBytes;
  final int? responseBytes;
  final String? payloadFingerprint;
  final Map<String, Object?> metadata;
  final String? errorCode;
  final String? errorMessage;
  final int? retryCount;
  final bool? isCacheHit;

  int get totalBytes {
    final req = requestBytes ?? 0;
    final res = responseBytes ?? 0;
    return req + res;
  }

  bool get isFailure => status.isFailure;

  @override
  List<Object?> get props => [
    id,
    method,
    direction,
    status,
    startedAt,
    endedAt,
    duration,
    requestBytes,
    responseBytes,
    payloadFingerprint,
    const DeepCollectionEquality().hash(metadata),
    errorCode,
    errorMessage,
    retryCount,
    isCacheHit,
  ];

  static DateTime? _parseTimestamp(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      // Accept both milliseconds and microseconds.
      if (value > 1000000000000) {
        // Likely milliseconds since epoch.
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.fromMicrosecondsSinceEpoch(value);
    }
    final raw = value.toString();
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

  static bool? _parseBool(Object? value) {
    if (value == null) return null;
    if (value is bool) return value;
    final normalized = value.toString().toLowerCase().trim();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }

  static Map<String, Object?> _parseMetadata(Map<String, dynamic> data) {
    final metadata = <String, Object?>{};
    final raw = data['metadata'] ?? data['meta'] ?? data['context'];
    if (raw is Map) {
      raw.forEach((key, value) {
        metadata[key.toString()] = value;
      });
    }
    return Map.unmodifiable(metadata);
  }

  static String _stableId(
    DateTime timestamp,
    String method,
    Map<String, Object?> metadata,
  ) {
    final metadataHash = const DeepCollectionEquality().hash(metadata);
    return '${timestamp.microsecondsSinceEpoch}:$method:$metadataHash';
  }
}

class RpcSummary extends Equatable {
  const RpcSummary({
    required this.totalCalls,
    required this.failedCalls,
    required this.cachedHits,
    required this.uniqueMethods,
    required this.generatedAt,
  });

  factory RpcSummary.fromExtensionData(Map<String, dynamic> data) {
    return RpcSummary(
      totalCalls: _parseInt(data['totalCalls']) ?? 0,
      failedCalls: _parseInt(data['failedCalls']) ?? 0,
      cachedHits: _parseInt(data['cachedHits']) ?? 0,
      uniqueMethods: _parseInt(data['uniqueMethods']) ?? 0,
      generatedAt:
          RpcCall._parseTimestamp(data['generatedAt']) ?? DateTime.now(),
    );
  }

  final int totalCalls;
  final int failedCalls;
  final int cachedHits;
  final int uniqueMethods;
  final DateTime generatedAt;

  double get failureRate => totalCalls == 0 ? 0 : failedCalls / totalCalls;

  @override
  List<Object?> get props => [
    totalCalls,
    failedCalls,
    cachedHits,
    uniqueMethods,
    generatedAt,
  ];

  static int? _parseInt(Object? value) => RpcCall._parseInt(value);
}
