part of 'kdf_event.dart';

/// Shutdown signal event broadcasted when OS signals (like SIGINT, SIGTERM)
/// are received by KDF before graceful shutdown.
///
/// Note: This feature is not supported on Windows and doesn't run on Web.
class ShutdownSignalEvent extends KdfEvent {
  ShutdownSignalEvent({required this.signalName});

  @override
  EventTypeString get typeEnum => EventTypeString.shutdownSignal;

  factory ShutdownSignalEvent.fromJson(JsonMap json) {
    return ShutdownSignalEvent(
      signalName: json.value<String>('message'),
    );
  }

  /// The name of the OS signal received (e.g., "SIGINT", "SIGTERM")
  /// or "UNKNOWN($id)" for signals that cannot be gracefully handled.
  final String signalName;

  @override
  String toString() => 'ShutdownSignalEvent(signalName: $signalName)';
}

