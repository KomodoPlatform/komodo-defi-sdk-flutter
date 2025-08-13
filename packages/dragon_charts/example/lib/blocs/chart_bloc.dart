import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'chart_event.dart';
import 'chart_state.dart';
import 'package:dragon_charts_flutter/dragon_charts_flutter.dart';

// For the purpose of simplifying this example, we are generating the data in
// the bloc class. However, in a real-world scenario, the data should be
// fetched from a repository class. See https://bloclibrary.dev/why-bloc/
class ChartBloc extends Bloc<ChartEvent, ChartState> {
  ChartBloc() : super(ChartState.initial()) {
    on<ChartUpdated>(_onChartUpdated);
    on<ChartDataPointCountChanged>(_onChartDataPointAdded);

    add(const ChartDataPointCountChanged(50));

    // Timer to periodically update chart data
    Timer.periodic(const Duration(seconds: 5), (timer) {
      // add(ChartUpdated());
      if (Random().nextBool() || true) {
        add(ChartDataPointCountChanged(

            // Randomly add or remove 5 to 50 data points
            (Random().nextInt(50) + 5) * (Random().nextBool() ? 1 : -1)));
      }
    });
  }

  Future<void> _onChartUpdated(
      ChartUpdated event, Emitter<ChartState> emit) async {
    final updatedData1 = state.data1
        .map((element) => ChartData(x: element.x, y: Random().nextDouble()))
        .toList();
    final updatedData2 = state.data2
        .map((element) => ChartData(x: element.x, y: Random().nextDouble()))
        .toList();
    emit(state.copyWith(data1: updatedData1, data2: updatedData2));
  }

  Future<void> _onChartDataPointAdded(
      ChartDataPointCountChanged event, Emitter<ChartState> emit) async {
    if (event.count.abs() == 0) return;

    final currentCount = state.data1.length;

    final updatedData1 = List<ChartData>.from(state.data1);
    final updatedData2 = List<ChartData>.from(state.data2);

    if (event.count > 0) {
      for (int i = 0; i < event.count; i++) {
        updatedData1.add(ChartData(
            x: (currentCount + i).toDouble(), y: Random().nextDouble()));
        updatedData2.add(ChartData(
            x: (currentCount + i).toDouble(), y: Random().nextDouble()));
      }
    } else {
      for (int i = 0; i < event.count.abs(); i++) {
        if (updatedData1.isEmpty) break;
        updatedData1.removeLast();
        updatedData2.removeLast();
      }
    }

    emit(state.copyWith(data1: updatedData1, data2: updatedData2));
  }
}
