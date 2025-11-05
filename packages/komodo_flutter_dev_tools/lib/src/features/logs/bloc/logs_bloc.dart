import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/constants.dart';
import '../../../data/devtools_data_bridge.dart';
import '../../../data/models/log_entry.dart';

part 'logs_event.dart';
part 'logs_state.dart';

class LogsBloc extends Bloc<LogsEvent, LogsState> {
  LogsBloc(this._bridge) : super(LogsState.initial()) {
    on<LogsSubscriptionRequested>(_onSubscriptionRequested);
    on<_LogsEntriesAdded>(_onEntriesAdded);
    on<LogsFilterTextChanged>(_onFilterTextChanged);
    on<LogsLogLevelToggled>(_onLogLevelToggled);
    on<LogsCleared>(_onLogsCleared);
    on<LogsSnapshotRequested>(_onSnapshotRequested);
    on<LogsSelectionChanged>(_onSelectionChanged);
  }

  final DevToolsDataBridge _bridge;
  final Map<String, LogEntry> _entries = {};
  StreamSubscription<LogsStreamEvent>? _logSubscription;

  Future<void> _onSubscriptionRequested(
    LogsSubscriptionRequested event,
    Emitter<LogsState> emit,
  ) async {
    await _logSubscription?.cancel();
    _logSubscription = _bridge.logStream.listen((update) {
      add(_LogsEntriesAdded(update));
    });
  }

  void _onEntriesAdded(_LogsEntriesAdded event, Emitter<LogsState> emit) {
    for (final entry in event.update.entries) {
      _entries[entry.id] = entry;
    }

    while (_entries.length > KomodoDevToolsConstants.maxRetainedLogs) {
      _entries.remove(_entries.keys.first);
    }

    final entries = List<LogEntry>.unmodifiable(_entries.values);
    final filtered = _applyFilters(
      entries,
      state.filterText,
      state.activeLevels,
    );

    emit(
      state.copyWith(
        entries: entries,
        filteredEntries: filtered,
        lastSnapshotAt: event.update.isSnapshot
            ? DateTime.now()
            : state.lastSnapshotAt,
        error: null,
      ),
    );
  }

  void _onFilterTextChanged(
    LogsFilterTextChanged event,
    Emitter<LogsState> emit,
  ) {
    final filtered = _applyFilters(
      state.entries,
      event.filterText,
      state.activeLevels,
    );
    emit(
      state.copyWith(filterText: event.filterText, filteredEntries: filtered),
    );
  }

  void _onLogLevelToggled(LogsLogLevelToggled event, Emitter<LogsState> emit) {
    final updatedLevels = Set<LogLevel>.from(state.activeLevels);
    if (updatedLevels.contains(event.level)) {
      if (updatedLevels.length == 1) {
        // Ensure at least one level remains active.
        return;
      }
      updatedLevels.remove(event.level);
    } else {
      updatedLevels.add(event.level);
    }

    final filtered = _applyFilters(
      state.entries,
      state.filterText,
      updatedLevels,
    );
    emit(
      state.copyWith(activeLevels: updatedLevels, filteredEntries: filtered),
    );
  }

  void _onLogsCleared(LogsCleared event, Emitter<LogsState> emit) {
    _entries.clear();
    emit(state.copyWith(entries: const [], filteredEntries: const []));
  }

  Future<void> _onSnapshotRequested(
    LogsSnapshotRequested event,
    Emitter<LogsState> emit,
  ) async {
    emit(state.copyWith(isLoadingSnapshot: true, error: null));
    try {
      await _bridge.fetchLogSnapshot();
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
    } finally {
      emit(state.copyWith(isLoadingSnapshot: false));
    }
  }

  void _onSelectionChanged(
    LogsSelectionChanged event,
    Emitter<LogsState> emit,
  ) {
    emit(state.copyWith(selectedLogId: event.logId));
  }

  List<LogEntry> _applyFilters(
    List<LogEntry> entries,
    String filterText,
    Set<LogLevel> activeLevels,
  ) {
    final query = filterText.trim().toLowerCase();
    if (query.isEmpty) {
      return entries
          .where((entry) => activeLevels.contains(entry.level))
          .toList(growable: false);
    }

    return entries
        .where((entry) {
          if (!activeLevels.contains(entry.level)) {
            return false;
          }
          if (entry.message.toLowerCase().contains(query)) {
            return true;
          }
          if (entry.category.toLowerCase().contains(query)) {
            return true;
          }
          if (entry.tags.any((tag) => tag.toLowerCase().contains(query))) {
            return true;
          }
          return entry.metadata.entries.any(
            (element) =>
                element.key.toLowerCase().contains(query) ||
                element.value?.toString().toLowerCase().contains(query) == true,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<void> close() async {
    await _logSubscription?.cancel();
    return super.close();
  }
}
