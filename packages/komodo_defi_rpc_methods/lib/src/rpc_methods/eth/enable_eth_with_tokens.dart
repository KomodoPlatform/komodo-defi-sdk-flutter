import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
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
        ...activationParams.toJsonRequestParams(),
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
    required this.currentBlock,
    required this.walletBalance,
    required this.nftsInfos,
  });

  factory EnableEthWithTokensResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return EnableEthWithTokensResponse(
      mmrpc: json.value<String>('mmrpc'),
      currentBlock: result.value<int>('current_block'),
      walletBalance: WalletBalance.fromJson(
        result.value<JsonMap>('wallet_balance'),
      ),
      nftsInfos: result.value<JsonMap>('nfts_infos'),
    );
  }

  final int currentBlock;
  final WalletBalance walletBalance;
  final JsonMap nftsInfos; // Could be expanded into a proper type if needed

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': {
          'current_block': currentBlock,
          'wallet_balance': walletBalance.toJson(),
          'nfts_infos': nftsInfos,
        },
      };
}

class WalletBalance {
  const WalletBalance({
    required this.walletType,
    required this.accounts,
  });

  factory WalletBalance.fromJson(JsonMap json) {
    return WalletBalance(
      walletType: json.value<String>('wallet_type'),
      accounts: json
          .value<List<dynamic>>('accounts')
          .map((e) => WalletAccount.fromJson(e as JsonMap))
          .toList(),
    );
  }

  final String walletType;
  final List<WalletAccount> accounts;

  Map<String, dynamic> toJson() => {
        'wallet_type': walletType,
        'accounts': accounts.map((e) => e.toJson()).toList(),
      };
}

class WalletAccount {
  const WalletAccount({
    required this.accountIndex,
    required this.derivationPath,
    required this.totalBalance,
    required this.addresses,
  });

  factory WalletAccount.fromJson(JsonMap json) {
    return WalletAccount(
      accountIndex: json.value<int>('account_index'),
      derivationPath: json.value<String>('derivation_path'),
      totalBalance: TokenBalanceMap.fromJson(
        json.value<JsonMap>('total_balance'),
      ),
      addresses: json
          .value<List<dynamic>>('addresses')
          .map((e) => WalletAddress.fromJson(e as JsonMap))
          .toList(),
    );
  }

  final int accountIndex;
  final String derivationPath;
  final TokenBalanceMap totalBalance;
  final List<WalletAddress> addresses;

  Map<String, dynamic> toJson() => {
        'account_index': accountIndex,
        'derivation_path': derivationPath,
        'total_balance': totalBalance.toJson(),
        'addresses': addresses.map((e) => e.toJson()).toList(),
      };
}

class WalletAddress {
  const WalletAddress({
    required this.address,
    required this.derivationPath,
    required this.chain,
    required this.balance,
  });

  factory WalletAddress.fromJson(JsonMap json) {
    return WalletAddress(
      address: json.value<String>('address'),
      derivationPath: json.value<String>('derivation_path'),
      chain: json.value<String>('chain'),
      balance: TokenBalanceMap.fromJson(
        json.value<JsonMap>('balance'),
      ),
    );
  }

  final String address;
  final String derivationPath;
  final String chain;
  final TokenBalanceMap balance;

  Map<String, dynamic> toJson() => {
        'address': address,
        'derivation_path': derivationPath,
        'chain': chain,
        'balance': balance.toJson(),
      };
}
