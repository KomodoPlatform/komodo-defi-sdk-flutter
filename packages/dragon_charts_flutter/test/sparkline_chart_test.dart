import 'package:dragon_charts_flutter/dragon_charts_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SparklineChart', () {
    testWidgets('handles empty data without crashing',
        (WidgetTester tester) async {
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

    testWidgets('handles single data point without crashing',
        (WidgetTester tester) async {
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

    testWidgets('handles all same values without crashing',
        (WidgetTester tester) async {
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

    testWidgets('handles negative values correctly',
        (WidgetTester tester) async {
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
