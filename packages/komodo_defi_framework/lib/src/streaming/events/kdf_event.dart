import 'package:flutter/foundation.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'balance_event.dart';
part 'heartbeat_event.dart';
part 'network_event.dart';
part 'order_status_event.dart';
part 'orderbook_event.dart';
part 'shutdown_signal_event.dart';
part 'swap_status_event.dart';
part 'task_event.dart';
part 'tx_history_event.dart';
part 'unknown_event.dart';

/// Private enum for internal event type string mapping
enum EventTypeString {
  balance('BALANCE'),
  orderbook('ORDERBOOK'),
  network('NETWORK'),
  heartbeat('HEARTBEAT'),
  swapStatus('SWAP_STATUS'),
  orderStatus('ORDER_STATUS'),
  task('TASK'),
  txHistory('TX_HISTORY'),
  shutdownSignal('SHUTDOWN_SIGNAL');

  const EventTypeString(this.value);
  final String value;
}

/// Base class for all KDF stream events.
///
/// This is a sealed class, which means you can exhaustively pattern match
/// on all possible event types using switch expressions.
///
/// Example:
/// ```dart
/// final event = KdfEvent.fromJson(json);
/// switch (event) {
///   case BalanceEvent(:final coin, :final balance):
///     print('Balance for $coin: $balance');
///   case OrderbookEvent(:final base, :final rel):
///     print('Orderbook update for $base/$rel');
///   case TaskEvent(:final taskId, :final taskData):
///     print('Task $taskId update: $taskData');
///   // ... handle other event types
/// }
/// ```
sealed class KdfEvent {
  const KdfEvent();

  /// Parse a KdfEvent from raw JSON data
  static KdfEvent fromJson(JsonMap json) {
    final typeString = json.value<String>('_type');
    final message = json.value<JsonMap>('message');

    // Handle TASK:{taskId} pattern
    if (typeString.startsWith('TASK:')) {
      final taskIdStr = typeString.substring(5); // Remove "TASK:" prefix
      final taskId = int.tryParse(taskIdStr);
      if (taskId != null) {
        return TaskEvent.fromJson(message, taskId);
      }
    }

    return switch (typeString) {
      'BALANCE' => BalanceEvent.fromJson(message),
      'ORDERBOOK' => OrderbookEvent.fromJson(message),
      'NETWORK' => NetworkEvent.fromJson(message),
      'HEARTBEAT' => HeartbeatEvent.fromJson(message),
      'SWAP_STATUS' => SwapStatusEvent.fromJson(message),
      'ORDER_STATUS' => OrderStatusEvent.fromJson(message),
      'TX_HISTORY' => TxHistoryEvent.fromJson(message),
      'SHUTDOWN_SIGNAL' => ShutdownSignalEvent.fromJson(message),
      _ => _handleUnknownEvent(typeString, message),
    };
  }

  /// Handles unknown event types by logging and returning an UnknownEvent
  static UnknownEvent _handleUnknownEvent(String typeString, JsonMap message) {
    if (kDebugMode) {
      print('[EventStream] Unknown event type: $typeString');
    }
    return UnknownEvent(typeString: typeString, rawData: message);
  }

  /// Internal method to get the event type enum for linking with RPC responses
  EventTypeString get typeEnum;
}
