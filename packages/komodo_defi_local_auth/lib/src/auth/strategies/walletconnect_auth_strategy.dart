import 'dart:async';

import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_state.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/authentication_strategy.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:logging/logging.dart';

/// Authentication strategy for WalletConnect mobile wallet connections.
///
/// This strategy handles WalletConnect-specific authentication flows including
/// QR code generation, session establishment, and connection monitoring.
class WalletConnectAuthStrategy implements AuthenticationStrategy {
  /// Creates a new WalletConnect authentication strategy.
  ///
  /// [authService] - The underlying authentication service
  /// [walletConnectMethods] - WalletConnect RPC methods namespace
  WalletConnectAuthStrategy(this._authService, this._walletConnectMethods);

  static final _log = Logger('WalletConnectAuthStrategy');
  static const Duration _connectionTimeout = Duration(minutes: 5);

  final IAuthService _authService;
  final WalletConnectMethodsNamespace _walletConnectMethods;

  Timer? _connectionTimer;
  StreamController<AuthenticationState>? _stateController;

  @override
  Stream<AuthenticationState> signInStream({
    required AuthOptions options,
    String? walletName,
    String? password,
    Mnemonic? mnemonic,
  }) async* {
    _log.info('Starting WalletConnect sign-in for wallet: $walletName');

    // Validate and extract session topic from WalletConnect policy
    final sessionTopic = options.privKeyPolicy.maybeWhen(
      walletConnect: (topic) => topic,
      orElse: () {
        return null;
      },
    );

    if (sessionTopic == null) {
      _log.severe(
        'Invalid policy for WalletConnectAuthStrategy: ${options.privKeyPolicy}',
      );
      yield AuthenticationState.error(
        'WalletConnectAuthStrategy only supports WalletConnect private key policy',
      );
      return;
    }

    _log.fine(
      'Sign-in with session topic: ${sessionTopic.isEmpty ? 'new session' : sessionTopic}',
    );

    try {
      yield* _authenticateWalletConnectStream(
        sessionTopic: sessionTopic,
        isRegistration: false,
        options: options,
      );
      _log.info('Successfully completed WalletConnect sign-in');
    } catch (e, stackTrace) {
      _log.severe('WalletConnect sign-in failed', e, stackTrace);
      yield AuthenticationState.error('WalletConnect sign-in failed: $e');
    }
  }

  @override
  Stream<AuthenticationState> registerStream({
    required AuthOptions options,
    required String walletName,
    required String password,
    Mnemonic? mnemonic,
  }) async* {
    _log.info('Starting WalletConnect registration for wallet: $walletName');

    // Validate and extract session topic from WalletConnect policy
    final sessionTopic = options.privKeyPolicy.maybeWhen(
      walletConnect: (topic) => topic,
      orElse: () => null,
    );

    if (sessionTopic == null) {
      _log.severe(
        'Invalid policy for WalletConnectAuthStrategy registration: ${options.privKeyPolicy}',
      );
      yield AuthenticationState.error(
        'WalletConnectAuthStrategy only supports WalletConnect private key policy',
      );
      return;
    }

    _log.fine(
      'Registration with session topic: ${sessionTopic.isEmpty ? 'new session' : sessionTopic}',
    );

    try {
      yield* _authenticateWalletConnectStream(
        sessionTopic: sessionTopic,
        isRegistration: true,
        options: options,
        walletName: walletName,
        password: password,
        mnemonic: mnemonic,
      );
      _log.info(
        'Successfully completed WalletConnect registration for wallet: $walletName',
      );
    } catch (e, stackTrace) {
      _log.severe(
        'WalletConnect registration failed for wallet: $walletName',
        e,
        stackTrace,
      );
      yield AuthenticationState.error('WalletConnect registration failed: $e');
    }
  }

  @override
  Future<void> cancel(int? taskId) async {
    _log.info('Cancelling WalletConnect authentication (taskId: $taskId)');

    _connectionTimer?.cancel();
    _connectionTimer = null;

    if (_stateController != null && !_stateController!.isClosed) {
      _stateController!.add(
        const AuthenticationState(
          status: AuthenticationStatus.cancelled,
          message: 'WalletConnect authentication cancelled',
        ),
      );
      await _stateController!.close();
    }

    _log.fine('WalletConnect authentication cancelled successfully');
  }

  @override
  Future<void> dispose() async {
    _log.fine('Disposing WalletConnect auth strategy');

    _connectionTimer?.cancel();
    _connectionTimer = null;

    if (_stateController != null && !_stateController!.isClosed) {
      await _stateController!.close();
    }

    _log.fine('WalletConnect auth strategy disposed successfully');
  }

  /// Main authentication stream that handles the complete WalletConnect flow
  Stream<AuthenticationState> _authenticateWalletConnectStream({
    required bool isRegistration,
    required AuthOptions options,
    String? sessionTopic,
    String? walletName,
    String? password,
    Mnemonic? mnemonic,
  }) async* {
    _log.fine(
      'Starting WalletConnect authentication stream (isRegistration: $isRegistration)',
    );
    _stateController = StreamController<AuthenticationState>();

    try {
      // Step 1: Check if we have an existing session
      if (sessionTopic != null && sessionTopic.isNotEmpty) {
        _log.fine('Checking existing WalletConnect session: $sessionTopic');
        yield const AuthenticationState(
          status: AuthenticationStatus.initializing,
          message: 'Checking existing WalletConnect session...',
        );

        final sessionValid = await _validateExistingSession(sessionTopic);
        if (sessionValid) {
          _log.info('Found valid existing session: $sessionTopic');
          yield* _completeAuthenticationWithSession(
            sessionTopic,
            isRegistration,
            options,
            walletName: walletName,
            password: password,
            mnemonic: mnemonic,
          );
          return;
        } else {
          _log.warning('Existing session is invalid: $sessionTopic');
        }
      }

      // Step 2: Generate QR code for new connection
      _log.info('Generating new WalletConnect QR code');
      yield const AuthenticationState(
        status: AuthenticationStatus.generatingQrCode,
        message: 'Generating QR code for WalletConnect...',
      );

      final connectionResponse = await _generateQRCode();
      _log.fine('Generated QR code with URI: ${connectionResponse.uri}');

      yield AuthenticationState(
        status: AuthenticationStatus.waitingForConnection,
        message: 'Scan QR code with your mobile wallet',
        data: AuthenticationData.qrCode(
          uri: connectionResponse.uri,
          requiredNamespaces: _getRequiredNamespaces().toJson(),
        ),
      );

      // Step 3: Wait for connection with timeout
      _log.fine('Starting connection timeout and waiting for mobile wallet');
      _startConnectionTimeout();

      final newSessionTopic = await _waitForConnection(connectionResponse.uri);
      _log.info(
        'Mobile wallet connected successfully with session: $newSessionTopic',
      );

      _connectionTimer?.cancel();
      _connectionTimer = null;

      // Step 4: Complete authentication with established session
      _log.fine(
        'Completing authentication with established session: $newSessionTopic',
      );
      yield* _completeAuthenticationWithSession(
        newSessionTopic,
        isRegistration,
        options,
        walletName: walletName,
        password: password,
        mnemonic: mnemonic,
      );
    } catch (e, stackTrace) {
      _connectionTimer?.cancel();
      _connectionTimer = null;

      if (e is TimeoutException) {
        _log.warning('WalletConnect connection timeout');
        yield AuthenticationState.error(
          'Connection timeout. Please try again.',
        );
      } else {
        _log.severe('WalletConnect authentication error', e, stackTrace);
        yield AuthenticationState.error('WalletConnect error: $e');
      }
    } finally {
      if (_stateController != null && !_stateController!.isClosed) {
        await _stateController!.close();
      }
    }
  }

  /// Validates if an existing session is still active
  Future<bool> _validateExistingSession(String sessionTopic) async {
    _log.fine('Validating existing session: $sessionTopic');
    try {
      final response = await _walletConnectMethods.pingSession(
        topic: sessionTopic,
      );
      final isValid = response.status == 'success';
      _log.fine('Session validation result: $isValid');
      return isValid;
    } catch (e, stackTrace) {
      _log.warning(
        'Failed to validate existing session: $sessionTopic',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Generates a QR code for WalletConnect connection
  Future<WcNewConnectionResponse> _generateQRCode() async {
    _log.fine('Generating QR code with required namespaces');
    final requiredNamespaces = _getRequiredNamespaces();

    try {
      final response = await _walletConnectMethods.newConnection(
        requiredNamespaces: requiredNamespaces,
      );
      _log.fine('QR code generated successfully');
      return response;
    } catch (e, stackTrace) {
      _log.severe('Failed to generate QR code', e, stackTrace);
      rethrow;
    }
  }

  /// Gets the required namespaces for WalletConnect connection
  WcRequiredNamespaces _getRequiredNamespaces() {
    // Define the required namespaces for EIP155 (Ethereum) and Cosmos chains
    return WcRequiredNamespaces(
      eip155: WcConnNs(
        chains: ['eip155:1', 'eip155:137'], // Ethereum mainnet and Polygon
        methods: [
          'eth_sendTransaction',
          'eth_signTransaction',
          'eth_sign',
          'personal_sign',
          'eth_signTypedData',
        ],
        events: ['chainChanged', 'accountsChanged'],
      ),
      cosmos: WcConnNs(
        chains: ['cosmos:cosmoshub-4'], // Cosmos Hub
        methods: ['cosmos_signDirect', 'cosmos_signAmino'],
        events: ['chainChanged', 'accountsChanged'],
      ),
    );
  }

  /// Starts a timeout timer for connection attempts
  void _startConnectionTimeout() {
    _log.fine(
      'Starting connection timeout timer: ${_connectionTimeout.inMinutes} minutes',
    );
    _connectionTimer = Timer(_connectionTimeout, () {
      _log.warning('WalletConnect connection timeout reached');
      if (_stateController != null && !_stateController!.isClosed) {
        _stateController!.addError(
          TimeoutException('Connection timeout', _connectionTimeout),
        );
      }
    });
  }

  /// Waits for a mobile wallet to connect and returns the session topic
  Future<String> _waitForConnection(String uri) async {
    _log.fine('Waiting for mobile wallet connection');
    // In a real implementation, this would monitor the WalletConnect session
    // establishment. For now, we'll simulate the process.

    // Poll for active sessions to detect new connections
    const pollInterval = Duration(seconds: 2);
    final maxAttempts = (_connectionTimeout.inSeconds / pollInterval.inSeconds)
        .ceil();

    _log.finest(
      'Polling for sessions with interval: $pollInterval, max attempts: $maxAttempts',
    );

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      await Future<void>.delayed(pollInterval);
      _log.finest('Polling attempt ${attempt + 1}/$maxAttempts');

      try {
        final sessionsResponse = await _walletConnectMethods.getSessions();

        // Look for a new session that wasn't there before
        // In a real implementation, you'd track which sessions existed before
        if (sessionsResponse.sessions.isNotEmpty) {
          final latestSession = sessionsResponse.sessions.last;
          _log.info('Found new session: ${latestSession.topic}');

          // Emit connection established state
          if (_stateController != null && !_stateController!.isClosed) {
            _stateController!.add(
              AuthenticationState(
                status: AuthenticationStatus.walletConnected,
                message: 'Mobile wallet connected successfully',
                data: AuthenticationData.walletConnect(
                  sessionTopic: latestSession.topic,
                  session: latestSession.toJson(),
                ),
              ),
            );
          }

          return latestSession.topic;
        }
      } catch (e, stackTrace) {
        _log.warning(
          'Error polling for sessions (attempt ${attempt + 1})',
          e,
          stackTrace,
        );
      }
    }

    _log.severe('No wallet connection detected after $maxAttempts attempts');
    throw TimeoutException('No wallet connection detected', _connectionTimeout);
  }

  /// Completes authentication using an established WalletConnect session
  Stream<AuthenticationState> _completeAuthenticationWithSession(
    String sessionTopic,
    bool isRegistration,
    AuthOptions options, {
    String? walletName,
    String? password,
    Mnemonic? mnemonic,
  }) async* {
    _log.info(
      'Completing authentication with session: $sessionTopic (isRegistration: $isRegistration)',
    );

    try {
      yield AuthenticationState(
        status: AuthenticationStatus.sessionEstablished,
        message: 'WalletConnect session established',
        data: AuthenticationData.walletConnect(sessionTopic: sessionTopic),
      );

      // Create updated options with the session topic
      final updatedOptions = AuthOptions(
        derivationMethod: options.derivationMethod,
        allowWeakPassword: options.allowWeakPassword,
        privKeyPolicy: PrivateKeyPolicy.walletConnect(sessionTopic),
      );

      KdfUser user;
      if (isRegistration) {
        if (walletName == null || password == null) {
          _log.warning('Registration failed: missing wallet name or password');
          yield AuthenticationState.error(
            'Wallet name and password are required for registration',
          );
          return;
        }

        _log.fine('Registering WalletConnect wallet: $walletName');
        yield const AuthenticationState(
          status: AuthenticationStatus.authenticating,
          message: 'Registering WalletConnect wallet...',
        );

        user = await _authService.register(
          walletName: walletName,
          password: password,
          options: updatedOptions,
          mnemonic: mnemonic,
        );
        _log.info('Successfully registered WalletConnect wallet: $walletName');
      } else {
        _log.fine('Signing in with WalletConnect');
        yield const AuthenticationState(
          status: AuthenticationStatus.authenticating,
          message: 'Signing in with WalletConnect...',
        );

        // For sign-in, we need to find the existing wallet
        // In a real implementation, you'd have a way to map session topics to wallets
        final users = await _authService.getUsers();
        final wcUser = users.firstWhereOrNull(
          (KdfUser u) => u.walletId.authOptions.privKeyPolicy.maybeWhen(
            walletConnect: (_) => true,
            orElse: () => false,
          ),
        );

        if (wcUser == null) {
          _log.warning('No WalletConnect wallet found for sign-in');
          yield AuthenticationState.error(
            'No WalletConnect wallet found. Please register first.',
          );
          return;
        }

        _log.fine(
          'Found existing WalletConnect wallet: ${wcUser.walletId.name}',
        );
        user = await _authService.signIn(
          walletName: wcUser.walletId.name,
          password: password ?? '',
          options: updatedOptions,
        );
        _log.info(
          'Successfully signed in WalletConnect wallet: ${wcUser.walletId.name}',
        );
      }

      _log.info('WalletConnect authentication completed successfully');
      yield AuthenticationState(
        status: AuthenticationStatus.completed,
        user: user,
        data: AuthenticationData.walletConnect(sessionTopic: sessionTopic),
      );
    } catch (e, stackTrace) {
      _log.severe(
        'Failed to complete WalletConnect authentication',
        e,
        stackTrace,
      );
      yield AuthenticationState.error(
        'Failed to complete WalletConnect authentication: $e',
      );
    }
  }
}
