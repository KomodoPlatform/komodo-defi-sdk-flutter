import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Represents the current state of an authentication process
class AuthenticationState extends Equatable {
  const AuthenticationState({
    required this.status,
    this.message,
    this.taskId,
    this.error,
    this.user,
  });

  factory AuthenticationState.completed(KdfUser user) =>
      AuthenticationState(status: AuthenticationStatus.completed, user: user);

  factory AuthenticationState.error(String error) =>
      AuthenticationState(status: AuthenticationStatus.error, error: error);

  final AuthenticationStatus status;
  final String? message;
  final int? taskId;
  final String? error;
  final KdfUser? user;

  AuthenticationState copyWith({
    AuthenticationStatus? status,
    String? message,
    int? taskId,
    String? error,
    KdfUser? user,
  }) {
    return AuthenticationState(
      status: status ?? this.status,
      message: message ?? this.message,
      taskId: taskId ?? this.taskId,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, message, taskId, error, user];
}

/// General authentication status that can be used for any wallet type
enum AuthenticationStatus {
  initializing,
  waitingForDevice,
  waitingForDeviceConfirmation,
  pinRequired,
  passphraseRequired,
  authenticating,
  completed,
  error,
  cancelled,
}
