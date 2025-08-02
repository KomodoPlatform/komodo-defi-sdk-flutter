import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A list item widget for displaying validator information.
///
/// Shows validator name, commission rate, voting power, and status.
class ValidatorListItem extends StatelessWidget {
  const ValidatorListItem({
    required this.validator,
    this.isSelected = false,
    this.onTap,
    this.showScore = false,
    this.score,
    this.recommendation,
    super.key,
  });

  final EnhancedValidatorInfo validator;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showScore;
  final double? score;
  final ValidatorRecommendation? recommendation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isJailed = validator.isJailed;
    final isInactive = !validator.isActive;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: isJailed || isInactive ? null : onTap,
        borderRadius: BorderRadius.circular(12),
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
                                validator.name ?? validator.address,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration:
                                      isJailed || isInactive
                                          ? TextDecoration.lineThrough
                                          : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isJailed || isInactive)
                              _buildStatusChip(context, isJailed),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _truncateAddress(validator.address),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showScore && score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(score!).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getScoreColor(score!).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        score!.toStringAsFixed(0),
                        style: TextStyle(
                          color: _getScoreColor(score!),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildMetrics(context),
              if (recommendation != null &&
                  recommendation!.reasons.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children:
                      recommendation!.reasons
                          .take(3)
                          .map((reason) => _buildReasonChip(context, reason))
                          .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, bool isJailed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Text(
        isJailed ? 'JAILED' : 'INACTIVE',
        style: const TextStyle(
          color: Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _decimalToPercentage(Decimal decimal) {
    return '${(decimal.toDouble() * 100).toStringAsFixed(2)}%';
  }

  Widget _buildMetrics(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMetric(
          context,
          'Commission',
          _decimalToPercentage(validator.commission),
          _getCommissionColor(validator.commission),
        ),
        _buildMetric(
          context,
          'Voting Power',
          _decimalToPercentage(validator.votingPower),
        ),
        _buildMetric(
          context,
          'Uptime',
          _decimalToPercentage(validator.uptime),
          _getUptimeColor(validator.uptime),
        ),
      ],
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String label,
    String value, [
    Color? valueColor,
  ]) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
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

  Widget _buildReasonChip(BuildContext context, String reason) {
    final theme = Theme.of(context);

    return Chip(
      label: Text(
        reason,
        style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
      ),
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _truncateAddress(String address) {
    if (address.length <= 20) return address;
    return '${address.substring(0, 10)}...${address.substring(address.length - 10)}';
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getCommissionColor(Decimal commission) {
    if (commission <= Decimal.parse('0.05')) return Colors.green;
    if (commission <= Decimal.parse('0.1')) return Colors.orange;
    return Colors.red;
  }

  Color _getUptimeColor(Decimal uptime) {
    if (uptime >= Decimal.parse('0.99')) return Colors.green;
    if (uptime >= Decimal.parse('0.95')) return Colors.orange;
    return Colors.red;
  }
}
