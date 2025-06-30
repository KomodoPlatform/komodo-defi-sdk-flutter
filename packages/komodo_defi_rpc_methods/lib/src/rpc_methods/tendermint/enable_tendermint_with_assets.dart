import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class EnableTendermintWithAssetsRequest
    extends
        BaseRequest<EnableTendermintWithAssetsResponse, GeneralErrorResponse> {
  EnableTendermintWithAssetsRequest({
    required super.rpcPass,
    required this.ticker,
    required this.params,
  }) : super(method: 'enable_tendermint_with_assets', mmrpc: '2.0');

  final String ticker;
  @override
  final TendermintActivationParams params;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'ticker': ticker, ...params.toRpcParams()},
  };

  @override
  EnableTendermintWithAssetsResponse parse(Map<String, dynamic> json) =>
      EnableTendermintWithAssetsResponse.parse(json);
}

// tendermint_response.dart
class EnableTendermintWithAssetsResponse extends BaseResponse {
  EnableTendermintWithAssetsResponse({
    required super.mmrpc,
    required this.ticker,
    required this.address,
    required this.currentBlock,
    this.balance,
    this.tokensBalances = const {},
    this.tokensTickers = const [],
  });

  factory EnableTendermintWithAssetsResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    final hasBalances = result.containsKey('balance');

    return EnableTendermintWithAssetsResponse(
      mmrpc: json.value<String>('mmrpc'),
      ticker: result.value<String>('ticker'),
      address: result.value<String>('address'),
      currentBlock: result.value<int>('current_block'),
      balance:
          hasBalances
              ? BalanceInfo.fromJson(result.value<JsonMap>('balance'))
              : null,
      tokensBalances:
          hasBalances
              ? Map.fromEntries(
                result
                    .value<JsonMap>('tokens_balances')
                    .entries
                    .map(
                      (e) => MapEntry(
                        e.key,
                        BalanceInfo.fromJson(e.value as JsonMap),
                      ),
                    ),
              )
              : {},
      tokensTickers:
          !hasBalances
              ? result.value<List<dynamic>>('tokens_tickers').cast<String>()
              : [],
    );
  }

  final String ticker;
  final String address;
  final int currentBlock;
  final BalanceInfo? balance;
  final Map<String, BalanceInfo> tokensBalances;
  final List<String> tokensTickers;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'ticker': ticker,
      'address': address,
      'current_block': currentBlock,
      if (balance != null) 'balance': balance!.toJson(),
      if (tokensBalances.isNotEmpty)
        'tokens_balances': Map.fromEntries(
          tokensBalances.entries.map((e) => MapEntry(e.key, e.value.toJson())),
        ),
      if (tokensTickers.isNotEmpty) 'tokens_tickers': tokensTickers,
    },
  };
}
