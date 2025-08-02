import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// A visual indicator for staking health status.
///
/// Displays the health of staking positions with color-coded status
/// and optional detailed information.
class StakingHealthIndicator extends StatelessWidget {
  const StakingHealthIndicator({
    required this.health,
    this.showLabel = true,
    this.size = StakingHealthIndicatorSize.medium,
    this.onTap,
    super.key,
  });

  final StakingHealth health;
  final bool showLabel;
  final StakingHealthIndicatorSize size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = _getHealthInfo(health);
    final dimensions = _getDimensions(size);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(dimensions.borderRadius),
      child: Container(
        padding: EdgeInsets.all(dimensions.padding),
        decoration: BoxDecoration(
          color: info.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
          border: Border.all(
            color: info.color.withOpacity(0.3),
            width: dimensions.borderWidth,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: dimensions.indicatorSize,
              height: dimensions.indicatorSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: info.color,
                boxShadow: [
                  BoxShadow(
                    color: info.color.withOpacity(0.4),
                    blurRadius: dimensions.glowRadius,
                    spreadRadius: dimensions.glowSpread,
                  ),
                ],
              ),
              child: Icon(
                info.icon,
                color: Colors.white,
                size: dimensions.iconSize,
              ),
            ),
            if (showLabel) ...[
              SizedBox(width: dimensions.spacing),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: info.color,
                      fontWeight: FontWeight.w600,
                      fontSize: dimensions.labelSize,
                    ),
                  ),
                  if (info.description != null &&
                      size != StakingHealthIndicatorSize.small)
                    Text(
                      info.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: info.color.withOpacity(0.8),
                        fontSize: dimensions.descriptionSize,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  _HealthInfo _getHealthInfo(StakingHealth health) {
    switch (health) {
      case StakingHealth.good:
        return _HealthInfo(
          label: 'Healthy',
          description: 'All validators active',
          icon: Icons.check_circle,
          color: Colors.green,
        );
      case StakingHealth.warning:
        return _HealthInfo(
          label: 'Needs Attention',
          description: 'Review validators',
          icon: Icons.warning,
          color: Colors.orange,
        );
      case StakingHealth.critical:
        return _HealthInfo(
          label: 'Critical',
          description: 'Immediate action required',
          icon: Icons.error,
          color: Colors.red,
        );
    }
  }

  _IndicatorDimensions _getDimensions(StakingHealthIndicatorSize size) {
    switch (size) {
      case StakingHealthIndicatorSize.small:
        return const _IndicatorDimensions(
          indicatorSize: 16,
          iconSize: 10,
          padding: 6,
          spacing: 6,
          borderRadius: 12,
          borderWidth: 1,
          glowRadius: 4,
          glowSpread: 1,
          labelSize: 12,
          descriptionSize: 10,
        );
      case StakingHealthIndicatorSize.medium:
        return const _IndicatorDimensions(
          indicatorSize: 24,
          iconSize: 14,
          padding: 8,
          spacing: 8,
          borderRadius: 16,
          borderWidth: 1.5,
          glowRadius: 6,
          glowSpread: 2,
          labelSize: 14,
          descriptionSize: 11,
        );
      case StakingHealthIndicatorSize.large:
        return const _IndicatorDimensions(
          indicatorSize: 32,
          iconSize: 20,
          padding: 12,
          spacing: 12,
          borderRadius: 20,
          borderWidth: 2,
          glowRadius: 8,
          glowSpread: 3,
          labelSize: 16,
          descriptionSize: 13,
        );
    }
  }
}

enum StakingHealthIndicatorSize { small, medium, large }

class _HealthInfo {
  const _HealthInfo({
    required this.label,
    this.description,
    required this.icon,
    required this.color,
  });

  final String label;
  final String? description;
  final IconData icon;
  final Color color;
}

class _IndicatorDimensions {
  const _IndicatorDimensions({
    required this.indicatorSize,
    required this.iconSize,
    required this.padding,
    required this.spacing,
    required this.borderRadius,
    required this.borderWidth,
    required this.glowRadius,
    required this.glowSpread,
    required this.labelSize,
    required this.descriptionSize,
  });

  final double indicatorSize;
  final double iconSize;
  final double padding;
  final double spacing;
  final double borderRadius;
  final double borderWidth;
  final double glowRadius;
  final double glowSpread;
  final double labelSize;
  final double descriptionSize;
}
