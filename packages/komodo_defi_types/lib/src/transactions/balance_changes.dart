import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Represents the effect a transaction has on wallet balances
class BalanceChanges extends Equatable {
  const BalanceChanges({
    required this.netChange,
    required this.receivedByMe,
    required this.spentByMe,
    required this.totalAmount,
  });

  factory BalanceChanges.fromJson(JsonMap json) => BalanceChanges(
        netChange: Decimal.parse(json.value<String>('my_balance_change')),
        receivedByMe: Decimal.parse(json.value<String>('received_by_me')),
        spentByMe: Decimal.parse(json.value<String>('spent_by_me')),
        totalAmount: Decimal.parse(json.value<String>('total_amount')),
      );

  /// The net change in the wallet's balance (positive for incoming,
  /// negative for outgoing)
  final Decimal netChange;

  /// Amount received by my addresses in this transaction
  final Decimal receivedByMe;

  /// Amount spent from my addresses in this transaction
  final Decimal spentByMe;

  /// The total amount of coins transferred
  final Decimal totalAmount;

  bool get isIncoming => netChange > Decimal.zero;

  @override
  List<Object?> get props => [netChange, receivedByMe, spentByMe, totalAmount];

  JsonMap toJson() => {
        'my_balance_change': netChange.toString(),
        'received_by_me': receivedByMe.toString(),
        'spent_by_me': spentByMe.toString(),
        'total_amount': totalAmount.toString(),
      };
}
