part of 'kdf_event.dart';

/// Transaction history event from stream::tx_history::enable
class TxHistoryEvent extends KdfEvent {
  TxHistoryEvent({
    required this.coin,
    required this.transactions,
  });

  @override
  EventTypeString get typeEnum => EventTypeString.txHistory;

  factory TxHistoryEvent.fromJson(JsonMap json) {
    final txList = json.value<List<dynamic>>('transactions');
    return TxHistoryEvent(
      coin: json.value<String>('coin'),
      transactions: txList
          .map((tx) => TransactionInfo.fromJson(tx as JsonMap))
          .toList(),
    );
  }

  /// The coin ticker this transaction history is for
  final String coin;

  /// List of transaction information
  final List<TransactionInfo> transactions;

  @override
  String toString() =>
      'TxHistoryEvent(coin: $coin, transactions: ${transactions.length})';
}

