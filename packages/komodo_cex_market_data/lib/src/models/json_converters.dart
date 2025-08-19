import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Custom converter for Decimal type
class DecimalConverter implements JsonConverter<Decimal?, dynamic> {
  const DecimalConverter();

  @override
  Decimal? fromJson(dynamic json) {
    if (json == null) return null;

    try {
      // Handle different input types
      if (json is String) {
        if (json.isEmpty) return null;
        return Decimal.parse(json);
      } else if (json is num) {
        return Decimal.parse(json.toString());
      } else if (json is int) {
        return Decimal.parse(json.toString());
      } else if (json is double) {
        return Decimal.parse(json.toString());
      }

      // Try to convert any other type to string first
      final stringValue = json.toString();
      if (stringValue.isEmpty || stringValue == 'null') return null;
      return Decimal.parse(stringValue);
    } catch (e) {
      return null;
    }
  }

  @override
  String? toJson(Decimal? decimal) {
    return decimal?.toString();
  }
}

/// Custom converter for timestamp (Unix epoch in seconds)
class TimestampConverter implements JsonConverter<DateTime?, int?> {
  const TimestampConverter();

  /// Converts Unix timestamp in seconds to DateTime
  @override
  DateTime? fromJson(int? json) {
    if (json == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(json * 1000);
  }

  /// Converts DateTime to Unix timestamp in seconds
  @override
  int? toJson(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }
}
