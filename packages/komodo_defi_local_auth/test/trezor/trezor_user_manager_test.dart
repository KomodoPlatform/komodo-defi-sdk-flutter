import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_defi_local_auth/src/auth/auth_service.dart';
import 'package:komodo_defi_local_auth/src/trezor/trezor_user_manager.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements IAuthService {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// Fake classes for mocktail fallback values
class FakeAuthOptions extends Fake implements AuthOptions {}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeAuthOptions());
  });
  group('TrezorUserManager', () {
    late TrezorUserManager userManager;
    late MockAuthService mockAuthService;
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockAuthService = MockAuthService();
      mockSecureStorage = MockFlutterSecureStorage();
      userManager = TrezorUserManager(
        mockAuthService,
        secureStorage: mockSecureStorage,
        passwordGenerator: (length) => 'test_password_$length',
      );
    });

    tearDown(() {
      userManager.dispose();
    });

    group('getOrGeneratePassword', () {
      test('should return existing password for existing user', () async {
        // Arrange
        const existingPassword = 'existing_password';
        when(
          () => mockSecureStorage.read(key: 'trezor_wallet_password'),
        ).thenAnswer((_) async => existingPassword);

        // Act
        final password = await userManager.getOrGeneratePassword(
          isNewUser: false,
        );

        // Assert
        expect(password, equals(existingPassword));
        verify(
          () => mockSecureStorage.read(key: 'trezor_wallet_password'),
        ).called(1);
        verifyNever(
          () => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        );
      });

      test(
        'should throw exception when no password found for existing user',
        () async {
          // Arrange
          when(
            () => mockSecureStorage.read(key: 'trezor_wallet_password'),
          ).thenAnswer((_) async => null);

          // Act & Assert
          expect(
            () => userManager.getOrGeneratePassword(isNewUser: false),
            throwsA(isA<AuthException>()),
          );
        },
      );

      test('should generate and store new password for new user', () async {
        // Arrange
        when(
          () => mockSecureStorage.read(key: 'trezor_wallet_password'),
        ).thenAnswer((_) async => null);
        when(
          () => mockSecureStorage.write(
            key: 'trezor_wallet_password',
            value: 'test_password_16',
          ),
        ).thenAnswer((_) async {});

        // Act
        final password = await userManager.getOrGeneratePassword(
          isNewUser: true,
        );

        // Assert
        expect(password, equals('test_password_16'));
        verify(
          () => mockSecureStorage.read(key: 'trezor_wallet_password'),
        ).called(1);
        verify(
          () => mockSecureStorage.write(
            key: 'trezor_wallet_password',
            value: 'test_password_16',
          ),
        ).called(1);
      });
    });

    group('clearStoredPassword', () {
      test('should delete stored password', () async {
        // Arrange
        when(
          () => mockSecureStorage.delete(key: 'trezor_wallet_password'),
        ).thenAnswer((_) async {});

        // Act
        await userManager.clearStoredPassword();

        // Assert
        verify(
          () => mockSecureStorage.delete(key: 'trezor_wallet_password'),
        ).called(1);
      });
    });

    group('findExistingUser', () {
      test('should return Trezor user if found', () async {
        // Arrange
        final mockUser = _createMockTrezorUser();
        final users = [mockUser, _createMockWalletConnectUser()];
        when(() => mockAuthService.getUsers()).thenAnswer((_) async => users);

        // Act
        final result = await userManager.findExistingUser();

        // Assert
        expect(result, equals(mockUser));
      });

      test('should return null if no Trezor user found', () async {
        // Arrange
        final users = [_createMockWalletConnectUser()];
        when(() => mockAuthService.getUsers()).thenAnswer((_) async => users);

        // Act
        final result = await userManager.findExistingUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('authenticateWallet', () {
      test('should sign in with existing user', () async {
        // Arrange
        final existingUser = _createMockTrezorUser();
        const authOptions = AuthOptions(
          derivationMethod: DerivationMethod.iguana,
          privKeyPolicy: PrivateKeyPolicy.trezor(),
        );
        when(
          () => mockAuthService.signIn(
            walletName: 'My Trezor',
            password: 'test_password',
            options: authOptions,
          ),
        ).thenAnswer((_) async => existingUser);

        // Act
        final result = await userManager.authenticateWallet(
          existingUser: existingUser,
          password: 'test_password',
          authOptions: authOptions,
        );

        // Assert
        expect(result, equals(existingUser));
        verify(
          () => mockAuthService.signIn(
            walletName: 'My Trezor',
            password: 'test_password',
            options: authOptions,
          ),
        ).called(1);
      });

      test('should register new user', () async {
        // Arrange
        final newUser = _createMockTrezorUser();
        const authOptions = AuthOptions(
          derivationMethod: DerivationMethod.iguana,
          privKeyPolicy: PrivateKeyPolicy.trezor(),
        );
        when(
          () => mockAuthService.register(
            walletName: 'My Trezor',
            password: 'test_password',
            options: authOptions,
          ),
        ).thenAnswer((_) async => newUser);

        // Act
        final result = await userManager.authenticateWallet(
          existingUser: null,
          password: 'test_password',
          authOptions: authOptions,
        );

        // Assert
        expect(result, equals(newUser));
        verify(
          () => mockAuthService.register(
            walletName: 'My Trezor',
            password: 'test_password',
            options: authOptions,
          ),
        ).called(1);
      });
    });

    group('createOrAuthenticateWallet', () {
      test('should create new wallet when no existing user', () async {
        // Arrange
        when(
          () => mockAuthService.getActiveUser(),
        ).thenAnswer((_) async => null);
        when(() => mockAuthService.getUsers()).thenAnswer((_) async => []);
        when(
          () => mockSecureStorage.read(key: 'trezor_wallet_password'),
        ).thenAnswer((_) async => null);
        when(
          () => mockSecureStorage.write(
            key: 'trezor_wallet_password',
            value: 'test_password_16',
          ),
        ).thenAnswer((_) async {});

        final newUser = _createMockTrezorUser();
        when(
          () => mockAuthService.register(
            walletName: 'My Trezor',
            password: 'test_password_16',
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) async => newUser);

        // Act
        final result = await userManager.createOrAuthenticateWallet(
          derivationMethod: DerivationMethod.iguana,
        );

        // Assert
        expect(result, equals(newUser));
        verify(
          () => mockAuthService.register(
            walletName: 'My Trezor',
            password: 'test_password_16',
            options: any(named: 'options'),
          ),
        ).called(1);
      });
    });

    group('isUserForThisWallet', () {
      test('should return true for Trezor user', () {
        // Arrange
        final trezorUser = _createMockTrezorUser();

        // Act
        final result = userManager.isUserForThisWallet(trezorUser);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for non-Trezor user', () {
        // Arrange
        final wcUser = _createMockWalletConnectUser();

        // Act
        final result = userManager.isUserForThisWallet(wcUser);

        // Assert
        expect(result, isFalse);
      });
    });

    group('hasActiveTrezorUser', () {
      test('should return true when active user is Trezor', () async {
        // Arrange
        final trezorUser = _createMockTrezorUser();
        when(
          () => mockAuthService.getActiveUser(),
        ).thenAnswer((_) async => trezorUser);

        // Act
        final result = await userManager.hasActiveTrezorUser();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when no active user', () async {
        // Arrange
        when(
          () => mockAuthService.getActiveUser(),
        ).thenAnswer((_) async => null);

        // Act
        final result = await userManager.hasActiveTrezorUser();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when active user is not Trezor', () async {
        // Arrange
        final wcUser = _createMockWalletConnectUser();
        when(
          () => mockAuthService.getActiveUser(),
        ).thenAnswer((_) async => wcUser);

        // Act
        final result = await userManager.hasActiveTrezorUser();

        // Assert
        expect(result, isFalse);
      });
    });
  });
}

KdfUser _createMockTrezorUser() {
  return const KdfUser(
    walletId: WalletId(
      name: 'My Trezor',
      authOptions: AuthOptions(
        derivationMethod: DerivationMethod.iguana,
        privKeyPolicy: PrivateKeyPolicy.trezor(),
      ),
    ),
    isBip39Seed: false,
  );
}

KdfUser _createMockWalletConnectUser() {
  return const KdfUser(
    walletId: WalletId(
      name: 'My WalletConnect',
      authOptions: AuthOptions(
        derivationMethod: DerivationMethod.iguana,
        privKeyPolicy: PrivateKeyPolicy.walletConnect('test_topic'),
      ),
    ),
    isBip39Seed: false,
  );
}
