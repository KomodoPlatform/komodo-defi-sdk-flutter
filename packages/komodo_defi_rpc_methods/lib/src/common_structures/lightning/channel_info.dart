import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Represents information about a Lightning Network channel.
/// 
/// This class encapsulates all the essential details about a Lightning channel,
/// including its capacity, balance distribution, and operational status.
class ChannelInfo {
  /// Creates a new [ChannelInfo] instance.
  /// 
  /// All parameters except [closureReason] are required.
  /// 
  /// - [channelId]: Unique identifier for the channel
  /// - [counterpartyNodeId]: The node ID of the channel counterparty
  /// - [fundingTxId]: Transaction ID that funded this channel
  /// - [capacity]: Total capacity of the channel in satoshis
  /// - [localBalance]: Balance available on the local side in satoshis
  /// - [remoteBalance]: Balance available on the remote side in satoshis
  /// - [isOutbound]: Whether this is an outbound channel (initiated by us)
  /// - [isPublic]: Whether this channel is publicly announced
  /// - [isUsable]: Whether this channel can currently be used for payments
  /// - [closureReason]: Optional reason if the channel was closed
  ChannelInfo({
    required this.channelId,
    required this.counterpartyNodeId,
    required this.fundingTxId,
    required this.capacity,
    required this.localBalance,
    required this.remoteBalance,
    required this.isOutbound,
    required this.isPublic,
    required this.isUsable,
    this.closureReason,
  });

  /// Creates a [ChannelInfo] instance from a JSON map.
  /// 
  /// Expects the following keys in the JSON:
  /// - `channel_id`: String
  /// - `counterparty_node_id`: String
  /// - `funding_tx_id`: String
  /// - `capacity`: int
  /// - `local_balance`: int
  /// - `remote_balance`: int
  /// - `is_outbound`: bool
  /// - `is_public`: bool
  /// - `is_usable`: bool
  /// - `closure_reason`: String (optional)
  factory ChannelInfo.fromJson(JsonMap json) {
    return ChannelInfo(
      channelId: json.value<String>('channel_id'),
      counterpartyNodeId: json.value<String>('counterparty_node_id'),
      fundingTxId: json.value<String>('funding_tx_id'),
      capacity: json.value<int>('capacity'),
      localBalance: json.value<int>('local_balance'),
      remoteBalance: json.value<int>('remote_balance'),
      isOutbound: json.value<bool>('is_outbound'),
      isPublic: json.value<bool>('is_public'),
      isUsable: json.value<bool>('is_usable'),
      closureReason: json.valueOrNull<String?>('closure_reason'),
    );
  }

  /// Unique identifier for this Lightning channel.
  /// 
  /// This is typically a 64-character hex string that uniquely identifies
  /// the channel on the Lightning Network.
  final String channelId;

  /// The public key/node ID of the channel counterparty.
  /// 
  /// This identifies the other participant in this channel.
  final String counterpartyNodeId;

  /// The transaction ID of the funding transaction that opened this channel.
  /// 
  /// This links the channel to its on-chain funding transaction.
  final String fundingTxId;

  /// Total capacity of the channel in satoshis.
  /// 
  /// This is the sum of [localBalance] and [remoteBalance], representing
  /// the total amount that was locked when the channel was opened.
  final int capacity;

  /// Balance available on the local side of the channel in satoshis.
  /// 
  /// This is the amount that can be sent through this channel.
  final int localBalance;

  /// Balance available on the remote side of the channel in satoshis.
  /// 
  /// This is the amount that can be received through this channel.
  final int remoteBalance;

  /// Whether this is an outbound channel.
  /// 
  /// `true` if we initiated the channel opening, `false` if the counterparty did.
  final bool isOutbound;

  /// Whether this channel is publicly announced on the Lightning Network.
  /// 
  /// Public channels can be used for routing payments for other nodes.
  final bool isPublic;

  /// Whether this channel is currently usable for payments.
  /// 
  /// A channel might be unusable if it's closing, has insufficient balance,
  /// or if there are connectivity issues with the counterparty.
  final bool isUsable;

  /// Optional reason for channel closure.
  /// 
  /// Only present if the channel has been closed. Contains a human-readable
  /// description of why the channel was closed.
  final String? closureReason;

  /// Converts this [ChannelInfo] instance to a JSON map.
  /// 
  /// The resulting map can be serialized to JSON and will contain all
  /// the channel information in the expected format.
  Map<String, dynamic> toJson() => {
    'channel_id': channelId,
    'counterparty_node_id': counterpartyNodeId,
    'funding_tx_id': fundingTxId,
    'capacity': capacity,
    'local_balance': localBalance,
    'remote_balance': remoteBalance,
    'is_outbound': isOutbound,
    'is_public': isPublic,
    'is_usable': isUsable,
    if (closureReason != null) 'closure_reason': closureReason,
  };
}