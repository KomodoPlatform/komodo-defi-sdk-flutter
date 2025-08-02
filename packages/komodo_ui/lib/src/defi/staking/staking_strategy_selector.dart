import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A widget for selecting staking strategies.
///
/// Allows users to choose between different staking strategies with
/// visual indicators and descriptions.
class StakingStrategySelector extends StatelessWidget {
  const StakingStrategySelector({
    required this.selectedStrategy,
    required this.onStrategyChanged,
    this.showDescriptions = true,
    super.key,
  });

  final StakingStrategy selectedStrategy;
  final ValueChanged<StakingStrategy> onStrategyChanged;
  final bool showDescriptions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Staking Strategy', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...StakingStrategy.values
            .where((s) => s != StakingStrategy.custom)
            .map(
              (strategy) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildStrategyOption(context, strategy),
              ),
            ),
      ],
    );
  }

  Widget _buildStrategyOption(BuildContext context, StakingStrategy strategy) {
    final theme = Theme.of(context);
    final isSelected = selectedStrategy == strategy;
    final info = _getStrategyInfo(strategy);

    return InkWell(
      onTap: () => onStrategyChanged(strategy),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          color:
              isSelected ? theme.colorScheme.primary.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: info.color.withOpacity(0.1),
              ),
              child: Icon(info.icon, color: info.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        info.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: info.riskColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: info.riskColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          info.riskLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: info.riskColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (showDescriptions) ...[
                    const SizedBox(height: 4),
                    Text(
                      info.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Radio<StakingStrategy>(
              value: strategy,
              groupValue: selectedStrategy,
              onChanged: (value) {
                if (value != null) onStrategyChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  _StrategyInfo _getStrategyInfo(StakingStrategy strategy) {
    switch (strategy) {
      case StakingStrategy.aggressive:
        return const _StrategyInfo(
          title: 'Aggressive',
          description:
              'Maximize returns with lowest commission validators. Higher risk, single validator.',
          icon: Icons.rocket_launch,
          color: Colors.red,
          riskLabel: 'High Risk',
          riskColor: Colors.red,
        );
      case StakingStrategy.balanced:
        return const _StrategyInfo(
          title: 'Balanced',
          description:
              'Optimal mix of returns and safety. Stakes across 3 validators.',
          icon: Icons.balance,
          color: Colors.blue,
          riskLabel: 'Medium Risk',
          riskColor: Colors.orange,
        );
      case StakingStrategy.conservative:
        return const _StrategyInfo(
          title: 'Conservative',
          description:
              'Prioritize safety with high uptime validators. Lower returns, higher security.',
          icon: Icons.shield,
          color: Colors.green,
          riskLabel: 'Low Risk',
          riskColor: Colors.green,
        );
      case StakingStrategy.custom:
        return const _StrategyInfo(
          title: 'Custom',
          description: 'Select validators manually',
          icon: Icons.tune,
          color: Colors.purple,
          riskLabel: 'Variable',
          riskColor: Colors.grey,
        );
    }
  }
}

class _StrategyInfo {
  const _StrategyInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.riskLabel,
    required this.riskColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String riskLabel;
  final Color riskColor;
}
