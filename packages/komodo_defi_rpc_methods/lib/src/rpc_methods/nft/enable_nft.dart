import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to enable NFT functionality for a given coin
class EnableNftRequest
    extends BaseRequest<EnableNftResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  EnableNftRequest({
    required String rpcPass,
    required this.ticker,
    required this.activationParams,
  }) : super(
         method: 'enable_nft',
         rpcPass: rpcPass,
         mmrpc: '2.0',
         params: activationParams,
       );

  final String ticker;
  final NftActivationParams activationParams;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'params': {
        'ticker': ticker,
        'activation_params': activationParams.toRpcParams(),
      },
    });
  }

  @override
  EnableNftResponse parse(Map<String, dynamic> json) =>
      EnableNftResponse.parse(json);
}

/// Response from enabling NFT functionality
class EnableNftResponse extends BaseResponse {
  EnableNftResponse({
    required super.mmrpc,
    required this.nfts,
    required this.platformCoin,
  });

  factory EnableNftResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return EnableNftResponse(
      mmrpc: json.value<String>('mmrpc'),
      nfts: result
          .value<JsonMap>('nfts')
          .map(
            (key, value) => MapEntry(key, NftInfo.fromJson(value as JsonMap)),
          ),
      platformCoin: result.value<String>('platform_coin'),
    );
  }

  final Map<String, NftInfo> nfts;
  final String platformCoin;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'nfts': nfts.map((key, value) => MapEntry(key, value.toJson())),
      'platform_coin': platformCoin,
    },
  };
}

/// Information about an NFT
class NftInfo {
  NftInfo({
    required this.tokenAddress,
    required this.tokenId,
    required this.chain,
    required this.contractType,
    required this.amount,
  });

  factory NftInfo.fromJson(JsonMap json) {
    // Validate required fields exist
    final requiredFields = [
      'token_address',
      'token_id',
      'chain',
      'contract_type',
      'amount',
    ];
    for (final field in requiredFields) {
      if (!json.containsKey(field)) {
        throw FormatException('Missing required field: $field in NftInfo JSON');
      }
    }

    return NftInfo(
      tokenAddress: json.value<String>('token_address'),
      tokenId: json.value<String>('token_id'),
      chain: json.value<String>('chain'),
      contractType: json.value<String>('contract_type'),
      amount: json.value<String>('amount'),
    );
  }

  final String tokenAddress;
  final String tokenId;
  final String chain;
  final String contractType;
  final String amount;

  Map<String, dynamic> toJson() => {
    'token_address': tokenAddress,
    'token_id': tokenId,
    'chain': chain,
    'contract_type': contractType,
    'amount': amount,
  };
}
