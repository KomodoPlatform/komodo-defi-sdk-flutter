import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart'
    show FractionalValue, RationalValue;
import 'package:rational/rational.dart';

/// Extension methods for [Decimal] to convert to Komodo DeFi value types.
extension DecimalToLegacyApiExtension on Decimal {
  /// Converts this [Decimal] to a [FractionalValue].
  ///
  /// This is useful for JSON serialization in the Komodo DeFi SDK format.
  /// Returns a [FractionalValue] with numerator and denominator as strings.
  FractionalValue toFractionalValue() {
    final rational = toRational();
    return FractionalValue(
      numerator: rational.numerator.toString(),
      denominator: rational.denominator.toString(),
    );
  }

  /// Converts this [Decimal] to a JSON representation of a [FractionalValue].
  ///
  /// This is useful for JSON serialization in the simple fractional format.
  /// Returns a [JsonMap] with 'numerator' and 'denominator' keys.
  JsonMap toJsonFractionalValue() {
    final fractionalValue = toFractionalValue();
    return fractionalValue.toJson();
  }

  /// Converts this [Decimal] to a [RationalValue].
  ///
  /// This converts to the complex Komodo DeFi SDK rational format.
  /// Each part is represented as [sign, [uint32_array]].
  /// This is useful for JSON serialization in the complex format.
  /// Returns a [RationalValue] with numerator and denominator as lists.
  RationalValue toRationalValue() {
    final rational = toRational();
    return rational.toRationalValue();
  }

  /// Converts this [Decimal] to a JSON representation of a [RationalValue].
  ///
  /// This is useful for JSON serialization in the complex Komodo DeFi SDK format.
  /// Returns a [List] with 'numerator' and 'denominator' keys.
  List<dynamic> toJsonRationalValue() {
    final rationalValue = toRationalValue();
    return rationalValue.toJson();
  }
}

/// Extension methods for [Rational] to convert to Komodo DeFi value types.
extension RationalToLegacyApiExtension on Rational {
  /// Converts this [Rational] to a [FractionalValue].
  ///
  /// This is useful for JSON serialization in the simple fractional format.
  FractionalValue toFractionalValue() {
    return FractionalValue(
      numerator: numerator.toString(),
      denominator: denominator.toString(),
    );
  }

  /// Converts this [Rational] to a [RationalValue].
  ///
  /// This converts to the complex Komodo DeFi SDK rational format where
  /// each part is represented as [sign, [uint32_array]].
  RationalValue toRationalValue() {
    // Convert BigInt to uint32 array in little-endian order
    final numArray = _bigIntToUint32Array(numerator.abs());
    final denomArray = _bigIntToUint32Array(denominator.abs());

    // Determine signs (1 for positive, -1 for negative)
    final numSign = numerator >= BigInt.zero ? 1 : -1;
    final denomSign = denominator >= BigInt.zero ? 1 : -1;

    return RationalValue(
      numerator: [numSign, numArray],
      denominator: [denomSign, denomArray],
    );
  }

  /// Converts a [BigInt] to a uint32 array in little-endian order.
  ///
  /// Each element in the array represents a 32-bit part of the big integer.
  List<int> _bigIntToUint32Array(BigInt value) {
    if (value == BigInt.zero) return [0];

    final result = <int>[];
    final base = BigInt.from(0x100000000); // 2^32 = 4294967296
    var remaining = value;

    while (remaining > BigInt.zero) {
      final part = (remaining % base).toInt();
      result.add(part);
      remaining = remaining ~/ base;
    }

    return result;
  }
}
