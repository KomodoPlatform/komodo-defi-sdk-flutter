part of 'auth_bloc.dart';

/// Mixin that exposes Trezor authentication helpers for [AuthBloc].
mixin TrezorAuthMixin on Bloc<AuthEvent, AuthState> {
  KomodoDefiSdk get _sdk;

  /// Registers handlers for Trezor specific events.
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
      await for (final state in _sdk.trezorWallets.initializeAndAuthenticate(
        derivationMethod: event.derivationMethod,
        register: event.isRegister,
      )) {
        final authState = _handleTrezorInitializationState(state);
        emit(authState);

        if (authState.status == AuthStatus.authenticated) {
          await _performTrezorAuthentication(emit);
        }

        if (state.status == TrezorInitializationStatus.completed ||
            state.status == TrezorInitializationStatus.error ||
            state.status == TrezorInitializationStatus.cancelled) {
          break;
        }
      }
    } catch (e) {
      emit(
        AuthState.error(
          message: 'Trezor initialization error: $e',
          walletName: TrezorWalletManager.trezorWalletName,
          knownUsers: state.knownUsers,
        ),
      );
    }
  }

  AuthState _handleTrezorInitializationState(
    TrezorInitializationState trezorInitState,
  ) {
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
          walletName: TrezorWalletManager.trezorWalletName,
        );
      case TrezorInitializationStatus.cancelled:
        return AuthState.error(
          message: 'Trezor initialization was cancelled',
          walletName: TrezorWalletManager.trezorWalletName,
        );
    }
  }

  Future<void> _performTrezorAuthentication(Emitter<AuthState> emit) async {
    try {
      emit(AuthState.loading());
      final knownUsers = await _fetchKnownUsers();
      final trezorUser = knownUsers.firstWhere(
        (u) =>
            u.walletId.name == TrezorWalletManager.trezorWalletName &&
            u.authOptions.privKeyPolicy == PrivateKeyPolicy.trezor,
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
          walletName: TrezorWalletManager.trezorWalletName,
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
      await _sdk.trezorWallets.providePin(event.taskId, event.pin);
    } catch (e) {
      emit(
        AuthState.error(
          message: 'Failed to provide PIN: $e',
          walletName: TrezorWalletManager.trezorWalletName,
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
      await _sdk.trezorWallets.providePassphrase(
        event.taskId,
        event.passphrase,
      );
    } catch (e) {
      emit(
        AuthState.error(
          message: 'Failed to provide passphrase: $e',
          walletName: TrezorWalletManager.trezorWalletName,
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
      await _sdk.trezorWallets.cancelInitialization(event.taskId);
      emit(AuthState.unauthenticated(knownUsers: await _fetchKnownUsers()));
    } catch (e) {
      emit(
        AuthState.error(
          message: 'Failed to cancel Trezor initialization: $e',
          walletName: TrezorWalletManager.trezorWalletName,
          knownUsers: await _fetchKnownUsers(),
        ),
      );
    }
  }

  Future<void> clearTrezorWallet() async {
    await _sdk.trezorWallets.clearPassword();
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
