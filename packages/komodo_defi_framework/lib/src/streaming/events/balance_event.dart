part of 'kdf_event.dart';

/// Balance update event from stream::balance::enable
class BalanceEvent extends KdfEvent {
  BalanceEvent({
    required this.coin,
    required this.balance,
  });

  @override
  EventTypeString get typeEnum => EventTypeString.balance;

  factory BalanceEvent.fromJson(JsonMap json) {
    return BalanceEvent(
      coin: json.value<String>('coin'),
      balance: BalanceInfo.fromJson(json.value<JsonMap>('balance')),
    );
  }

  /// The coin ticker this balance update is for
  final String coin;

  /// The updated balance information
  final BalanceInfo balance;

  @override
  String toString() => 'BalanceEvent(coin: $coin, balance: $balance)';
}

