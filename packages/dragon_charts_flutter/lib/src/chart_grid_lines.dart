import 'package:dragon_charts_flutter/src/chart_data_transform.dart';
import 'package:dragon_charts_flutter/src/chart_element.dart';
import 'package:flutter/material.dart';

class ChartGridLines extends ChartElement {
  ChartGridLines({required this.isVertical, required this.count});
  final bool isVertical;
  final int count;

  @override
  void paint(
    Canvas canvas,
    Size size,
    ChartDataTransform transform,
    double animation,
  ) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1.0;

    if (isVertical) {
      for (var i = 0; i <= count; i++) {
        final x = i * size.width / count;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
    } else {
      for (var i = 0; i <= count; i++) {
        final y = i * size.height / count;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }
  }
}
