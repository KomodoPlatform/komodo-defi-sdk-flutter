import 'dart:ui';

import 'package:dragon_charts_flutter/src/chart_data.dart';
import 'package:dragon_charts_flutter/src/chart_data_series.dart';
import 'package:dragon_charts_flutter/src/chart_data_transform.dart';
import 'package:dragon_charts_flutter/src/chart_element.dart';
import 'package:dragon_charts_flutter/src/marker_selection_strategies/marker_selection_strategies.dart';

class CartesianSelectionStrategy extends MarkerSelectionStrategy {
  CartesianSelectionStrategy({
    this.enableVerticalSelection = true,
    this.enableHorizontalSelection = false,
    this.enableVerticalDrawing = true,
    this.enableHorizontalDrawing = false,
    this.verticalLineColor = const Color.fromARGB(255, 158, 158, 158),
    this.horizontalLineColor = const Color.fromARGB(255, 158, 158, 158),
    this.lineWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 5.0,
    this.highlightFillColor,
    this.highlightBorderColor = const Color.fromRGBO(0, 0, 0, 0.87),
    this.highlightBorderWidth = 2.0,
    this.snapToClosest = false,
  });

  final bool enableVerticalSelection;
  final bool enableHorizontalSelection;
  final bool enableVerticalDrawing;
  final bool enableHorizontalDrawing;
  final Color verticalLineColor;
  final Color horizontalLineColor;
  final double lineWidth;
  final double dashWidth;
  final double dashSpace;
  final Color? highlightFillColor;
  final Color highlightBorderColor;
  final double highlightBorderWidth;
  final bool snapToClosest;

  @override
  (List<ChartData>, List<Offset>, List<Color>) handleHover(
    Offset localPosition,
    ChartDataTransform transform,
    List<ChartElement> elements,
  ) {
    final highlightedData = <ChartData>[];
    final highlightedPoints = <Offset>[];
    final highlightedColors = <Color>[];
    double? minXDistance;
    double? closestX;

    for (final element in elements) {
      if (element is ChartDataSeries) {
        for (final point in element.data) {
          final x = transform.transformX(point.x);
          final y = transform.transformY(point.y);
          final xDistance = (localPosition.dx - x).abs();

          if (snapToClosest) {
            if (minXDistance == null || xDistance < minXDistance) {
              minXDistance = xDistance;
              closestX = x;
            }
          } else {
            if (enableVerticalSelection && xDistance < 5) {
              highlightedData.add(point);
              highlightedPoints.add(Offset(x, y));
              highlightedColors.add(element.color);
            }
            if (enableHorizontalSelection && (localPosition.dy - y).abs() < 5) {
              highlightedData.add(point);
              highlightedPoints.add(Offset(x, y));
              highlightedColors.add(element.color);
            }
          }
        }
      }
    }

    if (snapToClosest && closestX != null) {
      for (final element in elements) {
        if (element is ChartDataSeries) {
          for (final point in element.data) {
            final x = transform.transformX(point.x);
            final y = transform.transformY(point.y);
            if ((x - closestX).abs() < 1e-6) {
              highlightedData.add(point);
              highlightedPoints.add(Offset(x, y));
              highlightedColors.add(element.color);
            }
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
    if (hoverPosition != null) {
      final linePaint = Paint()
        ..color = verticalLineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth;

      if (enableVerticalDrawing) {
        double startY = 0.0;
        while (startY < size.height) {
          canvas.drawLine(
            Offset(hoverPosition.dx, startY),
            Offset(hoverPosition.dx, startY + dashWidth),
            linePaint,
          );
          startY += dashWidth + dashSpace;
        }
      }

      if (enableHorizontalDrawing) {
        linePaint.color = horizontalLineColor;
        double startX = 0.0;
        while (startX < size.width) {
          canvas.drawLine(
            Offset(startX, hoverPosition.dy),
            Offset(startX + dashWidth, hoverPosition.dy),
            linePaint,
          );
          startX += dashWidth + dashSpace;
        }
      }
    }

    if (highlightedPoints != null) {
      for (var i = 0; i < highlightedPoints.length; i++) {
        final point = highlightedPoints[i];
        final color = highlightedColors[i];
        final highlightPaint = Paint()
          ..color = highlightFillColor ?? color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 4, highlightPaint);

        final borderPaint = Paint()
          ..color = highlightBorderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = highlightBorderWidth;

        canvas.drawCircle(point, 5, borderPaint);
      }
    }
  }
}
