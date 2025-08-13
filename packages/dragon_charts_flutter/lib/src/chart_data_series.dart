import 'dart:math';
import 'dart:ui';

import 'package:dragon_charts_flutter/src/chart_data.dart';
import 'package:dragon_charts_flutter/src/chart_data_transform.dart';
import 'package:dragon_charts_flutter/src/chart_element.dart';

enum LineType { straight, bezier }

class ChartDataSeries extends ChartElement {
  ChartDataSeries({
    required this.data,
    required this.color,
    this.strokeWidth = 2.0,
    this.lineType = LineType.straight,
    this.nodeRadius,
  });

  final List<ChartData> data;
  final Color color;
  final LineType lineType;
  final double? nodeRadius;
  final double strokeWidth;

  ChartDataSeries animateTo(
    ChartDataSeries newDataSeries,
    double animationValue,
    double minY,
  ) {
    final interpolatedData = <ChartData>[];
    final int minLength = min(data.length, newDataSeries.data.length);
    // final int maxLength = max(data.length, newDataSeries.data.length);

    // Interpolate shared data points
    for (var i = 0; i < minLength; i++) {
      final oldX = data[i].x;
      final newX = newDataSeries.data[i].x;
      final interpolatedX = oldX + (newX - oldX) * animationValue;

      final oldY = data[i].y;
      final newY = newDataSeries.data[i].y;
      final interpolatedY = oldY + (newY - oldY) * animationValue;

      interpolatedData.add(
        ChartData(
          x: interpolatedX,
          y: interpolatedY,
        ),
      );
    }

    // Handle removed data points
    for (var i = minLength; i < data.length; i++) {
      final oldX = data[i].x;
      final oldY = data[i].y;
      final interpolatedY = oldY + (minY - oldY) * animationValue;

      interpolatedData.add(
        ChartData(
          x: oldX,
          y: interpolatedY,
        ),
      );
    }

    // Handle added data points
    for (var i = minLength; i < newDataSeries.data.length; i++) {
      final newX = newDataSeries.data[i].x;
      final newY = newDataSeries.data[i].y * animationValue;

      interpolatedData.add(
        ChartData(
          x: newX,
          y: newY,
        ),
      );
    }

    return ChartDataSeries(
      data: interpolatedData,
      color: color,
      strokeWidth: strokeWidth,
      lineType: lineType,
      nodeRadius: nodeRadius,
    );
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    ChartDataTransform transform,
    double animation,
  ) {
    if (data.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    var first = true;

    // final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // // canvas.clipRect(rect);

    if (lineType == LineType.straight) {
      for (final point in data) {
        final x = transform.transformX(point.x);
        final y = transform.transformY(point.y);

        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }

        _drawNode(canvas, nodePaint, Offset(x, y));
      }
    } else if (lineType == LineType.bezier) {
      if (data.isNotEmpty) {
        path.moveTo(
          transform.transformX(data[0].x),
          transform.transformY(data[0].y),
        );

        for (var i = 0; i < data.length - 1; i++) {
          final x1 = transform.transformX(data[i].x);
          final y1 = transform.transformY(data[i].y);
          final x2 = transform.transformX(data[i + 1].x);
          final y2 = transform.transformY(data[i + 1].y);

          final controlPointX1 = x1 + (x2 - x1) / 3;
          final controlPointY1 = y1;
          final controlPointX2 = x1 + 2 * (x2 - x1) / 3;
          final controlPointY2 = y2;

          path.cubicTo(
            controlPointX1,
            controlPointY1,
            controlPointX2,
            controlPointY2,
            x2,
            y2,
          );

          _drawNode(canvas, nodePaint, Offset(x1, y1));
        }
      }
    }
    canvas.drawPath(path, linePaint);
  }

  void _drawNode(Canvas canvas, Paint paint, Offset offset) {
    if (nodeRadius == null) return;

    canvas.drawCircle(offset, nodeRadius!, paint);
  }

  ChartDataSeries copyWith({
    List<ChartData>? data,
    Color? color,
    double? strokeWidth,
    LineType? lineType,
    double? nodeRadius,
  }) {
    return ChartDataSeries(
      data: data ?? this.data,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      lineType: lineType ?? this.lineType,
      nodeRadius: nodeRadius ?? this.nodeRadius,
    );
  }
}
