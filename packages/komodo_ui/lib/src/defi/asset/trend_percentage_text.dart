import 'package:flutter/material.dart';

/// A widget that displays a percentage trend with an indicator icon.
///
/// Enhanced version of the original TrendPercentageText with more customization
/// options while maintaining backwards compatibility.
///
/// There may be breaking changes in the near future that enhance
/// re-usability and customization, but the initial version will be focused on
/// migrating from the Komodo Wallet app to the new SDK repository.
///
/// E.g.:
/// - Locked into using investmentReturnPercentage prop name
/// - Fixed icon choices and behaviors
///
/// Could be enhanced with:
/// - Animated transitions
/// - More general value representation
/// - Custom formatters
/// - Support for different trend indicators
/// - Multi-period comparisons
class TrendPercentageText extends StatelessWidget {
  /// A widget that displays a percentage trend with an indicator icon.
  ///
  /// Enhanced version of the original TrendPercentageText with more
  /// customization options while maintaining backwards compatibility.
  const TrendPercentageText({
    required this.investmentReturnPercentage,
    this.showIcon = true,
    this.iconSize = 24,
    this.spacing = 2,
    this.precision = 2,
    this.upIcon = Icons.trending_up,
    this.downIcon = Icons.trending_down,
    this.neutralIcon = Icons.trending_flat,
    this.upColor,
    this.downColor,
    this.neutralColor,
    this.textStyle,
    super.key,
  });

  /// The percentage value to display
  final double investmentReturnPercentage;

  /// Whether to show the trend icon
  final bool showIcon;

  /// Size of the trend icon
  final double iconSize;

  /// Spacing between icon and text
  final double spacing;

  /// Number of decimal places to show
  final int precision;

  /// Icon for upward trend
  final IconData upIcon;

  /// Icon for downward trend
  final IconData downIcon;

  /// Icon for neutral/no trend
  final IconData neutralIcon;

  /// Color for positive trends
  final Color? upColor;

  /// Color for negative trends
  final Color? downColor;

  /// Color for neutral/no trend
  final Color? neutralColor;

  /// Optional text style (falls back to theme's bodyLarge)
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle =
        theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 12);

    final isPositive = investmentReturnPercentage > 0;
    final isNeutral = investmentReturnPercentage == 0;

    final color = isPositive
        ? (upColor ?? Colors.green)
        : isNeutral
            ? (neutralColor ?? theme.disabledColor)
            : (downColor ?? theme.colorScheme.error);

    final icon = isPositive
        ? upIcon
        : isNeutral
            ? neutralIcon
            : downIcon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(
            icon,
            color: color,
            size: iconSize,
          ),
          SizedBox(width: spacing),
        ],
        Text(
          '${investmentReturnPercentage.toStringAsFixed(precision)}%',
          style: (textStyle ?? defaultTextStyle).copyWith(color: color),
        ),
      ],
    );
  }
}
