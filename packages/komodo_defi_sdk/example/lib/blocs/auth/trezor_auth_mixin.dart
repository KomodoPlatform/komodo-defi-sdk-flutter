part of 'auth_bloc.dart';

/// Mixin that exposes Trezor authentication helpers for [AuthBloc].
mixin TrezorAuthMixin on Bloc<AuthEvent, AuthState> {
  KomodoDefiSdk get _sdk;

  static final Logger _log = Logger('TrezorAuthMixin');

  /// Registers handlers for Trezor specific events.
  ///
  /// Note: PIN and passphrase handling is now automatic in the stream-based approach.
  /// The PIN and passphrase events are kept for backward compatibility but may not
  /// be needed in the new implementation.
  void setupTrezorEventHandlers() {
    _log.finer('Registering Trezor event handlers');
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
      _log.fine(
        'Trezor init/auth started (isRegister=${event.isRegister}, method=${event.derivationMethod})',
      );
      final authOptions = AuthOptions(
        derivationMethod: event.derivationMethod,
        privKeyPolicy: const PrivateKeyPolicy.trezor(),
      );

      // Trezor generates and securely stores a random password internally,
      // and manages PIN/passphrase handling through the streamed events.
      final Stream<AuthenticationState> authStream;
      if (event.isRegister) {
        _log.finer('Creating auth.registerStream');
        authStream = _sdk.auth.registerStream(
          walletName: 'My Trezor',
          password: '',
          options: authOptions,
        );
      } else {
        _log.finer('Creating auth.signInStream');
        authStream = _sdk.auth.signInStream(
          walletName: 'My Trezor',
          password: '',
          options: authOptions,
        );
      }

      await for (final authState in authStream) {
        _log.finer(
          'Auth stream event: ${authState.status} taskId=${authState.taskId}',
        );
        final mappedState = _handleAuthenticationState(authState);
        emit(mappedState);

        if (authState.status == AuthenticationStatus.completed ||
            authState.status == AuthenticationStatus.error ||
            authState.status == AuthenticationStatus.cancelled) {
          _log.fine('Auth stream terminal status: ${authState.status}');
          break;
        }
      }
    } catch (e, s) {
      _log.severe('Trezor initialization error', e, s);
      emit(
        AuthState.error(
          message: 'Trezor initialization error: $e',
          walletName: 'My Trezor',
          knownUsers: state.knownUsers,
        ),
      );
    }
  }

  AuthState _handleAuthenticationState(AuthenticationState authState) {
    // Conservative logging
    _log.finer('Handling auth state: ${authState.status}');
    switch (authState.status) {
      case AuthenticationStatus.initializing:
        return AuthState.trezorInitializing(
          message: authState.message ?? 'Initializing Trezor device...',
          taskId: authState.taskId,
        );
      case AuthenticationStatus.waitingForDevice:
        return AuthState.trezorInitializing(
          message:
              authState.message ?? 'Waiting for Trezor device connection...',
          taskId: authState.taskId,
        );
      case AuthenticationStatus.waitingForDeviceConfirmation:
        return AuthState.trezorAwaitingConfirmation(
          taskId: authState.taskId!,
          message:
              authState.message ??
              'Please follow instructions on your Trezor device',
        );
      case AuthenticationStatus.pinRequired:
        return AuthState.trezorPinRequired(
          taskId: authState.taskId!,
          message: authState.message ?? 'Please enter your Trezor PIN',
        );
      case AuthenticationStatus.passphraseRequired:
        return AuthState.trezorPassphraseRequired(
          taskId: authState.taskId!,
          message: authState.message ?? 'Please enter your Trezor passphrase',
        );
      case AuthenticationStatus.authenticating:
        return AuthState.loading();
      case AuthenticationStatus.completed:
        if (authState.user != null) {
          _log.fine('Trezor authentication completed with user');
          return AuthState.authenticated(
            user: authState.user!,
            knownUsers: state.knownUsers,
          );
        } else {
          _log.fine('Trezor device is ready (no user)');
          return AuthState.trezorReady(deviceInfo: null);
        }
      case AuthenticationStatus.error:
        _log.warning('Trezor authentication failed: ${authState.message}');
        return AuthState.error(
          message: 'Trezor authentication failed: ${authState.message}',
          walletName: 'My Trezor',
          knownUsers: state.knownUsers,
        );
      case AuthenticationStatus.cancelled:
        _log.fine('Trezor authentication was cancelled');
        return AuthState.error(
          message: 'Trezor authentication was cancelled',
          walletName: 'My Trezor',
          knownUsers: state.knownUsers,
        );
    }
  }

  // NOTE: The following methods are kept for backward compatibility but are no longer
  // needed in the new stream-based approach. PIN and passphrase handling is now
  // automatic within the TrezorAuthService stream implementation.

  Future<void> _onTrezorProvidePin(
    AuthTrezorPinProvided event,
    Emitter<AuthState> emit,
  ) async {
    try {
      _log.fine('Providing Trezor PIN for taskId=${event.taskId}');
      await _sdk.auth.setHardwareDevicePin(event.taskId, event.pin);
    } catch (e) {
      _log.severe('Failed to provide PIN', e);
      emit(
        AuthState.error(
          message: 'Failed to provide PIN: $e',
          walletName: 'My Trezor',
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
      _log.fine('Providing Trezor passphrase for taskId=${event.taskId}');
      await _sdk.auth.setHardwareDevicePassphrase(
        event.taskId,
        event.passphrase,
      );
    } catch (e) {
      _log.severe('Failed to provide passphrase', e);
      emit(
        AuthState.error(
          message: 'Failed to provide passphrase: $e',
          walletName: 'My Trezor',
          knownUsers: await _fetchKnownUsers(),
        ),
      );
    }
  }

  Future<void> _onTrezorCancel(
    AuthTrezorCancelled event,
    Emitter<AuthState> emit,
  ) async {
    // Cancellation is handled by stopping the stream subscription
    // This method is kept for backward compatibility
    _log.info('Trezor authentication cancelled by user');
    emit(AuthState.unauthenticated(knownUsers: await _fetchKnownUsers()));
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
