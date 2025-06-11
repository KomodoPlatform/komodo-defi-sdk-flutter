import 'package:decimal/decimal.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts [Decimal] values to and from JSON.
class DecimalConverter implements JsonConverter<Decimal, dynamic> {
  const DecimalConverter();

  @override
  Decimal fromJson(dynamic json) => Decimal.parse(json.toString());

  @override
  dynamic toJson(Decimal object) => object.toString();
}
