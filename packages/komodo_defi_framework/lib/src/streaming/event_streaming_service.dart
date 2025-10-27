// Minimal streaming service facade; on Web, relies on a SharedWorker posting
// messages from the WASM layer using `mm2_net::handle_worker_stream`.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:komodo_defi_framework/src/streaming/event_streaming_models.dart';
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
        final type = map.value<String>('_type');
        final message = map.value<JsonMap>('message');
        _events.add(KdfEvent(type: type, message: message));
      } catch (_) {
        // ignore
      }
    });
  }

  /// Convenience filter function to get a stream of a specific event type
  Stream<KdfEvent> whereType(String type) =>
      events.where((e) => e.type == type);

  /// Cleanup
  Future<void> dispose() async {
    _unsubscribe?.call();
    await _events.close();
  }

  SharedWorkerUnsubscribe? _unsubscribe;
}
