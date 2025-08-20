part of 'migration_bloc.dart';

/// Base class for all migration events
abstract class MigrationEvent extends Equatable {
  const MigrationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initiate the migration process
class MigrationInitiated extends MigrationEvent {
  const MigrationInitiated({
    this.sourceWalletName,
    this.destinationWalletName,
  });

  final String? sourceWalletName;
  final String? destinationWalletName;

  @override
  List<Object?> get props => [sourceWalletName, destinationWalletName];
}

/// Event to start scanning for coins with non-zero balances
class MigrationScanStarted extends MigrationEvent {
  const MigrationScanStarted();
}

/// Event fired when coins are found during scanning
class MigrationCoinsFound extends MigrationEvent {
  const MigrationCoinsFound({required this.coins});

  final List<MigrationCoin> coins;

  @override
  List<Object> get props => [coins];
}

/// Event to confirm migration after preview
class MigrationConfirmed extends MigrationEvent {
  const MigrationConfirmed();
}

/// Event to start transferring coins
class MigrationTransferStarted extends MigrationEvent {
  const MigrationTransferStarted();
}

/// Event fired when a single coin transfer starts
class MigrationCoinTransferStarted extends MigrationEvent {
  const MigrationCoinTransferStarted({required this.coinIndex});

  final int coinIndex;

  @override
  List<Object> get props => [coinIndex];
}

/// Event fired when a single coin transfer completes successfully
class MigrationCoinTransferCompleted extends MigrationEvent {
  const MigrationCoinTransferCompleted({
    required this.coinIndex,
    required this.transactionId,
  });

  final int coinIndex;
  final String transactionId;

  @override
  List<Object> get props => [coinIndex, transactionId];
}

/// Event fired when a single coin transfer fails
class MigrationCoinTransferFailed extends MigrationEvent {
  const MigrationCoinTransferFailed({
    required this.coinIndex,
    required this.errorMessage,
  });

  final int coinIndex;
  final String errorMessage;

  @override
  List<Object> get props => [coinIndex, errorMessage];
}

/// Event fired when all transfers are completed
class MigrationTransferCompleted extends MigrationEvent {
  const MigrationTransferCompleted();
}

/// Event to retry failed coin migrations
class MigrationRetryFailed extends MigrationEvent {
  const MigrationRetryFailed();
}

/// Event to retry a specific coin migration
class MigrationRetryCoin extends MigrationEvent {
  const MigrationRetryCoin({required this.coinIndex});

  final int coinIndex;

  @override
  List<Object> get props => [coinIndex];
}

/// Event to reset the migration state
class MigrationReset extends MigrationEvent {
  const MigrationReset();
}

/// Event to clear migration error
class MigrationErrorCleared extends MigrationEvent {
  const MigrationErrorCleared();
}

/// Event to cancel the migration process
class MigrationCancelled extends MigrationEvent {
  const MigrationCancelled();
}

/// Event fired when an error occurs during migration
class MigrationErrorOccurred extends MigrationEvent {
  const MigrationErrorOccurred({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}
