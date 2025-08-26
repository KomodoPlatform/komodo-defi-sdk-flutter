import 'package:dragon_charts_flutter/dragon_charts_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChartAxisLabels', () {
    test('should create an instance of ChartAxisLabels', () {
      final chartAxisLabels = ChartAxisLabels(
        isVertical: true,
        count: 5,
        labelBuilder: (value) => value.toStringAsFixed(2),
      );

      expect(chartAxisLabels.isVertical, true);
      expect(chartAxisLabels.count, 5);
      expect(chartAxisLabels.labelBuilder(1.2345), '1.23');
    });
  });
}
