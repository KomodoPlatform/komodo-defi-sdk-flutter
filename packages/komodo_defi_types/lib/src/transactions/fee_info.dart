import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Base abstract class for fee information
abstract class FeeInfo extends Equatable {
  const FeeInfo({
    required this.coin,
    required this.amount,
  });

  /// Factory constructor to create the appropriate fee type from JSON
  factory FeeInfo.fromJson(Map<String, dynamic> json) {
    final feeType = WithdrawalFeeType.parse(json.value<String>('type'));
    final coin = json.value<String>('coin');

    switch (feeType) {
      case WithdrawalFeeType.eth:
        final gas = json.valueOrNull<int>('gas');
        final gasPriceString = json.valueOrNull<String>('gas_price');

        if (gas != null && gasPriceString != null) {
          return EthFeeInfo.fromGasParams(
            coin: coin,
            gasPrice: Decimal.parse(gasPriceString),
            gasLimit: gas,
          );
        }

        return EthFeeInfo(
          coin: coin,
          amount: Decimal.parse(json.value('amount')),
          gas: gas,
          gasPrice:
              gasPriceString != null ? Decimal.parse(gasPriceString) : null,
        );

      case WithdrawalFeeType.utxo:
        return UtxoFeeInfo(
          coin: coin,
          amount: Decimal.parse(json.value('amount')),
        );

      default:
        throw ArgumentError('Unknown fee type: $feeType');
    }
  }

  /// The coin identifier the fee is paid in
  final String coin;

  /// The total fee amount in the native coin unit
  final Decimal amount;

  /// The type of fee (UTXO, ETH, etc)
  WithdrawalFeeType get type;

  /// Gets the total fee amount in the native coin unit
  Decimal get totalFee => amount;

  /// Convert to JSON representation
  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'amount': amount.toString(),
        'total_fee': totalFee.toString(),
        'coin': coin,
      };

  @override
  String toString() => toJson().toString();
}

/// Fee information for UTXO-based coins
class UtxoFeeInfo extends FeeInfo {
  const UtxoFeeInfo({
    required super.coin,
    required super.amount,
  });

  @override
  WithdrawalFeeType get type => WithdrawalFeeType.utxo;

  @override
  List<Object?> get props => [coin, amount];
}

/// Fee information for ETH/ERC20 coins
class EthFeeInfo extends FeeInfo {
  const EthFeeInfo({
    required super.coin,
    required super.amount,
    this.gas,
    this.gasPrice,
  });

  factory EthFeeInfo.fromGasParams({
    required String coin,
    required Decimal gasPrice,
    required int gasLimit,
  }) {
    final totalFee = _calculateTotalFee(gasPrice, gasLimit);
    return EthFeeInfo(
      coin: coin,
      amount: totalFee,
      gas: gasLimit,
      gasPrice: gasPrice,
    );
  }

  /// Gas limit for transaction
  final int? gas;

  /// Gas price in Gwei
  final Decimal? gasPrice;

  @override
  WithdrawalFeeType get type => WithdrawalFeeType.eth;

  /// Calculate total fee from gas parameters (gas price in Gwei)
  static Decimal _calculateTotalFee(Decimal gasPriceGwei, int gasUnits) {
    return (gasPriceGwei.toRational() *
            (Decimal.fromInt(gasUnits).toRational() /
                Decimal.fromInt(1000000000).toRational()))
        .toDecimal(scaleOnInfinitePrecision: 18);
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        if (gas != null) 'gas': gas,
        if (gasPrice != null) 'gas_price': gasPrice.toString(),
      };

  @override
  List<Object?> get props => [coin, amount, gas, gasPrice];
}
