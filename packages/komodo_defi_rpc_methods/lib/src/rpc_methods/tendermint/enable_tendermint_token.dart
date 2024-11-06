import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class EnableTendermintTokenRequest
    extends BaseRequest<EnableTendermintTokenResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  EnableTendermintTokenRequest({
    required String rpcPass,
    required this.ticker,
    required this.activationParams,
  }) : super(
          method: 'enable_tendermint_token',
          rpcPass: rpcPass,
          mmrpc: '2.0',
          params: activationParams,
        );

  final String ticker;
  final CosmosActivationParams activationParams;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'params': {
        'ticker': ticker,
        'activation_params': activationParams.toJson(),
      },
    };
  }

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

  factory EnableTendermintTokenResponse.parse(Map<String, dynamic> json) {
    return EnableTendermintTokenResponse(
      mmrpc: json.value<String>('mmrpc'),
      balances: json.value<Map<String, dynamic>>('result', 'balances'),
      platformCoin: json.value<String>('result', 'platform_coin'),
    );
  }

  final Map<String, dynamic> balances;
  final String platformCoin;

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': {
          'balances': balances,
          'platform_coin': platformCoin,
        },
      };
}
