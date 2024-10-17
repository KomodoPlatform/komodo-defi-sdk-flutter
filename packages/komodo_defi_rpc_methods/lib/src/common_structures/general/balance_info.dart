import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class BalanceInfo {
  BalanceInfo({
    required this.spendable,
    required this.unspendable,
  });

  factory BalanceInfo.fromJson(Map<String, dynamic> json) {
    return BalanceInfo(
      spendable: Decimal.parse(json.value<String>('spendable')),
      unspendable: Decimal.parse(json.value<String>('unspendable')),
    );
  }
  final Decimal spendable;
  final Decimal unspendable;

  Map<String, dynamic> toJson() {
    return {
      'spendable': spendable,
      'unspendable': unspendable,
    };
  }
}
