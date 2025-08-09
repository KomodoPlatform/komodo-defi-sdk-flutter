import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get Lightning channels information
class GetChannelsRequest
    extends BaseRequest<GetChannelsResponse, GeneralErrorResponse> {
  GetChannelsRequest({
    required String rpcPass,
    required this.coin,
    this.openFilter,
    this.closedFilter,
  }) : super(
         method: 'lightning::channels',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String coin;
  final LightningOpenChannelsFilter? openFilter;
  final LightningClosedChannelsFilter? closedFilter;

  @override
  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{
      'coin': coin,
    };
    
    if (openFilter != null) {
      params['filter'] = {
        'open': openFilter!.toJson(),
      };
    } else if (closedFilter != null) {
      params['filter'] = {
        'closed': closedFilter!.toJson(),
      };
    }

    return super.toJson().deepMerge({
      'params': params,
    });
  }

  @override
  GetChannelsResponse parse(Map<String, dynamic> json) =>
      GetChannelsResponse.parse(json);
}

/// Response containing Lightning channels information
class GetChannelsResponse extends BaseResponse {
  GetChannelsResponse({
    required super.mmrpc,
    required this.openChannels,
    required this.closedChannels,
  });

  factory GetChannelsResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return GetChannelsResponse(
      mmrpc: json.value<String>('mmrpc'),
      openChannels: (result.valueOrNull<List<dynamic>>('open_channels') ?? [])
          .map((e) => ChannelInfo.fromJson(e as JsonMap))
          .toList(),
      closedChannels: (result.valueOrNull<List<dynamic>>('closed_channels') ?? [])
          .map((e) => ChannelInfo.fromJson(e as JsonMap))
          .toList(),
    );
  }

  final List<ChannelInfo> openChannels;
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

/// Information about a Lightning channel
class ChannelInfo {
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

  final String channelId;
  final String counterpartyNodeId;
  final String fundingTxId;
  final int capacity;
  final int localBalance;
  final int remoteBalance;
  final bool isOutbound;
  final bool isPublic;
  final bool isUsable;
  final String? closureReason;

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