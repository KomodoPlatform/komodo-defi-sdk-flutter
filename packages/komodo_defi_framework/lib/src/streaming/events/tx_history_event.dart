part of 'kdf_event.dart';

/// Transaction history event from stream::tx_history::enable
class TxHistoryEvent extends KdfEvent {
  TxHistoryEvent({required this.coin, required this.transactions});

  @override
  EventTypeString get typeEnum => EventTypeString.txHistory;

  factory TxHistoryEvent.fromJson(JsonMap json) {
    // Some backends emit a single transaction object as the message payload
    // instead of wrapping it in a { transactions: [...] } structure.
    // Support both shapes by normalizing to a list.
    final String coin = json.value<String>('coin');

    final List<dynamic> txList = json.containsKey('transactions')
        ? json.value<List<dynamic>>('transactions')
        : <dynamic>[json];

    final List<TransactionInfo> parsed = txList.map((dynamic tx) {
      final JsonMap map = tx is Map ? JsonMap.from(tx) : (tx as JsonMap);
      // Ensure required fields exist with sensible defaults for streaming
      map.putIfAbsent('confirmations', () => 0);
      return TransactionInfo.fromJson(map);
    }).toList();

    return TxHistoryEvent(coin: coin, transactions: parsed);
  }

  /// The coin ticker this transaction history is for
  final String coin;

  /// List of transaction information
  final List<TransactionInfo> transactions;

  @override
  String toString() =>
      'TxHistoryEvent(coin: $coin, transactions: ${transactions.length})';
}
