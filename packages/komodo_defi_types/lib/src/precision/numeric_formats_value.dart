import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:rational/rational.dart';

/// Represents a value in multiple numeric formats: decimal string, rational, and fraction.
/// Used for JSON formats like:
/// ```json
/// {
///   "decimal": "0.0001",
///   "rational": [[1, [1]], [1, [10000]]],
///   "fraction": {"numer": "1", "denom": "10000"}
/// }
/// ```
class NumericFormatsValue extends Equatable {
  /// Creates a new [NumericFormatsValue].
  const NumericFormatsValue({
    required this.decimal,
    required this.rational,
    required this.fraction,
  });

  /// Creates a [NumericFormatsValue] from a JSON map.
  factory NumericFormatsValue.fromJson(Map<String, dynamic> json) {
    return NumericFormatsValue(
      decimal: json['decimal'] as String,
      rational: RationalValue.fromJson(json['rational'] as List<dynamic>),
      fraction:
          FractionalValue.fromJson(json['fraction'] as Map<String, dynamic>),
    );
  }

  /// A decimal number as a string.
  final String decimal;

  /// A standard RationalValue object.
  final RationalValue rational;

  /// A standard FractionalValue object.
  final FractionalValue fraction;

  /// Converts this value to a [Decimal].
  Decimal toDecimal() => Decimal.parse(decimal);

  /// Converts this value to a JSON map.
  Map<String, dynamic> toJson() => {
        'decimal': decimal,
        'rational': rational.toJson(),
        'fraction': fraction.toJson(),
      };

  @override
  List<Object?> get props => [decimal, rational, fraction];
}

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
    if (json.length != 2) {
      throw const FormatException(
        'Invalid JSON format for RationalValue: expected exactly 2 elements',
      );
    }

    return RationalValue(
      numerator: BigIntArray.fromJson(json[0] as List<dynamic>),
      denominator: BigIntArray.fromJson(json[1] as List<dynamic>),
    );
  }

  /// The numerator part of the rational value.
  final BigIntArray numerator;

  /// The denominator part of the rational value.
  final BigIntArray denominator;

  /// Converts this value to a [Rational].
  ///
  /// Handles the Komodo DeFi SDK format where each part is represented as
  /// [sign, [uint32_array]] where the uint32 array contains 32-bit parts
  /// of a big integer in little-endian order.
  ///
  /// Throws [FormatException] if the input data is malformed.
  Rational toRational() {
    try {
      // Convert uint32 array to BigInt (little-endian order)
      // Each element represents a 32-bit part: sum of (parts[i] * (2^32)^i)
      final numValue = numerator.toBigInt();
      final denomValue = denominator.toBigInt();

      // Check for division by zero
      if (denomValue == BigInt.zero) {
        throw const FormatException(
          'Division by zero: denominator evaluates to zero',
        );
      }

      return Rational(numValue, denomValue);
    } on RangeError catch (e) {
      throw FormatException('Invalid data in array: ${e.message}');
    } catch (e) {
      if (e is FormatException) rethrow;
      throw FormatException('Error converting to Rational: $e');
    }
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
  List<dynamic> toJson() => [numerator.toJson(), denominator.toJson()];

  @override
  List<Object?> get props => [numerator, denominator];
}

/// Represents a big integer as an array of 32-bit parts in little-endian order.
/// Used for JSON formats like: [1, ["0", "1", "2"]]
/// The first element is the sign (1 for positive, -1 for negative),
/// and the second element is a list of stringified 32-bit parts.
class BigIntArray extends Equatable {
  const BigIntArray(this.sign, this.parts);

  /// Creates a [BigIntArray] from a JSON-compatible format.
  factory BigIntArray.fromJson(List<dynamic> json) {
    if (json.length != 2) {
      throw const FormatException('Invalid JSON format for BigIntArray');
    }

    final sign = json[0] as int;
    final parts = (json[1] as List<dynamic>)
        .map((part) => BigInt.from(part as int))
        .toList();

    return BigIntArray(sign, parts);
  }

  factory BigIntArray.fromBigInt(BigInt value) {
    if (value == BigInt.zero) {
      return BigIntArray(1, [BigInt.zero]);
    }

    final sign = value.isNegative ? -1 : 1;
    final absValue = value.abs();
    final parts = <BigInt>[];
    final maxUint32 = BigInt.from(0xFFFFFFFF); // 2^32 - 1

    // Convert to uint32 array in little-endian order
    var current = absValue;
    while (current > BigInt.zero) {
      parts.add(current & maxUint32);
      current >>= 32;
    }

    return BigIntArray(sign, parts);
  }

  /// The sign of the big integer: 1 for positive, -1 for negative.
  final int sign;

  /// The parts of the big integer represented as a list of [BigInt].
  /// Each part is a 32-bit chunk of the overall value.
  final List<BigInt> parts;

  @override
  String toString() {
    return 'BigIntArray(sign: $sign, parts: $parts)';
  }

  /// Converts this array to a JSON-compatible format.
  List<dynamic> toJson() {
    return [sign, parts.map((e) => e.toInt()).toList()];
  }

  /// Converts a uint32 array in little-endian order to a [BigInt].
  ///
  /// Each element in the array represents a 32-bit part of the big integer.
  /// The value is calculated as the sum of each part multiplied by powers
  /// of 2^32.
  ///
  /// Throws [FormatException] if any part is not a valid uint32 value.
  BigInt toBigInt() {
    var result = BigInt.zero;
    final base = BigInt.from(0x100000000); // 2^32 = 4294967296
    final maxUint32 = BigInt.from(0xFFFFFFFF);

    for (var i = 0; i < parts.length; i++) {
      final bigIntPart = parts[i];

      if (bigIntPart < BigInt.zero || bigIntPart > maxUint32) {
        throw FormatException(
          'Array element at index $i is outside uint32 range: $bigIntPart',
        );
      }

      // Guard against overflow in large calculations
      try {
        final term = bigIntPart * base.pow(i);
        result += term;
      } catch (e) {
        throw FormatException('Numeric overflow occurred at index $i');
      }
    }

    return result;
  }

  @override
  List<Object?> get props => [sign, parts];
}
