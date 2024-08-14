import 'package:komodo_defi_types/komodo_defi_types.dart';

class WithdrawFee {
  WithdrawFee({
    required this.type,
    required this.amount,
    this.gas,
    this.gasPrice,
    this.totalFee,
  });

  factory WithdrawFee.fromJson(Map<String, dynamic> json) {
    return WithdrawFee(
      type: json.value<String>('type'),
      amount: json.value<String>('amount'),
      gas: json.value<int>('gas'),
      gasPrice: json.value<String>('gas_price'),
      totalFee: json.value<String>('total_fee'),
    );
  }
  final String type;
  final String amount;
  final int? gas;
  final String? gasPrice;
  final String? totalFee;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      if (gas != null) 'gas': gas,
      if (gasPrice != null) 'gas_price': gasPrice,
      if (totalFee != null) 'total_fee': totalFee,
    };
  }
}
