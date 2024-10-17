import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AddressInfo {
  AddressInfo({
    required this.address,
    required this.derivationPath,
    required this.chain,
    required this.balance,
  });

  factory AddressInfo.fromJson(JsonMap json) {
    return AddressInfo(
      address: json.value<String>('address'),
      derivationPath: json.value<String>('derivation_path'),
      chain: json.value<String>('chain'),
      balance: BalanceInfo.fromJson(json.value<JsonMap>('balance')),
    );
  }

  final String address;
  final String derivationPath;
  final String chain;
  final BalanceInfo balance;

  JsonMap toJson() {
    return {
      'address': address,
      'derivation_path': derivationPath,
      'chain': chain,
      'balance': balance.toJson(),
    };
  }
}
