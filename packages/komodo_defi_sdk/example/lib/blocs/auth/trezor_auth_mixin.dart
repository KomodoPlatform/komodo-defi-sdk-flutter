part of 'auth_bloc.dart';

/// Mixin that provides Trezor authentication functionality to AuthBloc
mixin TrezorAuthMixin on Bloc<AuthEvent, AuthState> {
  static const String trezorWalletName = 'My Trezor';
  static const String _trezorPasswordKey = 'trezor_wallet_password';

  // Secure storage instance for persisting Trezor wallet password
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  KomodoDefiSdk get _sdk;

  /// Gets or generates a secure password for the Trezor wallet
  Future<String> _getTrezorPassword({required bool isNewUser}) async {
    final existingPassword = await _secureStorage.read(key: _trezorPasswordKey);

    if (!isNewUser) {
      // For existing users, we must have a stored password
      if (existingPassword == null) {
        throw Exception(
          'Trezor wallet exists but no stored password found. '
          'This may indicate data corruption or the wallet was created '
          'before password persistence was implemented.',
        );
      }
      return existingPassword;
    } else {
      // For new users, generate and store a new password
      if (existingPassword != null) {
        // Password already exists, use it
        return existingPassword;
      }

      final newPassword = SecurityUtils.generatePasswordSecure(16);
      await _secureStorage.write(key: _trezorPasswordKey, value: newPassword);
      return newPassword;
    }
  }

  /// Clears the stored Trezor password (useful for cleanup)
  Future<void> _clearTrezorPassword() async {
    await _secureStorage.delete(key: _trezorPasswordKey);
  }

  /// Sets up all Trezor-related event handlers
  void setupTrezorEventHandlers() {
    on<AuthTrezorInitAndAuthStarted>(_onTrezorInitAndAuth);
    on<AuthTrezorPinProvided>(_onTrezorProvidePin);
    on<AuthTrezorPassphraseProvided>(_onTrezorProvidePassphrase);
    on<AuthTrezorCancelled>(_onTrezorCancel);
  }

  Future<void> _onTrezorInitAndAuth(
    AuthTrezorInitAndAuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Step 1: Sign out if "My Trezor" user is already signed in
      final currentUser = await _sdk.auth.currentUser;
      if (currentUser?.walletId.name == trezorWalletName) {
        emit(
          AuthState.trezorInitializing(
            message: 'Signing out existing Trezor wallet...',
            knownUsers: state.knownUsers,
            walletName: state.walletName,
            isHdMode: state.isHdMode,
          ),
        );

        try {
          await _sdk.auth.signOut();
        } catch (e) {
          // ignore sign out errors
        }
      }

      // Step 2: Determine if this is a new user and get/generate password
      emit(
        AuthState.trezorInitializing(
          message: 'Preparing wallet for Trezor initialization...',
          knownUsers: state.knownUsers,
          walletName: state.walletName,
          isHdMode: state.isHdMode,
        ),
      );

      final knownUsers = await _fetchKnownUsers();
      final existingTrezorUser =
          knownUsers
              .where(
                (user) =>
                    user.walletId.name == trezorWalletName &&
                    user.authOptions.privKeyPolicy == PrivateKeyPolicy.trezor,
              )
              .firstOrNull;

      final isNewUser = existingTrezorUser == null || event.isRegister;

      // Get or generate secure password
      final String password;
      try {
        password = await _getTrezorPassword(isNewUser: isNewUser);
      } catch (e) {
        emit(
          AuthState.error(
            message: e.toString(),
            walletName: trezorWalletName,
            knownUsers: knownUsers,
          ),
        );
        return;
      }

      if (existingTrezorUser != null && !event.isRegister) {
        // Sign in to existing Trezor wallet with stored password
        await _sdk.auth.signIn(
          walletName: trezorWalletName,
          password: password,
          options: const AuthOptions(
            derivationMethod: DerivationMethod.hdWallet,
            privKeyPolicy: PrivateKeyPolicy.trezor,
          ),
        );
      } else {
        // Register new Trezor wallet with generated password
        await _sdk.auth.register(
          walletName: trezorWalletName,
          password: password,
          options: const AuthOptions(
            derivationMethod: DerivationMethod.hdWallet,
            privKeyPolicy: PrivateKeyPolicy.trezor,
          ),
        );
      }

      // Step 2: Initialize Trezor device
      emit(
        AuthState.trezorInitializing(
          message: 'Initializing Trezor device...',
          knownUsers: knownUsers,
          walletName: trezorWalletName,
          isHdMode: event.derivationMethod == DerivationMethod.hdWallet,
        ),
      );

      // Start Trezor initialization and wait for completion
      try {
        await for (final state in _sdk.trezor.initializeDevice()) {
          final authState = _handleTrezorInitializationState(state, event);
          emit(authState);
          if (authState.status == AuthStatus.authenticated) {
            await _performTrezorAuthentication(event, emit);
          }

          // Break the loop when initialization is complete or encounters an error
          if (state.status == TrezorInitializationStatus.completed ||
              state.status == TrezorInitializationStatus.error ||
              state.status == TrezorInitializationStatus.cancelled) {
            break;
          }
        }
      } catch (error) {
        emit(
          AuthState.error(
            message: 'Trezor initialization error: $error',
            walletName: trezorWalletName,
            knownUsers: state.knownUsers,
          ),
        );
      }
    } catch (e) {
      emit(
        AuthState.error(
          message: 'Failed to prepare Trezor initialization: $e',
          walletName: trezorWalletName,
          knownUsers: state.knownUsers,
        ),
      );
    }
  }

  AuthState _handleTrezorInitializationState(
    TrezorInitializationState trezorInitState,
    AuthTrezorInitAndAuthStarted event,
  ) {
    // Avoid emitting duplicate events by checking current AuthState
    final currentTrezorStatus = AuthTrezorStatus.fromTrezorInitializationStatus(
      trezorInitState.status,
    );
    if (state.trezorStatus == currentTrezorStatus) {
      return state;
    }

    switch (trezorInitState.status) {
      case TrezorInitializationStatus.initializing:
        return AuthState.trezorInitializing(
          message: trezorInitState.message ?? 'Initializing Trezor device...',
          taskId: trezorInitState.taskId,
        );

      case TrezorInitializationStatus.waitingForDevice:
        return AuthState.trezorInitializing(
          message:
              trezorInitState.message ??
              'Waiting for Trezor device connection...',
          taskId: trezorInitState.taskId,
        );

      case TrezorInitializationStatus.waitingForDeviceConfirmation:
        return AuthState.trezorAwaitingConfirmation(
          taskId: trezorInitState.taskId!,
          message:
              trezorInitState.message ??
              'Please follow instructions on your Trezor device',
        );

      case TrezorInitializationStatus.pinRequired:
        return AuthState.trezorPinRequired(
          taskId: trezorInitState.taskId!,
          message: trezorInitState.message ?? 'Please enter your Trezor PIN',
        );

      case TrezorInitializationStatus.passphraseRequired:
        return AuthState.trezorPassphraseRequired(
          taskId: trezorInitState.taskId!,
          message:
              trezorInitState.message ?? 'Please enter your Trezor passphrase',
        );

      case TrezorInitializationStatus.completed:
        return AuthState.trezorReady(deviceInfo: trezorInitState.deviceInfo);

      case TrezorInitializationStatus.error:
        return AuthState.error(
          message: 'Trezor initialization failed: ${trezorInitState.error}',
          walletName: trezorWalletName,
        );

      case TrezorInitializationStatus.cancelled:
        return AuthState.error(
          message: 'Trezor initialization was cancelled',
          walletName: trezorWalletName,
        );
    }
  }

  Future<void> _performTrezorAuthentication(
    AuthTrezorInitAndAuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthState.loading());

      // The Trezor wallet should already be registered/signed in from the prep step
      // Just fetch the updated known users and emit authenticated state
      final knownUsers = await _fetchKnownUsers();
      final trezorUser = knownUsers.firstWhere(
        (user) =>
            user.walletId.name == trezorWalletName &&
            user.authOptions.privKeyPolicy == PrivateKeyPolicy.trezor,
        orElse:
            () =>
                throw Exception(
                  'Trezor user not found. The Trezor wallet may not be properly '
                  'registered or the authentication process was incomplete.',
                ),
      );

      emit(AuthState.authenticated(user: trezorUser, knownUsers: knownUsers));
    } catch (e) {
      emit(
        AuthState.error(
          message: 'Trezor authentication failed: $e',
          walletName: trezorWalletName,
          knownUsers: await _fetchKnownUsers(),
        ),
      );
    }
  }

  Future<void> _onTrezorProvidePin(
    AuthTrezorPinProvided event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _sdk.trezor.providePin(event.taskId, event.pin);
      // State updates will come through the stream
    } catch (e) {
      emit(
        AuthState.error(
          message: 'Failed to provide PIN: $e',
          walletName: trezorWalletName,
          knownUsers: await _fetchKnownUsers(),
        ),
      );
    }
  }

  Future<void> _onTrezorProvidePassphrase(
    AuthTrezorPassphraseProvided event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _sdk.trezor.providePassphrase(event.taskId, event.passphrase);
      // State updates will come through the stream
    } catch (e) {
      emit(
        AuthState.error(
          message: 'Failed to provide passphrase: $e',
          walletName: trezorWalletName,
          knownUsers: await _fetchKnownUsers(),
        ),
      );
    }
  }

  Future<void> _onTrezorCancel(
    AuthTrezorCancelled event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _sdk.trezor.cancelInitialization(event.taskId);

      emit(AuthState.unauthenticated(knownUsers: await _fetchKnownUsers()));
    } catch (e) {
      emit(
        AuthState.error(
          message: 'Failed to cancel Trezor initialization: $e',
          walletName: trezorWalletName,
          knownUsers: await _fetchKnownUsers(),
        ),
      );
    }
  }

  /// Clears stored Trezor password and disposes resources
  /// Use this when you want to completely reset the Trezor wallet
  Future<void> clearTrezorWallet() async {
    await _clearTrezorPassword();
  }

  Future<List<KdfUser>> _fetchKnownUsers() async {
    try {
      return await _sdk.auth.getUsers();
    } catch (e) {
      debugPrint('Error fetching known users: $e');
      return [];
    }
  }
}
