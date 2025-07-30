class ChartDataTransform {
  ChartDataTransform({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.width,
    required this.height,
  }) : assert(
          [minX, maxX, minY, maxY, width, height]
              .every((element) => element.isFinite),
          'All values must be finite.',
        );
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final double width;
  final double height;

  double transformX(double x) => (x - minX) / (maxX - minX) * width;

  double reverseTransformX(double x) => minX + (x / width) * (maxX - minX);

  double transformY(double y) => height - (y - minY) / (maxY - minY) * height;

  double invertX(double dx) => minX + (dx / width) * (maxX - minX);

  double invertY(double dy) => minY + (1 - dy / height) * (maxY - minY);
}
