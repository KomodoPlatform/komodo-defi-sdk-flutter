part of 'vm_connection_bloc.dart';

abstract class VmConnectionEvent extends Equatable {
  const VmConnectionEvent();

  @override
  List<Object?> get props => const [];
}

class VmConnectionSubscriptionRequested extends VmConnectionEvent {
  const VmConnectionSubscriptionRequested();
}

class _VmConnectionChanged extends VmConnectionEvent {
  const _VmConnectionChanged({required this.connected});

  final bool connected;

  @override
  List<Object?> get props => [connected];
}

class _VmConnectionMetadataRequested extends VmConnectionEvent {
  const _VmConnectionMetadataRequested();
}
