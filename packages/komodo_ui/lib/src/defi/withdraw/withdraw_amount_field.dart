import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class WithdrawAmountField extends StatelessWidget {
  const WithdrawAmountField({
    required this.asset,
    required this.amount,
    required this.isMaxAmount,
    required this.onChanged,
    required this.onMaxToggled,
    this.amountError,
    this.hasInsufficientBalance = false,
    super.key,
  });
  final Asset asset;
  final String amount;
  final bool isMaxAmount;
  final ValueChanged<String> onChanged;
  final ValueChanged<bool> onMaxToggled;
  final String? amountError;
  final bool hasInsufficientBalance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: amount,
          enabled: !isMaxAmount,
          decoration: InputDecoration(
            labelText: 'Amount',
            border: const OutlineInputBorder(),
            errorText: amountError,
            suffixText: asset.id.name,
            helperText: hasInsufficientBalance ? 'Insufficient balance' : null,
            helperStyle: hasInsufficientBalance
                ? TextStyle(color: theme.colorScheme.error)
                : null,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: isMaxAmount,
              onChanged: (value) => onMaxToggled(value ?? false),
            ),
            const Text('Send maximum amount'),
          ],
        ),
      ],
    );
  }
}
