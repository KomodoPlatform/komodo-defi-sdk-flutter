import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'log_entry.dart';
import 'rpc_call.dart';

class RpcMethodMetrics extends Equatable {
  const RpcMethodMetrics({
    required this.method,
    required this.callCount,
    required this.averageDurationMs,
    required this.p95DurationMs,
    required this.minDurationMs,
    required this.maxDurationMs,
    required this.failureRate,
    required this.duplicateFingerprintCount,
    required this.cacheHitCount,
    required this.totalBytes,
    required this.firstCallAt,
    required this.lastCallAt,
  });

  factory RpcMethodMetrics.fromCalls(String method, List<RpcCall> calls) {
    if (calls.isEmpty) {
      return RpcMethodMetrics(
        method: method,
        callCount: 0,
        averageDurationMs: 0,
        p95DurationMs: 0,
        minDurationMs: 0,
        maxDurationMs: 0,
        failureRate: 0,
        duplicateFingerprintCount: 0,
        cacheHitCount: 0,
        totalBytes: 0,
        firstCallAt: DateTime.now(),
        lastCallAt: DateTime.now(),
      );
    }

    final durations = calls
        .map((c) => c.duration.inMilliseconds.toDouble())
        .toList();
    durations.sort();
    final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
    final p95Index = math.max(0, ((durations.length - 1) * 0.95).round());
    final p95Duration = durations[p95Index];
    final failureRate =
        calls.where((c) => c.isFailure).length / calls.length.toDouble();
    final fingerprints = <String>{};
    for (final call in calls) {
      if (call.payloadFingerprint != null) {
        fingerprints.add(call.payloadFingerprint!);
      }
    }
    final duplicateCount = math.max(0, calls.length - fingerprints.length);
    final cacheHits = calls.where((call) => call.isCacheHit == true).length;
    final totalBytes = calls.fold<int>(0, (sum, call) => sum + call.totalBytes);
    final firstCall = calls.map((c) => c.startedAt).minOrNull ?? DateTime.now();
    final lastCall = calls.map((c) => c.endedAt).maxOrNull ?? DateTime.now();

    return RpcMethodMetrics(
      method: method,
      callCount: calls.length,
      averageDurationMs: avgDuration,
      p95DurationMs: p95Duration,
      minDurationMs: durations.first,
      maxDurationMs: durations.last,
      failureRate: failureRate,
      duplicateFingerprintCount: duplicateCount,
      cacheHitCount: cacheHits,
      totalBytes: totalBytes,
      firstCallAt: firstCall,
      lastCallAt: lastCall,
    );
  }

  final String method;
  final int callCount;
  final double averageDurationMs;
  final double p95DurationMs;
  final double minDurationMs;
  final double maxDurationMs;
  final double failureRate;
  final int duplicateFingerprintCount;
  final int cacheHitCount;
  final int totalBytes;
  final DateTime firstCallAt;
  final DateTime lastCallAt;

  double get callRatePerMinute {
    final windowMinutes = math.max(
      1 / 60,
      lastCallAt.difference(firstCallAt).inSeconds / 60,
    );
    return callCount / windowMinutes;
  }

  double get cacheHitRatio => callCount == 0 ? 0 : cacheHitCount / callCount;

  double get duplicateRatio =>
      callCount == 0 ? 0 : duplicateFingerprintCount / callCount;

  @override
  List<Object?> get props => [
    method,
    callCount,
    averageDurationMs,
    p95DurationMs,
    minDurationMs,
    maxDurationMs,
    failureRate,
    duplicateFingerprintCount,
    cacheHitCount,
    totalBytes,
    firstCallAt,
    lastCallAt,
  ];
}

enum RpcInsightType { duplication, latency, failure, bandwidth }

class RpcInsight extends Equatable {
  const RpcInsight({
    required this.type,
    required this.method,
    required this.message,
    required this.score,
    this.relatedLogs = const <LogEntry>[],
  });

  final RpcInsightType type;
  final String method;
  final String message;
  final double score;
  final List<LogEntry> relatedLogs;

  @override
  List<Object?> get props => [type, method, message, score, relatedLogs];
}
