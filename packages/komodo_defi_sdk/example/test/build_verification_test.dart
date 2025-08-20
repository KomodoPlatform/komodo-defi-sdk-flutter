import 'package:flutter_test/flutter_test.dart';
import 'package:kdf_sdk_example/blocs/migration/migration_bloc.dart';
import 'package:kdf_sdk_example/blocs/migration/migration_models.dart';
import 'package:kdf_sdk_example/widgets/migration/initiate_migration_screen.dart';
import 'package:kdf_sdk_example/widgets/migration/migration_preview_screen.dart';
import 'package:kdf_sdk_example/widgets/migration/migration_results_screen.dart';
import 'package:kdf_sdk_example/widgets/migration/migration_widget.dart';
import 'package:kdf_sdk_example/widgets/migration/scanning_balances_screen.dart';
import 'package:kdf_sdk_example/widgets/migration/transferring_funds_screen.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

void main() {
  group('Build Verification Tests', () {
    test('MigrationBloc can be instantiated without SDK', () {
      expect(() => MigrationBloc(), returnsNormally);
    });

    test('MigrationState models work correctly', () {
      final initialState = MigrationState.initial();
      expect(initialState.status, equals(MigrationFlowStatus.idle));
      expect(initialState.coins, isEmpty);

      final scanningState = MigrationState.scanning();
      expect(scanningState.status, equals(MigrationFlowStatus.scanning));

      final coin = MigrationCoin.ready(
        asset: const Asset(
          id: AssetId('TEST'),
          name: 'Test Coin',
          symbol: 'TEST',
          decimals: 8,
          logoUrl: '',
        ),
        balance: '10.0',
      );

      expect(coin.canMigrate, isTrue);
      expect(coin.statusMessage, equals('Ready'));
    });

    test('MigrationCoin factory methods work correctly', () {
      final asset = const Asset(
        id: AssetId('KMD'),
        name: 'Komodo',
        symbol: 'KMD',
        decimals: 8,
        logoUrl: '',
      );

      final readyCoin = MigrationCoin.ready(asset: asset, balance: '10.0');
      expect(readyCoin.status, equals(CoinMigrationStatus.ready));
      expect(readyCoin.canMigrate, isTrue);

      final feeTooLowCoin = MigrationCoin.feeTooLow(
        asset: asset,
        balance: '0.001',
        errorMessage: 'Balance too low',
      );
      expect(feeTooLowCoin.status, equals(CoinMigrationStatus.feeTooLow));
      expect(feeTooLowCoin.canMigrate, isFalse);
      expect(feeTooLowCoin.hasFailed, isTrue);

      final transferredCoin = MigrationCoin.transferred(
        asset: asset,
        balance: '10.0',
        transactionId: 'tx123',
      );
      expect(transferredCoin.status, equals(CoinMigrationStatus.transferred));
      expect(transferredCoin.isSuccess, isTrue);
      expect(transferredCoin.transactionId, equals('tx123'));

      final failedCoin = MigrationCoin.failed(
        asset: asset,
        balance: '10.0',
        errorMessage: 'Network error',
      );
      expect(failedCoin.status, equals(CoinMigrationStatus.failed));
      expect(failedCoin.canRetry, isTrue);
      expect(failedCoin.hasFailed, isTrue);
    });

    test('MigrationSummary calculations work correctly', () {
      final coins = [
        MigrationCoin.transferred(
          asset: const Asset(
            id: AssetId('KMD'),
            name: 'Komodo',
            symbol: 'KMD',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '10.0',
          transactionId: 'tx1',
        ),
        MigrationCoin.failed(
          asset: const Asset(
            id: AssetId('BTC'),
            name: 'Bitcoin',
            symbol: 'BTC',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '0.1',
          errorMessage: 'Network error',
        ),
        MigrationCoin.feeTooLow(
          asset: const Asset(
            id: AssetId('ETH'),
            name: 'Ethereum',
            symbol: 'ETH',
            decimals: 18,
            logoUrl: '',
          ),
          balance: '0.001',
          errorMessage: 'Fee too low',
        ),
      ];

      final state = MigrationState.completed(coins: coins);
      final summary = MigrationSummary.fromState(state);

      expect(summary.totalCoins, equals(3));
      expect(summary.successfulCoins, equals(1));
      expect(summary.failedCoins, equals(2));
      expect(summary.isPartialSuccess, isTrue);
      expect(summary.isFullSuccess, isFalse);
      expect(summary.isCompleteFailure, isFalse);
    });

    test('Migration flow status transitions work correctly', () {
      final bloc = MigrationBloc();

      expect(bloc.state.status, equals(MigrationFlowStatus.idle));
      expect(bloc.isInProgress, isFalse);
      expect(bloc.isCompleted, isFalse);

      bloc.emit(MigrationState.scanning());
      expect(bloc.isInProgress, isTrue);
      expect(bloc.isCompleted, isFalse);

      bloc.emit(MigrationState.transferring(coins: const []));
      expect(bloc.isInProgress, isTrue);
      expect(bloc.isCompleted, isFalse);

      bloc.emit(MigrationState.completed(coins: const []));
      expect(bloc.isInProgress, isFalse);
      expect(bloc.isCompleted, isTrue);

      bloc.close();
    });

    test('MigrationState helper properties work correctly', () {
      final readyCoins = [
        MigrationCoin.ready(
          asset: const Asset(
            id: AssetId('KMD'),
            name: 'Komodo',
            symbol: 'KMD',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '10.0',
        ),
      ];

      final failedCoins = [
        MigrationCoin.failed(
          asset: const Asset(
            id: AssetId('BTC'),
            name: 'Bitcoin',
            symbol: 'BTC',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '0.1',
          errorMessage: 'Error',
        ),
      ];

      final allCoins = [...readyCoins, ...failedCoins];

      final state = MigrationState.preview(coins: allCoins);

      expect(state.migrateableCoins.length, equals(1));
      expect(state.failedCoins.length, equals(1));
      expect(state.hasCoinsToMigrate, isTrue);
      expect(state.progress, equals(0.0)); // No completed coins yet

      final completedState = MigrationState.completed(
        coins: [
          readyCoins.first.copyWith(
            status: CoinMigrationStatus.transferred,
            transactionId: 'tx123',
          ),
          ...failedCoins,
        ],
      );

      expect(completedState.successfulCoins.length, equals(1));
      expect(completedState.failedCoins.length, equals(1));
      expect(completedState.progress, equals(1.0)); // All coins processed
    });

    test('All widget classes can be imported without errors', () {
      // This test verifies that all the migration widget classes
      // can be imported and don't have compilation errors

      expect(InitiateMigrationScreen, isNotNull);
      expect(ScanningBalancesScreen, isNotNull);
      expect(MigrationPreviewScreen, isNotNull);
      expect(TransferringFundsScreen, isNotNull);
      expect(MigrationResultsScreen, isNotNull);
      expect(MigrationWidget, isNotNull);
    });

    test('Widget constructors work correctly', () {
      final testCoins = [
        MigrationCoin.ready(
          asset: const Asset(
            id: AssetId('TEST'),
            name: 'Test',
            symbol: 'TEST',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '1.0',
        ),
      ];

      expect(
        () => const InitiateMigrationScreen(),
        returnsNormally,
      );

      expect(
        () => const ScanningBalancesScreen(),
        returnsNormally,
      );

      expect(
        () => MigrationPreviewScreen(coins: testCoins),
        returnsNormally,
      );

      expect(
        () => TransferringFundsScreen(coins: testCoins),
        returnsNormally,
      );

      expect(
        () => MigrationResultsScreen(coins: testCoins),
        returnsNormally,
      );

      expect(
        () => const MigrationWidget(),
        returnsNormally,
      );
    });
  });
}
