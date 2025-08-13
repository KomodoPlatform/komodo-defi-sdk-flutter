import 'package:dragon_charts_flutter/dragon_charts_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChartGridLines', () {
    test('should create an instance of ChartGridLines', () {
      final chartGridLines = ChartGridLines(isVertical: false, count: 5);

      expect(chartGridLines.isVertical, false);
      expect(chartGridLines.count, 5);
    });
  });
}
