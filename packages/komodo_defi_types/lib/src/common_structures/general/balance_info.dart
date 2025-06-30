import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:meta/meta.dart';

@immutable
class BalanceInfo {
  BalanceInfo({
    required Decimal? total,
    required Decimal? spendable,
    required Decimal? unspendable,
  })  : assert(
          ((total ?? Decimal.zero) ==
                  (spendable ?? Decimal.zero) +
                      (unspendable ?? Decimal.zero)) ||
              [spendable, unspendable, total].where((e) => e != null).length ==
                  2,
          'Exactly 2 of the 3 values must be provided, or all 3 must '
          'add up to the same value',
        ),
        _total = total,
        _spendable = spendable,
        _unspendable = unspendable;

  factory BalanceInfo.fromJson(Map<String, dynamic> json) {
    return BalanceInfo(
      total: _parseDecimalKeywords(json, ['total', 'balance', 'total_balance']),
      spendable: _parseDecimalKeywords(json, [
        'spendable',
        'spendable_balance',
      ]),
      unspendable: _parseDecimalKeywords(json, [
        'unspendable',
        'unspendable_balance',
      ]),
    );
  }

  BalanceInfo.zero()
      : _total = Decimal.zero,
        _spendable = Decimal.zero,
        _unspendable = Decimal.zero;

  static Decimal? _parseDecimalKeywords(JsonMap json, List<String> keywords) =>
      keywords
          .map((e) => json.valueOrNull<String>(e))
          .singleWhere((e) => e != null, orElse: () => null)
          ?.toDecimalOrNull;

  final Decimal? _total;
  late final Decimal total =
      _total ?? (_spendable ?? Decimal.zero) + (_unspendable ?? Decimal.zero);

  final Decimal? _spendable;
  late final Decimal spendable = _spendable ?? _total! - _unspendable!;

  final Decimal? _unspendable;
  late final Decimal unspendable = _unspendable ?? _total! - _spendable!;

  /// Whether the balance has any spendable or unspendable funds.
  bool get hasValue => spendable > Decimal.zero || unspendable > Decimal.zero;

  Map<String, dynamic> toJson() => {
        // 'total': total.toString(),
        'spendable': spendable.toString(),
        'unspendable': unspendable.toString(),
      };

  @override
  String toString() => toJson().toJsonString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BalanceInfo &&
        other.total == total &&
        other.spendable == spendable &&
        other.unspendable == unspendable;
  }

  @override
  int get hashCode =>
      total.hashCode ^ spendable.hashCode ^ unspendable.hashCode;

  BalanceInfo operator +(BalanceInfo other) => BalanceInfo(
        total: total + other.total,
        spendable: spendable + other.spendable,
        unspendable: unspendable + other.unspendable,
      );

  BalanceInfo operator -(BalanceInfo other) => BalanceInfo(
        total: total - other.total,
        spendable: spendable - other.spendable,
        unspendable: unspendable - other.unspendable,
      );

  BalanceInfo operator *(Decimal multiplier) => BalanceInfo(
        total: total * multiplier,
        spendable: spendable * multiplier,
        unspendable: unspendable * multiplier,
      );
}
