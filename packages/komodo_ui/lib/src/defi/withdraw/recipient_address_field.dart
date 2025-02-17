import 'package:flutter/material.dart';
import 'package:komodo_ui/komodo_ui.dart';

class RecipientAddressField extends StatelessWidget {
  const RecipientAddressField({
    required this.address,
    required this.onChanged,
    required this.onQrScanned,
    this.addressError,
    this.isMixedCase = false,
    this.onConvertAddress,
    super.key,
  });
  final String address;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String> onQrScanned;
  final String? addressError;
  final bool isMixedCase;
  final VoidCallback? onConvertAddress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: address,
          readOnly: onChanged == null,
          decoration: InputDecoration(
            labelText: 'Recipient Address',
            border: const OutlineInputBorder(),
            errorText: addressError,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMixedCase && onConvertAddress != null)
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    tooltip: 'Convert case',
                    onPressed: onConvertAddress,
                  ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QrCodeReaderOverlay(),
                      ),
                    );
                    if (result != null) onQrScanned(result);
                  },
                ),
              ],
            ),
          ),
          onChanged: onChanged,
        ),
        if (isMixedCase)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This address contains mixed case characters. Click the convert button to fix.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
