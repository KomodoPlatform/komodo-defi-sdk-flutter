import 'package:komodo_defi_rpc_methods/src/common_structures/primitive/fraction.dart';
import 'package:komodo_defi_rpc_methods/src/common_structures/primitive/mm2_rational.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:rational/rational.dart';

/// Represents a numeric value returned by MM2 APIs that can include
/// decimal, fraction, and rational representations.
class NumericValue {
  NumericValue({required this.decimal, this.fraction, this.rational});

  /// Parses a [NumericValue] from a JSON map.
  factory NumericValue.fromJson(JsonMap json) {
    final decimalValue =
        json.valueOrNull<String>('decimal') ?? json['decimal']?.toString();

    if (decimalValue == null) {
      throw ArgumentError('Key "decimal" not found in Map');
    }

    final fractionJson = json.valueOrNull<JsonMap>('fraction');
    final rationalJson = json.valueOrNull<List<dynamic>>('rational');

    return NumericValue(
      decimal: decimalValue,
      fraction: fractionJson != null ? Fraction.fromJson(fractionJson) : null,
      rational: rationalJson != null ? rationalFromMm2(rationalJson) : null,
    );
  }

  /// Attempts to parse a [NumericValue] from any supported JSON structure.
  ///
  /// Returns `null` if the input is null or cannot be parsed.
  static NumericValue? tryParse(dynamic data) {
    if (data == null) return null;
    if (data is NumericValue) return data;

    if (data is String) {
      return NumericValue(decimal: data);
    }

    if (data is num) {
      return NumericValue(decimal: data.toString());
    }

    JsonMap? asMap;

    if (data is JsonMap) {
      asMap = data;
    } else if (data is Map) {
      asMap = <String, dynamic>{};
      data.forEach((key, value) {
        asMap![key.toString()] = value;
      });
    }

    if (asMap != null) {
      try {
        return NumericValue.fromJson(asMap);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  /// Decimal string representation of the numeric value.
  final String decimal;

  /// Fractional representation, if available.
  final Fraction? fraction;

  /// Rational representation, if available.
  final Rational? rational;

  /// Converts this numeric value back to JSON format used by MM2 APIs.
  Map<String, dynamic> toJson() => {
    'decimal': decimal,
    'fraction': ?fraction?.toJson(),
    if (rational != null) 'rational': rationalToMm2(rational!),
  };
}
