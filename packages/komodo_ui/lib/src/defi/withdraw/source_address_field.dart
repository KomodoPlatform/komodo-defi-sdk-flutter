import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/komodo_ui.dart';

class SourceAddressField extends StatelessWidget {

  const SourceAddressField({
    required this.asset,
    required this.pubkeys,
    required this.selectedAddress,
    required this.onChanged,
    this.networkError,
    super.key,
  });
  final Asset asset;
  final AssetPubkeys? pubkeys;
  final PubkeyInfo? selectedAddress;
  final ValueChanged<PubkeyInfo>? onChanged;
  final String? networkError;

  @override
  Widget build(BuildContext context) {
    if (pubkeys == null || pubkeys!.keys.isEmpty) {
      return ErrorDisplay(
        message: networkError ?? 'No addresses available',
        icon: Icons.account_balance_wallet,
      );
    }

    return AddressSelect(
      addresses: pubkeys!.keys,
      selectedAddress: selectedAddress,
      onAddressSelected: onChanged,
      assetName: asset.id.name,
      hint: 'From Address',
      onCopied: (address) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address copied to clipboard'),
          ),
        );
      },
      // Example of how to use verified - implement your own logic
      verified: (address) => address.balance.spendable > Decimal.zero,
    );
  }
}
