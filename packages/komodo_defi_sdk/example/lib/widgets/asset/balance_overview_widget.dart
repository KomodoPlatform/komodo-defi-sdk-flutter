import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class BalanceOverviewWidget extends StatelessWidget {
  const BalanceOverviewWidget({
    required this.balance,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    super.key,
  });

  final BalanceInfo? balance;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children:
              isLoading
                  ? [
                    const SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(),
                    ),
                  ]
                  : error != null
                  ? [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      'Error loading balance',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      error!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: onRetry, child: const Text('Retry')),
                  ]
                  : [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      (balance?.total.toDouble() ?? 0.0).toString(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(width: 128, child: Divider()),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Available',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              balance?.spendable.toDouble().toString() ?? '0.0',
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            Text(
                              'Locked',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              balance?.unspendable.toDouble().toString() ??
                                  '0.0',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
        ),
      ),
    );
  }
}
