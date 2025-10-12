import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

void main() {
  group('AuthenticationState', () {
    group('Basic state creation', () {
      test('should create AuthenticationState with required status', () {
        const state = AuthenticationState(
          status: AuthenticationStatus.authenticating,
        );

        expect(state.status, equals(AuthenticationStatus.authenticating));
        expect(state.message, isNull);
        expect(state.taskId, isNull);
        expect(state.error, isNull);
        expect(state.user, isNull);
        expect(state.data, isNull);
      });

      test('should create AuthenticationState with optional fields', () {
        const state = AuthenticationState(
          status: AuthenticationStatus.waitingForDevice,
          message: 'Waiting for device...',
          taskId: 12345,
        );

        expect(state.status, equals(AuthenticationStatus.waitingForDevice));
        expect(state.message, equals('Waiting for device...'));
        expect(state.taskId, equals(12345));
        expect(state.error, isNull);
        expect(state.user, isNull);
        expect(state.data, isNull);
      });
    });

    group('Factory constructors', () {
      test('should create completed state using factory constructor', () {
        final user = KdfUser(
          walletId: WalletId(
            name: 'test-wallet',
            authOptions: const AuthOptions(
              derivationMethod: DerivationMethod.hdWallet,
            ),
          ),
          isBip39Seed: true,
        );

        final state = AuthenticationState.completed(user);

        expect(state.status, equals(AuthenticationStatus.completed));
        expect(state.user, equals(user));
        expect(state.data, isNull);
      });

      test('should create error state using factory constructor', () {
        const errorMessage = 'Authentication failed';

        final state = AuthenticationState.error(errorMessage);

        expect(state.status, equals(AuthenticationStatus.error));
        expect(state.error, equals(errorMessage));
        expect(state.data, isNull);
      });
    });

    group('WalletConnect authentication statuses', () {
      test('should support generatingQrCode status', () {
        const state = AuthenticationState(
          status: AuthenticationStatus.generatingQrCode,
        );

        expect(state.status, equals(AuthenticationStatus.generatingQrCode));
      });

      test('should support waitingForConnection status', () {
        const state = AuthenticationState(
          status: AuthenticationStatus.waitingForConnection,
        );

        expect(state.status, equals(AuthenticationStatus.waitingForConnection));
      });

      test('should support walletConnected status', () {
        const state = AuthenticationState(
          status: AuthenticationStatus.walletConnected,
        );

        expect(state.status, equals(AuthenticationStatus.walletConnected));
      });

      test('should support sessionEstablished status', () {
        const state = AuthenticationState(
          status: AuthenticationStatus.sessionEstablished,
        );

        expect(state.status, equals(AuthenticationStatus.sessionEstablished));
      });
    });

    group('Authentication data', () {
      test('should create AuthenticationState with TrezorData', () {
        const taskId = 12345;
        const trezorData = AuthenticationData.trezor(taskId: taskId);

        final state = AuthenticationState(
          status: AuthenticationStatus.waitingForDevice,
          taskId: taskId,
          data: trezorData,
        );

        expect(state.status, equals(AuthenticationStatus.waitingForDevice));
        expect(state.data, equals(trezorData));
        expect(state.taskId, equals(taskId));
      });

      test('should create TrezorData with optional deviceInfo', () {
        const taskId = 12345;
        const deviceInfo = 'Trezor Model T';
        const trezorData = AuthenticationData.trezor(
          taskId: taskId,
          deviceInfo: deviceInfo,
        );

        final state = AuthenticationState(
          status: AuthenticationStatus.waitingForDeviceConfirmation,
          data: trezorData,
        );

        expect(state.data, equals(trezorData));
      });
    });
  });
}
