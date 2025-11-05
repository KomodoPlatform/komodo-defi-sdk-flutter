part of 'rpc_metrics_bloc.dart';

class RpcMetricsState extends Equatable {
  static const _noValue = Object();

  const RpcMetricsState({
    required this.calls,
    required this.filteredCalls,
    required this.methodMetrics,
    required this.insights,
    required this.filterText,
    required this.isLoadingSnapshot,
    required this.isTracingEnabled,
    required this.isTogglingTracing,
    required this.isRefreshingInsights,
    required this.lastSnapshotAt,
    required this.error,
    this.summary,
  });

  factory RpcMetricsState.initial() => const RpcMetricsState(
    calls: [],
    filteredCalls: [],
    methodMetrics: [],
    insights: [],
    filterText: '',
    isLoadingSnapshot: false,
    isTracingEnabled: null,
    isTogglingTracing: false,
    isRefreshingInsights: false,
    lastSnapshotAt: null,
    error: null,
  );

  final List<RpcCall> calls;
  final List<RpcCall> filteredCalls;
  final List<RpcMethodMetrics> methodMetrics;
  final List<RpcInsight> insights;
  final String filterText;
  final bool isLoadingSnapshot;
  final bool? isTracingEnabled;
  final bool isTogglingTracing;
  final bool isRefreshingInsights;
  final DateTime? lastSnapshotAt;
  final String? error;
  final RpcSummary? summary;

  RpcMetricsState copyWith({
    List<RpcCall>? calls,
    List<RpcCall>? filteredCalls,
    List<RpcMethodMetrics>? methodMetrics,
    List<RpcInsight>? insights,
    String? filterText,
    bool? isLoadingSnapshot,
    bool? isTracingEnabled,
    bool? isTogglingTracing,
    bool? isRefreshingInsights,
    DateTime? lastSnapshotAt,
    Object? error = _noValue,
    RpcSummary? summary,
  }) {
    return RpcMetricsState(
      calls: calls ?? this.calls,
      filteredCalls: filteredCalls ?? this.filteredCalls,
      methodMetrics: methodMetrics ?? this.methodMetrics,
      insights: insights ?? this.insights,
      filterText: filterText ?? this.filterText,
      isLoadingSnapshot: isLoadingSnapshot ?? this.isLoadingSnapshot,
      isTracingEnabled: isTracingEnabled ?? this.isTracingEnabled,
      isTogglingTracing: isTogglingTracing ?? this.isTogglingTracing,
      isRefreshingInsights: isRefreshingInsights ?? this.isRefreshingInsights,
      lastSnapshotAt: lastSnapshotAt ?? this.lastSnapshotAt,
      error: identical(error, _noValue) ? this.error : error as String?,
      summary: summary ?? this.summary,
    );
  }

  @override
  List<Object?> get props => [
    calls,
    filteredCalls,
    methodMetrics,
    insights,
    filterText,
    isLoadingSnapshot,
    isTracingEnabled,
    isTogglingTracing,
    isRefreshingInsights,
    lastSnapshotAt,
    error,
    summary,
  ];
}
