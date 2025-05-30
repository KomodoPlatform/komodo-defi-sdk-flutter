import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:rational/rational.dart';

/// Represents a fractional value using numerator and denominator.
/// Used for JSON formats like: {"numer": "3", "denom": "2"}
class FractionalValue extends Equatable {
  /// Creates a new [FractionalValue].
  const FractionalValue({
    required this.numerator,
    required this.denominator,
  });

  /// Creates a [FractionalValue] from a JSON map.
  factory FractionalValue.fromJson(Map<String, dynamic> json) {
    return FractionalValue(
      numerator: json['numer'] as String,
      denominator: json['denom'] as String,
    );
  }

  /// The numerator of the fraction.
  final String numerator;

  /// The denominator of the fraction.
  final String denominator;

  /// Converts this value to a [Rational].
  Rational toRational() {
    return Rational(
      BigInt.parse(numerator),
      BigInt.parse(denominator),
    );
  }

  /// Converts this value to a [Decimal].
  Decimal toDecimal() {
    final rational = toRational();
    try {
      return rational.toDecimal();
    } catch (e) {
      // Handle infinite precision by using a reasonable scale
      return rational.toDecimal(scaleOnInfinitePrecision: 28);
    }
  }

  /// Converts this value to a JSON map.
  Map<String, dynamic> toJson() => {
        'numer': numerator,
        'denom': denominator,
      };

  @override
  List<Object?> get props => [numerator, denominator];
}

/// Represents a rational value using the Komodo DeFi SDK format.
/// Used for JSON formats like: [[1,[0,1]],[1,[1]]]
class RationalValue extends Equatable {
  /// Creates a new [RationalValue].
  const RationalValue({
    required this.numerator,
    required this.denominator,
  });

  /// Creates a [RationalValue] from a JSON list.
  factory RationalValue.fromJson(List<dynamic> json) {
    return RationalValue(
      numerator: json[0] as List<dynamic>,
      denominator: json[1] as List<dynamic>,
    );
  }

  /// The numerator part of the rational value.
  final List<dynamic> numerator;

  /// The denominator part of the rational value.
  final List<dynamic> denominator;

  /// Converts this value to a [Rational].
  ///
  /// Handles the Komodo DeFi SDK format where each part is represented as
  /// [sign, [uint32_array]] where the uint32 array contains 32-bit parts
  /// of a big integer in little-endian order.
  Rational toRational() {
    final numSign = numerator[0] as int;
    final numParts = numerator[1] as List<dynamic>;

    final denomSign = denominator[0] as int;
    final denomParts = denominator[1] as List<dynamic>;

    // Convert uint32 array to BigInt (little-endian order)
    // Each element represents a 32-bit part: sum of (parts[i] * (2^32)^i)
    var numValue = _uint32ArrayToBigInt(numParts);
    var denomValue = _uint32ArrayToBigInt(denomParts);

    // Apply signs
    if (numSign < 0) numValue = -numValue;
    if (denomSign < 0) denomValue = -denomValue;

    return Rational(numValue, denomValue);
  }

  /// Converts a uint32 array in little-endian order to a [BigInt].
  ///
  /// Each element in the array represents a 32-bit part of the big integer.
  /// The value is calculated as the sum of each part multiplied by powers
  /// of 2^32.
  BigInt _uint32ArrayToBigInt(List<dynamic> parts) {
    var result = BigInt.zero;
    final base = BigInt.from(0x100000000); // 2^32 = 4294967296

    for (var i = 0; i < parts.length; i++) {
      final part = BigInt.from(parts[i] as int);
      result += part * base.pow(i);
    }

    return result;
  }

  /// Converts this value to a [Decimal].
  Decimal toDecimal() {
    final rational = toRational();
    try {
      return rational.toDecimal();
    } catch (e) {
      // Handle infinite precision by using a reasonable scale
      return rational.toDecimal(scaleOnInfinitePrecision: 28);
    }
  }

  /// Converts this value to a JSON list.
  List<dynamic> toJson() => [numerator, denominator];

  @override
  List<Object?> get props => [numerator, denominator];
}
