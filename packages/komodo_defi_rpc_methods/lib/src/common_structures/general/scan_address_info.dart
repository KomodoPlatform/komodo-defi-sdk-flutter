import 'package:komodo_defi_rpc_methods/src/common_structures/general/new_address_info.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class ScanAddressesInfo {
  ScanAddressesInfo({
    required this.accountIndex,
    required this.derivationPath,
    required this.newAddresses,
  });

  factory ScanAddressesInfo.fromJson(Map<String, dynamic> json) {
    return ScanAddressesInfo(
      accountIndex: json.value<int>('account_index'),
      derivationPath: json.value<String>('derivation_path'),
      newAddresses: (json['new_addresses'] as List)
          .map((e) => NewAddressInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  final int accountIndex;
  final String derivationPath;
  final List<NewAddressInfo> newAddresses;

  Map<String, dynamic> toJson() {
    return {
      'account_index': accountIndex,
      'derivation_path': derivationPath,
      'new_addresses': newAddresses.map((e) => e.toJson()).toList(),
    };
  }
}
