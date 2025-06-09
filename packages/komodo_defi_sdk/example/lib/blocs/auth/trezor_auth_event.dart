part of 'auth_bloc.dart';

/// Event to authenticate with Trezor device
class AuthTrezorSignIn extends AuthEvent {
  const AuthTrezorSignIn({
    required this.walletName,
    required this.derivationMethod,
  });

  final String walletName;
  final DerivationMethod derivationMethod;

  @override
  List<Object?> get props => [walletName, derivationMethod];
}

/// Event to register a new Trezor wallet
class AuthTrezorRegister extends AuthEvent {
  const AuthTrezorRegister({
    required this.walletName,
    required this.derivationMethod,
  });

  final String walletName;
  final DerivationMethod derivationMethod;

  @override
  List<Object?> get props => [walletName, derivationMethod];
}

/// Event to start complete Trezor initialization and authentication flow
class AuthTrezorInitAndAuth extends AuthEvent {
  const AuthTrezorInitAndAuth({
    required this.derivationMethod,
    this.isRegister = false,
  });

  final DerivationMethod derivationMethod;
  final bool isRegister;

  @override
  List<Object?> get props => [derivationMethod, isRegister];
}

/// Event to provide PIN during Trezor initialization
class AuthTrezorProvidePin extends AuthEvent {
  const AuthTrezorProvidePin({required this.taskId, required this.pin});

  final int taskId;
  final String pin;

  @override
  List<Object?> get props => [taskId, pin];
}

/// Event to provide passphrase during Trezor initialization
class AuthTrezorProvidePassphrase extends AuthEvent {
  const AuthTrezorProvidePassphrase({
    required this.taskId,
    required this.passphrase,
  });

  final int taskId;
  final String passphrase;

  @override
  List<Object?> get props => [taskId, passphrase];
}

/// Event to cancel Trezor initialization
class AuthTrezorCancel extends AuthEvent {
  const AuthTrezorCancel({required this.taskId});

  final int taskId;

  @override
  List<Object?> get props => [taskId];
}
