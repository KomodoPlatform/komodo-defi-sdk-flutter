part of 'kdf_event.dart';

/// Heartbeat event from stream::heartbeat::enable
class HeartbeatEvent extends KdfEvent {
  HeartbeatEvent({required this.timestamp});

  @override
  EventTypeString get typeEnum => EventTypeString.heartbeat;

  factory HeartbeatEvent.fromJson(JsonMap json) {
    return HeartbeatEvent(
      timestamp: json.value<int>('timestamp'),
    );
  }

  /// Unix timestamp of the heartbeat
  final int timestamp;

  @override
  String toString() => 'HeartbeatEvent(timestamp: $timestamp)';
}

