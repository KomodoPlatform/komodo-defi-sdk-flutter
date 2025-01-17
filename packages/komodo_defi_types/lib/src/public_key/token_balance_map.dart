import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:meta/meta.dart';

/// A mapping of token tickers to their balances. Unlike many other common
/// structures, this one does not correspond to a KDF-defined common structure.
@immutable
class TokenBalanceMap {
  const TokenBalanceMap({
    required Map<String, BalanceInfo> balances,
  }) : _balances = balances;

  factory TokenBalanceMap.fromJson(JsonMap json) {
    final balances = <String, BalanceInfo>{};

    for (final entry in json.entries) {
      balances[entry.key] = BalanceInfo.fromJson(
        entry.value as JsonMap,
      );
    }

    return TokenBalanceMap(balances: balances);
  }

  factory TokenBalanceMap.zero() => const TokenBalanceMap(balances: {});

  final Map<String, BalanceInfo> _balances;

  /// Gets balance for a specific token
  BalanceInfo balanceOf(String ticker) =>
      _balances[ticker] ?? BalanceInfo.zero();

  /// Gets all tokens that have non-zero balances
  Set<String> get tokensWithBalance => _balances.entries
      .where((e) => e.value.hasBalance)
      .map((e) => e.key)
      .toSet();

  /// Gets total balance across all tokens
  BalanceInfo get totalBalance => _balances.values.fold(
        BalanceInfo.zero(),
        (prev, curr) => prev + curr,
      );

  Map<String, dynamic> toJson() => Map.fromEntries(
        _balances.entries.map((e) => MapEntry(e.key, e.value.toJson())),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TokenBalanceMap &&
        _mapsAreEqual(other._balances, _balances);
  }

  bool _mapsAreEqual(
    Map<String, BalanceInfo> a,
    Map<String, BalanceInfo> b,
  ) {
    if (a.length != b.length) return false;
    return a.entries.every((e) => b.containsKey(e.key) && b[e.key] == e.value);
  }

  @override
  int get hashCode => Object.hashAll(_balances.entries);
}
