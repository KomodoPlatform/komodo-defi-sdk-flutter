import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

part 'auth_state.freezed.dart';

/// Represents the current state of an authentication process
@freezed
abstract class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState({
    required AuthenticationStatus status,
    String? message,
    int? taskId,
    String? error,
    KdfUser? user,
  }) = _AuthenticationState;

  factory AuthenticationState.completed(KdfUser user) =>
      AuthenticationState(status: AuthenticationStatus.completed, user: user);

  factory AuthenticationState.error(String error) =>
      AuthenticationState(status: AuthenticationStatus.error, error: error);
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
