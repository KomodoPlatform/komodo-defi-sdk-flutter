import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_coins/src/komodo_coins_base.dart';

void main() {
  group('KomodoCoins Cold Start Caching', () {
    test('can be imported and instantiated', () {
      // This test just verifies that the class can be imported and instantiated
      // The actual caching behavior will be tested in integration tests
      expect(KomodoCoins.new, returnsNormally);
    });

    test('has expected constructor parameters', () {
      // Verify that the constructor accepts the expected parameters
      final instance = KomodoCoins(
        enableAutoUpdate: false,
        appStoragePath: '/test/path',
        appName: 'test_app',
      );

      expect(instance, isNotNull);
      expect(instance.enableAutoUpdate, isFalse);
      expect(instance.appStoragePath, equals('/test/path'));
      expect(instance.appName, equals('test_app'));
    });
  });
}
