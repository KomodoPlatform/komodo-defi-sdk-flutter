import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class EnableSlpRequest
    extends BaseRequest<EnableSlpResponse, GeneralErrorResponse> {
  EnableSlpRequest({
    required this.ticker,
    required this.activationParams,
    super.rpcPass,
  }) : super(method: 'enable_slp', mmrpc: RpcVersion.v2_0);

  final String ticker;
  final SlpActivationParams activationParams;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {
      'ticker': ticker,
      ...activationParams.toJson(),
      // 'activation_params': activationParams.toJson(),
    },
  };

  @override
  EnableSlpResponse parse(Map<String, dynamic> json) =>
      EnableSlpResponse.parse(json);
}

class EnableSlpResponse extends BaseResponse {
  EnableSlpResponse({
    required super.mmrpc,
    required this.balances,
    required this.platformCoin,
  });

  factory EnableSlpResponse.parse(Map<String, dynamic> json) {
    return EnableSlpResponse(
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
    'result': {'balances': balances, 'platform_coin': platformCoin},
  };
}
