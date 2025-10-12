import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/auth_strategy_factory.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/regular_auth_strategy.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/trezor_auth_strategy.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/walletconnect_auth_strategy.dart';
import 'package:komodo_defi_local_auth/src/trezor/trezor_repository.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements IAuthService {}

class MockApiClient extends Mock implements ApiClient {}

class MockKomodoDefiRpcMethods extends Mock implements KomodoDefiRpcMethods {}

class MockWalletConnectMethodsNamespace extends Mock
    implements WalletConnectMethodsNamespace {}

class MockTrezorRepository extends Mock implements TrezorRepository {}

void main() {
  group('AuthStrategyFactory', () {
    late MockAuthService mockAuthService;
    late MockApiClient mockApiClient;
    late MockKomodoDefiRpcMethods mockRpcMethods;
    late MockWalletConnectMethodsNamespace mockWalletConnectMethods;
    late MockTrezorRepository mockTrezorRepository;

    setUp(() {
      mockAuthService = MockAuthService();
      mockApiClient = MockApiClient();
      mockRpcMethods = MockKomodoDefiRpcMethods();
      mockWalletConnectMethods = MockWalletConnectMethodsNamespace();
      mockTrezorRepository = MockTrezorRepository();

      when(
        () => mockRpcMethods.walletConnect,
      ).thenReturn(mockWalletConnectMethods);
    });

    group('createStrategy', () {
      test('should create RegularAuthStrategy for contextPrivKey policy', () {
        const policy = PrivateKeyPolicy.contextPrivKey();

        final strategy = AuthStrategyFactory.createStrategy(
          policy,
          mockAuthService,
          mockApiClient,
          rpcMethods: mockRpcMethods,
        );

        expect(strategy, isA<RegularAuthStrategy>());
      });

      test('should create TrezorAuthStrategy for trezor policy', () {
        const policy = PrivateKeyPolicy.trezor();

        final strategy = AuthStrategyFactory.createStrategy(
          policy,
          mockAuthService,
          mockApiClient,
          rpcMethods: mockRpcMethods,
        );

        expect(strategy, isA<TrezorAuthStrategy>());
      });

      test('should create TrezorAuthStrategy with provided repository', () {
        const policy = PrivateKeyPolicy.trezor();

        final strategy = AuthStrategyFactory.createStrategy(
          policy,
          mockAuthService,
          mockApiClient,
          rpcMethods: mockRpcMethods,
          trezorRepository: mockTrezorRepository,
        );

        expect(strategy, isA<TrezorAuthStrategy>());
      });

      test(
        'should create WalletConnectAuthStrategy for walletConnect policy',
        () {
          const policy = PrivateKeyPolicy.walletConnect('test-session');

          final strategy = AuthStrategyFactory.createStrategy(
            policy,
            mockAuthService,
            mockApiClient,
            rpcMethods: mockRpcMethods,
          );

          expect(strategy, isA<WalletConnectAuthStrategy>());
        },
      );

      test('should throw error for metamask policy', () {
        const policy = PrivateKeyPolicy.metamask();

        expect(
          () => AuthStrategyFactory.createStrategy(
            policy,
            mockAuthService,
            mockApiClient,
            rpcMethods: mockRpcMethods,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('validateDependencies', () {
      test(
        'should return true for contextPrivKey policy with dependencies',
        () {
          const policy = PrivateKeyPolicy.contextPrivKey();

          final result = AuthStrategyFactory.validateDependencies(
            policy,
            apiClient: mockApiClient,
            rpcMethods: mockRpcMethods,
          );

          expect(result, isTrue);
        },
      );

      test('should return true for trezor policy with dependencies', () {
        const policy = PrivateKeyPolicy.trezor();

        final result = AuthStrategyFactory.validateDependencies(
          policy,
          apiClient: mockApiClient,
          rpcMethods: mockRpcMethods,
        );

        expect(result, isTrue);
      });

      test('should return true for walletConnect policy with dependencies', () {
        const policy = PrivateKeyPolicy.walletConnect('test-session');

        final result = AuthStrategyFactory.validateDependencies(
          policy,
          apiClient: mockApiClient,
          rpcMethods: mockRpcMethods,
        );

        expect(result, isTrue);
      });

      test('should return false for metamask policy', () {
        const policy = PrivateKeyPolicy.metamask();

        final result = AuthStrategyFactory.validateDependencies(
          policy,
          apiClient: mockApiClient,
          rpcMethods: mockRpcMethods,
        );

        expect(result, isFalse);
      });
    });

    group('getStrategyDescription', () {
      test('should return correct description for contextPrivKey', () {
        const policy = PrivateKeyPolicy.contextPrivKey();

        final description = AuthStrategyFactory.getStrategyDescription(policy);

        expect(description, contains('Regular wallet authentication'));
      });

      test('should return correct description for trezor', () {
        const policy = PrivateKeyPolicy.trezor();

        final description = AuthStrategyFactory.getStrategyDescription(policy);

        expect(description, contains('Trezor hardware wallet'));
      });

      test('should return correct description for walletConnect', () {
        const policy = PrivateKeyPolicy.walletConnect('test-session');

        final description = AuthStrategyFactory.getStrategyDescription(policy);

        expect(description, contains('WalletConnect mobile wallet'));
        expect(description, contains('test-session'));
      });

      test(
        'should return correct description for empty walletConnect session',
        () {
          const policy = PrivateKeyPolicy.walletConnect('');

          final description = AuthStrategyFactory.getStrategyDescription(
            policy,
          );

          expect(description, contains('WalletConnect mobile wallet'));
          expect(description, contains('new'));
        },
      );

      test('should return correct description for metamask', () {
        const policy = PrivateKeyPolicy.metamask();

        final description = AuthStrategyFactory.getStrategyDescription(policy);

        expect(description, contains('MetaMask browser wallet'));
        expect(description, contains('not implemented'));
      });
    });

    group('getSupportedPolicies', () {
      test('should return list of supported policies', () {
        final policies = AuthStrategyFactory.getSupportedPolicies();

        expect(policies, hasLength(3));
        expect(policies, contains(const PrivateKeyPolicy.contextPrivKey()));
        expect(policies, contains(const PrivateKeyPolicy.trezor()));
        expect(policies, contains(const PrivateKeyPolicy.walletConnect('')));
      });
    });

    group('isPolicySupported', () {
      test('should return true for contextPrivKey', () {
        const policy = PrivateKeyPolicy.contextPrivKey();

        final result = AuthStrategyFactory.isPolicySupported(policy);

        expect(result, isTrue);
      });

      test('should return true for trezor', () {
        const policy = PrivateKeyPolicy.trezor();

        final result = AuthStrategyFactory.isPolicySupported(policy);

        expect(result, isTrue);
      });

      test('should return true for walletConnect', () {
        const policy = PrivateKeyPolicy.walletConnect('test-session');

        final result = AuthStrategyFactory.isPolicySupported(policy);

        expect(result, isTrue);
      });

      test('should return false for metamask', () {
        const policy = PrivateKeyPolicy.metamask();

        final result = AuthStrategyFactory.isPolicySupported(policy);

        expect(result, isFalse);
      });
    });
  });
}
