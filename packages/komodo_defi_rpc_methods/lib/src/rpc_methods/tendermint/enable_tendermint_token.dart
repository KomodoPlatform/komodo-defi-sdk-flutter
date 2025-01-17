import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class EnableTendermintTokenRequest
    extends BaseRequest<EnableTendermintTokenResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  EnableTendermintTokenRequest({
    required super.rpcPass,
    required this.ticker,
    required this.params,
  }) : super(
          method: 'enable_tendermint_token',
          mmrpc: '2.0',
        );

  final String ticker;
  @override
  final TendermintTokenActivationParams params;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
        'params': {
          'ticker': ticker,
          'activation_params': params.toJsonRequestParams(),
        },
      });

  @override
  EnableTendermintTokenResponse parse(Map<String, dynamic> json) =>
      EnableTendermintTokenResponse.parse(json);
}

class EnableTendermintTokenResponse extends BaseResponse {
  EnableTendermintTokenResponse({
    required super.mmrpc,
    required this.balances,
    required this.platformCoin,
  });

  factory EnableTendermintTokenResponse.parse(JsonMap json) {
    return EnableTendermintTokenResponse(
      mmrpc: json.value<String>('mmrpc'),
      balances: Map.fromEntries(
        json.value<JsonMap>('result', 'balances').entries.map(
              (e) => MapEntry(e.key, BalanceInfo.fromJson(e.value as JsonMap)),
            ),
      ),
      platformCoin: json.value<String>('result', 'platform_coin'),
    );
  }

  final Map<String, BalanceInfo> balances;
  final String platformCoin;

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': {
          'balances': Map.fromEntries(
            balances.entries.map((e) => MapEntry(e.key, e.value.toJson())),
          ),
          'platform_coin': platformCoin,
        },
      };
}
