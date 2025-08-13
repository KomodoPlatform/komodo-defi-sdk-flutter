import 'dart:ui';

import 'package:dragon_charts_flutter/dragon_charts_flutter.dart';
import 'package:dragon_charts_flutter/src/chart_data_transform.dart';
import 'package:dragon_charts_flutter/src/marker_selection_strategies/marker_selection_strategies.dart';

class PointSelectionStrategy extends MarkerSelectionStrategy {
  @override
  (List<ChartData>, List<Offset>, List<Color>) handleHover(
    Offset localPosition,
    ChartDataTransform transform,
    List<ChartElement> elements,
  ) {
    final highlightedData = <ChartData>[];
    final highlightedPoints = <Offset>[];
    final highlightedColors = <Color>[];
    for (final element in elements) {
      if (element is ChartDataSeries) {
        for (final point in element.data) {
          final x = transform.transformX(point.x);
          final y = transform.transformY(point.y);
          if ((Offset(x, y) - localPosition).distance < 10) {
            highlightedData.add(point);
            highlightedPoints.add(Offset(x, y));
            highlightedColors.add(element.color);
          }
        }
      }
    }
    return (highlightedData, highlightedPoints, highlightedColors);
  }

  @override
  (List<ChartData>, List<Offset>, List<Color>) handleTap(
    Offset localPosition,
    ChartDataTransform transform,
    List<ChartElement> elements,
  ) {
    return handleHover(localPosition, transform, elements);
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    ChartDataTransform transform,
    List<Offset>? highlightedPoints,
    List<Color> highlightedColors,
    Offset? hoverPosition,
  ) {
    if (highlightedPoints != null) {
      for (var i = 0; i < highlightedPoints.length; i++) {
        final point = highlightedPoints[i];
        final color = highlightedColors[i];
        final highlightPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 4, highlightPaint);

        final borderPaint = Paint()
          ..color = const Color.fromRGBO(0, 0, 0, 0.87)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        canvas.drawCircle(point, 5, borderPaint);
      }
    }
  }
}
