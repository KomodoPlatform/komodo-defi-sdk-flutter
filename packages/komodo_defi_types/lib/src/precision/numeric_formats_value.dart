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
  Decimal toDecimal() {
    return Decimal.parse(decimal);
  }

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
  ///
  /// Throws [FormatException] if the input data is malformed.
  Rational toRational() {
    // Validate numerator format
    if (numerator.length != 2) {
      throw const FormatException(
        'Invalid numerator format: expected [sign, array]',
      );
    }

    final numSign = numerator[0] as int;
    // Validate sign values are only -1, 0, or 1
    if (numSign < -1 || numSign > 1) {
      throw const FormatException(
        'Invalid numerator sign: must be -1, 0, or 1',
      );
    }

    if (numerator[1] is! List) {
      throw const FormatException(
        'Invalid numerator: second element must be a list',
      );
    }

    final numParts = numerator[1] as List<dynamic>;
    // Check that array is not empty
    if (numParts.isEmpty) {
      throw const FormatException('Invalid numerator: empty parts array');
    }

    // Validate denominator format
    if (denominator.length != 2) {
      throw const FormatException(
        'Invalid denominator format: expected [sign, array]',
      );
    }

    final denomSign = denominator[0] as int;
    // Validate sign values
    if (denomSign < -1 || denomSign > 1) {
      throw const FormatException(
        'Invalid denominator sign: must be -1, 0, or 1',
      );
    }

    if (denominator[1] is! List) {
      throw const FormatException(
        'Invalid denominator: second element must be a list',
      );
    }

    final denomParts = denominator[1] as List<dynamic>;
    // Check that array is not empty
    if (denomParts.isEmpty) {
      throw const FormatException('Invalid denominator: empty parts array');
    }

    // Check for excessively large numbers (arbitrary limit of 1000 parts which is more than enough)
    if (numParts.length > 1000 || denomParts.length > 1000) {
      throw const FormatException(
        'Input too large: number of parts exceeds maximum allowed',
      );
    }

    try {
      // Convert uint32 array to BigInt (little-endian order)
      // Each element represents a 32-bit part: sum of (parts[i] * (2^32)^i)
      var numValue = _uint32ArrayToBigInt(numParts);
      var denomValue = _uint32ArrayToBigInt(denomParts);

      // Check for division by zero
      if (denomValue == BigInt.zero) {
        throw const FormatException(
          'Division by zero: denominator evaluates to zero',
        );
      }

      // Apply signs
      if (numSign < 0) numValue = -numValue;
      if (denomSign < 0) denomValue = -denomValue;

      return Rational(numValue, denomValue);
    } on RangeError catch (e) {
      throw FormatException('Invalid data in array: ${e.message}');
    } catch (e) {
      if (e is FormatException) rethrow;
      throw FormatException('Error converting to Rational: $e');
    }
  }

  /// Converts a uint32 array in little-endian order to a [BigInt].
  ///
  /// Each element in the array represents a 32-bit part of the big integer.
  /// The value is calculated as the sum of each part multiplied by powers
  /// of 2^32.
  ///
  /// Throws [FormatException] if any part is not a valid uint32 value.
  BigInt _uint32ArrayToBigInt(List<dynamic> parts) {
    var result = BigInt.zero;
    final base = BigInt.from(0x100000000); // 2^32 = 4294967296
    const maxUint32 = 0xFFFFFFFF; // Maximum value for uint32

    for (var i = 0; i < parts.length; i++) {
      final partValue = parts[i];

      // Validate part is an integer
      if (partValue is! int) {
        throw FormatException('Array element at index $i is not an integer');
      }

      // Validate part is within uint32 range (0 to 4294967295)
      if (partValue < 0 || partValue > maxUint32) {
        throw FormatException(
          'Array element at index $i is outside uint32 range: $partValue',
        );
      }

      final part = BigInt.from(partValue);

      // Guard against overflow in large calculations
      try {
        final term = part * base.pow(i);
        result += term;
      } catch (e) {
        throw FormatException('Numeric overflow occurred at index $i');
      }
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
