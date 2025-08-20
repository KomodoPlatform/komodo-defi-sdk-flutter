import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

import 'package:kdf_sdk_example/blocs/migration/migration_models.dart';

part 'migration_event.dart';

class MigrationBloc extends Bloc<MigrationEvent, MigrationState> {
  MigrationBloc()
      : super(MigrationState.initial()) {
    on<MigrationInitiated>(_onMigrationInitiated);
    on<MigrationScanStarted>(_onScanStarted);
    on<MigrationCoinsFound>(_onCoinsFound);
    on<MigrationConfirmed>(_onMigrationConfirmed);
    on<MigrationTransferStarted>(_onTransferStarted);
    on<MigrationCoinTransferStarted>(_onCoinTransferStarted);
    on<MigrationCoinTransferCompleted>(_onCoinTransferCompleted);
    on<MigrationCoinTransferFailed>(_onCoinTransferFailed);
    on<MigrationTransferCompleted>(_onTransferCompleted);
    on<MigrationRetryFailed>(_onRetryFailed);
    on<MigrationRetryCoin>(_onRetryCoin);
    on<MigrationReset>(_onReset);
    on<MigrationErrorCleared>(_onErrorCleared);
    on<MigrationCancelled>(_onCancelled);
    on<MigrationErrorOccurred>(_onErrorOccurred);
  }

  Future<void> _onMigrationInitiated(
    MigrationInitiated event,
    Emitter<MigrationState> emit,
  ) async {
    debugPrint('Migration initiated');

    // Start with scanning state
    emit(MigrationState.scanning(
      sourceWalletName: event.sourceWalletName,
      destinationWalletName: event.destinationWalletName,
    ));

    // Automatically start scanning
    add(const MigrationScanStarted());
  }

  Future<void> _onScanStarted(
    MigrationScanStarted event,
    Emitter<MigrationState> emit,
  ) async {
    try {
      debugPrint('Starting coin scan');

      // Use dummy data instead of real SDK calls
      final coins = await _scanForCoinsWithBalance();

      add(MigrationCoinsFound(coins: coins));
    } catch (e) {
      debugPrint('Error during coin scan: $e');
      add(MigrationErrorOccurred(errorMessage: 'Failed to scan for coins: $e'));
    }
  }

  Future<void> _onCoinsFound(
    MigrationCoinsFound event,
    Emitter<MigrationState> emit,
  ) async {
    if (event.coins.isEmpty) {
      // No coins found with balance
      emit(MigrationState.error(
        errorMessage: 'No coins with balance found to migrate',
        sourceWalletName: state.sourceWalletName,
        destinationWalletName: state.destinationWalletName,
      ));
      return;
    }

    // Move to preview state
    emit(MigrationState.preview(
      coins: event.coins,
      sourceWalletName: state.sourceWalletName,
      destinationWalletName: state.destinationWalletName,
    ));
  }

  Future<void> _onMigrationConfirmed(
    MigrationConfirmed event,
    Emitter<MigrationState> emit,
  ) async {
    if (!state.hasCoinsToMigrate) {
      add(const MigrationErrorOccurred(
        errorMessage: 'No coins available to migrate',
      ));
      return;
    }

    // Move to transferring state
    emit(MigrationState.transferring(
      coins: state.coins,
      sourceWalletName: state.sourceWalletName,
      destinationWalletName: state.destinationWalletName,
    ));

    add(const MigrationTransferStarted());
  }

  Future<void> _onTransferStarted(
    MigrationTransferStarted event,
    Emitter<MigrationState> emit,
  ) async {
    // Start transferring coins sequentially
    await _transferCoinsSequentially(emit);
  }

  Future<void> _onCoinTransferStarted(
    MigrationCoinTransferStarted event,
    Emitter<MigrationState> emit,
  ) async {
    final updatedCoins = List<MigrationCoin>.from(state.coins);

    if (event.coinIndex < updatedCoins.length) {
      updatedCoins[event.coinIndex] = updatedCoins[event.coinIndex].copyWith(
        status: CoinMigrationStatus.transferring,
      );

      emit(state.copyWith(
        coins: updatedCoins,
        currentCoinIndex: event.coinIndex,
      ));
    }
  }

  Future<void> _onCoinTransferCompleted(
    MigrationCoinTransferCompleted event,
    Emitter<MigrationState> emit,
  ) async {
    final updatedCoins = List<MigrationCoin>.from(state.coins);

    if (event.coinIndex < updatedCoins.length) {
      updatedCoins[event.coinIndex] = updatedCoins[event.coinIndex].copyWith(
        status: CoinMigrationStatus.transferred,
        transactionId: event.transactionId,
      );

      emit(state.copyWith(coins: updatedCoins));
    }
  }

  Future<void> _onCoinTransferFailed(
    MigrationCoinTransferFailed event,
    Emitter<MigrationState> emit,
  ) async {
    final updatedCoins = List<MigrationCoin>.from(state.coins);

    if (event.coinIndex < updatedCoins.length) {
      updatedCoins[event.coinIndex] = updatedCoins[event.coinIndex].copyWith(
        status: CoinMigrationStatus.failed,
        errorMessage: event.errorMessage,
      );

      emit(state.copyWith(coins: updatedCoins));
    }
  }

  Future<void> _onTransferCompleted(
    MigrationTransferCompleted event,
    Emitter<MigrationState> emit,
  ) async {
    emit(MigrationState.completed(
      coins: state.coins,
      sourceWalletName: state.sourceWalletName,
      destinationWalletName: state.destinationWalletName,
    ));
  }

  Future<void> _onRetryFailed(
    MigrationRetryFailed event,
    Emitter<MigrationState> emit,
  ) async {
    if (state.retryableCoins.isEmpty) return;

    // Reset retryable coins to ready state
    final updatedCoins = state.coins.map((coin) {
      if (coin.canRetry) {
        return coin.copyWith(
          status: CoinMigrationStatus.ready,
          errorMessage: null,
        );
      }
      return coin;
    }).toList();

    emit(MigrationState.transferring(
      coins: updatedCoins,
      sourceWalletName: state.sourceWalletName,
      destinationWalletName: state.destinationWalletName,
    ));

    // Start transferring failed coins
    await _transferCoinsSequentially(emit, retryOnly: true);
  }

  Future<void> _onRetryCoin(
    MigrationRetryCoin event,
    Emitter<MigrationState> emit,
  ) async {
    if (event.coinIndex >= state.coins.length) return;

    final coin = state.coins[event.coinIndex];
    if (!coin.canRetry) return;

    // Reset the specific coin to ready state
    final updatedCoins = List<MigrationCoin>.from(state.coins);
    updatedCoins[event.coinIndex] = coin.copyWith(
      status: CoinMigrationStatus.ready,
      errorMessage: null,
    );

    emit(state.copyWith(coins: updatedCoins));

    // Transfer this specific coin
    await _transferSingleCoin(event.coinIndex, emit);
  }

  Future<void> _onReset(
    MigrationReset event,
    Emitter<MigrationState> emit,
  ) async {
    emit(MigrationState.initial());
  }

  Future<void> _onErrorCleared(
    MigrationErrorCleared event,
    Emitter<MigrationState> emit,
  ) async {
    if (state.hasError) {
      emit(state.copyWith(
        status: MigrationFlowStatus.idle,
        clearError: true,
      ));
    }
  }

  Future<void> _onCancelled(
    MigrationCancelled event,
    Emitter<MigrationState> emit,
  ) async {
    emit(MigrationState.initial());
  }

  Future<void> _onErrorOccurred(
    MigrationErrorOccurred event,
    Emitter<MigrationState> emit,
  ) async {
    emit(MigrationState.error(
      errorMessage: event.errorMessage,
      coins: state.coins,
      sourceWalletName: state.sourceWalletName,
      destinationWalletName: state.destinationWalletName,
    ));
  }

  /// Create a mock asset for testing
  static Asset _createMockUtxoAsset(String symbol, String name) {
    return Asset(
      id: AssetId(
        id: symbol,
        name: name,
        symbol: AssetSymbol(assetConfigId: symbol),
        chainId: AssetChainId(chainId: 0),
        derivationPath: null,
        subClass: CoinSubClass.utxo,
      ),
      protocol: UtxoProtocol.fromJson({
        'type': 'UTXO',
        'coin': symbol,
        'is_testnet': false,
        'pubtype': 60,
        'p2shtype': 85,
        'wiftype': 188,
        'mm2': 1,
      }),
      isWalletOnly: false,
      signMessagePrefix: null,
    );
  }

  /// Create a mock ERC20 asset for testing
  static Asset _createMockErc20Asset(String symbol, String name) {
    return Asset(
      id: AssetId(
        id: symbol,
        name: name,
        symbol: AssetSymbol(assetConfigId: symbol),
        chainId: AssetChainId(chainId: 1),
        derivationPath: null,
        subClass: CoinSubClass.erc20,
      ),
      protocol: Erc20Protocol.fromJson({
        'type': 'ERC20',
        'coin': symbol,
        'is_testnet': false,
        'protocol': {
          'type': 'ERC20',
        },
      }),
      isWalletOnly: false,
      signMessagePrefix: null,
    );
  }

  /// Scan for coins with non-zero balance - DUMMY IMPLEMENTATION
  Future<List<MigrationCoin>> _scanForCoinsWithBalance() async {
    try {
      // Enhanced dummy data with more realistic scenarios
      final mockCoins = <MigrationCoin>[
        // Ready to migrate coins
        MigrationCoin.ready(
          asset: _createMockUtxoAsset('KMD', 'Komodo'),
          balance: '127.50000000',
          estimatedFee: '0.00010000',
        ),
        MigrationCoin.ready(
          asset: _createMockUtxoAsset('RFOX', 'RedFox Labs'),
          balance: '15000.00000000',
          estimatedFee: '0.00010000',
        ),
        MigrationCoin.ready(
          asset: _createMockUtxoAsset('LTC', 'Litecoin'),
          balance: '2.75000000',
          estimatedFee: '0.00100000',
        ),
        MigrationCoin.ready(
          asset: _createMockUtxoAsset('DOGE', 'Dogecoin'),
          balance: '5000.00000000',
          estimatedFee: '1.00000000',
        ),

        // Coins with issues
        MigrationCoin.feeTooLow(
          asset: _createMockUtxoAsset('BTC', 'Bitcoin'),
          balance: '0.00050000',
          errorMessage: 'Balance (0.00050000 BTC) is below minimum required to cover network fees (0.00100000 BTC)',
        ),
        MigrationCoin.feeTooLow(
          asset: _createMockErc20Asset('ETH', 'Ethereum'),
          balance: '0.001000000000000000',
          errorMessage: 'Insufficient balance to cover gas fees',
        ),
        MigrationCoin.notSupported(
          asset: _createMockErc20Asset('USDT', 'Tether'),
          balance: '100.00000000',
          errorMessage: 'Token migration not supported in current wallet version',
        ),
      ];

      // Simulate more realistic network scanning delay
      await Future.delayed(const Duration(seconds: 3));

      return mockCoins;
    } catch (e) {
      debugPrint('Error scanning for coins: $e');
      rethrow;
    }
  }

  /// Transfer coins sequentially - DUMMY IMPLEMENTATION
  Future<void> _transferCoinsSequentially(
    Emitter<MigrationState> emit, {
    bool retryOnly = false,
  }) async {
    final coinsToTransfer = retryOnly
        ? state.coins.where((coin) => coin.canMigrate).toList()
        : state.migrateableCoins;

    for (int i = 0; i < coinsToTransfer.length; i++) {
      // Find the actual index in the full coins list
      final actualIndex = state.coins.indexOf(coinsToTransfer[i]);
      if (actualIndex == -1) continue;

      await _transferSingleCoin(actualIndex, emit);
    }

    add(const MigrationTransferCompleted());
  }

  /// Transfer a single coin - DUMMY IMPLEMENTATION
  Future<void> _transferSingleCoin(
    int coinIndex,
    Emitter<MigrationState> emit,
  ) async {
    if (coinIndex >= state.coins.length) return;

    final coin = state.coins[coinIndex];
    if (!coin.canMigrate) return;

    add(MigrationCoinTransferStarted(coinIndex: coinIndex));

    try {
      // Dummy transfer implementation
      final txId = await _performCoinTransfer(coin);

      add(MigrationCoinTransferCompleted(
        coinIndex: coinIndex,
        transactionId: txId,
      ));
    } catch (e) {
      debugPrint('Transfer failed for ${coin.asset.id.symbol.common}: $e');
      add(MigrationCoinTransferFailed(
        coinIndex: coinIndex,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Perform the actual coin transfer - DUMMY IMPLEMENTATION
  Future<String> _performCoinTransfer(MigrationCoin coin) async {
    debugPrint('Transferring ${coin.asset.id.symbol.common} (${coin.balance})');

    // Simulate realistic transfer times based on coin type
    Duration transferDelay;
    switch (coin.asset.id.symbol.common) {
      case 'BTC':
        transferDelay = const Duration(seconds: 8); // Bitcoin is slower
        break;
      case 'ETH':
        transferDelay = const Duration(seconds: 5); // Ethereum medium speed
        break;
      case 'LTC':
        transferDelay = const Duration(seconds: 3); // Litecoin faster
        break;
      case 'DOGE':
        transferDelay = const Duration(seconds: 2); // Dogecoin fast
        break;
      default:
        transferDelay = const Duration(seconds: 4); // Default timing
    }

    await Future.delayed(transferDelay);

    // Simulate more realistic failure scenarios
    final random = DateTime.now().millisecondsSinceEpoch % 100;

    // 8% chance of network error
    if (random < 8) {
      throw Exception('Network timeout - transaction failed');
    }

    // 5% chance of insufficient funds error (shouldn't happen with proper validation)
    if (random >= 8 && random < 13) {
      throw Exception('Insufficient funds for transaction fees');
    }

    // 2% chance of node connection error
    if (random >= 13 && random < 15) {
      throw Exception('Unable to connect to network node');
    }

    // Generate realistic transaction ID based on coin type
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final coinPrefix = coin.asset.id.symbol.common.toLowerCase();

    String txId;
    switch (coin.asset.id.symbol.common) {
      case 'BTC':
        txId = '${coinPrefix}_${timestamp.substring(0, 8)}a1b2c3d4e5f6789012345678901234567890abcd';
        break;
      case 'ETH':
        txId = '0x${coinPrefix}${timestamp.substring(0, 6)}1234567890abcdef1234567890abcdef12345678';
        break;
      case 'LTC':
        txId = '${coinPrefix}_${timestamp.substring(0, 8)}f1e2d3c4b5a6987654321098765432109876fedc';
        break;
      default:
        txId = '${coinPrefix}_${timestamp}_${(random * 1000).toInt().toRadixString(16)}';
    }

    return txId;
  }

  /// Helper method to check if migration is in progress
  bool get isInProgress => state.isInProgress;

  /// Helper method to check if migration is completed
  bool get isCompleted => state.isCompleted;

  /// Helper method to get migration summary
  MigrationSummary get summary => MigrationSummary.fromState(state);

  @override
  Future<void> close() async {
    debugPrint('MigrationBloc closing');
    await super.close();
  }
}
