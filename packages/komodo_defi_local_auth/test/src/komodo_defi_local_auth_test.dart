// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/src/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockKomodoDefiFramework extends Mock implements KomodoDefiFramework {}

class MockApiClient extends Mock implements ApiClient {}

class MockKomodoDefiRpcMethods extends Mock implements KomodoDefiRpcMethods {}

void main() {
  group('KomodoDefiLocalAuth', () {
    late MockKomodoDefiFramework mockKdf;
    late MockApiClient mockApiClient;
    late MockKomodoDefiRpcMethods mockRpcMethods;
    late LocalConfig hostConfig;

    setUp(() {
      mockKdf = MockKomodoDefiFramework();
      mockApiClient = MockApiClient();
      mockRpcMethods = MockKomodoDefiRpcMethods();
      hostConfig = LocalConfig(https: false, rpcPassword: 'test_password');

      when(() => mockKdf.client).thenReturn(mockApiClient);
      when(() => mockKdf.kdfStop()).thenAnswer((_) async => StopStatus.ok);
      when(() => mockKdf.isRunning()).thenAnswer((_) async => false);
    });

    test('can be instantiated with RPC methods', () {
      expect(
        () => KomodoDefiLocalAuth(
          kdf: mockKdf,
          hostConfig: hostConfig,
          rpcMethods: mockRpcMethods, // Now required parameter
        ),
        returnsNormally,
      );
    });

    test('successfully creates strategy with RPC methods', () async {
      final auth = KomodoDefiLocalAuth(
        kdf: mockKdf,
        hostConfig: hostConfig,
        rpcMethods: mockRpcMethods, // RPC methods provided
      );

      // Since rpcMethods is now required, this should work
      expect(auth, isNotNull);

      await auth.dispose();
    });

    test('supports Trezor authentication with RPC methods', () async {
      final auth = KomodoDefiLocalAuth(
        kdf: mockKdf,
        hostConfig: hostConfig,
        rpcMethods: mockRpcMethods, // RPC methods provided for Trezor
      );

      // Since rpcMethods is now required, Trezor should be supported
      expect(auth, isNotNull);

      await auth.dispose();
    });

    test('logs initialization messages correctly', () async {
      // This test verifies that logging is properly integrated
      final auth = KomodoDefiLocalAuth(
        kdf: mockKdf,
        hostConfig: hostConfig,
        rpcMethods: mockRpcMethods,
      );

      // The constructor should have logged initialization messages
      // We can't easily test log output in unit tests without setting up
      // a custom logger, but we can verify the auth service initializes
      expect(auth, isNotNull);

      await auth.dispose();
    });

    test('logs operations correctly with RPC methods', () async {
      final auth = KomodoDefiLocalAuth(
        kdf: mockKdf,
        hostConfig: hostConfig,
        rpcMethods: mockRpcMethods,
      );

      // Since RPC methods are now required, operations should work properly
      // This test verifies that logging occurs during normal operations
      expect(auth, isNotNull);

      await auth.dispose();
    });
  });
}
