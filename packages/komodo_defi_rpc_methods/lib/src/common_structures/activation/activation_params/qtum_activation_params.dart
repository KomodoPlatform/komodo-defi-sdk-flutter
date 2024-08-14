import 'package:komodo_defi_rpc_methods/src/common_structures/activation/activation_params/activation_params.dart';

class QtumActivationParams extends ActivationParams {
  QtumActivationParams({
    required this.electrumServers,
    this.swapContractAddress,
    this.isHd = false,
    this.accountIndex,
    this.gapLimit,
    this.scanPolicy,
    this.minAddressesNumber,
  });
  final List<Map<String, dynamic>> electrumServers;
  final String? swapContractAddress;
  final bool isHd;
  final int? accountIndex;
  @override
  final int? gapLimit;
  @override
  final String? scanPolicy;
  @override
  final int? minAddressesNumber;

  @override
  Map<String, dynamic> toJson() {
    final json = {
      'mode': {
        'rpc': 'Electrum',
        'rpc_data': {
          'servers': electrumServers,
        },
      },
      if (swapContractAddress != null)
        'swap_contract_address': swapContractAddress,
    };

    if (isHd) {
      json['priv_key_policy'] = 'Trezor';
      if (accountIndex != null) json['account_index'] = accountIndex;
      if (gapLimit != null) json['gap_limit'] = gapLimit;
      if (scanPolicy != null) json['scan_policy'] = scanPolicy;
      if (minAddressesNumber != null) {
        json['min_addresses_number'] = minAddressesNumber;
      }
    }

    return json;
  }
}
