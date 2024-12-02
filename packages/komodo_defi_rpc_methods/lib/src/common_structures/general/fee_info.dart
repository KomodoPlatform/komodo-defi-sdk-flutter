import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class FeeInfo {
  const FeeInfo._({
    required this.type,
    required this.amount,
    this.gas,
    this.gasPrice,
  });

  FeeInfo.utxoFixed(Decimal amount)
      : this._(type: WithdrawalFeeType.utxo, amount: amount);

  factory FeeInfo.erc20(Decimal gasPrice, int gasLimit) {
    final totalFee = _calculateTotalFee(gasPrice, gasLimit);
    return FeeInfo._(
      type: WithdrawalFeeType.eth,
      gas: gasLimit,
      gasPrice: gasPrice.toString(),
      amount: totalFee,
    );
  }

  factory FeeInfo.fromJson(Map<String, dynamic> json) {
    final type = WithdrawalFeeType.parse(json.value<String>('type'));
    final gas = json.valueOrNull<int>('gas');
    final gasPriceString = json.valueOrNull<String>('gas_price');

    // For ERC20-type fees, calculate total from gas if available
    if (type == WithdrawalFeeType.eth &&
        gas != null &&
        gasPriceString != null) {
      final gasPrice = Decimal.parse(gasPriceString);
      final totalFee = _calculateTotalFee(gasPrice, gas);
      return FeeInfo._(
        type: type,
        amount: totalFee,
        gas: gas,
        gasPrice: gasPriceString,
      );
    }

    // For other types or when gas details aren't available
    return FeeInfo._(
      type: type,
      amount: Decimal.parse(
        json.valueOrNull<String>('amount') ?? json.value('total_fee'),
      ),
      gas: gas,
      gasPrice: gasPriceString,
    );
  }

  final WithdrawalFeeType type;
  final Decimal amount;
  final int? gas;
  final String? gasPrice;

  /// Gets the total fee amount in the native coin unit
  Decimal get totalFee => amount;

  /// Gets the gas price in Gwei if available
  Decimal? get gasPriceInGwei =>
      gasPrice != null ? Decimal.parse(gasPrice!) : null;

  /// Calculate total fee from gas parameters (gas price in Gwei)
  static Decimal _calculateTotalFee(Decimal gasPriceGwei, int gasUnits) {
    return (gasPriceGwei.toRational() *
            (Decimal.fromInt(gasUnits).toRational() /
                Decimal.fromInt(1000000000).toRational()))
        .toDecimal(scaleOnInfinitePrecision: 18);
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'amount': amount.toString(),
      'total_fee': amount.toString(),
      if (gas != null) 'gas': gas,
      if (gasPrice != null) 'gas_price': gasPrice,
    };
  }

  @override
  String toString() => toJson().toString();
}
