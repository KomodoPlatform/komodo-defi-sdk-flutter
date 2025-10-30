// Minimal streaming service facade; on Web, relies on a SharedWorker posting
// messages from the WASM layer using `mm2_net::handle_worker_stream`.

import 'dart:async';
import 'dart:convert' as convert;

import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_framework/src/config/kdf_logging_config.dart';
import 'package:komodo_defi_framework/src/streaming/event_streaming_platform_stub.dart'
    if (dart.library.io) 'package:komodo_defi_framework/src/streaming/event_streaming_platform_io.dart'
    if (dart.library.html) 'package:komodo_defi_framework/src/streaming/event_streaming_platform_web.dart';
import 'package:komodo_defi_framework/src/streaming/events/kdf_event.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:logging/logging.dart';

typedef EventPredicate = bool Function(KdfEvent event);

class KdfEventStreamingService {
  KdfEventStreamingService({IKdfHostConfig? hostConfig})
    : _hostConfig = hostConfig {
    _logger = Logger('KdfEventStreamingService');
  }

  final IKdfHostConfig? _hostConfig;
  late final Logger _logger;

  /// Enable debug logging for streaming events (event types, durations, errors)
  /// This can be controlled via app configuration
  static bool enableDebugLogging = true;

  final StreamController<KdfEvent> _events = StreamController.broadcast();

  Stream<KdfEvent> get events => _events.stream;

  /// Start listening to stream events.
  /// - Web: Connects to SharedWorker forwarded messages.
  /// - Native (IO): Connects to SSE endpoint exposed by KDF RPC server.
  void initialize() {
    _unsubscribe ??= connectEventStream(
      hostConfig: _hostConfig,
      onMessage: _onIncomingData,
    );
  }

  void _onIncomingData(Object? data) {
    if (!enableDebugLogging) {
      _processEventData(data);
      return;
    }

    final stopwatch = Stopwatch()..start();

    try {
      _processEventData(data);
      stopwatch.stop();
    } catch (e) {
      stopwatch.stop();
      _logger.warning(
        '[EventStream] Failed to process event after ${stopwatch.elapsedMilliseconds}ms: $e',
      );
    }
  }

  void _processEventData(Object? data) {
    try {
      if (data == null) return;
      JsonMap? map;

      if (data is String) {
        final String trimmed = data.trim();
        // First attempt: direct JSON object string
        map = tryParseJson(trimmed);
        if (map == null) {
          // Second attempt: payload is a JSON string wrapped in quotes
          try {
            final dynamic once = convert.jsonDecode(trimmed);
            if (once is String) {
              map = tryParseJson(once);
            } else if (once is Map) {
              map = JsonMap.from(once);
            }
          } catch (_) {}
        }

        if (map == null) {
          throw ArgumentError('Unsupported event payload string');
        }
      } else if (data is Map) {
        map = JsonMap.from(data);
      } else {
        throw ArgumentError('Unsupported event data type: ${data.runtimeType}');
      }

      final event = KdfEvent.fromJson(map);

      if (enableDebugLogging) {
        final summary = _summarizeEvent(event);
        _logger.info(
          '[EventStream] Received ${event.typeEnum.value}: $summary',
        );

        if (KdfLoggingConfig.verboseLogging) {
          _logger.fine('[EventStream] Event payload: ${map.toJsonString()}');
        }
      }

      _events.add(event);
    } catch (e) {
      if (enableDebugLogging) {
        _logger.warning('[EventStream] Failed to parse event: $e');
      }
    }
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

  /// Get a stream of task update events
  Stream<TaskEvent> get taskEvents => whereEventType<TaskEvent>();

  /// Get a stream of task update events for a specific task ID
  Stream<TaskEvent> taskEventsForId(int taskId) =>
      taskEvents.where((event) => event.taskId == taskId);

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
      TaskEvent(:final taskId) => 'taskId=$taskId',
      TxHistoryEvent(:final coin, :final transactions) =>
        'coin=$coin, txCount=${transactions.length}',
      ShutdownSignalEvent(:final signalName) => 'signal=$signalName',
      UnknownEvent(:final typeString) => 'unknown type=$typeString',
    };
  }

  EventStreamUnsubscribe? _unsubscribe;
}
