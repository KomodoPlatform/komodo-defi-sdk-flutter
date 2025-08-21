import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:kdf_sdk_example/migrations/bloc/migration_event.dart';
import 'package:kdf_sdk_example/migrations/bloc/migration_state.dart';

/// Simple migration BLoC that works with the existing widgets
class MigrationBloc extends Bloc<MigrationEvent, MigrationState> {
  final KomodoDefiSdk sdk;
  Timer? _migrationTimer;

  MigrationBloc({required this.sdk}) : super(const MigrationState()) {
    on<MigrationInitiated>(_onMigrationInitiated);
    on<MigrationConfirmed>(_onMigrationConfirmed);
    on<MigrationCancelled>(_onMigrationCancelled);
    on<MigrationRetryFailed>(_onMigrationRetryFailed);
    on<MigrationRetryCoin>(_onMigrationRetryCoin);
    on<MigrationReset>(_onMigrationReset);
    on<MigrationErrorCleared>(_onMigrationErrorCleared);
  }

  @override
  Future<void> close() {
    _migrationTimer?.cancel();
    return super.close();
  }

  Future<void> _onMigrationInitiated(
    MigrationInitiated event,
    Emitter<MigrationState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: MigrationFlowStatus.scanning,
        sourceWalletName: event.sourceWalletName,
        destinationWalletName: event.destinationWalletName,
      ));

      // Simulate scanning for coins with balance
      await Future<void>.delayed(const Duration(seconds: 2));

      // Mock coins data for demonstration
      final coins = await _scanForCoinsWithBalance();

      if (coins.isEmpty) {
        emit(state.copyWith(
          status: MigrationFlowStatus.error,
          errorMessage: 'No coins found with balance to migrate.',
        ));
        return;
      }

      emit(state.copyWith(
        status: MigrationFlowStatus.preview,
        coins: coins,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MigrationFlowStatus.error,
        errorMessage: 'Failed to scan for coins: $e',
      ));
    }
  }

  Future<void> _onMigrationConfirmed(
    MigrationConfirmed event,
    Emitter<MigrationState> emit,
  ) async {
    final migrateableCoins = state.coins.where((coin) => coin.canMigrate).toList();

    if (migrateableCoins.isEmpty) {
      emit(state.copyWith(
        status: MigrationFlowStatus.error,
        errorMessage: 'No coins available for migration.',
      ));
      return;
    }

    emit(state.copyWith(status: MigrationFlowStatus.transferring));

    // Start migration process
    await _performMigration(emit, migrateableCoins);
  }

  Future<void> _onMigrationCancelled(
    MigrationCancelled event,
    Emitter<MigrationState> emit,
  ) async {
    _migrationTimer?.cancel();
    emit(const MigrationState());
  }

  Future<void> _onMigrationRetryFailed(
    MigrationRetryFailed event,
    Emitter<MigrationState> emit,
  ) async {
    final failedCoins = state.coins
        .where((coin) => coin.status == CoinMigrationStatus.failed)
        .toList();

    if (failedCoins.isEmpty) return;

    // Reset failed coins to ready status
    final updatedCoins = state.coins.map((coin) {
      if (coin.status == CoinMigrationStatus.failed) {
        return coin.copyWith(
          status: CoinMigrationStatus.ready,
          errorMessage: null,
        );
      }
      return coin;
    }).toList();

    emit(state.copyWith(
      status: MigrationFlowStatus.transferring,
      coins: updatedCoins,
      currentCoinIndex: 0,
    ));

    await _performMigration(emit, failedCoins);
  }

  Future<void> _onMigrationRetryCoin(
    MigrationRetryCoin event,
    Emitter<MigrationState> emit,
  ) async {
    if (event.coinIndex >= state.coins.length) return;

    final coin = state.coins[event.coinIndex];
    if (!coin.canRetry) return;

    final updatedCoins = List<MigrationCoin>.from(state.coins);
    updatedCoins[event.coinIndex] = coin.copyWith(
      status: CoinMigrationStatus.transferring,
      errorMessage: null,
    );

    emit(state.copyWith(coins: updatedCoins));

    // Simulate transfer
    await Future<void>.delayed(const Duration(seconds: 3));

    // Mock result (80% success rate)
    final success = Random().nextBool() && Random().nextBool();

    updatedCoins[event.coinIndex] = success
        ? coin.copyWith(
            status: CoinMigrationStatus.transferred,
            transactionId: _generateMockTxId(),
          )
        : coin.copyWith(
            status: CoinMigrationStatus.failed,
            errorMessage: 'Transfer failed',
          );

    emit(state.copyWith(coins: updatedCoins));
  }

  Future<void> _onMigrationReset(
    MigrationReset event,
    Emitter<MigrationState> emit,
  ) async {
    _migrationTimer?.cancel();
    emit(const MigrationState());
  }

  Future<void> _onMigrationErrorCleared(
    MigrationErrorCleared event,
    Emitter<MigrationState> emit,
  ) async {
    emit(state.copyWith(
      errorMessage: null,
    ));
  }

  Future<List<MigrationCoin>> _scanForCoinsWithBalance() async {
    // Mock implementation - in reality this would scan actual balances
    final availableAssets = sdk.assets.available.values.take(5).toList();

    return availableAssets.map((Asset asset) {
      final hasBalance = ['KMD', 'BTC', 'RFOX'].contains(asset.id.symbol.common);
      final canMigrate = hasBalance && asset.id.symbol.common != 'RFOX';

      return MigrationCoin(
        asset: asset,
        balance: hasBalance ? '${(Random().nextDouble() * 10).toStringAsFixed(6)} ${asset.id.symbol.common}' : '0',
        status: !hasBalance
            ? CoinMigrationStatus.skipped
            : asset.id.symbol.common == 'RFOX'
                ? CoinMigrationStatus.feeTooLow
                : CoinMigrationStatus.ready,
        estimatedFee: hasBalance ? '0.0001' : null,
        errorMessage: asset.id.symbol.common == 'RFOX'
            ? 'Balance too low to cover network fees'
            : null,
      );
    }).where((coin) => coin.balance != '0').toList();
  }

  Future<void> _performMigration(
    Emitter<MigrationState> emit,
    List<MigrationCoin> coinsToMigrate,
  ) async {
    final allCoins = List<MigrationCoin>.from(state.coins);

    for (int i = 0; i < coinsToMigrate.length; i++) {
      final coinToMigrate = coinsToMigrate[i];
      final coinIndex = allCoins.indexWhere(
        (c) => c.asset.id == coinToMigrate.asset.id,
      );

      if (coinIndex == -1) continue;

      // Update coin status to transferring
      allCoins[coinIndex] = allCoins[coinIndex].copyWith(
        status: CoinMigrationStatus.transferring,
      );

      emit(state.copyWith(
        coins: allCoins,
        currentCoinIndex: coinIndex,
      ));

      // Simulate transfer time
      await Future<void>.delayed(const Duration(seconds: 3));

      // Mock transfer result (90% success rate for demo)
      final success = Random().nextDouble() > 0.1;

      if (success) {
        allCoins[coinIndex] = allCoins[coinIndex].copyWith(
          status: CoinMigrationStatus.transferred,
          transactionId: _generateMockTxId(),
        );
      } else {
        allCoins[coinIndex] = allCoins[coinIndex].copyWith(
          status: CoinMigrationStatus.failed,
          errorMessage: 'Network error during transfer',
        );
      }

      emit(state.copyWith(coins: allCoins));
    }

    // Migration completed
    emit(state.copyWith(status: MigrationFlowStatus.completed));
  }

  String _generateMockTxId() {
    const chars = 'abcdef0123456789';
    final random = Random();
    return List.generate(
      64,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }
}
