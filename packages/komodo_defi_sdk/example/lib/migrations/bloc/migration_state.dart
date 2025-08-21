import 'package:equatable/equatable.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

/// Migration flow status
enum MigrationFlowStatus {
  idle,
  scanning,
  preview,
  transferring,
  completed,
  error,
}

/// Coin migration status
enum CoinMigrationStatus {
  ready,
  feeTooLow,
  notSupported,
  transferring,
  transferred,
  failed,
  skipped,
}

/// Migration coin model
class MigrationCoin extends Equatable {
  const MigrationCoin({
    required this.asset,
    required this.balance,
    required this.status,
    this.transactionId,
    this.errorMessage,
    this.estimatedFee,
  });

  final Asset asset;
  final String balance;
  final CoinMigrationStatus status;
  final String? transactionId;
  final String? errorMessage;
  final String? estimatedFee;

  String get statusMessage {
    switch (status) {
      case CoinMigrationStatus.ready:
        return 'Ready';
      case CoinMigrationStatus.feeTooLow:
        return 'Fee too low';
      case CoinMigrationStatus.notSupported:
        return 'Not supported';
      case CoinMigrationStatus.transferring:
        return 'Transferring...';
      case CoinMigrationStatus.transferred:
        return 'Transferred';
      case CoinMigrationStatus.failed:
        return 'Failed';
      case CoinMigrationStatus.skipped:
        return 'Skipped';
    }
  }

  bool get canMigrate => status == CoinMigrationStatus.ready;
  bool get isSuccess => status == CoinMigrationStatus.transferred;
  bool get hasFailed => status == CoinMigrationStatus.failed ||
                       status == CoinMigrationStatus.feeTooLow ||
                       status == CoinMigrationStatus.notSupported;
  bool get isInProgress => status == CoinMigrationStatus.transferring;
  bool get canRetry => status == CoinMigrationStatus.failed;

  MigrationCoin copyWith({
    Asset? asset,
    String? balance,
    CoinMigrationStatus? status,
    String? transactionId,
    String? errorMessage,
    String? estimatedFee,
  }) {
    return MigrationCoin(
      asset: asset ?? this.asset,
      balance: balance ?? this.balance,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      errorMessage: errorMessage ?? this.errorMessage,
      estimatedFee: estimatedFee ?? this.estimatedFee,
    );
  }

  @override
  List<Object?> get props => [
        asset,
        balance,
        status,
        transactionId,
        errorMessage,
        estimatedFee,
      ];

  @override
  String toString() {
    return 'MigrationCoin('
        'asset: ${asset.id.symbol.common}, '
        'balance: $balance, '
        'status: $status, '
        'transactionId: $transactionId, '
        'errorMessage: $errorMessage, '
        'estimatedFee: $estimatedFee)';
  }
}

/// Migration state
class MigrationState extends Equatable {
  const MigrationState({
    this.status = MigrationFlowStatus.idle,
    this.coins = const [],
    this.currentCoinIndex = 0,
    this.errorMessage,
    this.sourceWalletName,
    this.destinationWalletName,
  });

  final MigrationFlowStatus status;
  final List<MigrationCoin> coins;
  final int currentCoinIndex;
  final String? errorMessage;
  final String? sourceWalletName;
  final String? destinationWalletName;

  bool get isInProgress => status == MigrationFlowStatus.transferring ||
                          status == MigrationFlowStatus.scanning;
  bool get hasError => status == MigrationFlowStatus.error;

  MigrationState copyWith({
    MigrationFlowStatus? status,
    List<MigrationCoin>? coins,
    int? currentCoinIndex,
    String? errorMessage,
    String? sourceWalletName,
    String? destinationWalletName,
  }) {
    return MigrationState(
      status: status ?? this.status,
      coins: coins ?? this.coins,
      currentCoinIndex: currentCoinIndex ?? this.currentCoinIndex,
      errorMessage: errorMessage ?? this.errorMessage,
      sourceWalletName: sourceWalletName ?? this.sourceWalletName,
      destinationWalletName: destinationWalletName ?? this.destinationWalletName,
    );
  }

  static MigrationState completed({required List<MigrationCoin> coins}) {
    return MigrationState(
      status: MigrationFlowStatus.completed,
      coins: coins,
    );
  }

  @override
  List<Object?> get props => [
        status,
        coins,
        currentCoinIndex,
        errorMessage,
        sourceWalletName,
        destinationWalletName,
      ];

  @override
  String toString() {
    return 'MigrationState('
        'status: $status, '
        'coins: ${coins.length}, '
        'currentCoinIndex: $currentCoinIndex, '
        'errorMessage: $errorMessage, '
        'sourceWalletName: $sourceWalletName, '
        'destinationWalletName: $destinationWalletName)';
  }
}

/// Migration summary helper
class MigrationSummary extends Equatable {
  const MigrationSummary({
    required this.successfulCoins,
    required this.failedCoins,
    required this.totalCoins,
  });

  final int successfulCoins;
  final int failedCoins;
  final int totalCoins;

  bool get isFullSuccess => failedCoins == 0 && successfulCoins > 0;
  bool get isPartialSuccess => successfulCoins > 0 && failedCoins > 0;
  bool get isCompleteFailure => successfulCoins == 0 && totalCoins > 0;

  static MigrationSummary fromState(MigrationState state) {
    final successful = state.coins.where((c) => c.isSuccess).length;
    final failed = state.coins.where((c) => c.hasFailed).length;
    return MigrationSummary(
      successfulCoins: successful,
      failedCoins: failed,
      totalCoins: state.coins.length,
    );
  }

  @override
  List<Object> get props => [successfulCoins, failedCoins, totalCoins];

  @override
  String toString() {
    return 'MigrationSummary('
        'successfulCoins: $successfulCoins, '
        'failedCoins: $failedCoins, '
        'totalCoins: $totalCoins)';
  }
}
