import 'package:dragon_charts_flutter/src/chart_data.dart';
import 'package:flutter/material.dart';

class ChartTooltip extends StatelessWidget {
  // TODO: Consider adding a label builder to the Chart class and passing it
  // to the tooltip builder. This would allow the user to customize the tooltip
  // label text without needing to create a custom tooltip widget.
  ChartTooltip({
    required this.dataPoints,
    required this.dataColors,
    required this.backgroundColor,
    super.key,
  }) : assert(dataPoints.length == dataColors.length);
  final List<ChartData> dataPoints;
  final List<Color> dataColors;

  // Being able to set the background color of the tooltip is perhaps
  // purposeless since the text color is not customizable which restricts
  // the viable background colors that have enough contrast with the text.
  final Color? backgroundColor;

  late final double? commonX = dataPoints
          .map((data) => data.x)
          .every((element) => element == dataPoints.first.x)
      ? dataPoints.first.x
      : null;

  String valueToString(double value) {
    // Show the value with 2 decimal places or at least 2 significant digits
    // if the first 2 decimal places are 0.
    if (value.abs() < 0.01) {
      return value.toStringAsPrecision(2);
    } else {
      return value.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 100,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          color: backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // If all data points have the same x value, only show the y value
              // in the tooltip and show a header with the common x value.
              if (commonX != null) ...[
                Text(
                  valueToString(commonX!),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
              ],
              ...dataPoints.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: dataColors.elementAt(index),
                        shape: BoxShape.circle,
                      ),
                      width: 8,
                      height: 8,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      commonX == null
                          ? '(${valueToString(data.x)}, ${valueToString(data.y)})'
                          : valueToString(data.y),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
