import 'package:flutter_test/flutter_test.dart';
import 'package:kdf_sdk_example/migrations/bloc/migration_bloc_exports.dart';
import 'package:kdf_sdk_example/widgets/migration/initiate_migration_screen.dart';
import 'package:kdf_sdk_example/widgets/migration/migration_preview_screen.dart';
import 'package:kdf_sdk_example/widgets/migration/migration_results_screen.dart';
import 'package:kdf_sdk_example/widgets/migration/migration_widget.dart';
import 'package:kdf_sdk_example/widgets/migration/scanning_balances_screen.dart';
import 'package:kdf_sdk_example/widgets/migration/transferring_funds_screen.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

void main() {
  group('Build Verification Tests', () {
    test('Migration exports are accessible', () {
      // Test that we can reference the migration classes without compilation errors
      expect(MigrationFlowStatus.idle, isA<MigrationFlowStatus>());
      expect(CoinMigrationStatus.ready, isA<CoinMigrationStatus>());
      expect(MigrationState, isA<Type>());
      expect(MigrationEvent, isA<Type>());
      expect(MigrationCoin, isA<Type>());
    });

    test('Migration widgets can be instantiated', () {
      // Test that widgets can be constructed without runtime errors
      expect(() => const InitiateMigrationScreen(), returnsNormally);
      expect(() => const ScanningBalancesScreen(), returnsNormally);
      expect(() => const MigrationWidget(), returnsNormally);
    });

    test('Migration state has correct initial values', () {
      const state = MigrationState();
      expect(state.status, equals(MigrationFlowStatus.idle));
      expect(state.coins, isEmpty);
      expect(state.currentCoinIndex, equals(0));
      expect(state.errorMessage, isNull);
    });

    test('Migration coin status enum values exist', () {
      expect(CoinMigrationStatus.ready, isNotNull);
      expect(CoinMigrationStatus.feeTooLow, isNotNull);
      expect(CoinMigrationStatus.notSupported, isNotNull);
      expect(CoinMigrationStatus.transferring, isNotNull);
      expect(CoinMigrationStatus.transferred, isNotNull);
      expect(CoinMigrationStatus.failed, isNotNull);
      expect(CoinMigrationStatus.skipped, isNotNull);
    });

    test('Migration flow status enum values exist', () {
      expect(MigrationFlowStatus.idle, isNotNull);
      expect(MigrationFlowStatus.scanning, isNotNull);
      expect(MigrationFlowStatus.preview, isNotNull);
      expect(MigrationFlowStatus.transferring, isNotNull);
      expect(MigrationFlowStatus.completed, isNotNull);
      expect(MigrationFlowStatus.error, isNotNull);
    });
  });
}
