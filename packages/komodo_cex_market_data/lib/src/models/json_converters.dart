import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Custom converter for Decimal type
class DecimalConverter implements JsonConverter<Decimal?, String?> {
  const DecimalConverter();

  @override
  Decimal? fromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      return Decimal.parse(json);
    } catch (e) {
      return null;
    }
  }

  @override
  String? toJson(Decimal? decimal) {
    return decimal?.toString();
  }
}

/// Custom converter for timestamp
class TimestampConverter implements JsonConverter<DateTime?, int?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(int? json) {
    if (json == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(json * 1000);
  }

  @override
  int? toJson(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }
}
