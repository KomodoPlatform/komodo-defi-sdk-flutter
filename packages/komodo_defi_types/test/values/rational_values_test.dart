import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/src/values/rational_values.dart';
import 'package:rational/rational.dart';
import 'package:test/test.dart';

void main() {
  group('FractionalValue', () {
    test('should create from JSON correctly', () {
      final json = {'numer': '3', 'denom': '2'};
      final fractional = FractionalValue.fromJson(json);

      expect(fractional.numerator, equals('3'));
      expect(fractional.denominator, equals('2'));
    });

    test('should convert to JSON correctly', () {
      const fractional = FractionalValue(numerator: '5', denominator: '4');
      final json = fractional.toJson();

      expect(json, equals({'numer': '5', 'denom': '4'}));
    });

    test('should convert to Rational correctly', () {
      const fractional = FractionalValue(numerator: '3', denominator: '2');
      final rational = fractional.toRational();

      expect(rational, equals(Rational(BigInt.from(3), BigInt.from(2))));
    });

    test('should convert to Decimal correctly', () {
      const fractional = FractionalValue(numerator: '3', denominator: '2');
      final decimal = fractional.toDecimal();

      expect(decimal, equals(Decimal.parse('1.5')));
    });
    test('should handle large numbers', () {
      const fractional = FractionalValue(
        numerator: '12345678901234567890',
        denominator: '9876543210987654321',
      );
      final rational = fractional.toRational();

      // Check that the rational represents the correct mathematical relationship
      final expectedRational = Rational(
        BigInt.parse('12345678901234567890'),
        BigInt.parse('9876543210987654321'),
      );
      expect(rational, equals(expectedRational));
    });

    test('should be equatable', () {
      const fractional1 = FractionalValue(numerator: '3', denominator: '2');
      const fractional2 = FractionalValue(numerator: '3', denominator: '2');
      const fractional3 = FractionalValue(numerator: '4', denominator: '2');

      expect(fractional1, equals(fractional2));
      expect(fractional1, isNot(equals(fractional3)));
    });
  });

  group('RationalValue', () {
    group('fromJson', () {
      test('should create from JSON correctly', () {
        final json = [
          [
            1,
            [0, 1]
          ],
          [
            1,
            [1]
          ]
        ];
        final rational = RationalValue.fromJson(json);

        expect(
            rational.numerator,
            equals([
              1,
              [0, 1]
            ]));
        expect(
            rational.denominator,
            equals([
              1,
              [1]
            ]));
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly', () {
        const rational = RationalValue(
          numerator: [
            1,
            [0, 1]
          ],
          denominator: [
            1,
            [1]
          ],
        );
        final json = rational.toJson();

        expect(
            json,
            equals([
              [
                1,
                [0, 1]
              ],
              [
                1,
                [1]
              ]
            ]));
      });
    });

    group('toRational', () {
      test('should handle simple positive case: [1,[0,1]] / [1,[1]]', () {
        // [1,[0,1]] = +4294967296, [1,[1]] = +1
        // Result should be 4294967296/1
        const rational = RationalValue(
          numerator: [
            1,
            [0, 1]
          ],
          denominator: [
            1,
            [1]
          ],
        );
        final result = rational.toRational();

        expect(result.numerator, equals(BigInt.from(4294967296)));
        expect(result.denominator, equals(BigInt.one));
      });

      test('should handle negative numerator: [-1,[1,1]] / [1,[1]]', () {
        // [-1,[1,1]] = -(1 + 4294967296) = -4294967297, [1,[1]] = +1
        // Result should be -4294967297/1
        const rational = RationalValue(
          numerator: [
            -1,
            [1, 1]
          ],
          denominator: [
            1,
            [1]
          ],
        );
        final result = rational.toRational();

        expect(result.numerator, equals(BigInt.from(-4294967297)));
        expect(result.denominator, equals(BigInt.one));
      });

      test('should handle negative denominator: [1,[1]] / [-1,[2]]', () {
        // [1,[1]] = +1, [-1,[2]] = -2
        // Result should be 1/(-2) = -1/2
        const rational = RationalValue(
          numerator: [
            1,
            [1]
          ],
          denominator: [
            -1,
            [2]
          ],
        );
        final result = rational.toRational();

        expect(result.numerator, equals(BigInt.from(-1)));
        expect(result.denominator, equals(BigInt.from(2)));
      });

      test('should handle both negative: [-1,[3]] / [-1,[2]]', () {
        // [-1,[3]] = -3, [-1,[2]] = -2
        // Result should be (-3)/(-2) = 3/2
        const rational = RationalValue(
          numerator: [
            -1,
            [3]
          ],
          denominator: [
            -1,
            [2]
          ],
        );
        final result = rational.toRational();

        expect(result.numerator, equals(BigInt.from(3)));
        expect(result.denominator, equals(BigInt.from(2)));
      });

      test('should handle zero numerator: [1,[0]] / [1,[5]]', () {
        // [1,[0]] = 0, [1,[5]] = 5
        // Result should be 0/5 = 0/1 (automatically reduced)
        const rational = RationalValue(
          numerator: [
            1,
            [0]
          ],
          denominator: [
            1,
            [5]
          ],
        );
        final result = rational.toRational();

        expect(result.numerator, equals(BigInt.zero));
        expect(result.denominator, equals(BigInt.one)); // Reduced form
      });

      test('should handle multiple uint32 parts in little-endian order', () {
        // [1,[1,2,3]] = 1*(2^32)^0 + 2*(2^32)^1 + 3*(2^32)^2
        // = 1 + 2*4294967296 + 3*4294967296^2
        // = 1 + 8589934592 + 55340232229718589440
        // = 55340232238308524033
        const rational = RationalValue(
          numerator: [
            1,
            [1, 2, 3]
          ],
          denominator: [
            1,
            [1]
          ],
        );
        final result = rational.toRational();

        final expectedNumerator = BigInt.one +
            BigInt.from(2) * BigInt.from(4294967296) +
            BigInt.from(3) * BigInt.from(4294967296) * BigInt.from(4294967296);

        expect(result.numerator, equals(expectedNumerator));
        expect(result.denominator, equals(BigInt.one));
      });

      test('should handle empty parts array as zero', () {
        // [1,[]] should be treated as 0
        const rational = RationalValue(
          numerator: [1, <int>[]],
          denominator: [
            1,
            [1]
          ],
        );
        final result = rational.toRational();

        expect(result.numerator, equals(BigInt.zero));
        expect(result.denominator, equals(BigInt.one));
      });

      test('should handle large numbers with multiple parts', () {
        // Test with maximum 32-bit values
        const maxUint32 = 4294967295; // 2^32 - 1
        const rational = RationalValue(
          numerator: [
            1,
            [maxUint32, maxUint32]
          ],
          denominator: [
            1,
            [1]
          ],
        );
        final result = rational.toRational();

        final expectedNumerator = BigInt.from(maxUint32) +
            BigInt.from(maxUint32) * BigInt.from(4294967296);

        expect(result.numerator, equals(expectedNumerator));
        expect(result.denominator, equals(BigInt.one));
      });

      test('should handle complex fraction with multiple parts', () {
        // [1,[5,10]] / [1,[2,3]]
        const rational = RationalValue(
          numerator: [
            1,
            [5, 10]
          ],
          denominator: [
            1,
            [2, 3]
          ],
        );
        final result = rational.toRational();

        final expectedNum =
            BigInt.from(5) + BigInt.from(10) * BigInt.from(4294967296);
        final expectedDenom =
            BigInt.from(2) + BigInt.from(3) * BigInt.from(4294967296);

        // Check the mathematical relationship rather than exact values
        // since Rational automatically reduces fractions
        final expectedRational = Rational(expectedNum, expectedDenom);
        expect(result, equals(expectedRational));
      });
    });

    group('toDecimal', () {
      test('should convert simple fraction to decimal', () {
        // [1,[1]] / [1,[2]] = 1/2 = 0.5
        const rational = RationalValue(
          numerator: [
            1,
            [1]
          ],
          denominator: [
            1,
            [2]
          ],
        );
        final decimal = rational.toDecimal();

        expect(decimal, equals(Decimal.parse('0.5')));
      });

      test('should convert complex fraction to decimal', () {
        // [1,[3]] / [1,[4]] = 3/4 = 0.75
        const rational = RationalValue(
          numerator: [
            1,
            [3]
          ],
          denominator: [
            1,
            [4]
          ],
        );
        final decimal = rational.toDecimal();

        expect(decimal, equals(Decimal.parse('0.75')));
      });

      test('should handle negative fractions', () {
        // [-1,[1]] / [1,[4]] = -1/4 = -0.25
        const rational = RationalValue(
          numerator: [
            -1,
            [1]
          ],
          denominator: [
            1,
            [4]
          ],
        );
        final decimal = rational.toDecimal();

        expect(decimal, equals(Decimal.parse('-0.25')));
      });

      test('should handle whole numbers', () {
        // [1,[8]] / [1,[2]] = 8/2 = 4
        const rational = RationalValue(
          numerator: [
            1,
            [8]
          ],
          denominator: [
            1,
            [2]
          ],
        );
        final decimal = rational.toDecimal();

        expect(decimal, equals(Decimal.parse('4')));
      });

      test('should handle zero', () {
        // [1,[0]] / [1,[5]] = 0/5 = 0
        const rational = RationalValue(
          numerator: [
            1,
            [0]
          ],
          denominator: [
            1,
            [5]
          ],
        );
        final decimal = rational.toDecimal();

        expect(decimal, equals(Decimal.zero));
      });

      test('should handle repeating decimals with precision', () {
        // [1,[1]] / [1,[3]] = 1/3 = 0.333...
        const rational = RationalValue(
          numerator: [
            1,
            [1]
          ],
          denominator: [
            1,
            [3]
          ],
        );
        final decimal = rational.toDecimal();

        final expected = (Decimal.one / Decimal.fromInt(3)).toDecimal(scaleOnInfinitePrecision: 28);
        expect(decimal, equals(expected));
      });
    });

    group('edge cases', () {
      test('should handle maximum precision numbers', () {
        // Test with very large numbers that would overflow regular integers
        const rational = RationalValue(
          numerator: [
            1,
            [4294967295, 4294967295, 4294967295]
          ],
          denominator: [
            1,
            [1]
          ],
        );

        expect(() => rational.toRational(), returnsNormally);
        expect(() => rational.toDecimal(), returnsNormally);
      });

      test('should handle single element arrays', () {
        const rational = RationalValue(
          numerator: [
            1,
            [42]
          ],
          denominator: [
            1,
            [7]
          ],
        );
        final result = rational.toRational();

        // 42/7 = 6/1 (automatically reduced)
        expect(result.numerator, equals(BigInt.from(6)));
        expect(result.denominator, equals(BigInt.one));
      });

      test('should maintain precision with large denominators', () {
        // Test precision is maintained when dealing with large denominators
        const rational = RationalValue(
          numerator: [
            1,
            [1]
          ],
          denominator: [
            1,
            [0, 1]
          ], // 2^32
        );
        final result = rational.toRational();

        expect(result.numerator, equals(BigInt.one));
        expect(result.denominator, equals(BigInt.from(4294967296)));
      });
    });

    group('equatable', () {
      test('should be equal when values are same', () {
        const rational1 = RationalValue(
          numerator: [
            1,
            [1, 2]
          ],
          denominator: [
            1,
            [3, 4]
          ],
        );
        const rational2 = RationalValue(
          numerator: [
            1,
            [1, 2]
          ],
          denominator: [
            1,
            [3, 4]
          ],
        );

        expect(rational1, equals(rational2));
      });

      test('should not be equal when values differ', () {
        const rational1 = RationalValue(
          numerator: [
            1,
            [1, 2]
          ],
          denominator: [
            1,
            [3, 4]
          ],
        );
        const rational2 = RationalValue(
          numerator: [
            1,
            [1, 3]
          ], // Different numerator
          denominator: [
            1,
            [3, 4]
          ],
        );

        expect(rational1, isNot(equals(rational2)));
      });
    });
  });
}
