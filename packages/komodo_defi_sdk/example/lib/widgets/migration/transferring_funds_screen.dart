import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/migrations/bloc/migration_bloc_exports.dart';

class TransferringFundsScreen extends StatefulWidget {
  const TransferringFundsScreen({
    required this.coins,
    this.currentCoinIndex = 0,
    super.key,
  });

  final List<MigrationCoin> coins;
  final int currentCoinIndex;

  @override
  State<TransferringFundsScreen> createState() => _TransferringFundsScreenState();
}

class _TransferringFundsScreenState extends State<TransferringFundsScreen>
    with TickerProviderStateMixin {
  bool _showDetails = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.coins.where((coin) =>
      coin.isSuccess || coin.hasFailed).length;
    final progress = widget.coins.isEmpty ? 0.0 : completedCount / widget.coins.length;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Migrating Funds...',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Step indicator
          Text(
            'Step 2 of 3: Transferring assets to HD',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Overall progress
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Please wait while your funds are being transferred to the HD wallet:',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Progress bar
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${completedCount} of ${widget.coins.length} completed',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Coins transfer status
          Expanded(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with toggle
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transfer Progress',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showDetails = !_showDetails;
                            });
                          },
                          icon: Icon(
                            _showDetails ? Icons.visibility_off : Icons.visibility,
                            size: 16,
                          ),
                          label: Text(_showDetails ? 'Hide Details' : 'View Details'),
                          key: const Key('toggle_details_button'),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Coins list
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.coins.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final coin = widget.coins[index];
                        final isCurrentlyTransferring = index == widget.currentCoinIndex &&
                            coin.isInProgress;

                        return _TransferStatusItem(
                          coin: coin,
                          isCurrentlyTransferring: isCurrentlyTransferring,
                          showDetails: _showDetails,
                          pulseAnimation: _pulseAnimation,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Time estimate
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This may take a minute per coin. Please do not close this window.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TransferStatusItem extends StatelessWidget {
  const _TransferStatusItem({
    required this.coin,
    required this.isCurrentlyTransferring,
    required this.showDetails,
    required this.pulseAnimation,
  });

  final MigrationCoin coin;
  final bool isCurrentlyTransferring;
  final bool showDetails;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentlyTransferring
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentlyTransferring
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main status row
          Row(
            children: [
              // Coin icon
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

              // Coin info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${coin.asset.id.symbol.common} – ${coin.balance}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (showDetails && coin.estimatedFee != null)
                      Text(
                        'Est. fee: ${coin.estimatedFee}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),

              // Status indicator
              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: isCurrentlyTransferring ? pulseAnimation.value : 1.0,
                    child: _StatusIndicatorWithText(coin: coin),
                  );
                },
              ),
            ],
          ),

          // Error message or transaction ID
          if (showDetails) ...[
            if (coin.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  coin.errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
            if (coin.transactionId != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'TX: ${coin.transactionId!}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _StatusIndicatorWithText extends StatelessWidget {
  const _StatusIndicatorWithText({
    required this.coin,
  });

  final MigrationCoin coin;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String text;

    switch (coin.status) {
      case CoinMigrationStatus.ready:
        icon = Icons.hourglass_empty;
        color = Theme.of(context).colorScheme.onSurfaceVariant;
        text = 'Pending...';
        break;
      case CoinMigrationStatus.transferring:
        icon = Icons.sync;
        color = Theme.of(context).colorScheme.secondary;
        text = 'Sending...';
        break;
      case CoinMigrationStatus.transferred:
        icon = Icons.check_circle;
        color = Theme.of(context).colorScheme.tertiary;
        text = 'Sent!';
        break;
      case CoinMigrationStatus.feeTooLow:
      case CoinMigrationStatus.notSupported:
        icon = Icons.warning;
        color = Theme.of(context).colorScheme.error;
        text = 'Skipped';
        break;
      case CoinMigrationStatus.failed:
        icon = Icons.error_outline;
        color = Theme.of(context).colorScheme.error;
        text = 'Failed';
        break;
      default:
        icon = Icons.circle_outlined;
        color = Theme.of(context).colorScheme.onSurface;
        text = coin.statusMessage;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
