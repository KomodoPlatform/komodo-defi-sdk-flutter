import 'package:dragon_charts_flutter/dragon_charts_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChartData', () {
    test('should create an instance of ChartData', () {
      final chartData = ChartData(x: 1, y: 2);

      expect(chartData.x, 1.0);
      expect(chartData.y, 2.0);
    });
  });
}
