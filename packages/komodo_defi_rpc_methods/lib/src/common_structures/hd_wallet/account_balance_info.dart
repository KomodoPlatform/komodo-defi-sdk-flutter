import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Complete account balance information including all addresses
class AccountBalanceInfo {
  const AccountBalanceInfo({
    required this.accountIndex,
    required this.derivationPath,
    required this.totalBalance,
    required this.addresses,
  });

  factory AccountBalanceInfo.fromJson(JsonMap json) {
    return AccountBalanceInfo(
      accountIndex: json.value<int>('account_index'),
      derivationPath: json.value<String>('derivation_path'),
      totalBalance: TokenBalanceMap.fromJson(
        json.value<JsonMap>('total_balance'),
      ),
      addresses: json
          .value<List<dynamic>>('addresses')
          .map((e) => AddressInfo.fromJson(e as JsonMap))
          .toList(),
    );
  }

  final int accountIndex;
  final String derivationPath;
  final TokenBalanceMap totalBalance;
  final List<AddressInfo> addresses;

  /// Gets all addresses with non-zero balance for a specific token
  List<AddressInfo> addressesWithBalance(String ticker) =>
      addresses.where((a) => a.balance.balanceOf(ticker).hasBalance).toList();

  /// Gets all tokens that have any balance across all addresses
  Set<String> get activeTokens => totalBalance.tokensWithBalance;

  JsonMap toJson() => {
        'account_index': accountIndex,
        'derivation_path': derivationPath,
        'total_balance': totalBalance.toJson(),
        'addresses': addresses.map((e) => e.toJson()).toList(),
      };
}
