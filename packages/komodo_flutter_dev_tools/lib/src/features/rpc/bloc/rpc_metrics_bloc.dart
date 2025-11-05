import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants.dart';
import '../../../data/devtools_data_bridge.dart';
import '../../../data/models/rpc_call.dart';
import '../../../data/models/rpc_method_metrics.dart';

part 'rpc_metrics_event.dart';
part 'rpc_metrics_state.dart';

class RpcMetricsBloc extends Bloc<RpcMetricsEvent, RpcMetricsState> {
  RpcMetricsBloc(this._bridge) : super(RpcMetricsState.initial()) {
    on<RpcMetricsSubscriptionRequested>(_onSubscriptionRequested);
    on<_RpcCallsReceived>(_onCallsReceived);
    on<_RpcSummaryReceived>(_onSummaryReceived);
    on<RpcFilterTextChanged>(_onFilterTextChanged);
    on<RpcSnapshotRequested>(_onSnapshotRequested);
    on<RpcTracingToggleRequested>(_onTracingToggleRequested);
    on<RpcInsightRefreshRequested>(_onInsightRefreshRequested);
  }

  final DevToolsDataBridge _bridge;
  final _calls = ListQueue<RpcCall>();
  StreamSubscription<RpcStreamEvent>? _rpcSubscription;
  StreamSubscription<RpcSummary>? _summarySubscription;

  Future<void> _onSubscriptionRequested(
    RpcMetricsSubscriptionRequested event,
    Emitter<RpcMetricsState> emit,
  ) async {
    await _rpcSubscription?.cancel();
    _rpcSubscription = _bridge.rpcStream.listen((update) {
      add(_RpcCallsReceived(update));
    });
    await _summarySubscription?.cancel();
    _summarySubscription = _bridge.rpcSummaryStream.listen((summary) {
      add(_RpcSummaryReceived(summary));
    });
  }

  void _onCallsReceived(
    _RpcCallsReceived event,
    Emitter<RpcMetricsState> emit,
  ) {
    if (event.update.calls.isEmpty) {
      return;
    }

    for (final call in event.update.calls) {
      _calls.addLast(call);
    }

    while (_calls.length > KomodoDevToolsConstants.maxRetainedRpcCalls) {
      _calls.removeFirst();
    }

    final calls = _calls.toList(growable: false);
    final metrics = event.update.metrics ?? _buildMethodMetrics(calls);
    final insights = _buildInsights(metrics, calls);
    final filtered = _applyFilter(calls, state.filterText);

    emit(
      state.copyWith(
        calls: calls,
        filteredCalls: filtered,
        methodMetrics: metrics,
        insights: insights,
        lastSnapshotAt: event.update.isSnapshot
            ? DateTime.now()
            : state.lastSnapshotAt,
        error: null,
      ),
    );
  }

  void _onSummaryReceived(
    _RpcSummaryReceived event,
    Emitter<RpcMetricsState> emit,
  ) {
    emit(state.copyWith(summary: event.summary, error: null));
  }

  void _onFilterTextChanged(
    RpcFilterTextChanged event,
    Emitter<RpcMetricsState> emit,
  ) {
    emit(
      state.copyWith(
        filterText: event.filterText,
        filteredCalls: _applyFilter(state.calls, event.filterText),
      ),
    );
  }

  Future<void> _onSnapshotRequested(
    RpcSnapshotRequested event,
    Emitter<RpcMetricsState> emit,
  ) async {
    emit(state.copyWith(isLoadingSnapshot: true, error: null));
    try {
      await _bridge.fetchRpcSnapshot();
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
    } finally {
      emit(state.copyWith(isLoadingSnapshot: false));
    }
  }

  Future<void> _onTracingToggleRequested(
    RpcTracingToggleRequested event,
    Emitter<RpcMetricsState> emit,
  ) async {
    emit(state.copyWith(isTogglingTracing: true));
    try {
      await _bridge.toggleRpcTracing(event.enable);
      emit(state.copyWith(isTracingEnabled: event.enable));
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
    } finally {
      emit(state.copyWith(isTogglingTracing: false));
    }
  }

  Future<void> _onInsightRefreshRequested(
    RpcInsightRefreshRequested event,
    Emitter<RpcMetricsState> emit,
  ) async {
    emit(state.copyWith(isRefreshingInsights: true));
    try {
      await _bridge.requestRpcInsightRefresh();
    } catch (error) {
      // If the app doesn't expose the extension, we fallback to local insights.
      emit(state.copyWith(error: error.toString()));
    } finally {
      emit(state.copyWith(isRefreshingInsights: false));
    }
  }

  List<RpcMethodMetrics> _buildMethodMetrics(List<RpcCall> calls) {
    final grouped = calls.groupListsBy((call) => call.method);
    return grouped.entries
        .map((entry) => RpcMethodMetrics.fromCalls(entry.key, entry.value))
        .sorted((a, b) => b.callCount.compareTo(a.callCount))
        .toList(growable: false);
  }

  List<RpcInsight> _buildInsights(
    List<RpcMethodMetrics> metrics,
    List<RpcCall> calls,
  ) {
    final insights = <RpcInsight>[];

    for (final metric in metrics) {
      if (metric.callCount < 3) continue;

      if (metric.duplicateRatio >= 0.35 && metric.callCount >= 6) {
        insights.add(
          RpcInsight(
            type: RpcInsightType.duplication,
            method: metric.method,
            message:
                'Detected duplicate payloads across ${metric.callCount} calls. Consider caching or batching.',
            score: metric.duplicateRatio * metric.callCount,
          ),
        );
      }

      if (metric.p95DurationMs >= 800) {
        insights.add(
          RpcInsight(
            type: RpcInsightType.latency,
            method: metric.method,
            message:
                'High latency: p95 ${metric.p95DurationMs.toStringAsFixed(0)} ms. Investigate backend or client retries.',
            score: metric.p95DurationMs / 100,
          ),
        );
      }

      if (metric.failureRate >= 0.1) {
        insights.add(
          RpcInsight(
            type: RpcInsightType.failure,
            method: metric.method,
            message:
                'Failure rate ${(metric.failureRate * 100).toStringAsFixed(1)}%. Review error handling.',
            score: metric.failureRate * metric.callCount,
          ),
        );
      }

      final avgBytes = metric.callCount == 0
          ? 0
          : metric.totalBytes / metric.callCount;
      if (avgBytes >= 200000) {
        insights.add(
          RpcInsight(
            type: RpcInsightType.bandwidth,
            method: metric.method,
            message:
                'Heavy payloads (~${(avgBytes / 1024).round()} KiB per call). Evaluate compression or selective fields.',
            score: avgBytes / 1000,
          ),
        );
      }
    }

    insights.sort((a, b) => b.score.compareTo(a.score));
    return insights.take(6).toList(growable: false);
  }

  List<RpcCall> _applyFilter(List<RpcCall> calls, String filterText) {
    final query = filterText.trim().toLowerCase();
    if (query.isEmpty) return calls;
    return calls
        .where((call) {
          if (call.method.toLowerCase().contains(query)) return true;
          if (call.status.label.toLowerCase().contains(query)) return true;
          if (call.payloadFingerprint?.toLowerCase().contains(query) == true) {
            return true;
          }
          return call.metadata.entries.any(
            (entry) =>
                entry.key.toLowerCase().contains(query) ||
                entry.value?.toString().toLowerCase().contains(query) == true,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<void> close() async {
    await _rpcSubscription?.cancel();
    await _summarySubscription?.cancel();
    return super.close();
  }
}
