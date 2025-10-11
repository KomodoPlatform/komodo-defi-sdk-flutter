import 'dart:async';

import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_state.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/authentication_strategy.dart';
import 'package:komodo_defi_local_auth/src/walletconnect/repositories/cosmos_chain_repository.dart';
import 'package:komodo_defi_local_auth/src/walletconnect/repositories/evm_chain_repository.dart';
import 'package:komodo_defi_local_auth/src/walletconnect/walletconnect_user_manager.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
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
  /// [userManager] - Optional user manager (created if not provided)
  /// [evmChainRepository] - Optional EVM chain repository (created if not provided)
  /// [cosmosChainRepository] - Optional Cosmos chain repository (created if not provided)
  WalletConnectAuthStrategy(
    IAuthService authService,
    this._walletConnectMethods, {
    WalletConnectUserManager? userManager,
    EvmChainRepository? evmChainRepository,
    CosmosChainRepository? cosmosChainRepository,
  }) : _userManager = userManager ?? WalletConnectUserManager(authService),
       _evmChainRepository = evmChainRepository ?? EvmChainRepository(),
       _cosmosChainRepository =
           cosmosChainRepository ?? CosmosChainRepository();

  static final _log = Logger('WalletConnectAuthStrategy');
  static const Duration _connectionTimeout = Duration(minutes: 5);

  final WalletConnectMethodsNamespace _walletConnectMethods;
  final WalletConnectUserManager _userManager;
  final EvmChainRepository _evmChainRepository;
  final CosmosChainRepository _cosmosChainRepository;

  Timer? _connectionTimer;
  StreamController<AuthenticationState>? _stateController;

  @override
  Stream<AuthenticationState> signInStream({
    required AuthOptions options,
    String? walletName,
    String? password,
    Mnemonic? mnemonic,
  }) async* {
    _log.info('Starting WalletConnect sign-in');

    // Validate and extract session topic from WalletConnect policy
    final sessionTopic = options.privKeyPolicy.maybeWhen(
      walletConnect: (topic) => topic,
      orElse: () => null,
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
      // Check if we have an existing session
      if (sessionTopic.isNotEmpty) {
        _log.fine('Checking existing WalletConnect session: $sessionTopic');
        yield const AuthenticationState(
          status: AuthenticationStatus.initializing,
          message: 'Checking existing WalletConnect session...',
        );

        final sessionValid = await _validateExistingSession(sessionTopic);
        if (sessionValid) {
          _log.info('Found valid existing session: $sessionTopic');

          // Authenticate with existing session
          yield const AuthenticationState(
            status: AuthenticationStatus.authenticating,
            message: 'Signing in with existing session...',
          );

          final user = await _userManager.createOrAuthenticateWallet(
            sessionTopic: sessionTopic,
            derivationMethod: options.derivationMethod,
          );

          yield AuthenticationState(
            status: AuthenticationStatus.completed,
            user: user,
            data: AuthenticationData.walletConnect(sessionTopic: sessionTopic),
          );
          return;
        } else {
          _log.warning('Existing session is invalid: $sessionTopic');
        }
      }

      // Generate new QR code for new connection
      _log.info('Generating new WalletConnect QR code for sign-in');
      yield const AuthenticationState(
        status: AuthenticationStatus.generatingQrCode,
        message: 'Generating QR code for WalletConnect...',
      );

      final requiredNamespaces = await _buildRequiredNamespaces();
      final connectionResponse = await _walletConnectMethods.newConnection(
        requiredNamespaces: requiredNamespaces,
      );

      _log.fine('Generated QR code with URI: ${connectionResponse.uri}');

      yield AuthenticationState(
        status: AuthenticationStatus.waitingForConnection,
        message: 'Scan QR code with your mobile wallet',
        data: AuthenticationData.qrCode(
          uri: connectionResponse.uri,
          requiredNamespaces: requiredNamespaces.toJson(),
        ),
      );

      // Wait for connection with timeout
      _log.fine('Starting connection timeout and waiting for mobile wallet');
      _startConnectionTimeout();

      final newSessionTopic = await _waitForConnection(connectionResponse.uri);
      _log.info(
        'Mobile wallet connected successfully with session: $newSessionTopic',
      );

      _connectionTimer?.cancel();
      _connectionTimer = null;

      // Complete authentication with established session
      yield const AuthenticationState(
        status: AuthenticationStatus.authenticating,
        message: 'Signing in with WalletConnect...',
      );

      final user = await _userManager.createOrAuthenticateWallet(
        sessionTopic: newSessionTopic,
        derivationMethod: options.derivationMethod,
      );

      _log.info('WalletConnect sign-in completed successfully');
      yield AuthenticationState(
        status: AuthenticationStatus.completed,
        user: user,
        data: AuthenticationData.walletConnect(sessionTopic: newSessionTopic),
      );
    } catch (e, stackTrace) {
      _connectionTimer?.cancel();
      _connectionTimer = null;

      if (e is TimeoutException) {
        _log.warning('WalletConnect connection timeout during sign-in');
        yield AuthenticationState.error(
          'Connection timeout. Please try again.',
        );
      } else {
        _log.severe('WalletConnect sign-in failed', e, stackTrace);
        yield AuthenticationState.error('WalletConnect sign-in failed: $e');
      }
    } finally {
      if (_stateController != null && !_stateController!.isClosed) {
        await _stateController!.close();
      }
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

    // For registration, we don't need an existing session topic
    // We'll create a new session during the registration process
    if (options.privKeyPolicy.maybeWhen(
      walletConnect: (_) => false, // WalletConnect policy is valid
      orElse: () => true, // Other policies are invalid
    )) {
      _log.severe(
        'Invalid policy for WalletConnectAuthStrategy registration: ${options.privKeyPolicy}',
      );
      yield AuthenticationState.error(
        'WalletConnectAuthStrategy only supports WalletConnect private key policy',
      );
      return;
    }

    _log.fine('Starting WalletConnect registration flow');

    try {
      // Step 1: Create/authenticate user account first
      yield const AuthenticationState(
        status: AuthenticationStatus.initializing,
        message: 'Setting up WalletConnect wallet...',
      );

      // Create a temporary session topic for initial registration
      // This will be updated when the actual session is established
      final tempSessionTopic = 'temp_${DateTime.now().millisecondsSinceEpoch}';

      final user = await _userManager.createOrAuthenticateWallet(
        sessionTopic: tempSessionTopic,
        derivationMethod: options.derivationMethod,
        walletName: walletName,
      );

      _log.info(
        'Successfully created WalletConnect wallet: ${user.walletId.name}',
      );

      // Step 2: Generate QR code with comprehensive chain support
      yield const AuthenticationState(
        status: AuthenticationStatus.generatingQrCode,
        message: 'Generating QR code with comprehensive blockchain support...',
      );

      final requiredNamespaces = await _buildRequiredNamespaces();
      final connectionResponse = await _walletConnectMethods.newConnection(
        requiredNamespaces: requiredNamespaces,
      );

      _log.fine('Generated QR code with URI: ${connectionResponse.uri}');

      yield AuthenticationState(
        status: AuthenticationStatus.waitingForConnection,
        message: 'Scan QR code with your mobile wallet',
        data: AuthenticationData.qrCode(
          uri: connectionResponse.uri,
          requiredNamespaces: requiredNamespaces.toJson(),
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

      // Step 4: Update user with actual session topic
      final updatedUser = await _userManager.updateSessionTopic(
        newSessionTopic: newSessionTopic,
        derivationMethod: options.derivationMethod,
      );

      _log.info('WalletConnect registration completed successfully');
      yield AuthenticationState(
        status: AuthenticationStatus.completed,
        user: updatedUser,
        data: AuthenticationData.walletConnect(sessionTopic: newSessionTopic),
      );
    } catch (e, stackTrace) {
      _connectionTimer?.cancel();
      _connectionTimer = null;

      if (e is TimeoutException) {
        _log.warning('WalletConnect connection timeout during registration');
        yield AuthenticationState.error(
          'Connection timeout. Please try again.',
        );
      } else {
        _log.severe('WalletConnect registration failed', e, stackTrace);
        yield AuthenticationState.error(
          'WalletConnect registration failed: $e',
        );
      }
    } finally {
      if (_stateController != null && !_stateController!.isClosed) {
        await _stateController!.close();
      }
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

    _userManager.dispose();
    _evmChainRepository.dispose();
    _cosmosChainRepository.dispose();

    _log.fine('WalletConnect auth strategy disposed successfully');
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

  /// Builds required namespaces with comprehensive chain support from repositories.
  Future<WcRequiredNamespaces> _buildRequiredNamespaces() async {
    _log.fine('Building required namespaces with dynamic chain support');

    try {
      // Get EVM chains from repository with fallback
      List<String> evmChains;
      try {
        evmChains = await _evmChainRepository.getEvmChainIds();
        _log.fine('Retrieved ${evmChains.length} EVM chains from repository');
      } catch (e, stackTrace) {
        _log.warning(
          'Failed to get EVM chains from repository, using cached',
          e,
          stackTrace,
        );
        evmChains = _evmChainRepository.getCachedEvmChainIds();
        if (evmChains.isEmpty) {
          _log.warning('No cached EVM chains available, using defaults');
          evmChains = _getDefaultEvmChains();
        }
      }

      // Get Cosmos chains from repository with fallback
      List<String> cosmosChains;
      try {
        cosmosChains = await _cosmosChainRepository.getCosmosChainIds();
        _log.fine(
          'Retrieved ${cosmosChains.length} Cosmos chains from repository',
        );
      } catch (e, stackTrace) {
        _log.warning(
          'Failed to get Cosmos chains from repository, using cached',
          e,
          stackTrace,
        );
        cosmosChains = _cosmosChainRepository.getCachedCosmosChainIds();
        if (cosmosChains.isEmpty) {
          _log.warning('No cached Cosmos chains available, using defaults');
          cosmosChains = _getDefaultCosmosChains();
        }
      }

      final requiredNamespaces = WcRequiredNamespaces(
        eip155: WcConnNs(
          chains: evmChains,
          methods: [
            'eth_sendTransaction',
            'eth_signTransaction',
            'eth_sign',
            'personal_sign',
            'eth_signTypedData',
            'eth_signTypedData_v1',
            'eth_signTypedData_v3',
            'eth_signTypedData_v4',
          ],
          events: ['chainChanged', 'accountsChanged'],
        ),
        cosmos: WcConnNs(
          chains: cosmosChains,
          methods: [
            'cosmos_signDirect',
            'cosmos_signAmino',
            'cosmos_getAccounts',
          ],
          events: ['chainChanged', 'accountsChanged'],
        ),
      );

      _log.info(
        'Built required namespaces with ${evmChains.length} EVM chains and ${cosmosChains.length} Cosmos chains',
      );

      return requiredNamespaces;
    } catch (e, stackTrace) {
      _log.severe('Failed to build required namespaces', e, stackTrace);
      // Return default namespaces as ultimate fallback
      return _getDefaultRequiredNamespaces();
    }
  }

  /// Gets default EVM chain IDs as fallback.
  List<String> _getDefaultEvmChains() {
    return [
      'eip155:1', // Ethereum Mainnet
      'eip155:137', // Polygon Mainnet
      'eip155:56', // BNB Smart Chain
      'eip155:43114', // Avalanche C-Chain
      'eip155:250', // Fantom Opera
    ];
  }

  /// Gets default Cosmos chain IDs as fallback.
  List<String> _getDefaultCosmosChains() {
    return [
      'cosmos:cosmoshub-4', // Cosmos Hub
      'cosmos:osmosis-1', // Osmosis
      'cosmos:juno-1', // Juno
      'cosmos:akashnet-2', // Akash Network
      'cosmos:secret-4', // Secret Network
    ];
  }

  /// Gets default required namespaces as ultimate fallback.
  WcRequiredNamespaces _getDefaultRequiredNamespaces() {
    return WcRequiredNamespaces(
      eip155: WcConnNs(
        chains: _getDefaultEvmChains(),
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
        chains: _getDefaultCosmosChains(),
        methods: ['cosmos_signDirect', 'cosmos_signAmino'],
        events: ['chainChanged', 'accountsChanged'],
      ),
    );
  }

  /// Gets the required namespaces for WalletConnect connection (legacy method for compatibility).

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
}
