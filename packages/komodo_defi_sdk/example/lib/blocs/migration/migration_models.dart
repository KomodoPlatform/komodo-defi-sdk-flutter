import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Represents the status of a coin during migration
enum CoinMigrationStatus {
  /// Coin is ready to be migrated
  ready,
  /// Coin balance is too low to cover network fees
  feeTooLow,
  /// Coin is not supported for migration
  notSupported,
  /// Coin is currently being transferred
  transferring,
  /// Coin has been successfully transferred
  transferred,
  /// Coin migration failed
  failed,
  /// Coin migration was skipped
  skipped,
}

/// Represents a coin that can be migrated with its current status
class MigrationCoin extends Equatable {
  const MigrationCoin({
    required this.asset,
    required this.balance,
    required this.status,
    this.errorMessage,
    this.transactionId,
    this.estimatedFee,
  });

  final Asset asset;
  final String balance;
  final CoinMigrationStatus status;
  final String? errorMessage;
  final String? transactionId;
  final String? estimatedFee;

  /// Creates a copy of this coin with updated properties
  MigrationCoin copyWith({
    Asset? asset,
    String? balance,
    CoinMigrationStatus? status,
    String? errorMessage,
    String? transactionId,
    String? estimatedFee,
  }) {
    return MigrationCoin(
      asset: asset ?? this.asset,
      balance: balance ?? this.balance,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      transactionId: transactionId ?? this.transactionId,
      estimatedFee: estimatedFee ?? this.estimatedFee,
    );
  }

  /// Creates a coin marked as ready for migration
  factory MigrationCoin.ready({
    required Asset asset,
    required String balance,
    String? estimatedFee,
  }) {
    return MigrationCoin(
      asset: asset,
      balance: balance,
      status: CoinMigrationStatus.ready,
      estimatedFee: estimatedFee,
    );
  }

  /// Creates a coin that cannot be migrated due to low balance
  factory MigrationCoin.feeTooLow({
    required Asset asset,
    required String balance,
    required String errorMessage,
  }) {
    return MigrationCoin(
      asset: asset,
      balance: balance,
      status: CoinMigrationStatus.feeTooLow,
      errorMessage: errorMessage,
    );
  }

  /// Creates a coin that is not supported for migration
  factory MigrationCoin.notSupported({
    required Asset asset,
    required String balance,
    required String errorMessage,
  }) {
    return MigrationCoin(
      asset: asset,
      balance: balance,
      status: CoinMigrationStatus.notSupported,
      errorMessage: errorMessage,
    );
  }

  /// Creates a coin that is currently being transferred
  factory MigrationCoin.transferring({
    required Asset asset,
    required String balance,
  }) {
    return MigrationCoin(
      asset: asset,
      balance: balance,
      status: CoinMigrationStatus.transferring,
    );
  }

  /// Creates a coin that has been successfully transferred
  factory MigrationCoin.transferred({
    required Asset asset,
    required String balance,
    required String transactionId,
  }) {
    return MigrationCoin(
      asset: asset,
      balance: balance,
      status: CoinMigrationStatus.transferred,
      transactionId: transactionId,
    );
  }

  /// Creates a coin whose migration failed
  factory MigrationCoin.failed({
    required Asset asset,
    required String balance,
    required String errorMessage,
  }) {
    return MigrationCoin(
      asset: asset,
      balance: balance,
      status: CoinMigrationStatus.failed,
      errorMessage: errorMessage,
    );
  }

  /// Whether this coin can be migrated
  bool get canMigrate => status == CoinMigrationStatus.ready;

  /// Whether this coin is in progress
  bool get isInProgress => status == CoinMigrationStatus.transferring;

  /// Whether this coin migration was successful
  bool get isSuccess => status == CoinMigrationStatus.transferred;

  /// Whether this coin migration failed or was skipped
  bool get hasFailed =>
      status == CoinMigrationStatus.failed ||
      status == CoinMigrationStatus.feeTooLow ||
      status == CoinMigrationStatus.notSupported ||
      status == CoinMigrationStatus.skipped;

  /// Whether this coin can be retried
  bool get canRetry =>
      status == CoinMigrationStatus.failed;

  /// Gets a human-readable status message
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

  @override
  List<Object?> get props => [
        asset,
        balance,
        status,
        errorMessage,
        transactionId,
        estimatedFee,
      ];
}

/// Represents the overall state of the migration process
enum MigrationFlowStatus {
  /// Migration has not started
  idle,
  /// Scanning for coins with balances
  scanning,
  /// Showing preview of coins to migrate
  preview,
  /// Transferring coins
  transferring,
  /// Migration completed (with results)
  completed,
  /// Migration encountered an error
  error,
}

/// Represents the complete migration state
class MigrationState extends Equatable {
  const MigrationState({
    required this.status,
    required this.coins,
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

  /// Creates an initial empty state
  factory MigrationState.initial() {
    return const MigrationState(
      status: MigrationFlowStatus.idle,
      coins: [],
    );
  }

  /// Creates a scanning state
  factory MigrationState.scanning({
    String? sourceWalletName,
    String? destinationWalletName,
  }) {
    return MigrationState(
      status: MigrationFlowStatus.scanning,
      coins: const [],
      sourceWalletName: sourceWalletName,
      destinationWalletName: destinationWalletName,
    );
  }

  /// Creates a preview state with coins to migrate
  factory MigrationState.preview({
    required List<MigrationCoin> coins,
    String? sourceWalletName,
    String? destinationWalletName,
  }) {
    return MigrationState(
      status: MigrationFlowStatus.preview,
      coins: coins,
      sourceWalletName: sourceWalletName,
      destinationWalletName: destinationWalletName,
    );
  }

  /// Creates a transferring state
  factory MigrationState.transferring({
    required List<MigrationCoin> coins,
    int currentCoinIndex = 0,
    String? sourceWalletName,
    String? destinationWalletName,
  }) {
    return MigrationState(
      status: MigrationFlowStatus.transferring,
      coins: coins,
      currentCoinIndex: currentCoinIndex,
      sourceWalletName: sourceWalletName,
      destinationWalletName: destinationWalletName,
    );
  }

  /// Creates a completed state
  factory MigrationState.completed({
    required List<MigrationCoin> coins,
    String? sourceWalletName,
    String? destinationWalletName,
  }) {
    return MigrationState(
      status: MigrationFlowStatus.completed,
      coins: coins,
      sourceWalletName: sourceWalletName,
      destinationWalletName: destinationWalletName,
    );
  }

  /// Creates an error state
  factory MigrationState.error({
    required String errorMessage,
    List<MigrationCoin>? coins,
    String? sourceWalletName,
    String? destinationWalletName,
  }) {
    return MigrationState(
      status: MigrationFlowStatus.error,
      coins: coins ?? const [],
      errorMessage: errorMessage,
      sourceWalletName: sourceWalletName,
      destinationWalletName: destinationWalletName,
    );
  }

  /// Creates a copy with updated properties
  MigrationState copyWith({
    MigrationFlowStatus? status,
    List<MigrationCoin>? coins,
    int? currentCoinIndex,
    String? errorMessage,
    String? sourceWalletName,
    String? destinationWalletName,
    bool clearError = false,
  }) {
    return MigrationState(
      status: status ?? this.status,
      coins: coins ?? this.coins,
      currentCoinIndex: currentCoinIndex ?? this.currentCoinIndex,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sourceWalletName: sourceWalletName ?? this.sourceWalletName,
      destinationWalletName: destinationWalletName ?? this.destinationWalletName,
    );
  }

  /// Gets coins that can be migrated
  List<MigrationCoin> get migrateableCoins =>
      coins.where((coin) => coin.canMigrate).toList();

  /// Gets coins that have been successfully migrated
  List<MigrationCoin> get successfulCoins =>
      coins.where((coin) => coin.isSuccess).toList();

  /// Gets coins that failed or were skipped
  List<MigrationCoin> get failedCoins =>
      coins.where((coin) => coin.hasFailed).toList();

  /// Gets coins that can be retried
  List<MigrationCoin> get retryableCoins =>
      coins.where((coin) => coin.canRetry).toList();

  /// Gets the currently transferring coin if any
  MigrationCoin? get currentTransferringCoin {
    if (status != MigrationFlowStatus.transferring ||
        currentCoinIndex >= coins.length) {
      return null;
    }
    return coins[currentCoinIndex];
  }

  /// Whether there are any coins to migrate
  bool get hasCoinsToMigrate => migrateableCoins.isNotEmpty;

  /// Whether migration is in progress
  bool get isInProgress =>
      status == MigrationFlowStatus.scanning ||
      status == MigrationFlowStatus.transferring;

  /// Whether migration is completed
  bool get isCompleted => status == MigrationFlowStatus.completed;

  /// Whether migration encountered an error
  bool get hasError => status == MigrationFlowStatus.error;

  /// Progress percentage (0.0 to 1.0)
  double get progress {
    if (coins.isEmpty) return 0.0;

    final completedCount = coins.where((coin) =>
      coin.isSuccess || coin.hasFailed).length;

    return completedCount / coins.length;
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
}

/// Summary statistics for migration results
class MigrationSummary extends Equatable {
  const MigrationSummary({
    required this.totalCoins,
    required this.successfulCoins,
    required this.failedCoins,
    required this.skippedCoins,
  });

  final int totalCoins;
  final int successfulCoins;
  final int failedCoins;
  final int skippedCoins;

  factory MigrationSummary.fromState(MigrationState state) {
    return MigrationSummary(
      totalCoins: state.coins.length,
      successfulCoins: state.successfulCoins.length,
      failedCoins: state.failedCoins.length,
      skippedCoins: state.coins.where((coin) =>
        coin.status == CoinMigrationStatus.skipped ||
        coin.status == CoinMigrationStatus.feeTooLow ||
        coin.status == CoinMigrationStatus.notSupported
      ).length,
    );
  }

  /// Whether migration was completely successful
  bool get isFullSuccess => failedCoins == 0 && totalCoins > 0;

  /// Whether migration had partial success
  bool get isPartialSuccess => successfulCoins > 0 && failedCoins > 0;

  /// Whether migration completely failed
  bool get isCompleteFailure => successfulCoins == 0 && totalCoins > 0;

  @override
  List<Object> get props => [totalCoins, successfulCoins, failedCoins, skippedCoins];
}
