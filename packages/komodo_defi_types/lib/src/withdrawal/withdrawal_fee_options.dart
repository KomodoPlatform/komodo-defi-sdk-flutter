import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/src/fees/fee_management.dart';
import 'package:komodo_defi_types/src/transactions/fee_info.dart';
import 'package:komodo_defi_types/src/withdrawal/withdrawal_enums.dart';

/// Represents fee options with different priority levels for withdrawals.
class WithdrawalFeeOptions extends Equatable {
  const WithdrawalFeeOptions({
    required this.coin,
    required this.low,
    required this.medium,
    required this.high,
    this.estimatorType = FeeEstimatorType.simple,
  });

  final String coin;
  final WithdrawalFeeOption low;
  final WithdrawalFeeOption medium;
  final WithdrawalFeeOption high;
  final FeeEstimatorType estimatorType;

  WithdrawalFeeOption getByPriority(WithdrawalFeeLevel priority) {
    switch (priority) {
      case WithdrawalFeeLevel.low:
        return low;
      case WithdrawalFeeLevel.medium:
        return medium;
      case WithdrawalFeeLevel.high:
        return high;
    }
  }

  @override
  List<Object?> get props => [coin, low, medium, high, estimatorType];
}

/// Represents a single fee option for a specific priority level.
class WithdrawalFeeOption extends Equatable {
  const WithdrawalFeeOption({
    required this.priority,
    required this.feeInfo,
    this.estimatedTime,
    this.displayName,
  });

  final WithdrawalFeeLevel priority;
  final FeeInfo feeInfo;
  final String? estimatedTime;
  final String? displayName;

  String get displayNameOrDefault {
    if (displayName != null) return displayName!;

    switch (priority) {
      case WithdrawalFeeLevel.low:
        return 'Slow';
      case WithdrawalFeeLevel.medium:
        return 'Standard';
      case WithdrawalFeeLevel.high:
        return 'Fast';
    }
  }

  @override
  List<Object?> get props => [priority, feeInfo, estimatedTime, displayName];
}
