import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_state.dart';
import 'package:komodo_defi_local_auth/src/auth/strategies/regular_auth_strategy.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements IAuthService {}

void main() {
  group('RegularAuthStrategy', () {
    late MockAuthService mockAuthService;
    late RegularAuthStrategy strategy;

    setUp(() {
      mockAuthService = MockAuthService();
      strategy = RegularAuthStrategy(mockAuthService);
    });

    group('signInStream', () {
      test('should emit error when wallet name is null', () async {
        const options = AuthOptions(
          derivationMethod: DerivationMethod.hdWallet,
          privKeyPolicy: PrivateKeyPolicy.contextPrivKey(),
        );

        final states = <AuthenticationState>[];
        await for (final state in strategy.signInStream(
          options: options,
          walletName: null,
          password: 'password',
        )) {
          states.add(state);
          break; // Only get the first state
        }

        expect(states, hasLength(1));
        expect(states.first.status, AuthenticationStatus.error);
        expect(
          states.first.error,
          contains('Wallet name and password are required'),
        );
      });

      test('should emit error for non-context private key policy', () async {
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
            'RegularAuthStrategy only supports context private key policy',
          ),
        );
      });

      test(
        'should emit authenticating then completed states on success',
        () async {
          const options = AuthOptions(
            derivationMethod: DerivationMethod.hdWallet,
            privKeyPolicy: PrivateKeyPolicy.contextPrivKey(),
          );

          final mockUser = KdfUser(
            walletId: WalletId.fromName('test-wallet', options),
            isBip39Seed: false,
            metadata: const {},
          );

          when(
            () => mockAuthService.signIn(
              walletName: 'test-wallet',
              password: 'password',
              options: options,
            ),
          ).thenAnswer((_) async => mockUser);

          final states = <AuthenticationState>[];
          await for (final state in strategy.signInStream(
            options: options,
            walletName: 'test-wallet',
            password: 'password',
          )) {
            states.add(state);
          }

          expect(states, hasLength(2));
          expect(states[0].status, AuthenticationStatus.authenticating);
          expect(states[0].message, 'Signing in...');
          expect(states[1].status, AuthenticationStatus.completed);
          expect(states[1].user, mockUser);
        },
      );
    });

    group('registerStream', () {
      test(
        'should emit authenticating then completed states on success',
        () async {
          const options = AuthOptions(
            derivationMethod: DerivationMethod.hdWallet,
            privKeyPolicy: PrivateKeyPolicy.contextPrivKey(),
          );

          final mockUser = KdfUser(
            walletId: WalletId.fromName('test-wallet', options),
            isBip39Seed: false,
            metadata: const {},
          );

          when(
            () => mockAuthService.register(
              walletName: 'test-wallet',
              password: 'password',
              options: options,
              mnemonic: null,
            ),
          ).thenAnswer((_) async => mockUser);

          final states = <AuthenticationState>[];
          await for (final state in strategy.registerStream(
            options: options,
            walletName: 'test-wallet',
            password: 'password',
          )) {
            states.add(state);
          }

          expect(states, hasLength(2));
          expect(states[0].status, AuthenticationStatus.authenticating);
          expect(states[0].message, 'Registering wallet...');
          expect(states[1].status, AuthenticationStatus.completed);
          expect(states[1].user, mockUser);
        },
      );
    });

    group('cancel', () {
      test('should complete without error', () async {
        await expectLater(strategy.cancel(null), completes);
      });
    });

    group('dispose', () {
      test('should complete without error', () async {
        await expectLater(strategy.dispose(), completes);
      });
    });
  });
}
