import 'dart:ui';
import 'package:dragon_charts_flutter/src/chart_data_transform.dart';

// ignore: one_member_abstracts
abstract class ChartElement {
  void paint(
    Canvas canvas,
    Size size,
    ChartDataTransform transform,
    double animation,
  );
}
