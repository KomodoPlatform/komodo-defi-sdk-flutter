import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AccountBalanceInfo {
  AccountBalanceInfo({
    required this.accountIndex,
    required this.derivationPath,
    required this.totalBalance,
    required this.addresses,
  });

  factory AccountBalanceInfo.fromJson(JsonMap json) {
    return AccountBalanceInfo(
      accountIndex: json.value<int>('account_index'),
      derivationPath: json.value<String>('derivation_path'),
      totalBalance: BalanceInfo.fromJson(json.value<JsonMap>('total_balance')),
      addresses: (json.value<JsonList>('addresses') as List)
          .map((e) => AddressInfo.fromJson(e as JsonMap))
          .toList(),
    );
  }

  final int accountIndex;
  final String derivationPath;
  final BalanceInfo totalBalance;
  final List<AddressInfo> addresses;

  JsonMap toJson() {
    return {
      'account_index': accountIndex,
      'derivation_path': derivationPath,
      'total_balance': totalBalance.toJson(),
      'addresses': addresses.map((e) => e.toJson()).toList(),
    };
  }
}
