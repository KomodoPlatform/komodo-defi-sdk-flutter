import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:meta/meta.dart';

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
    final maybeTotal = json.valueOrNull<String>('balance');
    final maybeUnspendable = json.valueOrNull<String>('unspendable') ??
        json.valueOrNull<String>('unspendable_balance');
    final maybeSpendable = json.valueOrNull<String>('spendable') ??
        json.valueOrNull<String>('spendable_balance');

    return maybeTotal != null
        ? BalanceInfo.fromTotal(
            Decimal.parse(maybeTotal),
            unspendable: maybeUnspendable != null
                ? Decimal.parse(maybeUnspendable)
                : null,
            spendable:
                maybeSpendable != null ? Decimal.parse(maybeSpendable) : null,
          )
        : BalanceInfo(
            spendable: Decimal.parse(maybeSpendable!),
            unspendable: Decimal.parse(maybeUnspendable!),
          );
  }

  factory BalanceInfo.fromTotal(
    Decimal total, {
    Decimal? unspendable,
    Decimal? spendable,
  }) {
    assert(
      [unspendable, spendable]
              .where((e) => e != null && e > Decimal.zero)
              .length <=
          1,
      'Only one can be greater than zero or non-null',
    );

    Decimal? spendableBalance;
    Decimal? unspendableBalance;

    spendableBalance = (spendable != null && spendable > Decimal.zero)
        ? spendable
        : total - (unspendable ?? Decimal.zero);

    unspendableBalance = (unspendable != null && unspendable > Decimal.zero)
        ? unspendable
        : total - (spendable ?? Decimal.zero);

    return BalanceInfo(
      spendable: spendableBalance,
      unspendable: unspendableBalance,
    );
  }

  final Decimal spendable;
  final Decimal unspendable;

  Decimal get total => spendable + unspendable;

  bool get hasBalance => spendable > Decimal.zero || unspendable > Decimal.zero;

  Map<String, dynamic> toJson() {
    return {
      'spendable': spendable,
      'unspendable': unspendable,
    };
  }

  @override
  String toString() {
    return toJson().toJsonString();
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
