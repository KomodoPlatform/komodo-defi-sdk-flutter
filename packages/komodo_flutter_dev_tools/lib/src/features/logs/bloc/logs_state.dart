part of 'logs_bloc.dart';

class LogsState extends Equatable {
  static const _noValue = Object();

  const LogsState({
    required this.entries,
    required this.filteredEntries,
    required this.activeLevels,
    required this.filterText,
    required this.isLoadingSnapshot,
    required this.lastSnapshotAt,
    required this.selectedLogId,
    required this.error,
  });

  factory LogsState.initial() => LogsState(
    entries: const [],
    filteredEntries: const [],
    activeLevels: LogLevel.values.toSet(),
    filterText: '',
    isLoadingSnapshot: false,
    lastSnapshotAt: null,
    selectedLogId: null,
    error: null,
  );

  final List<LogEntry> entries;
  final List<LogEntry> filteredEntries;
  final Set<LogLevel> activeLevels;
  final String filterText;
  final bool isLoadingSnapshot;
  final DateTime? lastSnapshotAt;
  final String? selectedLogId;
  final String? error;

  bool get hasError => error != null;

  LogsState copyWith({
    List<LogEntry>? entries,
    List<LogEntry>? filteredEntries,
    Set<LogLevel>? activeLevels,
    String? filterText,
    bool? isLoadingSnapshot,
    DateTime? lastSnapshotAt,
    String? selectedLogId,
    Object? error = _noValue,
  }) {
    return LogsState(
      entries: entries ?? this.entries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      activeLevels: activeLevels ?? this.activeLevels,
      filterText: filterText ?? this.filterText,
      isLoadingSnapshot: isLoadingSnapshot ?? this.isLoadingSnapshot,
      lastSnapshotAt: lastSnapshotAt ?? this.lastSnapshotAt,
      selectedLogId: selectedLogId ?? this.selectedLogId,
      error: identical(error, _noValue) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [
    entries,
    filteredEntries,
    activeLevels,
    filterText,
    isLoadingSnapshot,
    lastSnapshotAt,
    selectedLogId,
    error,
  ];
}
