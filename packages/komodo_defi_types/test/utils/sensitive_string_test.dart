import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:test/test.dart';

void main() {
  group('SensitiveString', () {
    test('toString() redacts content', () {
      const original = 'mySecretPassword';
      const sensitive = SensitiveString(original);

      expect(sensitive.toString(), '[REDACTED]');
      expect('$sensitive', '[REDACTED]');
    });

    test('SensitiveStringConverter serializes raw value', () {
      const original = 'rawSecret';
      const converter = SensitiveStringConverter();

      final jsonValue = converter.toJson(const SensitiveString(original));
      expect(jsonValue, original);
    });

    test(
      'SensitiveStringConverter deserializes to wrapper preserving value',
      () {
        const original = 'anotherSecret';
        const converter = SensitiveStringConverter();

        final wrapper = converter.fromJson(original);
        expect(wrapper, isA<SensitiveString>());
        expect(wrapper?.value, original);
        expect(wrapper.toString(), '[REDACTED]');
      },
    );
  });
}
