import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_chain_data/komodo_chain_data.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_state.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/walletconnect_auth_strategy.dart';
import 'package:komodo_defi_local_auth/src/walletconnect/walletconnect_user_manager.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements IAuthService {}

class MockWalletConnectMethodsNamespace extends Mock
    implements WalletConnectMethodsNamespace {}

class MockEvmChainRepository extends Mock implements EvmChainRepository {}

class MockCosmosChainRepository extends Mock implements CosmosChainRepository {}

class MockWalletConnectUserManager extends Mock
    implements WalletConnectUserManager {}

class FakeWcRequiredNamespaces extends Fake implements WcRequiredNamespaces {}

class FakeAuthOptions extends Fake implements AuthOptions {}

class FakeMnemonic extends Fake implements Mnemonic {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeWcRequiredNamespaces());
    registerFallbackValue(FakeAuthOptions());
    registerFallbackValue(FakeMnemonic());
    registerFallbackValue(DerivationMethod.hdWallet);
  });

  group('WalletConnectAuthStrategy', () {
    late MockAuthService mockAuthService;
    late MockWalletConnectMethodsNamespace mockWalletConnectMethods;
    late MockEvmChainRepository mockEvmRepo;
    late MockCosmosChainRepository mockCosmosRepo;
    late MockWalletConnectUserManager mockUserManager;
    late WalletConnectAuthStrategy strategy;

    setUp(() {
      mockAuthService = MockAuthService();
      mockWalletConnectMethods = MockWalletConnectMethodsNamespace();
      mockEvmRepo = MockEvmChainRepository();
      mockCosmosRepo = MockCosmosChainRepository();
      mockUserManager = MockWalletConnectUserManager();
      strategy = WalletConnectAuthStrategy(
        mockAuthService,
        mockWalletConnectMethods,
        userManager: mockUserManager,
        evmChainRepository: mockEvmRepo,
        cosmosChainRepository: mockCosmosRepo,
      );
    });

    tearDown(() {
      strategy.dispose();
    });

    group('signInStream', () {
      test('should emit error for non-WalletConnect policy', () async {
        const options = AuthOptions(
          derivationMethod: DerivationMethod.hdWallet,
        );

        final states = <AuthenticationState>[];
        await for (final state in strategy.signInStream(
          options: options,
          walletName: 'test-wallet',
          password: 'password',
        )) {
          states.add(state);
          break; // Only get the first state
        }

        expect(states, hasLength(1));
        expect(states.first.status, AuthenticationStatus.error);
        expect(
          states.first.error,
          contains(
            'WalletConnectAuthStrategy only supports WalletConnect private key policy',
          ),
        );
      });

      test('should emit error for trezor policy', () async {
        const options = AuthOptions(
          derivationMethod: DerivationMethod.hdWallet,
          privKeyPolicy: PrivateKeyPolicy.trezor(),
        );

        final states = <AuthenticationState>[];
        await for (final state in strategy.signInStream(
          options: options,
          walletName: 'test-wallet',
          password: 'password',
        )) {
          states.add(state);
          break; // Only get the first state
        }

        expect(states, hasLength(1));
        expect(states.first.status, AuthenticationStatus.error);
        expect(
          states.first.error,
          contains(
            'WalletConnectAuthStrategy only supports WalletConnect private key policy',
          ),
        );
      });

      test('should start authentication flow for WalletConnect policy', () async {
        const options = AuthOptions(
          derivationMethod: DerivationMethod.hdWallet,
          privKeyPolicy: PrivateKeyPolicy.walletConnect('test-session'),
        );

        // Set up chain repository mocks
        when(
          () => mockEvmRepo.getEvmChainIds(),
        ).thenAnswer((_) async => ['eip155:1', 'eip155:137']);
        when(
          () => mockCosmosRepo.getCosmosChainIds(),
        ).thenAnswer((_) async => ['cosmos:cosmoshub-4', 'cosmos:osmosis-1']);

        // Set up auth service mocks
        when(
          () => mockAuthService.getUsers(),
        ).thenAnswer((_) async => <KdfUser>[]);

        // Set up user manager mocks
        const mockUser = KdfUser(
          walletId: WalletId(
            name: 'test-wallet',
            authOptions: AuthOptions(
              derivationMethod: DerivationMethod.hdWallet,
              privKeyPolicy: PrivateKeyPolicy.walletConnect('test_session'),
            ),
          ),
          isBip39Seed: false,
        );

        when(
          () => mockUserManager.createOrAuthenticateWallet(
            sessionTopic: any(named: 'sessionTopic'),
            derivationMethod: any(named: 'derivationMethod'),
            walletName: any(named: 'walletName'),
          ),
        ).thenAnswer((_) async => mockUser);

        when(
          () => mockUserManager.updateSessionTopic(
            newSessionTopic: any(named: 'newSessionTopic'),
            derivationMethod: any(named: 'derivationMethod'),
          ),
        ).thenAnswer((_) async => mockUser);

        // Mock dispose method
        when(() => mockUserManager.dispose()).thenReturn(null);

        // Mock the ping session to return failure (session doesn't exist)
        when(
          () => mockWalletConnectMethods.pingSession(topic: 'test-session'),
        ).thenThrow(Exception('Session not found'));

        // Mock the new connection response
        when(
          () => mockWalletConnectMethods.newConnection(
            requiredNamespaces: any(named: 'requiredNamespaces'),
          ),
        ).thenAnswer(
          (_) async => WcNewConnectionResponse(
            mmrpc: '2.0',
            uri:
                'wc:test-uri@1?bridge=https://bridge.walletconnect.org&key=test-key',
          ),
        );

        // Mock getSessions to return a session after connection
        when(() => mockWalletConnectMethods.getSessions()).thenAnswer(
          (_) async => WcGetSessionsResponse(
            mmrpc: '2.0',
            sessions: [
              WcSession(
                topic: 'test_session_topic',
                metadata: WcMetadata(
                  name: 'Test Wallet',
                  description: 'Test wallet for testing',
                  url: 'https://test.wallet',
                  icons: ['https://test.wallet/icon.png'],
                ),
                pairingTopic: 'test_pairing_topic',
                namespaces: {
                  'eip155': WcNamespace(
                    chains: ['eip155:1'],
                    methods: ['eth_sendTransaction'],
                    events: ['chainChanged'],
                    accounts: ['eip155:1:0x123'],
                  ),
                },
                expiry:
                    DateTime.now()
                        .add(const Duration(days: 1))
                        .millisecondsSinceEpoch ~/
                    1000,
              ),
            ],
          ),
        );

        final states = <AuthenticationState>[];
        final stream = strategy.signInStream(
          options: options,
          walletName: 'test-wallet',
          password: 'password',
        );

        // Listen to states until we get to waiting for connection
        final subscription = stream.listen(states.add);

        // Wait for states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));

        await subscription.cancel();

        expect(states, isNotEmpty);
        expect(states.first.status, AuthenticationStatus.initializing);

        // Should eventually reach QR code generation
        final qrCodeState = states.firstWhere(
          (state) => state.status == AuthenticationStatus.generatingQrCode,
          orElse: () => states.last,
        );
        expect(qrCodeState.status, AuthenticationStatus.generatingQrCode);
      });
    });

    group('registerStream', () {
      test('should emit error for non-WalletConnect policy', () async {
        const options = AuthOptions(
          derivationMethod: DerivationMethod.hdWallet,
        );

        final states = <AuthenticationState>[];
        await for (final state in strategy.registerStream(
          options: options,
          walletName: 'test-wallet',
          password: 'password',
        )) {
          states.add(state);
          break; // Only get the first state
        }

        expect(states, hasLength(1));
        expect(states.first.status, AuthenticationStatus.error);
        expect(
          states.first.error,
          contains(
            'WalletConnectAuthStrategy only supports WalletConnect private key policy',
          ),
        );
      });

      test('should start registration flow for WalletConnect policy', () async {
        const options = AuthOptions(
          derivationMethod: DerivationMethod.hdWallet,
          privKeyPolicy: PrivateKeyPolicy.walletConnect(''),
        );

        // Set up chain repository mocks
        when(
          () => mockEvmRepo.getEvmChainIds(),
        ).thenAnswer((_) async => ['eip155:1', 'eip155:137']);
        when(
          () => mockCosmosRepo.getCosmosChainIds(),
        ).thenAnswer((_) async => ['cosmos:cosmoshub-4', 'cosmos:osmosis-1']);

        // Set up auth service mocks
        when(
          () => mockAuthService.getUsers(),
        ).thenAnswer((_) async => <KdfUser>[]);

        // Set up user manager mocks
        const mockUser = KdfUser(
          walletId: WalletId(
            name: 'test-wallet',
            authOptions: AuthOptions(
              derivationMethod: DerivationMethod.hdWallet,
              privKeyPolicy: PrivateKeyPolicy.walletConnect('test_session'),
            ),
          ),
          isBip39Seed: false,
        );

        when(
          () => mockUserManager.createOrAuthenticateWallet(
            sessionTopic: any(named: 'sessionTopic'),
            derivationMethod: any(named: 'derivationMethod'),
            walletName: any(named: 'walletName'),
          ),
        ).thenAnswer((_) async => mockUser);

        when(
          () => mockUserManager.updateSessionTopic(
            newSessionTopic: any(named: 'newSessionTopic'),
            derivationMethod: any(named: 'derivationMethod'),
          ),
        ).thenAnswer((_) async => mockUser);

        // Mock dispose method
        when(() => mockUserManager.dispose()).thenReturn(null);

        // Mock the new connection response
        when(
          () => mockWalletConnectMethods.newConnection(
            requiredNamespaces: any(named: 'requiredNamespaces'),
          ),
        ).thenAnswer(
          (_) async => WcNewConnectionResponse(
            mmrpc: '2.0',
            uri:
                'wc:test-uri@1?bridge=https://bridge.walletconnect.org&key=test-key',
          ),
        );

        // Mock getSessions to return a session after connection
        when(() => mockWalletConnectMethods.getSessions()).thenAnswer(
          (_) async => WcGetSessionsResponse(
            mmrpc: '2.0',
            sessions: [
              WcSession(
                topic: 'test_session_topic',
                metadata: WcMetadata(
                  name: 'Test Wallet',
                  description: 'Test wallet for testing',
                  url: 'https://test.wallet',
                  icons: ['https://test.wallet/icon.png'],
                ),
                pairingTopic: 'test_pairing_topic',
                namespaces: {
                  'eip155': WcNamespace(
                    chains: ['eip155:1'],
                    methods: ['eth_sendTransaction'],
                    events: ['chainChanged'],
                    accounts: ['eip155:1:0x123'],
                  ),
                },
                expiry:
                    DateTime.now()
                        .add(const Duration(days: 1))
                        .millisecondsSinceEpoch ~/
                    1000,
              ),
            ],
          ),
        );

        final states = <AuthenticationState>[];
        final stream = strategy.registerStream(
          options: options,
          walletName: 'test-wallet',
          password: 'password',
        );

        // Listen to states until we get to waiting for connection
        final subscription = stream.listen(states.add);

        // Wait for states to be emitted
        await Future.delayed(const Duration(milliseconds: 100));

        await subscription.cancel();

        expect(states, isNotEmpty);

        // Should reach QR code generation
        final qrCodeState = states.firstWhere(
          (state) => state.status == AuthenticationStatus.generatingQrCode,
          orElse: () => states.last,
        );
        expect(qrCodeState.status, AuthenticationStatus.generatingQrCode);
      });
    });

    group('cancel', () {
      test('should complete without error', () async {
        await expectLater(strategy.cancel(null), completes);
      });

      test('should complete without error with task ID', () async {
        await expectLater(strategy.cancel(123), completes);
      });
    });

    group('dispose', () {
      test('should complete without error', () async {
        await expectLater(strategy.dispose(), completes);
      });
    });
  });
}
