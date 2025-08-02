import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/src/utils/formatters/asset_formatting.dart';

/// A widget for displaying staking rewards with real-time updates.
///
/// Shows pending rewards amount, estimated next reward time, and claim button.
class RewardDisplay extends StatelessWidget {
  const RewardDisplay({
    required this.rewards,
    required this.asset,
    this.onClaim,
    this.showClaimButton = true,
    this.showNextRewardTime = true,
    this.compact = false,
    super.key,
  });

  final RewardUpdate rewards;
  final Asset asset;
  final VoidCallback? onClaim;
  final bool showClaimButton;
  final bool showNextRewardTime;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRewards = rewards.amount.compareTo(Decimal.zero) > 0;

    if (compact) {
      return _buildCompactView(context, theme, hasRewards);
    }

    return _buildFullView(context, theme, hasRewards);
  }

  Widget _buildCompactView(
    BuildContext context,
    ThemeData theme,
    bool hasRewards,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pending Rewards',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatAssetAmount(
                  rewards.amount,
                  asset.id.chainId.decimals ?? 8,
                  symbol: asset.id.id,
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasRewards ? theme.colorScheme.primary : null,
                ),
              ),
            ],
          ),
          if (showClaimButton && onClaim != null && hasRewards)
            TextButton(onPressed: onClaim, child: const Text('Claim')),
        ],
      ),
    );
  }

  Widget _buildFullView(
    BuildContext context,
    ThemeData theme,
    bool hasRewards,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Staking Rewards',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    hasRewards
                        ? theme.colorScheme.primary.withOpacity(0.05)
                        : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      hasRewards
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    formatAssetAmount(
                      rewards.amount,
                      asset.id.chainId.decimals ?? 8,
                    ),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          hasRewards
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    asset.id.id,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (rewards.estimatedAPY > Decimal.zero) ...[
              const SizedBox(height: 12),
              _buildMetric(
                context,
                'Current APY',
                '${rewards.estimatedAPY.toStringAsFixed(2)}%',
                Icons.trending_up,
              ),
            ],
            if (showNextRewardTime && rewards.timeToNext != null) ...[
              const SizedBox(height: 8),
              _buildMetric(
                context,
                'Next Reward',
                _formatDuration(rewards.timeToNext!),
                Icons.schedule,
              ),
            ],
            if (showClaimButton && onClaim != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: hasRewards ? onClaim : null,
                  icon: const Icon(Icons.download),
                  label: Text(
                    hasRewards ? 'Claim Rewards' : 'No Rewards to Claim',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return 'in ${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return 'in ${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return 'in ${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'soon';
    }
  }
}
