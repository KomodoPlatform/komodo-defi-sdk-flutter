import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get all currently running swaps on the Komodo DeFi Framework API node
class ActiveSwapsRequest
    extends BaseRequest<ActiveSwapsResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  ActiveSwapsRequest({
    required String rpcPass,
    this.includeStatus = false,
  }) : super(method: 'active_swaps', rpcPass: rpcPass, mmrpc: '2.0');

  /// Whether to include swap statuses in response; defaults to false
  final bool includeStatus;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'params': {
        'include_status': includeStatus,
      },
    });
  }

  @override
  ActiveSwapsResponse parse(Map<String, dynamic> json) =>
      ActiveSwapsResponse.parse(json);
}

class ActiveSwapsResponse extends BaseResponse {
  ActiveSwapsResponse({
    required super.mmrpc,
    required this.uuids,
    required this.statuses,
    super.id,
  });

  factory ActiveSwapsResponse.parse(Map<String, dynamic> json) {
    final result = json.value<JsonMap>('result');

    final uuidsJson = result.value<List<dynamic>>('uuids');
    final uuids = uuidsJson.cast<String>();

    final statusesJson = result.value<JsonMap>('statuses');
    final statuses = <String, Map<String, dynamic>>{};

    for (final entry in statusesJson.entries) {
      statuses[entry.key] = entry.value as Map<String, dynamic>;
    }

    return ActiveSwapsResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      id: json.valueOrNull<String>('id'),
      uuids: uuids,
      statuses: statuses,
    );
  }

  /// A list of currently active swap UUIDs
  final List<String> uuids;

  /// A map of SwapStatus objects, delineated by the related UUID
  /// Only visible if include_status request parameter is true
  final Map<String, Map<String, dynamic>> statuses;

  @override
  Map<String, dynamic> toJson() {
    return {
      'uuids': uuids,
      'statuses': statuses,
    };
  }
}