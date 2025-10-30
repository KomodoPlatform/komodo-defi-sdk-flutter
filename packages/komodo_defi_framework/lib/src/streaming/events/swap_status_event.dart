part of 'kdf_event.dart';

/// Swap status update event from stream::swap_status::enable
class SwapStatusEvent extends KdfEvent {
  SwapStatusEvent({
    required this.uuid,
    required this.swapInfo,
  });

  @override
  EventTypeString get typeEnum => EventTypeString.swapStatus;

  factory SwapStatusEvent.fromJson(JsonMap json) {
    return SwapStatusEvent(
      uuid: json.value<String>('uuid'),
      swapInfo: SwapInfo.fromJson(json.value<JsonMap>('data')),
    );
  }

  /// The UUID of the swap
  final String uuid;

  /// Detailed swap information
  final SwapInfo swapInfo;

  @override
  String toString() => 'SwapStatusEvent(uuid: $uuid)';
}

