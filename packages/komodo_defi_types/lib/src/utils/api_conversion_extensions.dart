import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart'
    show BigIntArray, FractionalValue, RationalValue;
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
  /// This is useful for JSON serialization in the complex Komodo DeFi SDK
  /// format. Returns a [List] with 'numerator' and 'denominator' keys.
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
    return RationalValue(
      numerator: BigIntArray.fromBigInt(numerator.abs()),
      denominator: BigIntArray.fromBigInt(denominator.abs()),
    );
  }
}
