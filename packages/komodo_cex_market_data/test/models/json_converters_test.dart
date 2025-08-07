import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:komodo_cex_market_data/src/models/json_converters.dart';

void main() {
  group('DecimalConverter', () {
    late DecimalConverter converter;

    setUp(() {
      converter = const DecimalConverter();
    });

    group('fromJson', () {
      test('should handle null input', () {
        expect(converter.fromJson(null), isNull);
      });

      test('should handle empty string', () {
        expect(converter.fromJson(''), isNull);
      });

      test('should handle valid string', () {
        final result = converter.fromJson('123.45');
        expect(result, equals(Decimal.parse('123.45')));
      });

      test('should handle integer input', () {
        final result = converter.fromJson(42);
        expect(result, equals(Decimal.parse('42')));
      });

      test('should handle double input', () {
        final result = converter.fromJson(123.45);
        expect(result, equals(Decimal.parse('123.45')));
      });

      test('should handle num input', () {
        const num value = 67.89;
        final result = converter.fromJson(value);
        expect(result, equals(Decimal.parse('67.89')));
      });

      test('should handle negative numbers', () {
        final result = converter.fromJson(-25.5);
        expect(result, equals(Decimal.parse('-25.5')));
      });

      test('should handle zero', () {
        final result = converter.fromJson(0);
        expect(result, equals(Decimal.zero));
      });

      test('should handle string zero', () {
        final result = converter.fromJson('0');
        expect(result, equals(Decimal.zero));
      });

      test('should handle invalid string gracefully', () {
        expect(converter.fromJson('invalid'), isNull);
      });

      test('should handle boolean input gracefully', () {
        expect(converter.fromJson(true), isNull);
        expect(converter.fromJson(false), isNull);
      });

      test('should handle list input gracefully', () {
        expect(converter.fromJson([1, 2, 3]), isNull);
      });

      test('should handle map input gracefully', () {
        expect(converter.fromJson({'key': 'value'}), isNull);
      });
    });

    group('toJson', () {
      test('should handle null input', () {
        expect(converter.toJson(null), isNull);
      });

      test('should convert decimal to string', () {
        final decimal = Decimal.parse('123.45');
        expect(converter.toJson(decimal), equals('123.45'));
      });

      test('should handle zero', () {
        expect(converter.toJson(Decimal.zero), equals('0'));
      });

      test('should handle negative decimal', () {
        final decimal = Decimal.parse('-67.89');
        expect(converter.toJson(decimal), equals('-67.89'));
      });
    });
  });

  group('TimestampConverter', () {
    late TimestampConverter converter;

    setUp(() {
      converter = const TimestampConverter();
    });

    group('fromJson', () {
      test('should handle null input', () {
        expect(converter.fromJson(null), isNull);
      });

      test('should convert timestamp to DateTime', () {
        const timestamp = 1691404800; // August 7, 2023 12:00:00 UTC
        final result = converter.fromJson(timestamp);
        expect(result, isA<DateTime>());
        expect(result!.millisecondsSinceEpoch, equals(timestamp * 1000));
      });

      test('should handle zero timestamp', () {
        final result = converter.fromJson(0);
        expect(result, isA<DateTime>());
        expect(result!.millisecondsSinceEpoch, equals(0));
      });
    });

    group('toJson', () {
      test('should handle null input', () {
        expect(converter.toJson(null), isNull);
      });

      test('should convert DateTime to timestamp', () {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(1691404800000);
        final result = converter.toJson(dateTime);
        expect(result, equals(1691404800));
      });
    });
  });
}
