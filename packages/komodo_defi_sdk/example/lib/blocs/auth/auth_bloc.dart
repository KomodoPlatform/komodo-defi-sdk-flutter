import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'trezor_auth_mixin.dart';
part 'trezor_auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> with TrezorAuthMixin {
  AuthBloc({required KomodoDefiSdk sdk})
    : _sdk = sdk,
      super(AuthState.initial()) {
    on<AuthFetchKnownUsers>(_onFetchKnownUsers);
    on<AuthSignIn>(_onSignIn);
    on<AuthSignOut>(_onSignOut);
    on<AuthRegister>(_onRegister);
    on<AuthSelectKnownUser>(_onSelectKnownUser);
    on<AuthClearError>(_onClearError);
    on<AuthReset>(_onReset);

    // Setup Trezor handlers from mixin
    setupTrezorEventHandlers();
  }

  @override
  final KomodoDefiSdk _sdk;

  @override
  Future<List<KdfUser>> fetchKnownUsersInternal() => _fetchKnownUsersInternal();

  Future<void> _onFetchKnownUsers(
    AuthFetchKnownUsers event,
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

  Future<void> _onSignIn(AuthSignIn event, Emitter<AuthState> emit) async {
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
      final knownUsers = await _fetchKnownUsersInternal();

      emit(AuthState.authenticated(user: user, knownUsers: knownUsers));
    } on AuthException catch (e) {
      emit(
        AuthState.error(
          message: 'Auth Error: ${e.message}',
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    } catch (e) {
      emit(
        AuthState.error(
          message: 'Unexpected error: $e',
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    }
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    emit(AuthState.signingOut());

    try {
      await _sdk.auth.signOut();

      final knownUsers = await _fetchKnownUsersInternal();
      emit(AuthState.unauthenticated(knownUsers: knownUsers));
    } catch (e) {
      final knownUsers = await _fetchKnownUsersInternal();
      emit(
        AuthState.error(
          message: 'Error signing out: $e',
          knownUsers: knownUsers,
        ),
      );
    }
  }

  Future<void> _onRegister(AuthRegister event, Emitter<AuthState> emit) async {
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
      final knownUsers = await _fetchKnownUsersInternal();

      emit(AuthState.authenticated(user: user, knownUsers: knownUsers));
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
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    } catch (e) {
      emit(
        AuthState.error(
          message: 'Registration failed: $e',
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    }
  }

  void _onSelectKnownUser(AuthSelectKnownUser event, Emitter<AuthState> emit) {
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

  void _onClearError(AuthClearError event, Emitter<AuthState> emit) {
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

  void _onReset(AuthReset event, Emitter<AuthState> emit) {
    emit(AuthState.unauthenticated());
  }

  /// Internal helper method to fetch known users
  Future<List<KdfUser>> _fetchKnownUsersInternal() async {
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

  @override
  Future<void> close() async {
    await disposeTrezorResources();
    return super.close();
  }
}
