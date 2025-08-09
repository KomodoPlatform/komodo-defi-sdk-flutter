import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/src/utils/formatters/asset_formatting.dart';

/// A card widget for displaying staking delegation information.
///
/// Shows validator info, staked amount, rewards, and action buttons.
class DelegationCard extends StatelessWidget {
  const DelegationCard({
    required this.position,
    required this.asset,
    this.onUnstake,
    this.onClaimRewards,
    this.showActions = true,
    super.key,
  });

  final StakingPosition position;
  final Asset asset;
  final VoidCallback? onUnstake;
  final VoidCallback? onClaimRewards;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRewards = position.rewards.compareTo(Decimal.zero) > 0;
    final isJailed = position.validator.isJailed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              position.validator.name ??
                                  position.validatorAddress,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isJailed)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: const Text(
                                'JAILED',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Commission: ${_decimalToPercentage(position.validator.commission)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (position.validatorAPY > Decimal.zero)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${position.validatorAPY.toStringAsFixed(1)}% APY',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetric(
              context,
              'Staked Amount',
              formatAssetAmount(
                position.stakedAmount,
                asset.id.chainId.decimals ?? 8,
                symbol: asset.id.id,
              ),
            ),
            const SizedBox(height: 12),
            _buildMetric(
              context,
              'Rewards',
              formatAssetAmount(
                position.rewards,
                asset.id.chainId.decimals ?? 8,
                symbol: asset.id.id,
              ),
              valueColor: hasRewards ? theme.colorScheme.primary : null,
            ),
            if (position.stakedAt != null) ...[
              const SizedBox(height: 12),
              _buildMetric(
                context,
                'Staked Since',
                _formatDate(position.stakedAt!),
              ),
            ],
            if (showActions &&
                (onUnstake != null ||
                    (onClaimRewards != null && hasRewards))) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onClaimRewards != null && hasRewards)
                    TextButton.icon(
                      onPressed: onClaimRewards,
                      icon: const Icon(Icons.card_giftcard, size: 18),
                      label: const Text('Claim Rewards'),
                    ),
                  if (onUnstake != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed:
                          isJailed
                              ? () => _showJailedDialog(context)
                              : onUnstake,
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                      label: const Text('Unstake'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isJailed ? Colors.orange : null,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _decimalToPercentage(Decimal decimal) {
    return '${(decimal.toDouble() * 100).toStringAsFixed(2)}%';
  }

  Widget _buildMetric(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).abs();

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  void _showJailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Validator Jailed'),
            content: const Text(
              'This validator has been jailed and is not earning rewards. '
              'It is recommended to unstake and delegate to an active validator.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onUnstake?.call();
                },
                child: const Text('Unstake Anyway'),
              ),
            ],
          ),
    );
  }
}
