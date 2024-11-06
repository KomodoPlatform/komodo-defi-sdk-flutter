import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Request to enable ETH with multiple ERC20 tokens
class EnableEthWithTokensRequest
    extends BaseRequest<EnableEthWithTokensResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  EnableEthWithTokensRequest({
    required String rpcPass,
    required this.ticker,
    required this.activationParams,
    this.getBalances = true,
  }) : super(
          method: 'enable_eth_with_tokens',
          rpcPass: rpcPass,
          mmrpc: '2.0',
          params: activationParams,
        );

  final String ticker;
  final EthWithTokensActivationParams activationParams;
  final bool getBalances;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'params': {
        'ticker': ticker,
        ...activationParams.toJson(),
        // 'erc20_tokens_requests':
        //     activationParams.erc20Tokens?.map((e) => e.toJson()).toList() ?? [],
        'get_balances': getBalances,
      },
    });
  }

  @override
  EnableEthWithTokensResponse parse(Map<String, dynamic> json) =>
      EnableEthWithTokensResponse.parse(json);
}

/// Response from enabling ETH with tokens request
class EnableEthWithTokensResponse extends BaseResponse {
  EnableEthWithTokensResponse({
    required super.mmrpc,
    required this.balance,
    required this.tokenBalances,
    required this.blockHeight,
    required this.requiredConfirmations,
    required this.swapContractAddress,
    required this.nodes,
    required this.maxGasPriceMultiplier,
  });

  factory EnableEthWithTokensResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return EnableEthWithTokensResponse(
      mmrpc: json.valueOrNull<String>('mmrpc') ?? '2.0',
      balance: BalanceInfo.fromJson(result.value<JsonMap>('balance')),
      tokenBalances: result
          .value<List<dynamic>>('token_balances')
          .map((e) => TokenBalance.fromJson(e as JsonMap))
          .toList(),
      blockHeight: result.value<int>('block_height'),
      requiredConfirmations: result.value<int>('required_confirmations'),
      swapContractAddress: result.value<String>('swap_contract_address'),
      nodes: result
          .value<JsonList>('nodes')
          .map((e) => e.value<String>('url'))
          .toList(),
      maxGasPriceMultiplier: result.value<num>('max_gas_price_multiplier'),
    );
  }

  final BalanceInfo balance;
  final List<TokenBalance> tokenBalances;
  final int blockHeight;
  final int requiredConfirmations;
  final String swapContractAddress;
  final List<String> nodes;
  final num maxGasPriceMultiplier;

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': {
          'balance': balance.toJson(),
          'token_balances': tokenBalances.map((e) => e.toJson()).toList(),
          'block_height': blockHeight,
          'required_confirmations': requiredConfirmations,
          'swap_contract_address': swapContractAddress,
          'nodes': nodes,
          'max_gas_price_multiplier': maxGasPriceMultiplier,
        },
      };
}
