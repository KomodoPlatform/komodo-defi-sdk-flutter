import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_state.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.instance}) : super(const AuthInitial()) {
    on<AuthFetchKnownUsers>(_onFetchKnownUsers);
    on<AuthSignIn>(_onSignIn);
    on<AuthSignOut>(_onSignOut);
    on<AuthRegister>(_onRegister);
    on<AuthSelectKnownUser>(_onSelectKnownUser);
    on<AuthClearError>(_onClearError);
    on<AuthReset>(_onReset);
    on<AuthTrezorSignIn>(_onTrezorSignIn);
    on<AuthTrezorRegister>(_onTrezorRegister);
    on<AuthTrezorInitAndAuth>(_onTrezorInitAndAuth);
    on<AuthTrezorProvidePin>(_onTrezorProvidePin);
    on<AuthTrezorProvidePassphrase>(_onTrezorProvidePassphrase);
    on<AuthTrezorCancel>(_onTrezorCancel);
  }

  final KdfInstanceState instance;

  // Track active Trezor initialization streams
  StreamSubscription<TrezorInitializationState>? _trezorSubscription;
  static const String _trezorWalletName = 'My Trezor';

  Future<void> _onFetchKnownUsers(
    AuthFetchKnownUsers event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final users = await instance.sdk.auth.getUsers();

      if (state is AuthUnauthenticated) {
        final currentState = state as AuthUnauthenticated;
        emit(currentState.copyWith(knownUsers: users));
      } else if (state is AuthAuthenticated) {
        final currentState = state as AuthAuthenticated;
        emit(currentState.copyWith(knownUsers: users));
      } else {
        emit(AuthUnauthenticated(knownUsers: users));
      }
    } catch (e) {
      debugPrint('Error fetching known users: $e');
      // Don't emit error state for this, just log it
      // as it's not critical to the authentication flow
    }
  }

  Future<void> _onSignIn(AuthSignIn event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final user = await instance.sdk.auth.signIn(
        walletName: event.walletName,
        password: event.password,
        options: AuthOptions(
          derivationMethod: event.derivationMethod,
          privKeyPolicy: event.privKeyPolicy,
        ),
      );

      // Fetch updated known users after successful sign-in
      final knownUsers = await _fetchKnownUsersInternal();

      emit(AuthAuthenticated(user: user, knownUsers: knownUsers));
    } on AuthException catch (e) {
      emit(
        AuthError(
          message: 'Auth Error: ${e.message}',
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    } catch (e) {
      emit(
        AuthError(
          message: 'Unexpected error: $e',
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    }
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    emit(const AuthSigningOut());

    try {
      await instance.sdk.auth.signOut();

      final knownUsers = await _fetchKnownUsersInternal();
      emit(AuthUnauthenticated(knownUsers: knownUsers));
    } catch (e) {
      final knownUsers = await _fetchKnownUsersInternal();
      emit(AuthError(message: 'Error signing out: $e', knownUsers: knownUsers));
    }
  }

  Future<void> _onRegister(AuthRegister event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final user = await instance.sdk.auth.register(
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

      emit(AuthAuthenticated(user: user, knownUsers: knownUsers));
    } on AuthException catch (e) {
      final errorMessage =
          e.type == AuthExceptionType.incorrectPassword
              ? 'HD mode requires a valid BIP39 seed phrase. The imported encrypted seed is not compatible.'
              : 'Registration failed: ${e.message}';

      emit(
        AuthError(
          message: errorMessage,
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    } catch (e) {
      emit(
        AuthError(
          message: 'Registration failed: $e',
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    }
  }

  void _onSelectKnownUser(AuthSelectKnownUser event, Emitter<AuthState> emit) {
    if (state is AuthUnauthenticated) {
      final currentState = state as AuthUnauthenticated;
      emit(
        currentState.copyWith(
          selectedUser: event.user,
          walletName: event.user.walletId.name,
          isHdMode:
              event.user.authOptions.derivationMethod ==
              DerivationMethod.hdWallet,
          clearError: true,
        ),
      );
    } else if (state is AuthError) {
      final currentState = state as AuthError;
      emit(
        AuthUnauthenticated(
          knownUsers: currentState.knownUsers,
          selectedUser: event.user,
          walletName: event.user.walletId.name,
          isHdMode:
              event.user.authOptions.derivationMethod ==
              DerivationMethod.hdWallet,
        ),
      );
    }
  }

  void _onClearError(AuthClearError event, Emitter<AuthState> emit) {
    if (state is AuthError) {
      final currentState = state as AuthError;
      emit(
        AuthUnauthenticated(
          knownUsers: currentState.knownUsers,
          selectedUser: currentState.selectedUser,
          walletName: currentState.walletName,
          isHdMode: currentState.isHdMode,
        ),
      );
    } else if (state is AuthUnauthenticated) {
      final currentState = state as AuthUnauthenticated;
      emit(currentState.copyWith(clearError: true));
    }
  }

  void _onReset(AuthReset event, Emitter<AuthState> emit) {
    emit(const AuthUnauthenticated());
  }

  /// Internal helper method to fetch known users
  Future<List<KdfUser>> _fetchKnownUsersInternal() async {
    try {
      return await instance.sdk.auth.getUsers();
    } catch (e) {
      debugPrint('Error fetching known users: $e');
      return [];
    }
  }

  /// Helper method to get current user if authenticated
  KdfUser? get currentUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  /// Helper method to check if currently authenticated
  bool get isAuthenticated => state is AuthAuthenticated;

  /// Helper method to check if currently loading
  bool get isLoading => state is AuthLoading;

  /// Helper method to get current error message
  String? get errorMessage {
    final currentState = state;
    if (currentState is AuthError) {
      return currentState.message;
    } else if (currentState is AuthUnauthenticated) {
      return currentState.errorMessage;
    }
    return null;
  }

  /// Helper method to get known users
  List<KdfUser> get knownUsers {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.knownUsers;
    } else if (currentState is AuthUnauthenticated) {
      return currentState.knownUsers;
    } else if (currentState is AuthError) {
      return currentState.knownUsers;
    }
    return [];
  }

  Future<void> _onTrezorSignIn(
    AuthTrezorSignIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await instance.sdk.auth.signIn(
        walletName: event.walletName,
        password: '', // Trezor doesn't require password
        options: AuthOptions(
          derivationMethod: event.derivationMethod,
          privKeyPolicy: PrivateKeyPolicy.trezor,
        ),
      );

      // Fetch updated known users after successful sign-in
      final knownUsers = await _fetchKnownUsersInternal();

      emit(AuthAuthenticated(user: user, knownUsers: knownUsers));
    } on AuthException catch (e) {
      emit(
        AuthError(
          message: 'Trezor Auth Error: ${e.message}',
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    } catch (e) {
      emit(
        AuthError(
          message: 'Trezor authentication failed: $e',
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    }
  }

  Future<void> _onTrezorRegister(
    AuthTrezorRegister event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await instance.sdk.auth.register(
        walletName: event.walletName,
        password: '', // Trezor doesn't require password
        options: AuthOptions(
          derivationMethod: event.derivationMethod,
          privKeyPolicy: PrivateKeyPolicy.trezor,
        ),
        mnemonic: null, // Trezor handles seed internally
      );

      // Fetch updated known users after successful registration
      final knownUsers = await _fetchKnownUsersInternal();

      emit(AuthAuthenticated(user: user, knownUsers: knownUsers));
    } on AuthException catch (e) {
      emit(
        AuthError(
          message: 'Trezor registration failed: ${e.message}',
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    } catch (e) {
      emit(
        AuthError(
          message: 'Trezor registration failed: $e',
          walletName: event.walletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    }
  }

  Future<void> _onTrezorInitAndAuth(
    AuthTrezorInitAndAuth event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Step 1: Create a temporary wallet with random password to enable Trezor initialization
      emit(
        const AuthTrezorInitializing(
          status: 'preparing',
          message: 'Preparing wallet for Trezor initialization...',
        ),
      );

      final tempPassword = SecurityUtils.generatePasswordSecure(16);

      // Check if "My Trezor" wallet already exists
      final knownUsers = await _fetchKnownUsersInternal();
      final existingTrezorUser =
          knownUsers
              .where(
                (user) =>
                    user.walletId.name == _trezorWalletName &&
                    user.authOptions.privKeyPolicy == PrivateKeyPolicy.trezor,
              )
              .firstOrNull;

      if (existingTrezorUser != null && !event.isRegister) {
        // Sign in to existing Trezor wallet
        await instance.sdk.auth.signIn(
          walletName: _trezorWalletName,
          password: tempPassword,
          options: AuthOptions(
            derivationMethod: event.derivationMethod,
            privKeyPolicy: PrivateKeyPolicy.trezor,
          ),
        );
      } else {
        // Register new Trezor wallet
        await instance.sdk.auth.register(
          walletName: _trezorWalletName,
          password: tempPassword,
          options: AuthOptions(
            derivationMethod: event.derivationMethod,
            privKeyPolicy: PrivateKeyPolicy.trezor,
          ),
          mnemonic: null, // Trezor handles seed internally
        );
      }

      // Step 2: Initialize Trezor device
      emit(
        const AuthTrezorInitializing(
          status: 'initializing',
          message: 'Initializing Trezor device...',
        ),
      );

      // Cancel any existing subscription
      await _trezorSubscription?.cancel();

      // Start Trezor initialization
      _trezorSubscription = instance.sdk.trezor.initializeDevice().listen(
        (state) => _handleTrezorInitializationState(state, event, emit),
        onError:
            (Object error) => _handleTrezorInitializationError(error, emit),
      );
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to prepare Trezor initialization: $e',
          walletName: _trezorWalletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    }
  }

  void _handleTrezorInitializationState(
    TrezorInitializationState state,
    AuthTrezorInitAndAuth event,
    Emitter<AuthState> emit,
  ) {
    switch (state.status) {
      case TrezorInitializationStatus.initializing:
        emit(
          AuthTrezorInitializing(
            status: 'initializing',
            message: state.message ?? 'Initializing Trezor device...',
            taskId: state.taskId,
          ),
        );

      case TrezorInitializationStatus.waitingForDevice:
        emit(
          AuthTrezorInitializing(
            status: 'waiting_device',
            message: state.message ?? 'Waiting for Trezor device connection...',
            taskId: state.taskId,
          ),
        );

      case TrezorInitializationStatus.waitingForDeviceConfirmation:
        emit(
          AuthTrezorAwaitingConfirmation(
            taskId: state.taskId!,
            message:
                state.message ??
                'Please follow instructions on your Trezor device',
          ),
        );

      case TrezorInitializationStatus.pinRequired:
        emit(
          AuthTrezorPinRequired(
            taskId: state.taskId!,
            message: state.message ?? 'Please enter your Trezor PIN',
          ),
        );

      case TrezorInitializationStatus.passphraseRequired:
        emit(
          AuthTrezorPassphraseRequired(
            taskId: state.taskId!,
            message: state.message ?? 'Please enter your Trezor passphrase',
          ),
        );

      case TrezorInitializationStatus.completed:
        emit(
          AuthTrezorReady(
            deviceInfo: state.deviceInfo,
            isRegister: event.isRegister,
            derivationMethod: event.derivationMethod,
          ),
        );
        _performTrezorAuthentication(event, emit);

      case TrezorInitializationStatus.error:
        emit(
          AuthError(
            message: 'Trezor initialization failed: ${state.error}',
            walletName: _trezorWalletName,
            isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
            knownUsers: const [],
          ),
        );

      case TrezorInitializationStatus.cancelled:
        emit(
          AuthError(
            message: 'Trezor initialization was cancelled',
            walletName: _trezorWalletName,
            isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
            knownUsers: const [],
          ),
        );
    }
  }

  void _handleTrezorInitializationError(Object error, Emitter<AuthState> emit) {
    emit(
      AuthError(
        message: 'Trezor initialization error: $error',
        walletName: _trezorWalletName,
        isHdMode: true,
        knownUsers: const [],
      ),
    );
  }

  Future<void> _performTrezorAuthentication(
    AuthTrezorInitAndAuth event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // The Trezor wallet should already be registered/signed in from the prep step
      // Just fetch the updated known users and emit authenticated state
      final knownUsers = await _fetchKnownUsersInternal();
      final trezorUser =
          knownUsers
              .where(
                (user) =>
                    user.walletId.name == _trezorWalletName &&
                    user.authOptions.privKeyPolicy == PrivateKeyPolicy.trezor,
              )
              .first;

      emit(AuthAuthenticated(user: trezorUser, knownUsers: knownUsers));
    } catch (e) {
      emit(
        AuthError(
          message: 'Trezor authentication failed: $e',
          walletName: _trezorWalletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    }
  }

  Future<void> _onTrezorProvidePin(
    AuthTrezorProvidePin event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await instance.sdk.trezor.providePin(event.taskId, event.pin);
      // State updates will come through the stream
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to provide PIN: $e',
          walletName: _trezorWalletName,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    }
  }

  Future<void> _onTrezorProvidePassphrase(
    AuthTrezorProvidePassphrase event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await instance.sdk.trezor.providePassphrase(
        event.taskId,
        event.passphrase,
      );
      // State updates will come through the stream
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to provide passphrase: $e',
          walletName: _trezorWalletName,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    }
  }

  Future<void> _onTrezorCancel(
    AuthTrezorCancel event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await instance.sdk.trezor.cancelInitialization(event.taskId);
      await _trezorSubscription?.cancel();
      _trezorSubscription = null;

      emit(AuthUnauthenticated(knownUsers: await _fetchKnownUsersInternal()));
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to cancel Trezor initialization: $e',
          walletName: _trezorWalletName,
          knownUsers: await _fetchKnownUsersInternal(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _trezorSubscription?.cancel();
    return super.close();
  }
}
