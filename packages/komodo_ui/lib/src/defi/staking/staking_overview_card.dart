import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/src/utils/formatters/asset_formatting.dart';

/// A card that displays an overview of staking positions and metrics.
///
/// Shows total staked amount, pending rewards, APY, and health status.
class StakingOverviewCard extends StatelessWidget {
  const StakingOverviewCard({
    required this.stakingInfo,
    required this.asset,
    this.onClaimRewards,
    this.showHealthIndicator = true,
    super.key,
  });

  final StakingInfo stakingInfo;
  final Asset asset;
  final VoidCallback? onClaimRewards;
  final bool showHealthIndicator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRewards = stakingInfo.pendingRewards.compareTo(Decimal.zero) > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Staking Overview', style: theme.textTheme.titleLarge),
                if (showHealthIndicator) _buildHealthChip(context),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              context,
              'Total Staked',
              formatAssetAmount(
                stakingInfo.totalStaked,
                8,
                symbol: asset.id.symbol.common,
              ),
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              'Available Balance',
              formatAssetAmount(
                stakingInfo.availableBalance,
                8,
                symbol: asset.id.symbol.common,
              ),
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              'Pending Rewards',
              formatAssetAmount(
                stakingInfo.pendingRewards,
                8,
                symbol: asset.id.symbol.common,
              ),
              trailing:
                  hasRewards && onClaimRewards != null
                      ? TextButton(
                        onPressed: onClaimRewards,
                        child: const Text('Claim'),
                      )
                      : null,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              'Estimated APY',
              '${stakingInfo.estimatedAPY.toStringAsFixed(2)}%',
            ),
            if (stakingInfo.unbondingAmount.compareTo(Decimal.zero) > 0) ...[
              const SizedBox(height: 12),
              _buildMetricRow(
                context,
                'Unbonding',
                formatAssetAmount(
                  stakingInfo.unbondingAmount,
                  8,
                  symbol: asset.id.symbol.common,
                ),
              ),
            ],
            if (stakingInfo.validators.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Delegated to ${stakingInfo.validators.length} validator${stakingInfo.validators.length > 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHealthChip(BuildContext context) {
    // We'd need to calculate health from stakingInfo
    // For now, just show a simple status
    final hasJailedValidator = stakingInfo.validators.any((v) => v.isJailed);
    final color = hasJailedValidator ? Colors.orange : Colors.green;
    final text = hasJailedValidator ? 'Needs Attention' : 'Healthy';

    return Chip(
      label: Text(text, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      padding: const EdgeInsets.all(4),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value, {
    Widget? trailing,
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
        if (trailing != null) ...[
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing,
        ] else
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
