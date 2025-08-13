import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

void main() {
  group('TrezorUserActionData redaction', () {
    test('toString() redacts pin and passphrase', () {
      final pinData = TrezorUserActionData.pin('1234');
      final passphraseData = TrezorUserActionData.passphrase('hello world');

      expect(pinData.toString(), contains('pin: [REDACTED]'));
      expect(pinData.toString(), contains('passphrase: null'));

      expect(passphraseData.toString(), contains('pin: null'));
      expect(passphraseData.toString(), contains('passphrase: [REDACTED]'));
    });

    test('JSON uses raw values for API', () {
      final pinData = TrezorUserActionData.pin('9876');
      final passphraseData = TrezorUserActionData.passphrase('secret pass');

      final pinJson = pinData.toJson();
      final passphraseJson = passphraseData.toJson();

      expect(pinJson['pin'], '9876');
      expect(pinJson['passphrase'], isNull);

      expect(passphraseJson['pin'], isNull);
      expect(passphraseJson['passphrase'], 'secret pass');
    });
  });
}
