import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/migrations/bloc/migration_bloc_exports.dart';

class MigrationPreviewScreen extends StatelessWidget {
  const MigrationPreviewScreen({
    required this.coins,
    super.key,
  });

  final List<MigrationCoin> coins;

  @override
  Widget build(BuildContext context) {
    final migrateableCoins = coins.where((coin) => coin.canMigrate).toList();
    final problemCoins = coins.where((coin) => coin.hasFailed).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Migration Preview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'We found the following assets in your legacy wallet that can be migrated to HD:',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Coins list
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table headers
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Coin',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Amount',
                              style: TextStyle(fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Status',
                              style: TextStyle(fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Coins list
                    Expanded(
                      child: ListView.separated(
                        itemCount: coins.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final coin = coins[index];
                          return _CoinListItem(coin: coin);
                        },
                      ),
                    ),

                    // Footnotes for problem coins
                    if (problemCoins.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Issues found:',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ...problemCoins.map((coin) => Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '• ${coin.asset.id.symbol.common}: ${coin.errorMessage}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Summary
          if (migrateableCoins.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Review the above and click "Confirm" to transfer ${migrateableCoins.length} coin${migrateableCoins.length == 1 ? '' : 's'} to your HD wallet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'No coins can be migrated at this time. Please resolve the issues above.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<MigrationBloc>().add(const MigrationCancelled());
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  key: const Key('migration_preview_back_button'),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: FilledButton.icon(
                  onPressed: migrateableCoins.isEmpty
                      ? null
                      : () {
                          context.read<MigrationBloc>().add(const MigrationConfirmed());
                        },
                  icon: const Icon(Icons.check),
                  label: const Text('Confirm & Migrate'),
                  key: const Key('confirm_migration_button'),
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

class _CoinListItem extends StatelessWidget {
  const _CoinListItem({
    required this.coin,
  });

  final MigrationCoin coin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Coin symbol
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      coin.asset.id.symbol.common.substring(0, 1).toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    coin.asset.id.symbol.common,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Balance
          Expanded(
            flex: 2,
            child: Text(
              coin.balance,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

          // Status
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatusIndicator(status: coin.status),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    coin.statusMessage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(context, coin.status),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context, CoinMigrationStatus status) {
    switch (status) {
      case CoinMigrationStatus.ready:
        return Theme.of(context).colorScheme.primary;
      case CoinMigrationStatus.feeTooLow:
      case CoinMigrationStatus.notSupported:
      case CoinMigrationStatus.failed:
        return Theme.of(context).colorScheme.error;
      case CoinMigrationStatus.transferred:
        return Theme.of(context).colorScheme.tertiary;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({
    required this.status,
  });

  final CoinMigrationStatus status;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (status) {
      case CoinMigrationStatus.ready:
        icon = Icons.check_circle_outline;
        color = Theme.of(context).colorScheme.primary;
        break;
      case CoinMigrationStatus.feeTooLow:
      case CoinMigrationStatus.notSupported:
        icon = Icons.warning;
        color = Theme.of(context).colorScheme.error;
        break;
      case CoinMigrationStatus.failed:
        icon = Icons.error_outline;
        color = Theme.of(context).colorScheme.error;
        break;
      case CoinMigrationStatus.transferred:
        icon = Icons.check_circle;
        color = Theme.of(context).colorScheme.tertiary;
        break;
      case CoinMigrationStatus.transferring:
        icon = Icons.sync;
        color = Theme.of(context).colorScheme.secondary;
        break;
      default:
        icon = Icons.circle_outlined;
        color = Theme.of(context).colorScheme.onSurface;
        break;
    }

    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }
}
