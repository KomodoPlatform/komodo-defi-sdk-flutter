part of 'auth_bloc.dart';

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
  List<Object?> get props => [
    walletName,
    password,
    derivationMethod,
    privKeyPolicy,
  ];
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
  List<Object?> get props => [
    walletName,
    password,
    derivationMethod,
    mnemonic,
    privKeyPolicy,
  ];
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

/// Event to start listening to auth state changes
class AuthStartListeningToAuthStateChanges extends AuthEvent {
  const AuthStartListeningToAuthStateChanges();
}
