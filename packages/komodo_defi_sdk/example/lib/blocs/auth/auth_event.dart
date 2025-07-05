part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch all known users from the SDK
class AuthKnownUsersFetched extends AuthEvent {
  const AuthKnownUsersFetched();
}

/// Event to sign in with credentials
class AuthSignedIn extends AuthEvent {
  const AuthSignedIn({
    required this.walletName,
    required this.password,
    required this.derivationMethod,
    this.privKeyPolicy = const PrivateKeyPolicy.contextPrivKey(),
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
class AuthSignedOut extends AuthEvent {
  const AuthSignedOut();
}

/// Event to register a new user
class AuthRegistered extends AuthEvent {
  const AuthRegistered({
    required this.walletName,
    required this.password,
    required this.derivationMethod,
    this.mnemonic,
    this.privKeyPolicy = const PrivateKeyPolicy.contextPrivKey(),
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
class AuthKnownUserSelected extends AuthEvent {
  const AuthKnownUserSelected(this.user);

  final KdfUser user;

  @override
  List<Object?> get props => [user];
}

/// Event to clear any authentication errors
class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}

/// Event to reset authentication state
class AuthStateReset extends AuthEvent {
  const AuthStateReset();
}

/// Event to start listening to auth state changes
class AuthStateChangesStarted extends AuthEvent {
  const AuthStateChangesStarted();
}

class AuthInitialStateChecked extends AuthEvent {
  const AuthInitialStateChecked();

  @override
  List<Object?> get props => [];
}
