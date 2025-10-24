import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class GetClaimableBalancesRequest
    extends BaseRequest<GetClaimableBalancesResponse, GeneralErrorResponse> {
  GetClaimableBalancesRequest({
    required String rpcPass,
    required this.coin,
    this.includeOpenChannelsBalances,
  }) : super(
         method: 'lightning::channels::get_claimable_balances',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String coin;
  final bool? includeOpenChannelsBalances;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {
      'coin': coin,
      if (includeOpenChannelsBalances != null)
        'include_open_channels_balances': includeOpenChannelsBalances,
    },
  });

  @override
  GetClaimableBalancesResponse parse(Map<String, dynamic> json) =>
      GetClaimableBalancesResponse.parse(json);
}

class GetClaimableBalancesResponse extends BaseResponse {
  GetClaimableBalancesResponse({required super.mmrpc, required this.balances});

  factory GetClaimableBalancesResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    return GetClaimableBalancesResponse(
      mmrpc: json.value<String>('mmrpc'),
      balances: result.value<JsonMap>('balances'),
    );
  }

  final Map<String, dynamic> balances;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'balances': balances},
  };
}
