import 'package:collection/collection.dart';
import 'package:devtools_app_shared/ui.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/log_entry.dart';
import '../bloc/logs_bloc.dart';

class LogsSection extends StatefulWidget {
  const LogsSection({super.key});

  @override
  State<LogsSection> createState() => _LogsSectionState();
}

class _LogsSectionState extends State<LogsSection> {
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
    return BlocBuilder<LogsBloc, LogsState>(
      builder: (context, state) {
        if (_filterController.text != state.filterText) {
          _filterController
            ..text = state.filterText
            ..selection = TextSelection.collapsed(
              offset: state.filterText.length,
            );
        }

        final logsBloc = context.read<LogsBloc>();
        final theme = Theme.of(context);

        return DevToolsAreaPane(
          header: AreaPaneHeader(
            title: Text(
              'Live Logs (${state.filteredEntries.length}/${state.entries.length})',
            ),
            actions: [
              SizedBox(
                width: 220,
                child: DevToolsClearableTextField(
                  controller: _filterController,
                  hintText: 'Filter logs…',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) =>
                      logsBloc.add(LogsFilterTextChanged(value)),
                ),
              ),
              const SizedBox(width: denseSpacing),
              _LogLevelToggle(state: state),
              const SizedBox(width: denseSpacing),
              DevToolsButton.iconOnly(
                icon: Icons.delete_sweep,
                tooltip: 'Clear logs',
                onPressed: state.entries.isEmpty
                    ? null
                    : () => logsBloc.add(const LogsCleared()),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.isLoadingSnapshot)
                const LinearProgressIndicator(minHeight: 2),
              if (state.hasError && state.error != null)
                Padding(
                  padding: const EdgeInsets.all(densePadding),
                  child: Text(
                    state.error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              Expanded(child: _LogsTable(state: state)),
              if (state.entries.isNotEmpty) _maybeDetails(state),
            ],
          ),
        );
      },
    );
  }
}

Widget _maybeDetails(LogsState state) {
  final selectedId = state.selectedLogId;
  if (state.entries.isEmpty) return const SizedBox.shrink();

  LogEntry? entry;
  if (selectedId != null) {
    entry = state.entries.firstWhereOrNull(
      (element) => element.id == selectedId,
    );
  }
  entry ??= state.filteredEntries.firstOrNull ?? state.entries.firstOrNull;
  if (entry == null) return const SizedBox.shrink();

  return _LogDetailsPane(entry: entry);
}

class _LogLevelToggle extends StatelessWidget {
  const _LogLevelToggle({required this.state});

  final LogsState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LogsBloc>();
    final levels = LogLevel.values;
    final selected = levels
        .map((level) => state.activeLevels.contains(level))
        .toList();
    return DevToolsToggleButtonGroup(
      selectedStates: selected,
      onPressed: (index) => bloc.add(LogsLogLevelToggled(levels[index])),
      children: [
        for (final level in levels)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: densePadding),
            child: Text(level.label),
          ),
      ],
    );
  }
}

class _LogsTable extends StatefulWidget {
  const _LogsTable({required this.state});

  final LogsState state;

  @override
  State<_LogsTable> createState() => _LogsTableState();
}

class _LogsTableState extends State<_LogsTable> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.filteredEntries.isEmpty) {
      return const Center(
        child: Text('No logs yet. Start interacting with the app to populate.'),
      );
    }

    final logsBloc = context.read<LogsBloc>();
    final theme = Theme.of(context);

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: state.filteredEntries.length,
        separatorBuilder: (_, __) => Divider(
          color: theme.dividerColor.withValues(alpha: 0.1),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final entry = state.filteredEntries[index];
          final selected = state.selectedLogId == entry.id;
          final color = _levelColor(entry.level, theme);

          return Material(
            color: selected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
                : Colors.transparent,
            child: InkWell(
              onTap: () => logsBloc.add(LogsSelectionChanged(entry.id)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: defaultSpacing,
                  vertical: densePadding,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        formatTimestamp(entry.timestamp),
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: Text(
                        entry.level.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: entry.isError
                                  ? FontWeight.w600
                                  : null,
                            ),
                          ),
                          const SizedBox(height: densePadding),
                          Wrap(
                            spacing: denseSpacing,
                            runSpacing: densePadding,
                            children: [
                              _LogMetaChip(
                                icon: Icons.category_outlined,
                                label: entry.category,
                              ),
                              if (entry.requestDuration != null)
                                _LogMetaChip(
                                  icon: Icons.timer_outlined,
                                  label: formatDurationShort(
                                    entry.requestDuration!,
                                  ),
                                ),
                              if (entry.appLifetime != null)
                                _LogMetaChip(
                                  icon: Icons.schedule,
                                  label:
                                      '+${formatDurationShort(entry.appLifetime!)}',
                                ),
                              for (final tag in entry.tags.take(3))
                                _LogMetaChip(
                                  icon: Icons.sell_outlined,
                                  label: tag,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Color _levelColor(LogLevel level, ThemeData theme) {
  final scheme = theme.colorScheme;
  switch (level) {
    case LogLevel.trace:
      return scheme.outlineVariant;
    case LogLevel.debug:
      return scheme.primary;
    case LogLevel.info:
      return scheme.secondary;
    case LogLevel.warn:
      return scheme.tertiary;
    case LogLevel.error:
      return scheme.error;
    case LogLevel.fatal:
      return scheme.errorContainer;
  }
}

class _LogMetaChip extends StatelessWidget {
  const _LogMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: densePadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.all(defaultRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: densePadding / 2),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _LogDetailsPane extends StatelessWidget {
  const _LogDetailsPane({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(defaultSpacing),
      child: RoundedOutlinedBorder(
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.message,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  DevToolsButton.iconOnly(
                    icon: Icons.copy_outlined,
                    tooltip: 'Copy log',
                    onPressed: () => extensionManager.copyToClipboard(
                      entry.message,
                      successMessage: 'Log copied to clipboard',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: denseSpacing),
              Wrap(
                spacing: defaultSpacing,
                runSpacing: denseSpacing,
                children: [
                  _DetailField(
                    'Timestamp',
                    dateTimeFormat.format(entry.timestamp),
                  ),
                  _DetailField('Level', entry.level.label),
                  _DetailField('Category', entry.category),
                  if (entry.isolateId != null)
                    _DetailField('Isolate', entry.isolateId!),
                  if (entry.requestDuration != null)
                    _DetailField(
                      'Duration',
                      formatDurationShort(entry.requestDuration!),
                    ),
                  if (entry.appLifetime != null)
                    _DetailField(
                      'App lifetime',
                      formatDurationShort(entry.appLifetime!),
                    ),
                ],
              ),
              if (entry.metadata.isNotEmpty) ...[
                const SizedBox(height: defaultSpacing),
                Text('Metadata', style: theme.textTheme.titleSmall),
                const SizedBox(height: densePadding),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final key = entry.metadata.keys.elementAt(index);
                    final value = entry.metadata[key];
                    return SelectableText('$key: $value');
                  },
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: densePadding),
                  itemCount: entry.metadata.length,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        SelectableText(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
