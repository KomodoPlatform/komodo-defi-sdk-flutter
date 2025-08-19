import 'package:dragon_charts_flutter/dragon_charts_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/chart_bloc.dart';
import '../blocs/chart_state.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Line Chart with Animation')),
      body: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const SizedBox(
              height: 80,
              width: 200,
              child: SparklineChart(
                data: [4, 2, 7, 9, 5, 3, 8, -12],
                positiveLineColor: Colors.green,
                negativeLineColor: Colors.red,
                lineThickness: 1,
                isCurved: true,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ChartBloc, ChartState>(
                builder: (context, state) {
                  return LineChart(
                    domainExtent:
                        const ChartExtent.withBounds(min: 4.1, max: 8.2),
                    // domainExtent: ChartExtent.tight(),
                    backgroundColor: Theme.of(context).cardColor,
                    elements: [
                      ChartGridLines(isVertical: false, count: 5),
                      ChartDataSeries(data: state.data1, color: Colors.blue),
                      ChartDataSeries(
                        data: state.data2,
                        color: Colors.red,
                        lineType: LineType.bezier,
                      ),
                      ChartAxisLabels(
                          isVertical: false,
                          count: 5,
                          labelBuilder: (value) => value.toStringAsFixed(9)),
                      ChartAxisLabels(
                          isVertical: true,
                          count: 5,
                          // reservedExtent: 80,
                          labelBuilder: (value) => value.toStringAsFixed(9)),
                    ],
                    markerSelectionStrategy: CartesianSelectionStrategy(
                      enableHorizontalDrawing: true,
                      snapToClosest: true,
                    ),
                    // tooltipBuilder: (context, dataPoints) {
                    //   return ChartTooltip(
                    //       dataPoints: dataPoints, backgroundColor: Colors);
                    // },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
