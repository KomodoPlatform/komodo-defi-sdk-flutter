part of 'auth_bloc.dart';

/// Event to authenticate with Trezor device
class AuthTrezorSignedIn extends AuthEvent {
  const AuthTrezorSignedIn({
    required this.walletName,
    required this.derivationMethod,
  });

  final String walletName;
  final DerivationMethod derivationMethod;

  @override
  List<Object?> get props => [walletName, derivationMethod];
}

/// Event to register a new Trezor wallet
class AuthTrezorRegistered extends AuthEvent {
  const AuthTrezorRegistered({
    required this.walletName,
    required this.derivationMethod,
  });

  final String walletName;
  final DerivationMethod derivationMethod;

  @override
  List<Object?> get props => [walletName, derivationMethod];
}

/// Event to start complete Trezor initialization and authentication flow
class AuthTrezorInitAndAuthStarted extends AuthEvent {
  const AuthTrezorInitAndAuthStarted({
    required this.derivationMethod,
    this.isRegister = false,
  });

  final DerivationMethod derivationMethod;
  final bool isRegister;

  @override
  List<Object?> get props => [derivationMethod, isRegister];
}

/// Event to provide PIN during Trezor initialization
class AuthTrezorPinProvided extends AuthEvent {
  const AuthTrezorPinProvided({required this.taskId, required this.pin});

  final int taskId;
  final String pin;

  @override
  List<Object?> get props => [taskId, pin];
}

/// Event to provide passphrase during Trezor initialization
class AuthTrezorPassphraseProvided extends AuthEvent {
  const AuthTrezorPassphraseProvided({
    required this.taskId,
    required this.passphrase,
  });

  final int taskId;
  final String passphrase;

  @override
  List<Object?> get props => [taskId, passphrase];
}

/// Event to cancel Trezor initialization
class AuthTrezorCancelled extends AuthEvent {
  const AuthTrezorCancelled({required this.taskId});

  final int taskId;

  @override
  List<Object?> get props => [taskId];
}
