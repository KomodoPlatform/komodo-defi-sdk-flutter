import 'package:dragon_charts_flutter/src/chart_data_transform.dart';
import 'package:dragon_charts_flutter/src/chart_element.dart';
import 'package:flutter/material.dart';

class ChartAxisLabels extends ChartElement {
  ChartAxisLabels({
    required this.isVertical,
    required this.count,
    required this.labelBuilder,
  });

  final bool isVertical;
  final int count;
  final String Function(double value) labelBuilder;

  double _calculateMaxLabelExtent(Size size, ChartDataTransform transform) {
    double maxExtent = 0.0;
    if (isVertical) {
      for (var i = 0; i <= count; i++) {
        final y = i * size.height / count;
        final textPainter = TextPainter(
          text: TextSpan(
            text: labelBuilder(transform.invertY(y)),
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        if (textPainter.width > maxExtent) {
          maxExtent = textPainter.width;
        }
      }
    } else {
      for (var i = 0; i <= count; i++) {
        final x = i * size.width / count;
        final textPainter = TextPainter(
          text: TextSpan(
            text: labelBuilder(transform.invertX(x)),
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        if (textPainter.height > maxExtent) {
          maxExtent = textPainter.height;
        }
      }
    }
    return maxExtent;
  }

  EdgeInsets getReservedMargin(Size size, ChartDataTransform transform) {
    final double maxExtent = _calculateMaxLabelExtent(size, transform);
    if (isVertical) {
      return EdgeInsets.only(left: maxExtent + 10);
    } else {
      return EdgeInsets.only(bottom: maxExtent + 10);
    }
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    ChartDataTransform transform,
    double animation,
  ) {
    if (isVertical) {
      for (var i = 0; i <= count; i++) {
        final y = i * size.height / count;
        final textPainter = TextPainter(
          text: TextSpan(
            text: labelBuilder(transform.invertY(y)),
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter
          ..layout()
          ..paint(
            canvas,
            Offset(-textPainter.width - 5, y - textPainter.height / 2),
          );
      }
    } else {
      for (var i = 0; i <= count; i++) {
        final x = i * size.width / count;
        final textPainter = TextPainter(
          text: TextSpan(
            text: labelBuilder(transform.invertX(x)),
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter
          ..layout()
          ..paint(
            canvas,
            Offset(x - textPainter.width / 2, size.height + 5),
          );
      }
    }
  }
}
