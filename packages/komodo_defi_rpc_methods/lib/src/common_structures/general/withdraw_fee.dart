import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class WithdrawFee {
  const WithdrawFee._({
    required this.type,
    required this.amount,
    this.gas,
    this.gasPrice,
    this.totalFee,
  });

  WithdrawFee.utxoFixed(Decimal amount)
      : this._(type: WithdrawalFeeType.utxo, amount: amount);

  // TODO: Verify this constructor reflects
  factory WithdrawFee.erc20(Decimal gasPrice, int gasLimit) {
    return WithdrawFee._(
      type: WithdrawalFeeType.eth,
      gas: gasLimit,
      gasPrice: gasPrice.toString(),
      amount: gasPrice,
    );
  }

  factory WithdrawFee.fromJson(Map<String, dynamic> json) {
    return WithdrawFee._(
      type: WithdrawalFeeType.parse(json.value<String>('type')),
      amount: Decimal.parse(
        json.valueOrNull<String>('amount') ?? json.value('total_fee'),
      ),
      gas: json.valueOrNull<int>('gas'),
      gasPrice: json.valueOrNull<String>('gas_price'),
      totalFee: Decimal.tryParse(json.valueOrNull<String>('total_fee') ?? ''),
    );
  }
  final WithdrawalFeeType type;
  final Decimal amount;
  final int? gas;
  final String? gasPrice;
  final Decimal? totalFee;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount.toString(),
      if (gas != null) 'gas': gas,
      if (gasPrice != null) 'gas_price': gasPrice,
      if (totalFee != null) 'total_fee': totalFee.toString(),
    };
  }
}
