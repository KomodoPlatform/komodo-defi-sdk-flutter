import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:meta/meta.dart';

@immutable
@immutable
class BalanceInfo {
  const BalanceInfo({
    required this.spendable,
    required this.unspendable,
  });

  BalanceInfo.zero()
      : spendable = Decimal.zero,
        unspendable = Decimal.zero;

  factory BalanceInfo.fromJson(Map<String, dynamic> json) {
    final spendable = json.value<String>('spendable') ?? '0.0';
    final unspendable = json.value<String>('unspendable') ?? '0.0';

    return BalanceInfo(
      spendable: Decimal.parse(spendable),
      unspendable: Decimal.parse(unspendable),
    );
  }

  final Decimal spendable;
  final Decimal unspendable;

  Decimal get total => spendable + unspendable;

  bool get hasBalance => spendable > Decimal.zero || unspendable > Decimal.zero;

  Map<String, dynamic> toJson() => {
        'spendable': spendable.toString(),
        'unspendable': unspendable.toString(),
      };

  @override
  String toString() => toJson().toJsonString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BalanceInfo &&
        other.spendable == spendable &&
        other.unspendable == unspendable;
  }

  @override
  int get hashCode => spendable.hashCode ^ unspendable.hashCode;

  BalanceInfo operator +(BalanceInfo other) => BalanceInfo(
        spendable: spendable + other.spendable,
        unspendable: unspendable + other.unspendable,
      );

  BalanceInfo operator -(BalanceInfo other) => BalanceInfo(
        spendable: spendable - other.spendable,
        unspendable: unspendable - other.unspendable,
      );
}
