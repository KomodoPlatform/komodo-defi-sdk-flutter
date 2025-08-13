import 'package:dragon_charts_flutter/dragon_charts_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChartDataSeries', () {
    test('should create an instance of ChartDataSeries', () {
      final chartDataSeries = ChartDataSeries(
        data: [ChartData(x: 1, y: 2)],
        color: Colors.blue,
      );

      expect(chartDataSeries.data.length, 1);
      expect(chartDataSeries.color, Colors.blue);
    });

    test('should animate to new data series', () {
      final chartDataSeries1 = ChartDataSeries(
        data: [ChartData(x: 1, y: 2)],
        color: Colors.blue,
      );

      final chartDataSeries2 = ChartDataSeries(
        data: [ChartData(x: 1, y: 4)],
        color: Colors.blue,
      );

      final animatedSeries =
          chartDataSeries1.animateTo(chartDataSeries2, 0.5, 0);

      expect(animatedSeries.data[0].y, 3.0);
    });
  });
}
