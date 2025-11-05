import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/formatters.dart';
import '../../connection/bloc/vm_connection_bloc.dart';
import '../../logs/bloc/logs_bloc.dart';
import '../../logs/view/logs_section.dart';
import '../../rpc/bloc/rpc_metrics_bloc.dart';
import '../../rpc/view/rpc_section.dart';

class KomodoDevToolsHomeView extends StatelessWidget {
  const KomodoDevToolsHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Padding(
        padding: const EdgeInsets.all(defaultSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _ConnectionHeader(),
            SizedBox(height: defaultSpacing),
            Expanded(child: _SectionTabs()),
          ],
        ),
      ),
    );
  }
}

class _ConnectionHeader extends StatelessWidget {
  const _ConnectionHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VmConnectionBloc, VmConnectionState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final statusColor = _statusColor(state.status, theme);
        final statusLabel = _statusLabel(state.status);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusChip(label: statusLabel, color: statusColor),
                if (state.appDescription != null) ...[
                  const SizedBox(width: denseSpacing),
                  Text(
                    state.appDescription!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                if (state.connectedAt != null) ...[
                  const SizedBox(width: denseSpacing),
                  Text(
                    'Connected ${formatDurationShort(DateTime.now().difference(state.connectedAt!))} ago',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
                const SizedBox(width: denseSpacing),
                if (state.error != null)
                  Icon(Icons.warning_amber, color: theme.colorScheme.error),
              ],
            ),
            const SizedBox(height: denseSpacing),
            _ActionsWrap(state: state),
            const SizedBox(height: denseSpacing),
            const _SnapshotMetaRow(),
            if (state.error != null) ...[
              const SizedBox(height: densePadding),
              Text(
                state.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Color _statusColor(ConnectionStatus status, ThemeData theme) {
    switch (status) {
      case ConnectionStatus.disconnected:
        return theme.colorScheme.error;
      case ConnectionStatus.connecting:
        return theme.colorScheme.tertiary;
      case ConnectionStatus.connected:
        return theme.colorScheme.secondary;
    }
  }

  String _statusLabel(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.connecting:
        return 'Connecting…';
      case ConnectionStatus.connected:
        return 'Connected';
    }
  }
}

class _SnapshotMetaRow extends StatelessWidget {
  const _SnapshotMetaRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        BlocBuilder<LogsBloc, LogsState>(
          builder: (context, logsState) {
            final last = logsState.lastSnapshotAt;
            final description = last == null
                ? 'No snapshots yet'
                : 'Snapshot ${formatDurationShort(DateTime.now().difference(last))} ago';
            return Text(
              'Logs · ${logsState.entries.length} ($description)',
              style: theme.textTheme.labelSmall,
            );
          },
        ),
        const SizedBox(width: defaultSpacing),
        BlocBuilder<RpcMetricsBloc, RpcMetricsState>(
          builder: (context, rpcState) {
            final last = rpcState.lastSnapshotAt;
            final description = last == null
                ? 'No snapshots yet'
                : 'Snapshot ${formatDurationShort(DateTime.now().difference(last))} ago';
            final failed =
                rpcState.summary?.failedCalls ??
                rpcState.calls.where((call) => call.isFailure).length;
            return Text(
              'RPC · ${rpcState.calls.length} (failures: $failed, $description)',
              style: theme.textTheme.labelSmall,
            );
          },
        ),
      ],
    );
  }
}

class _SectionTabs extends StatelessWidget {
  const _SectionTabs();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.all(defaultRadius),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: TabBar(
            physics: NeverScrollableScrollPhysics(),
            indicator: BoxDecoration(
              borderRadius: const BorderRadius.all(defaultRadius),
              color: theme.colorScheme.primary.withValues(alpha: 0.16),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Logs'),
              Tab(text: 'RPC Analytics'),
            ],
          ),
        ),
        const SizedBox(height: denseSpacing),
        const Expanded(
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [LogsSection(), RpcSection()],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: denseSpacing,
        vertical: densePadding,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.all(defaultRadius),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: densePadding),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _ActionsWrap extends StatelessWidget {
  const _ActionsWrap({required this.state});

  final VmConnectionState state;

  @override
  Widget build(BuildContext context) {
    final logsBloc = context.read<LogsBloc>();
    final rpcBloc = context.read<RpcMetricsBloc>();

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: denseSpacing,
      runSpacing: densePadding,
      children: [
        BlocBuilder<LogsBloc, LogsState>(
          builder: (context, logsState) {
            return DevToolsButton(
              icon: Icons.download,
              label: logsState.isLoadingSnapshot ? 'Snapshot…' : 'Log Snapshot',
              onPressed: state.isConnected && !logsState.isLoadingSnapshot
                  ? () => logsBloc.add(const LogsSnapshotRequested())
                  : null,
            );
          },
        ),
        BlocBuilder<RpcMetricsBloc, RpcMetricsState>(
          builder: (context, rpcState) {
            return DevToolsButton(
              icon: Icons.auto_graph,
              label: rpcState.isLoadingSnapshot ? 'Fetching…' : 'RPC Snapshot',
              onPressed: state.isConnected && !rpcState.isLoadingSnapshot
                  ? () => rpcBloc.add(const RpcSnapshotRequested())
                  : null,
            );
          },
        ),
        BlocBuilder<RpcMetricsBloc, RpcMetricsState>(
          builder: (context, rpcState) {
            return DevToolsButton(
              icon: Icons.lightbulb_outline,
              label: 'Refresh Insights',
              onPressed: state.isConnected && !rpcState.isRefreshingInsights
                  ? () => rpcBloc.add(const RpcInsightRefreshRequested())
                  : null,
            );
          },
        ),
        BlocBuilder<RpcMetricsBloc, RpcMetricsState>(
          builder: (context, rpcState) {
            final enabled = rpcState.isTracingEnabled ?? true;
            return DevToolsButton(
              icon: enabled ? Icons.pause_circle : Icons.play_circle_fill,
              label: enabled ? 'Pause Trace' : 'Resume Trace',
              onPressed: state.isConnected && !rpcState.isTogglingTracing
                  ? () =>
                        rpcBloc.add(RpcTracingToggleRequested(enable: !enabled))
                  : null,
            );
          },
        ),
      ],
    );
  }
}
