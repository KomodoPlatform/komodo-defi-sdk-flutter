part of 'kdf_event.dart';

/// Network connectivity event from stream::network::enable
class NetworkEvent extends KdfEvent {
  NetworkEvent({
    required this.netid,
    required this.peers,
  });

  @override
  EventTypeString get typeEnum => EventTypeString.network;

  factory NetworkEvent.fromJson(JsonMap json) {
    return NetworkEvent(
      netid: json.value<int>('netid'),
      peers: json.value<int>('peers'),
    );
  }

  /// Network ID
  final int netid;

  /// Number of connected peers
  final int peers;

  @override
  String toString() => 'NetworkEvent(netid: $netid, peers: $peers)';
}

