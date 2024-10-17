import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:meta/meta.dart';

@immutable
class BalanceInfo {
  const BalanceInfo({
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

  bool get hasBalance => spendable > Decimal.zero || unspendable > Decimal.zero;

  Map<String, dynamic> toJson() {
    return {
      'spendable': spendable,
      'unspendable': unspendable,
    };
  }

  @override
  String toString() {
    return 'BalanceInfo(spendable: $spendable, unspendable: $unspendable)';
  }

  // ===== Overriden mathemtical operators =====
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BalanceInfo &&
        other.spendable == spendable &&
        other.unspendable == unspendable;
  }

  @override
  int get hashCode => spendable.hashCode ^ unspendable.hashCode;

  // Overriden add and subtract operators
  BalanceInfo operator +(BalanceInfo other) {
    return BalanceInfo(
      spendable: spendable + other.spendable,
      unspendable: unspendable + other.unspendable,
    );
  }

  BalanceInfo operator -(BalanceInfo other) {
    return BalanceInfo(
      spendable: spendable - other.spendable,
      unspendable: unspendable - other.unspendable,
    );
  }

  //
}
