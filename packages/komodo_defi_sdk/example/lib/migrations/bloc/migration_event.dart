import 'package:equatable/equatable.dart';

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

  @override
  String toString() {
    return 'MigrationInitiated(sourceWalletName: $sourceWalletName, destinationWalletName: $destinationWalletName)';
  }
}

/// Event to confirm and start the migration after preview
class MigrationConfirmed extends MigrationEvent {
  const MigrationConfirmed();

  @override
  String toString() => 'MigrationConfirmed()';
}

/// Event to cancel the migration process
class MigrationCancelled extends MigrationEvent {
  const MigrationCancelled();

  @override
  String toString() => 'MigrationCancelled()';
}

/// Event to retry all failed coins
class MigrationRetryFailed extends MigrationEvent {
  const MigrationRetryFailed();

  @override
  String toString() => 'MigrationRetryFailed()';
}

/// Event to retry a specific coin at given index
class MigrationRetryCoin extends MigrationEvent {
  const MigrationRetryCoin({
    required this.coinIndex,
  });

  final int coinIndex;

  @override
  List<Object> get props => [coinIndex];

  @override
  String toString() => 'MigrationRetryCoin(coinIndex: $coinIndex)';
}

/// Event to reset migration state to initial
class MigrationReset extends MigrationEvent {
  const MigrationReset();

  @override
  String toString() => 'MigrationReset()';
}

/// Event to clear error state
class MigrationErrorCleared extends MigrationEvent {
  const MigrationErrorCleared();

  @override
  String toString() => 'MigrationErrorCleared()';
}
