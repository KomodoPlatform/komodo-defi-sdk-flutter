import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart'
    show MatchBy;

/// High-level SDK abstraction to constrain taker matches.
///
/// Use to target specific counterparties (pubkeys) or specific order UUIDs
/// when performing taker swaps via `marketSwap`, and for generating quotes.
class CounterpartyMatch {
  CounterpartyMatch._(this._type, this._values);

  /// Match against any available orders (default when omitted).
  factory CounterpartyMatch.any() => CounterpartyMatch._(_MatchType.any, null);

  /// Match only against orders created by the specified public keys.
  factory CounterpartyMatch.pubkeys(List<String> pubkeys) =>
      CounterpartyMatch._(_MatchType.pubkeys, List.unmodifiable(pubkeys));

  /// Match only against the specified order UUIDs.
  factory CounterpartyMatch.orders(List<String> orderUuids) =>
      CounterpartyMatch._(_MatchType.orders, List.unmodifiable(orderUuids));

  final _MatchType _type;
  final List<String>? _values;

  /// Returns values when the type supports them, otherwise null.
  List<String>? get values => _values;

  /// Convert to underlying RPC structure.
  MatchBy toRpc() {
    switch (_type) {
      case _MatchType.any:
        return MatchBy.any();
      case _MatchType.pubkeys:
        return MatchBy.pubkeys(_values ?? const <String>[]);
      case _MatchType.orders:
        return MatchBy.orders(_values ?? const <String>[]);
    }
  }

  /// True if this represents matching by pubkeys.
  bool get isPubkeys => _type == _MatchType.pubkeys;

  /// True if this represents matching by order UUIDs.
  bool get isOrders => _type == _MatchType.orders;
}

enum _MatchType { any, pubkeys, orders }
