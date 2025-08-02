import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/src/utils/formatters/asset_formatting.dart';

/// A card widget for displaying unbonding (undelegation) positions.
///
/// Shows unbonding amount, completion time, and progress.
class UnbondingCard extends StatelessWidget {
  const UnbondingCard({
    required this.unbonding,
    required this.asset,
    this.showProgress = true,
    super.key,
  });

  final UnbondingPosition unbonding;
  final Asset asset;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isCompleted = unbonding.completionTime.isBefore(now);
    final progress = _calculateProgress(now);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.schedule,
                  color: isCompleted ? Colors.green : theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCompleted
                        ? 'Unbonding Complete'
                        : 'Unbonding in Progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (isCompleted ? Colors.green : Colors.orange)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isCompleted ? Colors.green : Colors.orange)
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    formatAssetAmount(
                      unbonding.amount,
                      asset.id.chainId.decimals ?? 8,
                      symbol: asset.id.id,
                    ),
                    style: TextStyle(
                      color: isCompleted ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isCompleted) ...[
              _buildMetric(
                context,
                'Time Remaining',
                _formatTimeRemaining(unbonding.completionTime.difference(now)),
              ),
              const SizedBox(height: 12),
              _buildMetric(
                context,
                'Completion Date',
                _formatCompletionDate(unbonding.completionTime),
              ),
              if (showProgress && progress >= 0) ...[
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ],
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your funds are now available in your wallet',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (unbonding.validatorAddress.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildMetric(
                context,
                'From Validator',
                _truncateAddress(unbonding.validatorAddress),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value) {
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
          ),
        ),
      ],
    );
  }

  double _calculateProgress(DateTime now) {
    // Assume 21-day unbonding period for Cosmos chains
    const unbondingPeriod = Duration(days: 21);
    final startTime = unbonding.completionTime.subtract(unbondingPeriod);

    if (now.isBefore(startTime)) return 0.0;
    if (now.isAfter(unbonding.completionTime)) return 1.0;

    final elapsed = now.difference(startTime);
    final total = unbonding.completionTime.difference(startTime);

    return elapsed.inMilliseconds / total.inMilliseconds;
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.isNegative) return 'Complete';

    final days = duration.inDays;
    final hours = duration.inHours % 24;

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} ${hours > 0 ? '$hours hour${hours > 1 ? 's' : ''}' : ''}';
    } else if (hours > 0) {
      final minutes = duration.inMinutes % 60;
      return '$hours hour${hours > 1 ? 's' : ''} ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      final minutes = duration.inMinutes;
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }

  String _formatCompletionDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _truncateAddress(String address) {
    if (address.length <= 20) return address;
    return '${address.substring(0, 10)}...${address.substring(address.length - 10)}';
  }
}
