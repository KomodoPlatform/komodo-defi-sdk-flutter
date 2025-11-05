part of 'logs_bloc.dart';

abstract class LogsEvent extends Equatable {
  const LogsEvent();

  @override
  List<Object?> get props => const [];
}

class LogsSubscriptionRequested extends LogsEvent {
  const LogsSubscriptionRequested();
}

class _LogsEntriesAdded extends LogsEvent {
  const _LogsEntriesAdded(this.update);

  final LogsStreamEvent update;

  @override
  List<Object?> get props => [update];
}

class LogsFilterTextChanged extends LogsEvent {
  const LogsFilterTextChanged(this.filterText);

  final String filterText;

  @override
  List<Object?> get props => [filterText];
}

class LogsLogLevelToggled extends LogsEvent {
  const LogsLogLevelToggled(this.level);

  final LogLevel level;

  @override
  List<Object?> get props => [level];
}

class LogsCleared extends LogsEvent {
  const LogsCleared();
}

class LogsSnapshotRequested extends LogsEvent {
  const LogsSnapshotRequested();
}

class LogsSelectionChanged extends LogsEvent {
  const LogsSelectionChanged(this.logId);

  final String? logId;

  @override
  List<Object?> get props => [logId];
}
