import 'package:flutter/material.dart';

class SparklineChart extends StatelessWidget {
  const SparklineChart({
    required this.data,
    required this.positiveLineColor,
    required this.negativeLineColor,
    required this.lineThickness,
    this.isCurved = false,
    super.key,
  });

  final List<double> data;
  final Color positiveLineColor;
  final Color negativeLineColor;
  final double lineThickness;
  final bool isCurved;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _CustomSparklinePainter(
            data,
            positiveLineColor: positiveLineColor,
            negativeLineColor: negativeLineColor,
            lineThickness: lineThickness,
            isCurved: isCurved,
          ),
        );
      },
    );
  }
}

class _CustomSparklinePainter extends CustomPainter {
  _CustomSparklinePainter(
    this.data, {
    required this.positiveLineColor,
    required this.negativeLineColor,
    required this.lineThickness,
    required this.isCurved,
  }) {
    average = data.reduce((a, b) => a + b) / data.length;
  }

  final List<double> data;
  final Color positiveLineColor;
  final Color negativeLineColor;
  final double lineThickness;
  final bool isCurved;
  late double average;

  @override
  void paint(Canvas canvas, Size size) {
    final double dx = size.width / (data.length - 1);
    final double minValue = data.reduce((a, b) => a < b ? a : b);
    final double maxValue = data.reduce((a, b) => a > b ? a : b);
    final double scaleY = size.height / (maxValue - minValue);
    final double yAvg = size.height - ((average - minValue) * scaleY);

    final Path pathAbove = Path();
    final Path pathBelow = Path();
    pathAbove.moveTo(0, yAvg);
    pathBelow.moveTo(0, yAvg);

    Offset? prevPointAbove;
    Offset? prevPointBelow;

    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - ((data[i] - minValue) * scaleY);
      final currentPoint = Offset(x, y);

      if (data[i] >= average) {
        if (i > 0 && data[i - 1] < average) {
          final xPrev = (i - 1) * dx;
          // final yPrev = size.height - ((data[i - 1] - minValue) * scaleY);
          final intersectionX =
              xPrev + (dx * (average - data[i - 1]) / (data[i] - data[i - 1]));

          pathBelow
            ..lineTo(intersectionX, yAvg)
            ..lineTo(intersectionX, yAvg);
          pathAbove.moveTo(intersectionX, yAvg);
          prevPointAbove = Offset(intersectionX, yAvg);
        }

        if (isCurved && prevPointAbove != null) {
          final controlPoint1 = Offset(
            (prevPointAbove.dx + currentPoint.dx) / 2,
            prevPointAbove.dy,
          );
          final controlPoint2 = Offset(
            (prevPointAbove.dx + currentPoint.dx) / 2,
            currentPoint.dy,
          );

          pathAbove.cubicTo(
            controlPoint1.dx,
            controlPoint1.dy,
            controlPoint2.dx,
            controlPoint2.dy,
            currentPoint.dx,
            currentPoint.dy,
          );
        } else {
          pathAbove.lineTo(x, y);
        }
        prevPointAbove = currentPoint;
      } else {
        if (i > 0 && data[i - 1] >= average) {
          final xPrev = (i - 1) * dx;
          // final yPrev = size.height - ((data[i - 1] - minValue) * scaleY);
          final intersectionX =
              xPrev + (dx * (average - data[i - 1]) / (data[i] - data[i - 1]));

          pathAbove
            ..lineTo(intersectionX, yAvg)
            ..lineTo(intersectionX, yAvg);
          pathBelow.moveTo(intersectionX, yAvg);
          prevPointBelow = Offset(intersectionX, yAvg);
        }

        if (isCurved && prevPointBelow != null) {
          final controlPoint1 = Offset(
            (prevPointBelow.dx + currentPoint.dx) / 2,
            prevPointBelow.dy,
          );
          final controlPoint2 = Offset(
            (prevPointBelow.dx + currentPoint.dx) / 2,
            currentPoint.dy,
          );

          pathBelow.cubicTo(
            controlPoint1.dx,
            controlPoint1.dy,
            controlPoint2.dx,
            controlPoint2.dy,
            currentPoint.dx,
            currentPoint.dy,
          );
        } else {
          pathBelow.lineTo(x, y);
        }
        prevPointBelow = currentPoint;
      }
    }

    // Extend the path to the right edge of the canvas
    if (data.last >= average) {
      pathAbove.lineTo(size.width, yAvg);
    } else {
      pathBelow.lineTo(size.width, yAvg);
    }

    // Gradient Paints
    final Paint aboveGradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          positiveLineColor.withOpacity(0.2),
          positiveLineColor.withOpacity(0.6),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
        Rect.fromPoints(Offset.zero, Offset(0, size.height)),
      );

    final Paint belowGradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          negativeLineColor.withOpacity(0.6),
          negativeLineColor.withOpacity(0.2),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(
        Rect.fromPoints(Offset.zero, Offset(0, size.height)),
      );

    // Draw the filled paths first
    canvas
      ..drawPath(pathAbove, aboveGradientPaint)
      ..drawPath(pathBelow, belowGradientPaint);

    // Line Paint
    final Paint linePaint = Paint()
      ..strokeWidth = lineThickness
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < data.length - 1; i++) {
      final x1 = i * dx;
      final y1 = size.height - ((data[i] - minValue) * scaleY);
      final x2 = (i + 1) * dx;
      final y2 = size.height - ((data[i + 1] - minValue) * scaleY);

      if (data[i] >= average && data[i + 1] >= average) {
        linePaint.color = positiveLineColor;
      } else if (data[i] < average && data[i + 1] < average) {
        linePaint.color = negativeLineColor;
      } else {
        final intersectionX =
            x1 + (dx * (average - data[i]) / (data[i + 1] - data[i]));
        final yAvg = size.height - ((average - minValue) * scaleY);

        if (data[i] >= average) {
          linePaint.color = positiveLineColor;
          if (isCurved) {
            canvas.drawPath(
              Path()
                ..moveTo(x1, y1)
                ..cubicTo(
                  (x1 + intersectionX) / 2,
                  y1,
                  (x1 + intersectionX) / 2,
                  yAvg,
                  intersectionX,
                  yAvg,
                ),
              linePaint,
            );
            linePaint.color = negativeLineColor;
            canvas.drawPath(
              Path()
                ..moveTo(intersectionX, yAvg)
                ..cubicTo(
                  (intersectionX + x2) / 2,
                  yAvg,
                  (intersectionX + x2) / 2,
                  y2,
                  x2,
                  y2,
                ),
              linePaint,
            );
          } else {
            canvas.drawLine(
              Offset(x1, y1),
              Offset(intersectionX, yAvg),
              linePaint,
            );
            linePaint.color = negativeLineColor;
            canvas.drawLine(
              Offset(intersectionX, yAvg),
              Offset(x2, y2),
              linePaint,
            );
          }
        } else {
          linePaint.color = negativeLineColor;
          if (isCurved) {
            canvas.drawPath(
              Path()
                ..moveTo(x1, y1)
                ..cubicTo(
                  (x1 + intersectionX) / 2,
                  y1,
                  (x1 + intersectionX) / 2,
                  yAvg,
                  intersectionX,
                  yAvg,
                ),
              linePaint,
            );
            linePaint.color = positiveLineColor;
            canvas.drawPath(
              Path()
                ..moveTo(intersectionX, yAvg)
                ..cubicTo(
                  (intersectionX + x2) / 2,
                  yAvg,
                  (intersectionX + x2) / 2,
                  y2,
                  x2,
                  y2,
                ),
              linePaint,
            );
          } else {
            canvas.drawLine(
              Offset(x1, y1),
              Offset(intersectionX, yAvg),
              linePaint,
            );
            linePaint.color = positiveLineColor;
            canvas.drawLine(
              Offset(intersectionX, yAvg),
              Offset(x2, y2),
              linePaint,
            );
          }
        }
        continue;
      }
      if (isCurved) {
        final controlPoint1 = Offset((x1 + x2) / 2, y1);
        final controlPoint2 = Offset((x1 + x2) / 2, y2);

        canvas.drawPath(
          Path()
            ..moveTo(x1, y1)
            ..cubicTo(
              controlPoint1.dx,
              controlPoint1.dy,
              controlPoint2.dx,
              controlPoint2.dy,
              x2,
              y2,
            ),
          linePaint,
        );
      } else {
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
