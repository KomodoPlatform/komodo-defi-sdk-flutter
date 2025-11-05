import 'package:collection/collection.dart';
import 'package:devtools_app_shared/ui.dart';
import 'package:dragon_charts_flutter/dragon_charts_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/rpc_call.dart';
import '../../../data/models/rpc_method_metrics.dart';
import '../bloc/rpc_metrics_bloc.dart';

class RpcSection extends StatefulWidget {
  const RpcSection({super.key});

  @override
  State<RpcSection> createState() => _RpcSectionState();
}

class _RpcSectionState extends State<RpcSection> {
  late final TextEditingController _filterController;

  @override
  void initState() {
    super.initState();
    _filterController = TextEditingController();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RpcMetricsBloc, RpcMetricsState>(
      builder: (context, state) {
        if (_filterController.text != state.filterText) {
          _filterController
            ..text = state.filterText
            ..selection = TextSelection.collapsed(
              offset: state.filterText.length,
            );
        }

        final rpcBloc = context.read<RpcMetricsBloc>();
        final theme = Theme.of(context);

        return DevToolsAreaPane(
          header: AreaPaneHeader(
            title: Text(
              'RPC Analytics (${state.filteredCalls.length}/${state.calls.length})',
            ),
            actions: [
              SizedBox(
                width: 220,
                child: DevToolsClearableTextField(
                  controller: _filterController,
                  hintText: 'Search RPC calls…',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) =>
                      rpcBloc.add(RpcFilterTextChanged(value)),
                ),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.isLoadingSnapshot)
                const LinearProgressIndicator(minHeight: 2),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.all(densePadding),
                  child: Text(
                    state.error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              _RpcMetricsOverview(state: state),
              const SizedBox(height: defaultSpacing),
              SizedBox(height: 240, child: _RpcTimelineChart(state: state)),
              const SizedBox(height: defaultSpacing),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: _RpcMethodsTable(state: state)),
                    const SizedBox(width: defaultSpacing),
                    Expanded(flex: 2, child: _RpcInsightsList(state: state)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RpcMetricsOverview extends StatelessWidget {
  const _RpcMetricsOverview({required this.state});

  final RpcMetricsState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final callsPerMinute = _callsPerMinute(state.calls);
    final failureRate =
        state.summary?.failureRate ?? _computeFailureRate(state.calls);
    final avgPayload = _averagePayload(state.calls);
    final duplicateHeavy = state.methodMetrics
        .where((metric) => metric.duplicateRatio > 0.2)
        .length;

    return Wrap(
      spacing: defaultSpacing,
      runSpacing: defaultSpacing,
      children: [
        _MetricCard(
          label: 'Total Calls',
          value: state.calls.length.toString(),
          icon: Icons.data_usage,
          color: theme.colorScheme.primary,
        ),
        _MetricCard(
          label: 'Active Methods',
          value: state.methodMetrics.length.toString(),
          icon: Icons.view_list,
          color: theme.colorScheme.secondary,
        ),
        _MetricCard(
          label: 'Calls / min',
          value: formatPerMinute(callsPerMinute),
          icon: Icons.speed,
          color: theme.colorScheme.tertiary,
        ),
        _MetricCard(
          label: 'Failure Rate',
          value: formatPercentage(failureRate),
          icon: Icons.error_outline,
          color: theme.colorScheme.error,
        ),
        _MetricCard(
          label: 'Avg Payload',
          value: formatBytes(avgPayload.round()),
          icon: Icons.cloud_download_outlined,
          color: theme.colorScheme.outline,
        ),
        _MetricCard(
          label: 'Duplicate Methods',
          value: duplicateHeavy.toString(),
          icon: Icons.copy_all,
          color: theme.colorScheme.primaryContainer,
        ),
      ],
    );
  }

  double _computeFailureRate(List<RpcCall> calls) {
    if (calls.isEmpty) return 0;
    final failures = calls.where((call) => call.isFailure).length;
    return failures / calls.length;
  }

  int _averagePayload(List<RpcCall> calls) {
    if (calls.isEmpty) return 0;
    final total = calls.fold<int>(0, (sum, call) => sum + call.totalBytes);
    return total ~/ calls.length;
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 180,
      child: RoundedOutlinedBorder(
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: densePadding),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: densePadding / 2),
              Text(label, style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _RpcTimelineChart extends StatelessWidget {
  const _RpcTimelineChart({required this.state});

  final RpcMetricsState state;

  @override
  Widget build(BuildContext context) {
    final calls = state.filteredCalls.isNotEmpty
        ? state.filteredCalls
        : state.calls;
    if (calls.isEmpty) {
      return RoundedOutlinedBorder(
        child: Center(
          child: Text(
            'No RPC calls captured yet.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final sorted = calls.sortedBy((call) => call.startedAt);
    final base = sorted.first.startedAt;
    final data = <ChartData>[];
    for (final call in sorted) {
      final seconds = call.startedAt.difference(base).inMilliseconds / 1000.0;
      data.add(
        ChartData(x: seconds, y: call.duration.inMilliseconds.toDouble()),
      );
    }

    return RoundedOutlinedBorder(
      child: Padding(
        padding: const EdgeInsets.all(densePadding),
        child: LineChart(
          elements: [
            ChartGridLines(isVertical: true, count: 4),
            ChartGridLines(isVertical: false, count: 4),
            ChartAxisLabels(
              isVertical: true,
              count: 4,
              labelBuilder: (value) => formatMilliseconds(value),
            ),
            ChartAxisLabels(
              isVertical: false,
              count: 4,
              labelBuilder: (value) =>
                  '+${value.toStringAsFixed(value >= 60 ? 0 : 1)}s',
            ),
            ChartDataSeries(
              data: data,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
          tooltipBuilder: (context, dataPoints, colors) {
            if (dataPoints.isEmpty) {
              return const SizedBox();
            }
            final point = dataPoints.last;
            final index = data.indexOf(point);
            final call = sorted[index];
            return _TooltipCard(
              title: call.method,
              subtitle: formatMilliseconds(
                call.duration.inMilliseconds.toDouble(),
              ),
            );
          },
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _TooltipCard extends StatelessWidget {
  const _TooltipCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: densePadding,
          vertical: densePadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.labelLarge),
            Text(subtitle, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _RpcMethodsTable extends StatelessWidget {
  const _RpcMethodsTable({required this.state});

  final RpcMetricsState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RoundedOutlinedBorder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultSpacing),
            child: Text('Method Breakdown', style: theme.textTheme.titleMedium),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Method')),
                  DataColumn(label: Text('Calls')),
                  DataColumn(label: Text('Avg')),
                  DataColumn(label: Text('P95')),
                  DataColumn(label: Text('Dup%')),
                  DataColumn(label: Text('Fail%')),
                  DataColumn(label: Text('Rate')),
                  DataColumn(label: Text('Payload')),
                ],
                rows: [
                  for (final metric in state.methodMetrics)
                    DataRow(
                      cells: [
                        DataCell(Text(metric.method)),
                        DataCell(Text(metric.callCount.toString())),
                        DataCell(
                          Text(formatMilliseconds(metric.averageDurationMs)),
                        ),
                        DataCell(
                          Text(formatMilliseconds(metric.p95DurationMs)),
                        ),
                        DataCell(Text(formatPercentage(metric.duplicateRatio))),
                        DataCell(Text(formatPercentage(metric.failureRate))),
                        DataCell(
                          Text(formatPerMinute(metric.callRatePerMinute)),
                        ),
                        DataCell(
                          Text(
                            formatBytes(
                              (metric.totalBytes /
                                      (metric.callCount == 0
                                          ? 1
                                          : metric.callCount))
                                  .round(),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RpcInsightsList extends StatelessWidget {
  const _RpcInsightsList({required this.state});

  final RpcMetricsState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RoundedOutlinedBorder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultSpacing),
            child: Text(
              'Wasteful RPC Insights',
              style: theme.textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.insights.isEmpty
                ? const Center(
                    child: Text(
                      'No clear issues detected yet. Keep profiling!',
                    ),
                  )
                : ListView.separated(
                    itemCount: state.insights.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final insight = state.insights[index];
                      return ListTile(
                        leading: Icon(
                          _insightIcon(insight.type),
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(insight.method),
                        subtitle: Text(insight.message),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _insightIcon(RpcInsightType type) {
    switch (type) {
      case RpcInsightType.duplication:
        return Icons.copy_all;
      case RpcInsightType.latency:
        return Icons.timer_outlined;
      case RpcInsightType.failure:
        return Icons.error_outline;
      case RpcInsightType.bandwidth:
        return Icons.cloud_download;
    }
  }
}

double _callsPerMinute(List<RpcCall> calls) {
  if (calls.length < 2) {
    return calls.isEmpty ? 0 : calls.length.toDouble();
  }
  final sorted = calls.sortedBy((call) => call.startedAt);
  final window = sorted.last.startedAt.difference(sorted.first.startedAt);
  final minutes = window.inMilliseconds / 60000.0;
  if (minutes <= 0) {
    return sorted.length.toDouble();
  }
  return sorted.length / minutes;
}
