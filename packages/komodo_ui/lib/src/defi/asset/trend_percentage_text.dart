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
/// - Locked into using percentage prop name
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
    this.percentage,
    this.showIcon = true,
    this.iconSize = 24,
    this.contentSpacing = 4,
    this.spacing = 2,
    this.precision = 2,
    this.upIcon = Icons.trending_up,
    this.downIcon = Icons.trending_down,
    this.neutralIcon = Icons.trending_flat,
    this.upColor,
    this.downColor,
    this.neutralColor,
    this.textStyle,
    this.prefix,
    this.suffix,
    this.noValueText = '-',
    super.key,
  });

  /// The percentage value to display
  /// If null, will display [noValueText] and use neutral styling
  final double? percentage;

  /// Text to display when percentage is null
  final String noValueText;

  /// Whether to show the trend icon
  final bool showIcon;

  /// Size of the trend icon
  final double iconSize;

  /// Spacing between icon and text
  final double spacing;
  
  /// Spacing between contents and prefix/suffix
  final double contentSpacing;

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

  /// Optional prefix widget to display before the trend icon and text
  ///
  /// Typically a `Text` widget. The trend text style will automatically be
  /// applied to the prefix widget.
  final Widget? prefix;

  /// Optional suffix widget to display after the text
  ///
  /// Typically a `Text` widget. The trend text style will automatically be
  /// applied to the prefix widget.
  final Widget? suffix;

  bool get _isPositive => percentage != null && percentage! > 0;
  bool get _isNeutral => percentage == null || percentage == 0;

  IconData get _icon =>
      _isPositive
          ? upIcon
          : _isNeutral
          ? neutralIcon
          : downIcon;

  Color _trendColor(ThemeData theme) =>
      _isPositive
          ? (upColor ?? Colors.green)
          : _isNeutral
          ? (neutralColor ?? theme.disabledColor)
          : (downColor ?? theme.colorScheme.error);

  String get _displayText =>
      percentage == null
          ? noValueText
          : '${percentage!.toStringAsFixed(precision)}%';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle =
        theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 12);

    final color = _trendColor(theme);

    final resolvedTextStyle = (textStyle ?? defaultTextStyle).copyWith(
      color: color,
    );

    return DefaultTextStyle(
      style: resolvedTextStyle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefix != null) ...[prefix!, SizedBox(width: contentSpacing)],
          if (showIcon) ...[
            Icon(_icon, color: color, size: iconSize),
            SizedBox(width: spacing),
          ],
          Text(_displayText),
          if (suffix != null) ...[SizedBox(width: contentSpacing), suffix!],
        ],
      ),
    );
  }
}
