import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/komodo_ui.dart';

class AddressSelectInput extends StatelessWidget {
  const AddressSelectInput({
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
  final ValueChanged<PubkeyInfo?>? onAddressSelected;
  final PubkeyInfo? selectedAddress;
  final String assetName;
  final String hint;
  final bool Function(PubkeyInfo)? verified;
  final void Function(PubkeyInfo)? onCopied;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SearchableSelect<PubkeyInfo>(
        items:
            addresses.map((address) {
              final truncatedAddress = _truncateAddress(address.address);
              final isVerified = verified?.call(address) ?? false;

              return DropdownMenuItem<PubkeyInfo>(
                value: address,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      // Address icon or indicator
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              isVerified
                                  ? theme.colorScheme.primary.withOpacity(0.1)
                                  : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 18,
                            color:
                                isVerified
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withOpacity(
                                      0.7,
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Address details column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  truncatedAddress,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (isVerified)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.verified,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${address.balance.spendable} $assetName available',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Copy button with improved styling
                      if (onCopied != null)
                        IconButton(
                          icon: const Icon(Icons.copy_outlined, size: 18),
                          style: IconButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(8),
                          ),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: address.address),
                            );
                            onCopied?.call(address);
                          },
                          tooltip: 'Copy address',
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
        value: selectedAddress,
        hint: hint,
        onChanged: onAddressSelected,
        // Define a custom decoration for the select field
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
          prefixIcon: Icon(
            Icons.account_balance_wallet_outlined,
            size: 20,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          suffixIcon: Icon(
            Icons.arrow_drop_down,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        // Custom builder for the selected item
        selectedItemBuilder: (context, selected) {
          if (selected == null) return null;

          final isVerified = verified?.call(selected) ?? false;

          return Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      _truncateAddress(selected.address),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (isVerified)
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      '(${selected.balance.spendable} $assetName)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _truncateAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }
}
