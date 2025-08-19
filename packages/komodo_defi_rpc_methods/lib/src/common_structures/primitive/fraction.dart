import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class Fraction {
  Fraction({required this.numer, required this.denom});

  factory Fraction.fromJson(JsonMap json) {
    return Fraction(
      numer: json.value<String>('numer'),
      denom: json.value<String>('denom'),
    );
  }

  /// Numerator of the fraction
  final String numer;

  /// Denominator of the fraction
  final String denom;

  Map<String, dynamic> toJson() => {'numer': numer, 'denom': denom};
}