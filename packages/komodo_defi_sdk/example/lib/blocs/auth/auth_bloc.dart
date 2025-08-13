import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'trezor_auth_event.dart';
part 'trezor_auth_mixin.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> with TrezorAuthMixin {
  AuthBloc({required KomodoDefiSdk sdk})
    : _sdk = sdk,
      super(AuthState.initial()) {
    on<AuthKnownUsersFetched>(_onFetchKnownUsers);
    on<AuthSignedIn>(_onSignIn);
    on<AuthSignedOut>(_onSignOut);
    on<AuthRegistered>(_onRegister);
    on<AuthKnownUserSelected>(_onSelectKnownUser);
    on<AuthErrorCleared>(_onClearError);
    on<AuthStateReset>(_onReset);
    on<AuthInitialStateChecked>(_onCheckInitialState);
    on<AuthStateChangesStarted>(_onStartListeningToAuthStateChanges);

    // Setup Trezor handlers from mixin
    setupTrezorEventHandlers();
  }

  @override
  final KomodoDefiSdk _sdk;

  Future<void> _onFetchKnownUsers(
    AuthKnownUsersFetched event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final users = await _sdk.auth.getUsers();

      if (state.status == AuthStatus.unauthenticated) {
        emit(state.copyWith(knownUsers: users));
      } else if (state.status == AuthStatus.authenticated) {
        emit(state.copyWith(knownUsers: users));
      } else {
        emit(AuthState.unauthenticated(knownUsers: users));
      }
    } catch (e) {
      debugPrint('Error fetching known users: $e');
      // Don't emit error state for this, just log it
      // as it's not critical to the authentication flow
    }
  }

  Future<void> _onCheckInitialState(
    AuthInitialStateChecked event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentUser = await _sdk.auth.currentUser;
      final knownUsers = await _fetchKnownUsers();

      if (currentUser != null) {
        emit(
          AuthState.authenticated(user: currentUser, knownUsers: knownUsers),
        );
        // Start listening to auth state changes after confirming authentication
        add(const AuthStateChangesStarted());
      } else {
        emit(AuthState.unauthenticated(knownUsers: knownUsers));
      }
    } catch (e) {
      final knownUsers = await _fetchKnownUsers();
      emit(
        AuthState.error(
          message: 'Failed to check initial auth state: $e',
          knownUsers: knownUsers,
        ),
      );
    }
  }

  Future<void> _onSignIn(AuthSignedIn event, Emitter<AuthState> emit) async {
    emit(AuthState.loading());

    try {
      final user = await _sdk.auth.signIn(
        walletName: event.walletName,
        password: event.password,
        options: AuthOptions(
          derivationMethod: event.derivationMethod,
          privKeyPolicy: event.privKeyPolicy,
        ),
      );

      // Fetch updated known users after successful sign-in
      final knownUsers = await _fetchKnownUsers();

      emit(AuthState.authenticated(user: user, knownUsers: knownUsers));

      // Start listening to auth state changes after successful sign-in
      add(const AuthStateChangesStarted());
    } on AuthException catch (e) {
      emit(
        AuthState.error(
          message: 'Auth Error: ${e.message}',
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsers(),
        ),
      );
    } catch (e) {
      emit(
        AuthState.error(
          message: 'Unexpected error: $e',
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsers(),
        ),
      );
    }
  }

  Future<void> _onSignOut(AuthSignedOut event, Emitter<AuthState> emit) async {
    emit(AuthState.signingOut());

    try {
      await _sdk.auth.signOut();

      final knownUsers = await _fetchKnownUsers();
      emit(AuthState.unauthenticated(knownUsers: knownUsers));
    } catch (e) {
      final knownUsers = await _fetchKnownUsers();
      emit(
        AuthState.error(
          message: 'Error signing out: $e',
          knownUsers: knownUsers,
        ),
      );
    }
  }

  Future<void> _onRegister(
    AuthRegistered event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      final user = await _sdk.auth.register(
        walletName: event.walletName,
        password: event.password,
        options: AuthOptions(
          derivationMethod: event.derivationMethod,
          privKeyPolicy: event.privKeyPolicy,
        ),
        mnemonic: event.mnemonic,
      );

      // Fetch updated known users after successful registration
      final knownUsers = await _fetchKnownUsers();

      emit(AuthState.authenticated(user: user, knownUsers: knownUsers));

      // Start listening to auth state changes after successful registration
      add(const AuthStateChangesStarted());
    } on AuthException catch (e) {
      final errorMessage =
          e.type == AuthExceptionType.incorrectPassword
              ? 'HD mode requires a valid BIP39 seed phrase. '
                  'The imported encrypted seed is not compatible.'
              : 'Registration failed: ${e.message}';

      emit(
        AuthState.error(
          message: errorMessage,
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsers(),
        ),
      );
    } catch (e) {
      emit(
        AuthState.error(
          message: 'Registration failed: $e',
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsers(),
        ),
      );
    }
  }

  void _onSelectKnownUser(
    AuthKnownUserSelected event,
    Emitter<AuthState> emit,
  ) {
    if (state.status == AuthStatus.unauthenticated) {
      emit(
        state.copyWith(
          selectedUser: event.user,
          walletName: event.user.walletId.name,
          isHdMode: event.user.isHd,
          clearError: true,
        ),
      );
    } else if (state.status == AuthStatus.error) {
      emit(
        AuthState.unauthenticated(
          knownUsers: state.knownUsers,
          selectedUser: event.user,
          walletName: event.user.walletId.name,
          isHdMode: event.user.isHd,
        ),
      );
    }
  }

  void _onClearError(AuthErrorCleared event, Emitter<AuthState> emit) {
    if (state.status == AuthStatus.error) {
      emit(
        AuthState.unauthenticated(
          knownUsers: state.knownUsers,
          selectedUser: state.selectedUser,
          walletName: state.walletName,
          isHdMode: state.isHdMode,
        ),
      );
    } else if (state.status == AuthStatus.unauthenticated) {
      emit(state.copyWith(clearError: true));
    }
  }

  void _onReset(AuthStateReset event, Emitter<AuthState> emit) {
    emit(AuthState.unauthenticated());
  }

  Future<void> _onStartListeningToAuthStateChanges(
    AuthStateChangesStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await emit.forEach<KdfUser?>(
        _sdk.auth.authStateChanges,
        onData: (user) {
          if (user != null) {
            return AuthState.authenticated(
              user: user,
              knownUsers: state.knownUsers,
            );
          } else {
            return AuthState.unauthenticated(knownUsers: state.knownUsers);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          return AuthState.error(
            message: 'Auth state change error: $error',
            knownUsers: state.knownUsers,
          );
        },
      );
    } catch (e) {
      emit(
        AuthState.error(
          message: 'Failed to start listening to auth state changes: $e',
          knownUsers: state.knownUsers,
        ),
      );
    }
  }

  /// Internal helper method to fetch known users
  @override
  Future<List<KdfUser>> _fetchKnownUsers() async {
    try {
      return await _sdk.auth.getUsers();
    } catch (e) {
      debugPrint('Error fetching known users: $e');
      return [];
    }
  }

  /// Helper method to get current user if authenticated
  KdfUser? get currentUser {
    if (state.status == AuthStatus.authenticated) {
      return state.user;
    }
    return null;
  }

  /// Helper method to check if currently authenticated
  bool get isAuthenticated => state.status == AuthStatus.authenticated;

  /// Helper method to check if currently loading
  bool get isLoading => state.status == AuthStatus.loading;

  /// Helper method to get current error message
  String? get errorMessage {
    if (state.status == AuthStatus.error) {
      return state.errorMessage;
    } else if (state.status == AuthStatus.unauthenticated) {
      return state.errorMessage;
    }
    return null;
  }

  /// Helper method to get known users
  List<KdfUser> get knownUsers {
    return state.knownUsers;
  }

  /// Clean up resources when this bloc is no longer needed
  @override
  Future<void> close() async {
    // Make sure to clean up any subscriptions or resources
    // Not disposing the SDK here as it should be managed by the app
    await super.close();
  }
}
