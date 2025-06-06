import 'package:equatable/equatable.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch all known users from the SDK
class AuthFetchKnownUsers extends AuthEvent {
  const AuthFetchKnownUsers();
}

/// Event to sign in with credentials
class AuthSignIn extends AuthEvent {
  const AuthSignIn({
    required this.walletName,
    required this.password,
    required this.derivationMethod,
    this.privKeyPolicy = PrivateKeyPolicy.contextPrivKey,
  });

  final String walletName;
  final String password;
  final DerivationMethod derivationMethod;
  final PrivateKeyPolicy privKeyPolicy;

  @override
  List<Object?> get props => [walletName, password, derivationMethod, privKeyPolicy];
}

/// Event to sign out the current user
class AuthSignOut extends AuthEvent {
  const AuthSignOut();
}

/// Event to register a new user
class AuthRegister extends AuthEvent {
  const AuthRegister({
    required this.walletName,
    required this.password,
    required this.derivationMethod,
    this.mnemonic,
    this.privKeyPolicy = PrivateKeyPolicy.contextPrivKey,
  });

  final String walletName;
  final String password;
  final DerivationMethod derivationMethod;
  final Mnemonic? mnemonic;
  final PrivateKeyPolicy privKeyPolicy;

  @override
  List<Object?> get props => [walletName, password, derivationMethod, mnemonic, privKeyPolicy];
}

/// Event to select a known user and populate form fields
class AuthSelectKnownUser extends AuthEvent {
  const AuthSelectKnownUser(this.user);

  final KdfUser user;

  @override
  List<Object?> get props => [user];
}

/// Event to clear any authentication errors
class AuthClearError extends AuthEvent {
  const AuthClearError();
}

/// Event to reset authentication state
class AuthReset extends AuthEvent {
  const AuthReset();
}

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
  const AuthTrezorProvidePin({
    required this.taskId,
    required this.pin,
  });

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
  const AuthTrezorCancel({
    required this.taskId,
  });

  final int taskId;

  @override
  List<Object?> get props => [taskId];
}
