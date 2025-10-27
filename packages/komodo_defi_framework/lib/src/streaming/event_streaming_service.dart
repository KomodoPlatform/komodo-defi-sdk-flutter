// Minimal streaming service facade; on Web, relies on a SharedWorker posting
// messages from the WASM layer using `mm2_net::handle_worker_stream`.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:komodo_defi_framework/src/streaming/events/kdf_event.dart';
import 'package:komodo_defi_framework/src/streaming/event_streaming_platform_stub.dart'
    if (dart.library.html) 'package:komodo_defi_framework/src/streaming/event_streaming_platform_web.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

typedef EventPredicate = bool Function(KdfEvent event);

class KdfEventStreamingService {
  KdfEventStreamingService();

  final StreamController<KdfEvent> _events = StreamController.broadcast();

  Stream<KdfEvent> get events => _events.stream;

  /// Start listening to WASM SharedWorker forwarded messages (web only).
  /// No-op on non-web platforms.
  void initialize() {
    if (!kIsWeb) return;
    _unsubscribe ??= connectSharedWorker((data) {
      try {
        final map = JsonMap.from(data! as Map);
        // Parse to typed event using the sealed class hierarchy
        final event = KdfEvent.fromJson(map);

        // Log received events in debug mode
        if (kDebugMode) {
          final summary = _summarizeEvent(event);
          print('[EventStream] Received ${event.typeEnum.value}: $summary');
        }

        _events.add(event);
      } catch (e) {
        // Log parsing errors for debugging (silently ignore for now)
        if (kDebugMode) {
          print('Failed to parse stream event: $e');
        }
      }
    });
  }

  /// Generic filter for a specific event type with proper type casting
  Stream<T> whereEventType<T extends KdfEvent>() =>
      events.where((e) => e is T).cast<T>();

  /// Get a stream of balance update events
  Stream<BalanceEvent> get balanceEvents => whereEventType<BalanceEvent>();

  /// Get a stream of orderbook update events
  Stream<OrderbookEvent> get orderbookEvents =>
      whereEventType<OrderbookEvent>();

  /// Get a stream of network connectivity events
  Stream<NetworkEvent> get networkEvents => whereEventType<NetworkEvent>();

  /// Get a stream of heartbeat events
  Stream<HeartbeatEvent> get heartbeatEvents =>
      whereEventType<HeartbeatEvent>();

  /// Get a stream of swap status update events
  Stream<SwapStatusEvent> get swapStatusEvents =>
      whereEventType<SwapStatusEvent>();

  /// Get a stream of order status update events
  Stream<OrderStatusEvent> get orderStatusEvents =>
      whereEventType<OrderStatusEvent>();

  /// Get a stream of transaction history events
  Stream<TxHistoryEvent> get txHistoryEvents =>
      whereEventType<TxHistoryEvent>();

  /// Get a stream of shutdown signal events.
  ///
  /// This stream emits events when OS signals (like SIGINT, SIGTERM) are
  /// received by KDF before graceful shutdown.
  ///
  /// Note: This feature is not supported on Windows and doesn't run on Web.
  Stream<ShutdownSignalEvent> get shutdownSignals =>
      whereEventType<ShutdownSignalEvent>();

  /// Cleanup
  Future<void> dispose() async {
    _unsubscribe?.call();
    await _events.close();
  }

  /// Provides a concise summary of an event for debug logging
  String _summarizeEvent(KdfEvent event) {
    return switch (event) {
      BalanceEvent(:final coin, :final balance) =>
        'coin=$coin, spendable=${balance.spendable}, '
            'unspendable=${balance.unspendable}',
      OrderbookEvent(:final base, :final rel) => 'pair=$base/$rel',
      NetworkEvent(:final netid, :final peers) => 'netid=$netid, peers=$peers',
      HeartbeatEvent(:final timestamp) => 'timestamp=$timestamp',
      SwapStatusEvent(:final uuid) => 'uuid=$uuid',
      OrderStatusEvent(:final uuid) => 'uuid=$uuid',
      TxHistoryEvent(:final coin, :final transactions) =>
        'coin=$coin, txCount=${transactions.length}',
      ShutdownSignalEvent(:final signalName) => 'signal=$signalName',
    };
  }

  SharedWorkerUnsubscribe? _unsubscribe;
}
