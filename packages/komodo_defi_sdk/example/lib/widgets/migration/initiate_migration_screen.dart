import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/migrations/bloc/migration_bloc_exports.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

class InitiateMigrationScreen extends StatelessWidget {
  const InitiateMigrationScreen({
    this.sourceWallet,
    this.destinationWallet,
    super.key,
  });

  final KdfUser? sourceWallet;
  final KdfUser? destinationWallet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Migrate Funds to HD Wallet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You are about to transfer all funds from your Legacy (Iguana) Wallet to your HD Wallet. '
                    'This will move all coins with a balance > 0 to your HD wallet in one go.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 16),

                  // Source wallet info
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Source Wallet:',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sourceWallet?.walletId.name ?? 'Legacy Wallet (Iguana mode)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Destination wallet info
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Destination:',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          destinationWallet?.walletId.name ?? 'My HD Wallet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Important note
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Note: Your legacy wallet will remain accessible, but its funds will be moved to the HD wallet.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<MigrationBloc>().add(
                      MigrationInitiated(
                        sourceWalletName: sourceWallet?.walletId.name,
                        destinationWalletName: destinationWallet?.walletId.name,
                      ),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Start Migration'),
                  key: const Key('start_migration_button'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
