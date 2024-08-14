import 'package:komodo_defi_types/komodo_defi_types.dart';

class BalanceInfo {
  BalanceInfo({
    required this.spendable,
    required this.unspendable,
  });

  factory BalanceInfo.fromJson(Map<String, dynamic> json) {
    return BalanceInfo(
      spendable: json.value<String>('spendable'),
      unspendable: json.value<String>('unspendable'),
    );
  }
  final String spendable;
  final String unspendable;

  Map<String, dynamic> toJson() {
    return {
      'spendable': spendable,
      'unspendable': unspendable,
    };
  }
}
