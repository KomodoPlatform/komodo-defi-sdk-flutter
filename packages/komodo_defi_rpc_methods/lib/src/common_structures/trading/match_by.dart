/// Match-by configuration for taker swaps.
///
/// This structure maps to the `match_by` field accepted by KDF for taker
/// operations (e.g., `buy`, `sell`, unified `start_swap`). It allows limiting
/// order matching to particular orders or counterparties (pubkeys).
class MatchBy {
  /// Creates a new [MatchBy] with a specific [type] and optional [data].
  MatchBy._(this.type, this.data);

  /// Match against any available orders (default behavior when omitted).
  factory MatchBy.any() => MatchBy._('Any', null);

  /// Match only against orders created by the specified public keys.
  ///
  /// - [pubkeys]: List of hex-encoded public keys.
  factory MatchBy.pubkeys(List<String> pubkeys) =>
      MatchBy._('Pubkeys', pubkeys);

  /// Match only against specific order UUIDs.
  ///
  /// - [orderUuids]: List of order UUIDs.
  factory MatchBy.orders(List<String> orderUuids) =>
      MatchBy._('Orders', orderUuids);

  /// Matching strategy type. Accepted values are `Any`, `Orders`, `Pubkeys`.
  final String type;

  /// Optional strategy data. For `Orders`/`Pubkeys` this should be a list of
  /// strings (UUIDs or pubkeys). For `Any` it is omitted.
  final List<String>? data;

  /// Converts this [MatchBy] into a JSON map expected by the RPC.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (data != null) 'data': data,
  };
}
