class ChartData {
  ChartData({required this.x, required this.y})
      : assert(x.isFinite && y.isFinite, 'All values must be finite.');
  final double x;
  final double y;
}
