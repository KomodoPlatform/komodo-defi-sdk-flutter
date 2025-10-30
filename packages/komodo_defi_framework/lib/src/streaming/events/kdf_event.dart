import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:logging/logging.dart';

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

final Logger _kdfEventLogger = Logger('KdfEvent');

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
    final dynamic message = json.value<dynamic>('message');

    // Handle TASK:{taskId} pattern
    if (typeString.startsWith('TASK:')) {
      final taskIdStr = typeString.substring(5); // Remove "TASK:" prefix
      final taskId = int.tryParse(taskIdStr);
      if (taskId != null) {
        return TaskEvent.fromJson(_asJsonMap(message), taskId);
      }
    }

    // Some event types include contextual suffixes (e.g. "TX_HISTORY:COIN",
    // "ORDERBOOK:BASE:REL"). Normalize by stripping everything after the first
    // ':' so the base type can be matched, while keeping message payload for
    // concrete details (coin, pair, uuid, etc.).
    final normalizedType = typeString.contains(':')
        ? typeString.substring(0, typeString.indexOf(':'))
        : typeString;

    return switch (normalizedType) {
      'BALANCE' => _parseBalanceEvent(typeString, message),
      'ORDERBOOK' => OrderbookEvent.fromJson(_asJsonMap(message)),
      'NETWORK' => NetworkEvent.fromJson(_asJsonMap(message)),
      'HEARTBEAT' => HeartbeatEvent.fromJson(_asJsonMap(message)),
      'SWAP_STATUS' => SwapStatusEvent.fromJson(_asJsonMap(message)),
      'ORDER_STATUS' => OrderStatusEvent.fromJson(_asJsonMap(message)),
      'TX_HISTORY' => TxHistoryEvent.fromJson(_asJsonMap(message)),
      'SHUTDOWN_SIGNAL' => ShutdownSignalEvent.fromJson(_asJsonMap(message)),
      _ => _handleUnknownEvent(typeString, _wrapUnknown(message)),
    };
  }

  static JsonMap _asJsonMap(dynamic value) {
    if (value is Map) {
      return JsonMap.from(value);
    }
    if (value is String) {
      return JsonMapExtension.jsonFromString(value);
    }
    throw ArgumentError(
      'Expected type Map<String, dynamic> for message, but got ${value.runtimeType}',
    );
  }

  static JsonMap _wrapUnknown(dynamic value) {
    if (value is Map) return JsonMap.from(value);
    return {'raw': value};
  }

  /// Normalize BALANCE messages which may come as either a Map or a List.
  static BalanceEvent _parseBalanceEvent(String typeString, dynamic message) {
    // If the message is already a map with expected shape, parse directly
    if (message is Map) {
      return BalanceEvent.fromJson(JsonMap.from(message));
    }

    // Otherwise, handle list payloads by aggregating balances for the coin
    if (message is List) {
      // Extract coin suffix from type, e.g. BALANCE:DOC -> DOC
      String? coinFromType;
      final int firstColon = typeString.indexOf(':');
      if (firstColon != -1 && firstColon + 1 < typeString.length) {
        final int nextColon = typeString.indexOf(':', firstColon + 1);
        coinFromType = nextColon == -1
            ? typeString.substring(firstColon + 1)
            : typeString.substring(firstColon + 1, nextColon);
      }

      final List<JsonMap> entries = message
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => JsonMap.from(e))
          .toList();

      // Determine coin from type or first entry ticker
      final String coin =
          coinFromType ??
          (entries.isNotEmpty
              ? (entries.first.valueOrNull<String>('ticker') ?? 'UNKNOWN')
              : 'UNKNOWN');

      Decimal spendable = Decimal.zero;
      Decimal unspendable = Decimal.zero;

      for (final JsonMap entry in entries) {
        final String? ticker = entry.valueOrNull<String>('ticker');
        if (coinFromType != null && ticker != coinFromType) {
          continue;
        }
        final JsonMap bal = entry.value<JsonMap>('balance');
        final Decimal s =
            bal.valueOrNull<String>('spendable')?.toDecimalOrNull ??
            Decimal.zero;
        final Decimal u =
            bal.valueOrNull<String>('unspendable')?.toDecimalOrNull ??
            Decimal.zero;
        spendable += s;
        unspendable += u;
      }

      final JsonMap normalized = {
        'coin': coin,
        'balance': {
          'spendable': spendable.toString(),
          'unspendable': unspendable.toString(),
        },
      };

      return BalanceEvent.fromJson(normalized);
    }

    // Fallback: unknown shape
    throw ArgumentError(
      'Expected BALANCE message to be Map or List, got ${message.runtimeType}',
    );
  }

  /// Handles unknown event types by logging and returning an UnknownEvent
  static UnknownEvent _handleUnknownEvent(String typeString, JsonMap message) {
    if (kDebugMode) {
      _kdfEventLogger.warning('[EventStream] Unknown event type: $typeString');
    }
    return UnknownEvent(typeString: typeString, rawData: message);
  }

  /// Internal method to get the event type enum for linking with RPC responses
  EventTypeString get typeEnum;
}
