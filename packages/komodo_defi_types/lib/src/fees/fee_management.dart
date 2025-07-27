import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Estimator type used when requesting fee data from the API.
enum FeeEstimatorType {
  simple,
  provider;

  @override
  String toString() => switch (this) {
        FeeEstimatorType.simple => 'Simple',
        FeeEstimatorType.provider => 'Provider',
      };

  static FeeEstimatorType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'provider':
        return FeeEstimatorType.provider;
      case 'simple':
      default:
        return FeeEstimatorType.simple;
    }
  }
}

/// Fee policy used for swap transactions or general fee selection.
enum FeePolicy {
  low,
  medium,
  high,
  internal;

  @override
  String toString() => switch (this) {
        FeePolicy.low => 'Low',
        FeePolicy.medium => 'Medium',
        FeePolicy.high => 'High',
        FeePolicy.internal => 'Internal',
      };

  static FeePolicy fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return FeePolicy.low;
      case 'medium':
        return FeePolicy.medium;
      case 'high':
        return FeePolicy.high;
      case 'internal':
        return FeePolicy.internal;
      default:
        throw ArgumentError('Invalid fee policy: $value');
    }
  }
}

/// Represents a single fee level returned by the API.
class EthFeeLevel extends Equatable {
  const EthFeeLevel({
    required this.maxPriorityFeePerGas,
    required this.maxFeePerGas,
    this.minWaitTime,
    this.maxWaitTime,
  });

  factory EthFeeLevel.fromJson(Map<String, dynamic> json) {
    return EthFeeLevel(
      maxPriorityFeePerGas:
          Decimal.parse(json['max_priority_fee_per_gas'].toString()),
      maxFeePerGas: Decimal.parse(json['max_fee_per_gas'].toString()),
      minWaitTime: json['min_wait_time'] as int?,
      maxWaitTime: json['max_wait_time'] as int?,
    );
  }

  final Decimal maxPriorityFeePerGas;
  final Decimal maxFeePerGas;
  final int? minWaitTime;
  final int? maxWaitTime;

  Map<String, dynamic> toJson() => {
        'max_priority_fee_per_gas': maxPriorityFeePerGas.toString(),
        'max_fee_per_gas': maxFeePerGas.toString(),
        if (minWaitTime != null) 'min_wait_time': minWaitTime,
        if (maxWaitTime != null) 'max_wait_time': maxWaitTime,
      };

  @override
  List<Object?> get props =>
      [maxPriorityFeePerGas, maxFeePerGas, minWaitTime, maxWaitTime];
}

/// Response object for [get_eth_estimated_fee_per_gas].
class EthEstimatedFeePerGas extends Equatable {
  const EthEstimatedFeePerGas({
    required this.baseFee,
    required this.low,
    required this.medium,
    required this.high,
    required this.source,
    required this.units,
    this.baseFeeTrend,
    this.priorityFeeTrend,
  });

  factory EthEstimatedFeePerGas.fromJson(Map<String, dynamic> json) {
    return EthEstimatedFeePerGas(
      baseFee: Decimal.parse(json['base_fee'].toString()),
      low: EthFeeLevel.fromJson(json['low'] as Map<String, dynamic>),
      medium: EthFeeLevel.fromJson(json['medium'] as Map<String, dynamic>),
      high: EthFeeLevel.fromJson(json['high'] as Map<String, dynamic>),
      source: json['source'] as String,
      baseFeeTrend: json['base_fee_trend'] as String?,
      priorityFeeTrend: json['priority_fee_trend'] as String?,
      units: json['units'] as String? ?? 'Gwei',
    );
  }

  final Decimal baseFee;
  final EthFeeLevel low;
  final EthFeeLevel medium;
  final EthFeeLevel high;
  final String source;
  final String units;
  final String? baseFeeTrend;
  final String? priorityFeeTrend;

  Map<String, dynamic> toJson() => {
        'base_fee': baseFee.toString(),
        'low': low.toJson(),
        'medium': medium.toJson(),
        'high': high.toJson(),
        'source': source,
        if (baseFeeTrend != null) 'base_fee_trend': baseFeeTrend,
        if (priorityFeeTrend != null) 'priority_fee_trend': priorityFeeTrend,
        'units': units,
      };

  @override
  List<Object?> get props => [
        baseFee,
        low,
        medium,
        high,
        source,
        units,
        baseFeeTrend,
        priorityFeeTrend,
      ];
}
