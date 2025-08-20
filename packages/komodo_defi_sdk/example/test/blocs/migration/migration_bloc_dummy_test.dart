import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kdf_sdk_example/blocs/migration/migration_bloc.dart';
import 'package:kdf_sdk_example/blocs/migration/migration_models.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

void main() {
  group('MigrationBloc - Dummy Data Tests', () {
    late MigrationBloc migrationBloc;

    setUp(() {
      migrationBloc = MigrationBloc();
    });

    tearDown(() {
      migrationBloc.close();
    });

    test('initial state is correct', () {
      expect(
        migrationBloc.state,
        equals(MigrationState.initial()),
      );
    });

    blocTest<MigrationBloc, MigrationState>(
      'full migration flow with dummy data completes successfully',
      build: () => migrationBloc,
      act: (bloc) => bloc.add(const MigrationInitiated(
        sourceWalletName: 'Test Legacy Wallet',
        destinationWalletName: 'Test HD Wallet',
      )),
      wait: const Duration(seconds: 4), // Wait for scanning to complete
      verify: (bloc) {
        // Should have moved through scanning to preview or further
        expect(bloc.state.status, isNot(MigrationFlowStatus.idle));
        expect(bloc.state.status, isNot(MigrationFlowStatus.scanning));
      },
    );

    blocTest<MigrationBloc, MigrationState>(
      'scanning finds dummy coins',
      build: () => migrationBloc,
      act: (bloc) => bloc.add(const MigrationInitiated()),
      wait: const Duration(seconds: 4),
      verify: (bloc) {
        // Should have found some coins
        expect(bloc.state.coins.isNotEmpty, isTrue);

        // Should have specific dummy coins
        final coinSymbols = bloc.state.coins.map((c) => c.asset.symbol).toList();
        expect(coinSymbols, contains('KMD'));
        expect(coinSymbols, contains('RFOX'));
        expect(coinSymbols, contains('LTC'));
        expect(coinSymbols, contains('DOGE'));
        expect(coinSymbols, contains('BTC')); // Should be present but with fee issues

        // Should have some coins ready to migrate
        final readyCoins = bloc.state.coins.where((c) => c.canMigrate).toList();
        expect(readyCoins.isNotEmpty, isTrue);

        // Should have some problematic coins
        final problemCoins = bloc.state.coins.where((c) => c.hasFailed).toList();
        expect(problemCoins.isNotEmpty, isTrue);
      },
    );

    blocTest<MigrationBloc, MigrationState>(
      'migration confirmation starts transfer process',
      build: () => migrationBloc,
      seed: () => MigrationState.preview(coins: [
        MigrationCoin.ready(
          asset: const Asset(
            id: AssetId('TEST'),
            name: 'Test Coin',
            symbol: 'TEST',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '10.0',
        ),
      ]),
      act: (bloc) => bloc.add(const MigrationConfirmed()),
      expect: () => [
        isA<MigrationState>()
            .having((s) => s.status, 'status', MigrationFlowStatus.transferring)
      ],
    );

    blocTest<MigrationBloc, MigrationState>(
      'migration can be cancelled',
      build: () => migrationBloc,
      seed: () => MigrationState.scanning(),
      act: (bloc) => bloc.add(const MigrationCancelled()),
      expect: () => [
        MigrationState.initial(),
      ],
    );

    blocTest<MigrationBloc, MigrationState>(
      'migration can be reset from any state',
      build: () => migrationBloc,
      seed: () => MigrationState.completed(coins: [
        MigrationCoin.transferred(
          asset: const Asset(
            id: AssetId('TEST'),
            name: 'Test Coin',
            symbol: 'TEST',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '10.0',
          transactionId: 'test_tx_123',
        ),
      ]),
      act: (bloc) => bloc.add(const MigrationReset()),
      expect: () => [
        MigrationState.initial(),
      ],
    );

    test('helper methods work correctly', () {
      // Test with scanning state
      migrationBloc.emit(MigrationState.scanning());
      expect(migrationBloc.isInProgress, isTrue);
      expect(migrationBloc.isCompleted, isFalse);

      // Test with completed state
      final completedCoins = [
        MigrationCoin.transferred(
          asset: const Asset(
            id: AssetId('KMD'),
            name: 'Komodo',
            symbol: 'KMD',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '10.0',
          transactionId: 'tx123',
        ),
        MigrationCoin.failed(
          asset: const Asset(
            id: AssetId('BTC'),
            name: 'Bitcoin',
            symbol: 'BTC',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '0.001',
          errorMessage: 'Fee too low',
        ),
      ];

      migrationBloc.emit(MigrationState.completed(coins: completedCoins));
      expect(migrationBloc.isInProgress, isFalse);
      expect(migrationBloc.isCompleted, isTrue);

      final summary = migrationBloc.summary;
      expect(summary.totalCoins, equals(2));
      expect(summary.successfulCoins, equals(1));
      expect(summary.failedCoins, equals(1));
    });

    test('coin status types work correctly', () {
      final readyCoin = MigrationCoin.ready(
        asset: const Asset(
          id: AssetId('KMD'),
          name: 'Komodo',
          symbol: 'KMD',
          decimals: 8,
          logoUrl: '',
        ),
        balance: '10.0',
      );

      expect(readyCoin.canMigrate, isTrue);
      expect(readyCoin.isInProgress, isFalse);
      expect(readyCoin.isSuccess, isFalse);
      expect(readyCoin.hasFailed, isFalse);
      expect(readyCoin.canRetry, isFalse);
      expect(readyCoin.statusMessage, equals('Ready'));

      final failedCoin = MigrationCoin.failed(
        asset: const Asset(
          id: AssetId('BTC'),
          name: 'Bitcoin',
          symbol: 'BTC',
          decimals: 8,
          logoUrl: '',
        ),
        balance: '0.001',
        errorMessage: 'Network error',
      );

      expect(failedCoin.canMigrate, isFalse);
      expect(failedCoin.isInProgress, isFalse);
      expect(failedCoin.isSuccess, isFalse);
      expect(failedCoin.hasFailed, isTrue);
      expect(failedCoin.canRetry, isTrue);
      expect(failedCoin.statusMessage, equals('Failed'));
      expect(failedCoin.errorMessage, equals('Network error'));
    });

    test('migration summary calculations work correctly', () {
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
        MigrationCoin.transferred(
          asset: const Asset(
            id: AssetId('LTC'),
            name: 'Litecoin',
            symbol: 'LTC',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '5.0',
          transactionId: 'tx2',
        ),
        MigrationCoin.failed(
          asset: const Asset(
            id: AssetId('DOGE'),
            name: 'Dogecoin',
            symbol: 'DOGE',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '1000.0',
          errorMessage: 'Network timeout',
        ),
        MigrationCoin.feeTooLow(
          asset: const Asset(
            id: AssetId('BTC'),
            name: 'Bitcoin',
            symbol: 'BTC',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '0.001',
          errorMessage: 'Fee too low',
        ),
      ];

      final state = MigrationState.completed(coins: coins);
      final summary = MigrationSummary.fromState(state);

      expect(summary.totalCoins, equals(4));
      expect(summary.successfulCoins, equals(2));
      expect(summary.failedCoins, equals(2));
      expect(summary.skippedCoins, equals(1)); // BTC with fee too low

      expect(summary.isFullSuccess, isFalse);
      expect(summary.isPartialSuccess, isTrue);
      expect(summary.isCompleteFailure, isFalse);
    });
  });
}
