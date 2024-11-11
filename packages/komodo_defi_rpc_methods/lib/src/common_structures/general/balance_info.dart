import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
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
                [spendable, unspendable, total]
                        .where((e) => e != null)
                        .length ==
                    2,
            'Exactly 2 of the 3 values must be provided, or all 3 must '
            'add up to the same value'),
        _total = total,
        _spendable = spendable,
        _unspendable = unspendable;

  factory BalanceInfo.fromJson(Map<String, dynamic> json) {
    return BalanceInfo(
      total: _parseDecimalKeywords(json, ['total', 'balance', 'total_balance']),
      spendable:
          _parseDecimalKeywords(json, ['spendable', 'spendable_balance']),
      unspendable:
          _parseDecimalKeywords(json, ['unspendable', 'unspendable_balance']),
    );
  }

  BalanceInfo.zero()
      : _total = Decimal.zero,
        _spendable = Decimal.zero,
        _unspendable = Decimal.zero;

  // factory BalanceInfo.fromValues({
  //   Decimal? total,
  //   Decimal? spendable,
  //   Decimal? unspendable,
  // }) {
  //   // If any of the values are not provided, derive them accordingly.
  //   if (total == null) {
  //     if (spendable == null || unspendable == null) {
  //       throw ArgumentError(
  //         'If total is null, both spendable and unspendable must be provided',
  //       );
  //     }
  //     total = spendable + unspendable;
  //   }

  //  else if (spendable == null) {
  //     if (unspendable == null) {
  //       throw ArgumentError(
  //         'If spendable is null, unspendable must be provided',
  //       );
  //     }
  //     spendable = total - unspendable;
  //   }

  //   unspendable ??= total - spendable;

  //   return BalanceInfo(
  //     total: total,
  //     spendable: spendable,
  //     unspendable: unspendable,
  //   );
  // }

  static Decimal? _parseDecimalKeywords(
    JsonMap json,
    List<String> keywords,
  ) =>
      Decimal.tryParse(
        keywords
                .map((e) => json.valueOrNull<String>(e))
                .singleWhereOrNull((e) => e != null) ??
            '',
      );

  final Decimal? _total;
  late final Decimal total =
      _total ?? (_spendable ?? Decimal.zero) + (_unspendable ?? Decimal.zero);

  final Decimal? _spendable;
  late final Decimal spendable = _spendable ?? _total! - _unspendable!;

  final Decimal? _unspendable;
  late final Decimal unspendable = _unspendable ?? _total! - _spendable!;

  bool get hasBalance => spendable > Decimal.zero || unspendable > Decimal.zero;

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
}
