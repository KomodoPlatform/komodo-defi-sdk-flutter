import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get recent swaps (history)
class RecentSwapsRequest
    extends BaseRequest<RecentSwapsResponse, GeneralErrorResponse> {
  RecentSwapsRequest({
    required String rpcPass,
    this.limit,
    this.pageNumber,
    this.fromUuid,
    this.coin,
  }) : super(
         method: 'my_recent_swaps',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  /// Maximum number of swaps to return
  final int? limit;

  /// Page number for pagination (1-based)
  final int? pageNumber;

  /// UUID to start from (exclusive) for pagination
  final String? fromUuid;

  /// Optional coin filter; limits to swaps involving this coin
  final String? coin;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {
      if (limit != null ||
          pageNumber != null ||
          fromUuid != null ||
          coin != null)
        'filter': {
          if (limit != null) 'limit': limit,
          if (pageNumber != null) 'page_number': pageNumber,
          if (fromUuid != null) 'from_uuid': fromUuid,
          if (coin != null) 'my_coin': coin,
        },
    },
  });

  @override
  RecentSwapsResponse parse(Map<String, dynamic> json) =>
      RecentSwapsResponse.parse(json);
}

/// Response containing recent swaps
class RecentSwapsResponse extends BaseResponse {
  RecentSwapsResponse({required super.mmrpc, required this.swaps});

  factory RecentSwapsResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return RecentSwapsResponse(
      mmrpc: json.value<String>('mmrpc'),
      swaps: result.value<JsonList>('swaps').map(SwapInfo.fromJson).toList(),
    );
  }

  /// List of recent swaps matching the filter/pagination
  final List<SwapInfo> swaps;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'swaps': swaps.map((e) => e.toJson()).toList()},
  };
}
