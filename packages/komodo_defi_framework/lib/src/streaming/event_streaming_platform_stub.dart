import 'package:komodo_defi_framework/src/config/kdf_config.dart';

typedef EventStreamUnsubscribe = void Function();

EventStreamUnsubscribe connectEventStream({
  IKdfHostConfig? hostConfig,
  required void Function(Object? data) onMessage,
  required void Function() onFirstByte,
}) {
  // No-op default implementation; actual logic provided by IO/Web variants
  return () {};
}
