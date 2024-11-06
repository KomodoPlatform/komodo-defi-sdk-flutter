import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class EnableBchWithTokensResponse extends BaseResponse {
  EnableBchWithTokensResponse({
    required super.mmrpc,
    required this.currentBlock,
    required this.bchAddressesInfos,
    required this.slpAddressesInfos,
  });

  factory EnableBchWithTokensResponse.parse(Map<String, dynamic> json) {
    return EnableBchWithTokensResponse(
      mmrpc: json.value<String>('mmrpc'),
      currentBlock: json.value<int>('result', 'current_block'),
      bchAddressesInfos: json.value<JsonMap>('result', 'bch_addresses_infos'),
      slpAddressesInfos: json.value<JsonMap>('result', 'slp_addresses_infos'),
    );
  }

  final int currentBlock;
  final Map<String, dynamic> bchAddressesInfos;
  final Map<String, dynamic> slpAddressesInfos;

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': {
          'current_block': currentBlock,
          'bch_addresses_infos': bchAddressesInfos,
          'slp_addresses_infos': slpAddressesInfos,
        },
      };
}

class EnableBchWithTokensRequest
    extends BaseRequest<EnableBchWithTokensResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  EnableBchWithTokensRequest({
    required String rpcPass,
    required this.ticker,
    required this.activationParams,
    this.addressFormat,
    this.getBalances = true,
    this.utxoMergeParams,
  }) : super(
          method: 'enable_bch_with_tokens',
          rpcPass: rpcPass,
          mmrpc: '2.0',
          params: activationParams,
        );

  final String ticker;
  final BchActivationParams activationParams;
  final AddressFormat? addressFormat;
  final bool getBalances;
  final UtxoMergeParams? utxoMergeParams;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'params': {
        'ticker': ticker,
        'activation_params': activationParams.toJson(),
        if (addressFormat != null) 'address_format': addressFormat!.toJson(),
        'get_balances': getBalances,
        if (utxoMergeParams != null)
          'utxo_merge_params': utxoMergeParams!.toJson(),
      },
    };
  }

  @override
  EnableBchWithTokensResponse parse(Map<String, dynamic> json) =>
      EnableBchWithTokensResponse.parse(json);
}
