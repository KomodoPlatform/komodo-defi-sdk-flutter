import 'dart:ui';

import 'package:dragon_charts_flutter/src/chart_data.dart';
import 'package:dragon_charts_flutter/src/chart_data_transform.dart';
import 'package:dragon_charts_flutter/src/chart_element.dart';

abstract class MarkerSelectionStrategy {
  (List<ChartData> data, List<Offset> points, List<Color> colors) handleHover(
    Offset localPosition,
    ChartDataTransform transform,
    List<ChartElement> elements,
  );
  (List<ChartData> data, List<Offset> points, List<Color> colors) handleTap(
    Offset localPosition,
    ChartDataTransform transform,
    List<ChartElement> elements,
  );

  void paint(
    Canvas canvas,
    Size size,
    ChartDataTransform transform,
    List<Offset>? highlightedPoints,
    List<Color> highlightedColors,
    Offset? hoverPosition,
  );
}
