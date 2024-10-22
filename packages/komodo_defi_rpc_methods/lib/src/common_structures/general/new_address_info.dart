import 'package:komodo_defi_rpc_methods/src/common_structures/general/balance_info.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class NewAddressInfo {
  NewAddressInfo({
    required this.address,
    required this.derivationPath,
    required this.chain,
    required this.balance,
  });

  factory NewAddressInfo.fromJson(Map<String, dynamic> json) {
    return NewAddressInfo(
      address: json.value<String>('address'),
      derivationPath: json.valueOrNull<String>('derivation_path'),
      chain: json.valueOrNull<String>('chain'),
      balance: BalanceInfo.fromJson(json.value<JsonMap>('balance')),
    );
  }
  final String address;
  final BalanceInfo balance;

  // HD Wallet properties (Null if not HD Wallet)
  final String? derivationPath;
  final String? chain;

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'derivation_path': derivationPath,
      'chain': chain,
      'balance': balance.toJson(),
    };
  }
}
