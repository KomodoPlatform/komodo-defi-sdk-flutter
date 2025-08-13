import 'package:equatable/equatable.dart';
import 'package:dragon_charts_flutter/dragon_charts_flutter.dart';

class ChartState extends Equatable {
  final List<ChartData> data1;
  final List<ChartData> data2;

  const ChartState({required this.data1, required this.data2});

  factory ChartState.initial() {
    return const ChartState(data1: [], data2: []);
  }

  ChartState copyWith({List<ChartData>? data1, List<ChartData>? data2}) {
    return ChartState(
      data1: data1 ?? this.data1,
      data2: data2 ?? this.data2,
    );
  }

  @override
  List<Object> get props => [data1, data2];
}
