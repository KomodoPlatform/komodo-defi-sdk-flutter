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
    this.availableBalance,
    super.key,
  });

  final Asset asset;
  final String amount;
  final bool isMaxAmount;
  final ValueChanged<String> onChanged;
  final ValueChanged<bool> onMaxToggled;
  final String? amountError;
  final bool hasInsufficientBalance;
  final String? availableBalance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Amount',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (availableBalance != null)
              Text(
                'Available: $availableBalance ${asset.id.id}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: amount,
          enabled: !isMaxAmount,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            errorText: amountError,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    asset.id.id,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            prefixIcon:
                hasInsufficientBalance
                    ? Tooltip(
                      message: 'Insufficient balance',
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: theme.colorScheme.error,
                      ),
                    )
                    : null,
            helperText:
                hasInsufficientBalance
                    ? 'Insufficient balance'
                    : 'Enter the amount to send',
            helperStyle:
                hasInsufficientBalance
                    ? TextStyle(color: theme.colorScheme.error)
                    : null,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isMaxAmount,
                  onChanged: (value) => onMaxToggled(value ?? false),
                ),
                const Text('Send maximum available'),
              ],
            ),
            if (!isMaxAmount)
              TextButton(
                onPressed: () {
                  onMaxToggled(true);
                },
                child: const Text('MAX'),
              ),
          ],
        ),
      ],
    );
  }
}
