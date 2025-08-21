import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/migrations/bloc/migration_bloc_exports.dart';
import 'package:url_launcher/url_launcher.dart';

class MigrationResultsScreen extends StatelessWidget {
  const MigrationResultsScreen({
    required this.coins,
    super.key,
  });

  final List<MigrationCoin> coins;

  @override
  Widget build(BuildContext context) {
    final summary = MigrationSummary.fromState(
      MigrationState.completed(coins: coins),
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Migration Complete',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Summary message
          _SummaryMessage(summary: summary),

          const SizedBox(height: 24),

          // Results table
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
                              'Result',
                              style: TextStyle(fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'Transaction',
                              style: TextStyle(fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Results list
                    Expanded(
                      child: ListView.separated(
                        itemCount: coins.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final coin = coins[index];
                          return _ResultListItem(
                            coin: coin,
                            coinIndex: index,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Verification tip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tip:',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You can verify each transfer on the blockchain. Your legacy wallet balances for migrated coins should now be 0.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (summary.failedCoins > 0) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<MigrationBloc>().add(const MigrationRetryFailed());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Failed'),
                    key: const Key('retry_failed_button'),
                  ),
                ),
                const SizedBox(width: 16),
              ],

              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<MigrationBloc>().add(const MigrationReset());
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
                  key: const Key('migration_done_button'),
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

class _SummaryMessage extends StatelessWidget {
  const _SummaryMessage({
    required this.summary,
  });

  final MigrationSummary summary;

  @override
  Widget build(BuildContext context) {
    String message;
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (summary.isFullSuccess) {
      message = 'Successfully migrated ${summary.successfulCoins} coin${summary.successfulCoins == 1 ? '' : 's'} to your HD wallet!';
      backgroundColor = Theme.of(context).colorScheme.tertiaryContainer;
      textColor = Theme.of(context).colorScheme.onTertiaryContainer;
      icon = Icons.check_circle;
    } else if (summary.isPartialSuccess) {
      message = 'Migration completed with mixed results: ${summary.successfulCoins} successful, ${summary.failedCoins} failed.';
      backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
      textColor = Theme.of(context).colorScheme.onSecondaryContainer;
      icon = Icons.warning;
    } else if (summary.isCompleteFailure) {
      message = 'Migration failed: No coins could be transferred. Please check the issues below.';
      backgroundColor = Theme.of(context).colorScheme.errorContainer;
      textColor = Theme.of(context).colorScheme.onErrorContainer;
      icon = Icons.error;
    } else {
      message = 'The migration is finished. Summary of results:';
      backgroundColor = Theme.of(context).colorScheme.surfaceVariant;
      textColor = Theme.of(context).colorScheme.onSurfaceVariant;
      icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultListItem extends StatelessWidget {
  const _ResultListItem({
    required this.coin,
    required this.coinIndex,
  });

  final MigrationCoin coin;
  final int coinIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coin info
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      coin.asset.id.symbol.common.substring(0, 1).toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.asset.id.symbol.common,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        coin.balance,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Result status
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatusIcon(status: coin.status),
                    const SizedBox(width: 4),
                    Text(
                      coin.isSuccess ? 'Transferred' : 'Not migrated',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(context, coin.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (coin.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    coin.errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          // Transaction info
          Expanded(
            flex: 3,
            child: coin.isSuccess && coin.transactionId != null
                ? _TransactionInfo(
                    transactionId: coin.transactionId!,
                    coinSymbol: coin.asset.id.symbol.common,
                  )
                : coin.canRetry
                    ? Center(
                        child: TextButton.icon(
                          onPressed: () {
                            context.read<MigrationBloc>().add(
                              MigrationRetryCoin(coinIndex: coinIndex),
                            );
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry'),
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context, CoinMigrationStatus status) {
    switch (status) {
      case CoinMigrationStatus.transferred:
        return Theme.of(context).colorScheme.tertiary;
      case CoinMigrationStatus.failed:
      case CoinMigrationStatus.feeTooLow:
      case CoinMigrationStatus.notSupported:
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.status,
  });

  final CoinMigrationStatus status;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (status) {
      case CoinMigrationStatus.transferred:
        icon = Icons.check_circle;
        color = Theme.of(context).colorScheme.tertiary;
        break;
      case CoinMigrationStatus.failed:
        icon = Icons.error;
        color = Theme.of(context).colorScheme.error;
        break;
      case CoinMigrationStatus.feeTooLow:
      case CoinMigrationStatus.notSupported:
        icon = Icons.warning;
        color = Theme.of(context).colorScheme.error;
        break;
      default:
        icon = Icons.circle;
        color = Theme.of(context).colorScheme.onSurfaceVariant;
        break;
    }

    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }
}

class _TransactionInfo extends StatelessWidget {
  const _TransactionInfo({
    required this.transactionId,
    required this.coinSymbol,
  });

  final String transactionId;
  final String coinSymbol;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Transaction ID (truncated)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'TxID: ${_truncateTransactionId(transactionId)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Action buttons
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _ActionButton(
              icon: Icons.link,
              label: 'Explorer',
              onPressed: () => _viewOnExplorer(transactionId, coinSymbol),
            ),
            _ActionButton(
              icon: Icons.copy,
              label: 'Copy',
              onPressed: () => _copyTransactionId(context, transactionId),
            ),
          ],
        ),
      ],
    );
  }

  String _truncateTransactionId(String txId) {
    if (txId.length <= 16) return txId;
    return '${txId.substring(0, 8)}...${txId.substring(txId.length - 4)}';
  }

  void _viewOnExplorer(String txId, String coinSymbol) async {
    // Mock implementation - in reality this would use the appropriate explorer URL
    final explorerUrl = 'https://explorer.example.com/tx/$txId';
    final uri = Uri.parse(explorerUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyTransactionId(BuildContext context, String txId) {
    Clipboard.setData(ClipboardData(text: txId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction ID copied to clipboard')),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
