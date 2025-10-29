// Web implementation: connect to SharedWorker('event_streaming_worker.js')
// and forward messages to Dart via the provided callback.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show Event;
import 'package:js/js_util.dart' as jsu;
import 'package:logging/logging.dart';

import 'package:komodo_defi_framework/src/config/kdf_config.dart';

typedef EventStreamUnsubscribe = void Function();

Object _getGlobalProperty(String name) =>
    jsu.getProperty<Object>(jsu.globalThis, name);

Object? _getProperty(Object o, String name) =>
    jsu.getProperty<Object?>(o, name);

void _setProperty(Object o, String name, Object? value) =>
    jsu.setProperty(o, name, value);

T _callConstructor<T>(Object ctor, List<Object?> args) =>
    jsu.callConstructor(ctor, args) as T;

T _callMethod<T>(Object o, String name, List<Object?> args) =>
    jsu.callMethod(o, name, args) as T;

EventStreamUnsubscribe connectEventStream({
  IKdfHostConfig? hostConfig,
  required void Function(Object? data) onMessage,
}) {
  final Logger logger = Logger('KdfEventStreamingService[Web]');
  final Stopwatch connectionTimer = Stopwatch()..start();

  try {
    final Object sharedWorkerCtor = _getGlobalProperty('SharedWorker');
    final Object worker = _callConstructor<Object>(sharedWorkerCtor, <Object?>[
      'assets/packages/komodo_defi_framework/assets/web/event_streaming_worker.js',
    ]);
    final Object? portMaybe = _getProperty(worker, 'port');
    if (portMaybe == null) {
      logger.warning('[EventStream][Web] SharedWorker port is null');
      return () {};
    }
    final Object port = portMaybe;
    _callMethod<void>(port, 'start', const <Object>[]);

    void handler(html.Event e) {
      final Object? data = _getProperty(e, 'data');
      onMessage(data);
    }

    _setProperty(port, 'onmessage', jsu.allowInterop(handler));

    connectionTimer.stop();
    logger.info(
      '[EventStream][Web] Connected to SharedWorker in ${connectionTimer.elapsedMilliseconds}ms',
    );

    return () {
      try {
        _setProperty(port, 'onmessage', null);
        _callMethod<void>(port, 'close', const <Object>[]);
        logger.info('[EventStream][Web] Disconnected from SharedWorker');
      } catch (e) {
        logger.warning('[EventStream][Web] Error during disconnect: $e');
      }
    };
  } catch (e) {
    connectionTimer.stop();
    logger.severe(
      '[EventStream][Web] Failed to connect to SharedWorker after ${connectionTimer.elapsedMilliseconds}ms: $e',
    );
    return () {};
  }
}
