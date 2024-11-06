import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class EnableTendermintRequest
    extends BaseRequest<EnableTendermintResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  EnableTendermintRequest({
    required String rpcPass,
    required this.ticker,
    required this.activationParams,
    this.assetsRequests = const [],
  }) : super(
          method: 'enable_tendermint_with_assets',
          rpcPass: rpcPass,
          mmrpc: '2.0',
        );

  final String ticker;
  final CosmosActivationParams activationParams;
  final List<TokensRequest> assetsRequests;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'params': {
          'ticker': ticker,
          'activation_params': activationParams.toJson(),
          'assets_requests': assetsRequests.map((e) => e.toJson()).toList(),
        },
      };

  @override
  EnableTendermintResponse parse(Map<String, dynamic> json) =>
      EnableTendermintResponse.parse(json);
}

// lib/src/rpc_methods/tendermint/responses/enable_tendermint_response.dart

class EnableTendermintResponse extends BaseResponse {
  EnableTendermintResponse({
    required super.mmrpc,
    required this.balance,
    required this.assetBalances,
    required this.chainInfo,
  });

  factory EnableTendermintResponse.parse(Map<String, dynamic> json) {
    return EnableTendermintResponse(
      mmrpc: json.value<String>('mmrpc'),
      balance: BalanceInfo.fromJson(json.value<JsonMap>('result', 'balance')),
      assetBalances: json
          .value<List<dynamic>>('result', 'asset_balances')
          .map((e) => TokenBalance.fromJson(e as JsonMap))
          .toList(),
      chainInfo: json.value<Map<String, dynamic>>('result', 'chain_info'),
    );
  }

  final BalanceInfo balance;
  final List<TokenBalance> assetBalances;
  final Map<String, dynamic> chainInfo;

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': {
          'balance': balance.toJson(),
          'asset_balances': assetBalances.map((e) => e.toJson()).toList(),
          'chain_info': chainInfo,
        },
      };
}
