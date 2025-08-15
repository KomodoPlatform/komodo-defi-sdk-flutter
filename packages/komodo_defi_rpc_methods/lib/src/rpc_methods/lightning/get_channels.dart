import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get Lightning channels information.
///
/// This RPC method retrieves information about both open and closed Lightning
/// channels for a specified coin. Optionally, filters can be applied to
/// narrow down the results.
class GetChannelsRequest
    extends BaseRequest<GetChannelsResponse, GeneralErrorResponse> {
  /// Creates a new [GetChannelsRequest].
  ///
  /// - [rpcPass]: RPC password for authentication
  /// - [coin]: The coin/ticker for which to retrieve channel information
  /// - [openFilter]: Optional filter for open channels
  /// - [closedFilter]: Optional filter for closed channels
  GetChannelsRequest({
    required String rpcPass,
    required this.coin,
    this.openFilter,
    this.closedFilter,
  }) : super(
         method: 'lightning::channels::list_open_channels_by_filter',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  /// The coin/ticker for which to retrieve channel information.
  final String coin;

  /// Optional filter to apply to open channels.
  final LightningOpenChannelsFilter? openFilter;

  /// Optional filter to apply to closed channels.
  final LightningClosedChannelsFilter? closedFilter;

  @override
  Map<String, dynamic> toJson() {
    // This request now targets open channels list; use open filter if provided.
    return super.toJson().deepMerge({
      'params': {
        'coin': coin,
        if (openFilter != null) 'filter': openFilter!.toJson(),
      },
    });
  }

  @override
  GetChannelsResponse parse(Map<String, dynamic> json) =>
      GetChannelsResponse.parse(json);
}

/// Response containing Lightning channels information.
///
/// This response provides lists of both open and closed channels,
/// allowing for comprehensive channel management and monitoring.
class GetChannelsResponse extends BaseResponse {
  /// Creates a new [GetChannelsResponse].
  ///
  /// - [mmrpc]: The RPC version
  /// - [openChannels]: List of currently open channels
  /// - [closedChannels]: List of closed channels
  GetChannelsResponse({
    required super.mmrpc,
    required this.openChannels,
    required this.closedChannels,
  });

  /// Parses a [GetChannelsResponse] from a JSON map.
  factory GetChannelsResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return GetChannelsResponse(
      mmrpc: json.value<String>('mmrpc'),
      openChannels:
          (result.valueOrNull<JsonList>('channels') ?? [])
              .map(ChannelInfo.fromJson)
              .toList(),
      closedChannels: const [],
    );
  }

  /// List of currently open Lightning channels.
  ///
  /// These channels are active and can be used for sending and receiving payments.
  final List<ChannelInfo> openChannels;

  /// List of closed Lightning channels (not populated by this request).
  final List<ChannelInfo> closedChannels;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'open_channels': openChannels.map((e) => e.toJson()).toList(),
      'closed_channels': closedChannels.map((e) => e.toJson()).toList(),
    },
  };
}
