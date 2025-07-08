import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get recent atomic swaps executed by the Komodo DeFi Framework
/// API node
class MyRecentSwapsRequest
    extends BaseRequest<MyRecentSwapsResponse, GeneralErrorResponse> {
  MyRecentSwapsRequest({
    required String rpcPass,
    this.myCoin,
    this.otherCoin,
    this.fromTimestamp,
    this.toTimestamp,
    this.fromUuid,
    this.limit = 10,
    this.pageNumber = 1,
  }) : super(method: 'my_recent_swaps', rpcPass: rpcPass, mmrpc: '2.0');

  /// Coin being used by you for the swap/trade
  final String? myCoin;

  /// Coin you are trading against
  final String? otherCoin;

  /// Start timestamp in UNIX format
  final int? fromTimestamp;

  /// End timestamp in UNIX format
  final int? toTimestamp;

  /// The UUID from which to start fetching results
  final String? fromUuid;

  /// The maximum number of results to return
  final int limit;

  /// Offset for paginated results
  final int pageNumber;

  @override
  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{};

    if (myCoin != null) params['my_coin'] = myCoin;
    if (otherCoin != null) params['other_coin'] = otherCoin;
    if (fromTimestamp != null) params['from_timestamp'] = fromTimestamp;
    if (toTimestamp != null) params['to_timestamp'] = toTimestamp;
    if (fromUuid != null) params['from_uuid'] = fromUuid;
    params['limit'] = limit;
    params['page_number'] = pageNumber;

    return super.toJson().deepMerge({'params': params});
  }

  @override
  MyRecentSwapsResponse parse(Map<String, dynamic> json) =>
      MyRecentSwapsResponse.parse(json);
}

class MyRecentSwapsResponse extends BaseResponse {
  MyRecentSwapsResponse({
    required super.mmrpc,
    required this.swaps,
    required this.fromUuid,
    required this.skipped,
    required this.limit,
    required this.total,
    required this.pageNumber,
    required this.totalPages,
    required this.foundRecords,
    super.id,
  });

  factory MyRecentSwapsResponse.parse(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');

    final swapsJson = result.value<List<dynamic>>('swaps');
    final swaps =
        swapsJson
            .map((swap) => SwapStatus.parse(swap as Map<String, dynamic>))
            .toList();

    return MyRecentSwapsResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      id: json.valueOrNull<String>('id'),
      swaps: swaps,
      fromUuid: result.valueOrNull<String>('from_uuid'),
      skipped: result.value<int>('skipped'),
      limit: result.value<int>('limit'),
      total: result.value<int>('total'),
      pageNumber: result.valueOrNull<int>('page_number'),
      totalPages: result.value<int>('total_pages'),
      foundRecords: result.value<int>('found_records'),
    );
  }

  /// A list of standard SwapStatus objects
  final List<SwapStatus> swaps;

  /// The from_uuid that was set in the request; this value is null if nothing
  /// was set
  final String? fromUuid;

  /// The number of skipped records
  final int skipped;

  /// The limit that was set in the request
  final int limit;

  /// Total number of swaps available with the selected filters
  final int total;

  /// The page_number that was set in the request
  final int? pageNumber;

  /// Total pages available with the selected filters and limit
  final int totalPages;

  /// The number of returned swaps
  final int foundRecords;

  @override
  Map<String, dynamic> toJson() {
    return {
      'swaps': swaps.map((swap) => swap.toJson()).toList(),
      'from_uuid': fromUuid,
      'skipped': skipped,
      'limit': limit,
      'total': total,
      'page_number': pageNumber,
      'total_pages': totalPages,
      'found_records': foundRecords,
    };
  }
}
