part of 'vm_connection_bloc.dart';

enum ConnectionStatus { disconnected, connecting, connected }

class VmConnectionState extends Equatable {
  const VmConnectionState({
    required this.status,
    this.connectedAt,
    this.appDescription,
    this.error,
  });

  const VmConnectionState.disconnected()
    : status = ConnectionStatus.disconnected,
      connectedAt = null,
      appDescription = null,
      error = null;

  final ConnectionStatus status;
  final DateTime? connectedAt;
  final String? appDescription;
  final String? error;

  bool get isConnected => status == ConnectionStatus.connected;

  VmConnectionState copyWith({
    ConnectionStatus? status,
    DateTime? connectedAt,
    String? appDescription,
    String? error,
  }) {
    return VmConnectionState(
      status: status ?? this.status,
      connectedAt: connectedAt ?? this.connectedAt,
      appDescription: appDescription ?? this.appDescription,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, connectedAt, appDescription, error];
}
