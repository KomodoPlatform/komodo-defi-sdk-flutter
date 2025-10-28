part of 'kdf_event.dart';

/// Represents an unknown or unsupported event type received from the stream.
/// These events are logged but don't cause the stream to fail.
class UnknownEvent extends KdfEvent {
  UnknownEvent({required this.typeString, required this.rawData});

  /// The raw event type string that was not recognized
  final String typeString;

  /// The raw event data
  final JsonMap rawData;

  @override
  EventTypeString get typeEnum =>
      throw UnsupportedError('UnknownEvent does not have a type enum mapping');

  @override
  String toString() => 'UnknownEvent(type: $typeString)';
}
