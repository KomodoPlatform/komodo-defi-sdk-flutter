import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get active swaps
class ActiveSwapsRequest
    extends BaseRequest<ActiveSwapsResponse, GeneralErrorResponse> {
  ActiveSwapsRequest({required String rpcPass, this.includeStatus, this.coin})
    : super(method: 'active_swaps', rpcPass: rpcPass, mmrpc: RpcVersion.v2_0);

  /// If true, include detailed status objects for each active swap
  final bool? includeStatus;
  /// Optional coin filter to limit returned swaps
  final String? coin;

  @override
  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{};
    if (coin != null) {
      params['coin'] = coin;
    }
    if (includeStatus != null) {
      params['include_status'] = includeStatus;
    }

    return super.toJson().deepMerge({'params': params});
  }

  @override
  ActiveSwapsResponse parse(Map<String, dynamic> json) =>
      ActiveSwapsResponse.parse(json);
}

/// Response containing active swaps
class ActiveSwapsResponse extends BaseResponse {
  ActiveSwapsResponse({
    required super.mmrpc,
    required this.uuids,
    required this.statuses,
  });

  factory ActiveSwapsResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    final uuids =
        (result.value<List<dynamic>>('uuids')).map((e) => e as String).toList();

    final statusesJson = result.valueOrNull<JsonMap>('statuses');
    final statuses = <String, ActiveSwapStatus>{};
    if (statusesJson != null) {
      for (final entry in statusesJson.entries) {
        final key = entry.key;
        final value = entry.value as JsonMap;
        statuses[key] = ActiveSwapStatus.fromJson(value);
      }
    }

    return ActiveSwapsResponse(
      mmrpc: json.value<String>('mmrpc'),
      uuids: uuids,
      statuses: statuses.isEmpty ? null : statuses,
    );
  }

  /// List of active swap UUIDs
  final List<String> uuids;
  /// Optional map of UUID -> status when [includeStatus] was requested
  final Map<String, ActiveSwapStatus>? statuses;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'uuids': uuids,
      if (statuses != null)
        'statuses': statuses!.map((k, v) => MapEntry(k, v.toJson())),
    },
  };
}

/// Active swap status entry as returned by active_swaps when include_status is true
class ActiveSwapStatus {
  ActiveSwapStatus({required this.swapType, required this.swapData});

  factory ActiveSwapStatus.fromJson(JsonMap json) {
    return ActiveSwapStatus(
      swapType: json.value<String>('swap_type'),
      swapData: SwapInfo.fromJson(json.value<JsonMap>('swap_data')),
    );
  }

  /// Swap type string (maker/taker)
  final String swapType;
  /// Detailed swap information
  final SwapInfo swapData;

  Map<String, dynamic> toJson() => {
    'swap_type': swapType,
    'swap_data': swapData.toJson(),
  };
}
