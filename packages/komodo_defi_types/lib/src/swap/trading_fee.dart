import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Trading fee information
class TradingFee extends Equatable {
  const TradingFee({
    required this.coin,
    required this.amount,
  });

  /// The coin symbol for the fee
  final String coin;

  /// The amount of the fee
  final Decimal amount;

  @override
  List<Object?> get props => [coin, amount];

  Map<String, dynamic> toJson() => {
        'coin': coin,
        'amount': amount.toString(),
      };
}