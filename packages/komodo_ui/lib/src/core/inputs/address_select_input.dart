import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/komodo_ui.dart';

class AddressSelect extends StatelessWidget {
  const AddressSelect({
    required this.addresses,
    required this.onAddressSelected,
    required this.assetName,
    this.selectedAddress,
    this.hint = 'Select Address',
    this.verified,
    this.onCopied,
    super.key,
  });

  final List<PubkeyInfo> addresses;
  final ValueChanged<PubkeyInfo>? onAddressSelected;
  final PubkeyInfo? selectedAddress;
  final String assetName;
  final String hint;
  final bool Function(PubkeyInfo)? verified;
  final Function(PubkeyInfo)? onCopied;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = addresses.map((address) {
      final truncatedAddress = _truncateAddress(address.address);
      final balance = address.balance.spendable.toString();

      return SelectItem<PubkeyInfo>(
        id: address.address,
        title: truncatedAddress,
        value: address,
        // Show full address in tooltip on hover
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '($balance $assetName)',
              style: theme.textTheme.bodySmall,
            ),
            if (onCopied != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: address.address));
                  onCopied?.call(address);
                },
                tooltip: 'Copy address',
              ),
            ],
            if (verified != null && verified!(address))
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.verified, size: 20, color: Colors.blue),
              ),
          ],
        ),
      );
    }).toList();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SearchableSelect<PubkeyInfo>(
        items: items,
        initialValue: selectedAddress != null
            ? items
                .firstWhereOrNull(
                  (item) => item.value.address == selectedAddress!.address,
                )
                ?.value
            : null,
        hint: hint,
        onItemSelected: _onAddressSelected,
        // Custom builder for selected item to show tooltip with full address
        selectedItemBuilder: (item) => Tooltip(
          message: item.value.address,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${item.value.balance.spendable} $assetName)',
                style: theme.textTheme.bodySmall,
              ),
              if (onCopied != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: item.value.address));
                    onCopied?.call(item.value);
                  },
                  tooltip: 'Copy address',
                ),
              ],
              if (verified != null && verified!(item.value))
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.verified, size: 20, color: Colors.blue),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _truncateAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }

  void _onAddressSelected(SelectItem<PubkeyInfo> item) {
    onAddressSelected?.call(item.value);
  }
}
