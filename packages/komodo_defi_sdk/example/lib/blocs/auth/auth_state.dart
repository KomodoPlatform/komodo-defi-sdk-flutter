import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when authentication BLoC is first created
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when loading operations are in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({
    this.knownUsers = const [],
    this.selectedUser,
    this.walletName = '',
    this.isHdMode = true,
    this.errorMessage,
  });

  final List<KdfUser> knownUsers;
  final KdfUser? selectedUser;
  final String walletName;
  final bool isHdMode;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        knownUsers,
        selectedUser,
        walletName,
        isHdMode,
        errorMessage,
      ];

  AuthUnauthenticated copyWith({
    List<KdfUser>? knownUsers,
    KdfUser? selectedUser,
    String? walletName,
    bool? isHdMode,
    String? errorMessage,
    bool clearError = false,
    bool clearSelectedUser = false,
  }) {
    return AuthUnauthenticated(
      knownUsers: knownUsers ?? this.knownUsers,
      selectedUser: clearSelectedUser ? null : (selectedUser ?? this.selectedUser),
      walletName: walletName ?? this.walletName,
      isHdMode: isHdMode ?? this.isHdMode,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// State when user is successfully authenticated
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.user,
    this.knownUsers = const [],
  });

  final KdfUser user;
  final List<KdfUser> knownUsers;

  @override
  List<Object?> get props => [user, knownUsers];

  AuthAuthenticated copyWith({
    KdfUser? user,
    List<KdfUser>? knownUsers,
  }) {
    return AuthAuthenticated(
      user: user ?? this.user,
      knownUsers: knownUsers ?? this.knownUsers,
    );
  }
}

/// State when authentication operation fails
class AuthError extends AuthState {
  const AuthError({
    required this.message,
    this.knownUsers = const [],
    this.selectedUser,
    this.walletName = '',
    this.isHdMode = true,
  });

  final String message;
  final List<KdfUser> knownUsers;
  final KdfUser? selectedUser;
  final String walletName;
  final bool isHdMode;

  @override
  List<Object?> get props => [
        message,
        knownUsers,
        selectedUser,
        walletName,
        isHdMode,
      ];
}

/// State when sign out is in progress
class AuthSigningOut extends AuthState {
  const AuthSigningOut();
}

/// State when Trezor initialization is in progress
class AuthTrezorInitializing extends AuthState {
  const AuthTrezorInitializing({
    this.status,
    this.message,
    this.taskId,
  });

  final String? status;
  final String? message;
  final int? taskId;

  @override
  List<Object?> get props => [status, message, taskId];

  AuthTrezorInitializing copyWith({
    String? status,
    String? message,
    int? taskId,
  }) {
    return AuthTrezorInitializing(
      status: status ?? this.status,
      message: message ?? this.message,
      taskId: taskId ?? this.taskId,
    );
  }
}

/// State when Trezor requires PIN input
class AuthTrezorPinRequired extends AuthState {
  const AuthTrezorPinRequired({
    required this.taskId,
    this.message,
  });

  final int taskId;
  final String? message;

  @override
  List<Object?> get props => [taskId, message];
}

/// State when Trezor requires passphrase input
class AuthTrezorPassphraseRequired extends AuthState {
  const AuthTrezorPassphraseRequired({
    required this.taskId,
    this.message,
  });

  final int taskId;
  final String? message;

  @override
  List<Object?> get props => [taskId, message];
}

/// State when Trezor is waiting for device confirmation
class AuthTrezorAwaitingConfirmation extends AuthState {
  const AuthTrezorAwaitingConfirmation({
    required this.taskId,
    this.message,
  });

  final int taskId;
  final String? message;

  @override
  List<Object?> get props => [taskId, message];
}

/// State when Trezor initialization is completed and ready for auth
class AuthTrezorReady extends AuthState {
  const AuthTrezorReady({
    required this.deviceInfo,
    required this.isRegister,
    required this.derivationMethod,
  });

  final dynamic deviceInfo; // TrezorDeviceInfo from the response
  final bool isRegister;
  final DerivationMethod derivationMethod;

  @override
  List<Object?> get props => [deviceInfo, isRegister, derivationMethod];
}
