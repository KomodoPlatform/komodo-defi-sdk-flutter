part of 'rpc_metrics_bloc.dart';

abstract class RpcMetricsEvent extends Equatable {
  const RpcMetricsEvent();

  @override
  List<Object?> get props => const [];
}

class RpcMetricsSubscriptionRequested extends RpcMetricsEvent {
  const RpcMetricsSubscriptionRequested();
}

class _RpcCallsReceived extends RpcMetricsEvent {
  const _RpcCallsReceived(this.update);

  final RpcStreamEvent update;

  @override
  List<Object?> get props => [update];
}

class _RpcSummaryReceived extends RpcMetricsEvent {
  const _RpcSummaryReceived(this.summary);

  final RpcSummary summary;

  @override
  List<Object?> get props => [summary];
}

class RpcFilterTextChanged extends RpcMetricsEvent {
  const RpcFilterTextChanged(this.filterText);

  final String filterText;

  @override
  List<Object?> get props => [filterText];
}

class RpcSnapshotRequested extends RpcMetricsEvent {
  const RpcSnapshotRequested();
}

class RpcTracingToggleRequested extends RpcMetricsEvent {
  const RpcTracingToggleRequested({required this.enable});

  final bool enable;

  @override
  List<Object?> get props => [enable];
}

class RpcInsightRefreshRequested extends RpcMetricsEvent {
  const RpcInsightRefreshRequested();
}
