import 'package:dragon_charts_flutter/dragon_charts_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SparklineBaselines', () {
    test('initialValue returns 0 for empty data', () {
      expect(SparklineBaselines.initialValue(const []), equals(0));
    });

    test('initialValue returns the first value', () {
      expect(SparklineBaselines.initialValue(const [3, 5, 7]), equals(3));
    });

    test('average returns 0 for empty data', () {
      expect(SparklineBaselines.average(const []), equals(0));
    });

    test('average returns the average of the values', () {
      expect(SparklineBaselines.average(const [2, 4, 6]), equals(4));
    });
  });

  group('SparklineChart', () {
    testWidgets('handles empty data without crashing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 100,
            child: SparklineChart(
              data: [],
              positiveLineColor: Colors.green,
              negativeLineColor: Colors.red,
              lineThickness: 2,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles single data point without crashing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 100,
            child: SparklineChart(
              data: [5.0],
              positiveLineColor: Colors.green,
              negativeLineColor: Colors.red,
              lineThickness: 2,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles all same values without crashing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 100,
            child: SparklineChart(
              data: [5.0, 5.0, 5.0, 5.0],
              positiveLineColor: Colors.green,
              negativeLineColor: Colors.red,
              lineThickness: 2,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles negative values correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 100,
            child: SparklineChart(
              data: [-5.0, -2.0, 3.0, 1.0, -1.0],
              positiveLineColor: Colors.green,
              negativeLineColor: Colors.red,
              lineThickness: 2,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles curved line option', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 100,
            child: SparklineChart(
              data: [1.0, 5.0, 2.0, 8.0, 3.0],
              positiveLineColor: Colors.green,
              negativeLineColor: Colors.red,
              lineThickness: 2,
              isCurved: true,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('supports custom baseline calculator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 100,
            child: SparklineChart(
              data: [3.0, 1.0, 4.0, 2.0],
              positiveLineColor: Colors.green,
              negativeLineColor: Colors.red,
              lineThickness: 2,
              baselineCalculator: SparklineBaselines.average,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles zero values', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 100,
            child: SparklineChart(
              data: [0.0, 0.0, 0.0],
              positiveLineColor: Colors.green,
              negativeLineColor: Colors.red,
              lineThickness: 2,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
