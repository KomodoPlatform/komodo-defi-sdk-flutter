import 'package:hive_ce/hive.dart';

/// Data model for storing sparkline data in Hive
///
/// This replaces the previous Map<String, dynamic> approach to provide
/// type safety and proper serialization with Hive CE.
class SparklineData extends HiveObject {
  /// Creates a new SparklineData instance
  SparklineData({required this.data, required this.timestamp});

  /// Creates a SparklineData instance with null data (for failed fetches)
  factory SparklineData.failed() {
    return SparklineData(
      data: null,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  /// Creates a SparklineData instance with successful data
  factory SparklineData.success(List<double> sparklineData) {
    return SparklineData(
      data: sparklineData,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  /// The sparkline data points (closing prices)
  /// Can be null if fetching failed for all repositories
  List<double>? data;

  /// ISO8601 timestamp when the data was cached
  String timestamp;

  /// Checks if the cached data is expired based on the given expiry duration
  bool isExpired(Duration cacheExpiry) {
    final cachedTime = DateTime.parse(timestamp);
    return DateTime.now().difference(cachedTime) >= cacheExpiry;
  }
}
