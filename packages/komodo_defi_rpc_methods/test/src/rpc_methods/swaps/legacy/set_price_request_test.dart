import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:test/test.dart';

void main() {
  group('SetPriceRequest._validateInputs', () {
    test('throws for empty base symbol', () {
      expect(
        () => SetPriceRequest(
          base: '',
          rel: 'KMD',
          price: Decimal.one,
        ),
        throwsA(isA<SetPriceValidationException>()),
      );
    });

    test('throws for empty rel symbol', () {
      expect(
        () => SetPriceRequest(
          base: 'BTC',
          rel: '',
          price: Decimal.one,
        ),
        throwsA(isA<SetPriceValidationException>()),
      );
    });

    test('throws for zero price', () {
      expect(
        () => SetPriceRequest(
          base: 'BTC',
          rel: 'KMD',
          price: Decimal.zero,
        ),
        throwsA(isA<SetPriceValidationException>()),
      );
    });

    test('throws for negative price', () {
      expect(
        () => SetPriceRequest(
          base: 'BTC',
          rel: 'KMD',
          price: Decimal.parse('-1'),
        ),
        throwsA(isA<SetPriceValidationException>()),
      );
    });

    test('throws for zero volume', () {
      expect(
        () => SetPriceRequest(
          base: 'BTC',
          rel: 'KMD',
          price: Decimal.one,
          volume: Decimal.zero,
        ),
        throwsA(isA<SetPriceValidationException>()),
      );
    });

    test('throws for negative volume', () {
      expect(
        () => SetPriceRequest(
          base: 'BTC',
          rel: 'KMD',
          price: Decimal.one,
          volume: Decimal.parse('-1'),
        ),
        throwsA(isA<SetPriceValidationException>()),
      );
    });

    test('throws for zero minVolume', () {
      expect(
        () => SetPriceRequest(
          base: 'BTC',
          rel: 'KMD',
          price: Decimal.one,
          minVolume: Decimal.zero,
        ),
        throwsA(isA<SetPriceValidationException>()),
      );
    });

    test('throws for negative minVolume', () {
      expect(
        () => SetPriceRequest(
          base: 'BTC',
          rel: 'KMD',
          price: Decimal.one,
          minVolume: Decimal.parse('-0.1'),
        ),
        throwsA(isA<SetPriceValidationException>()),
      );
    });
  });

  group('SetPriceRequest positive case', () {
    test('serializes to expected JSON without throwing', () {
      final request = SetPriceRequest(
        base: 'KMD',
        rel: 'BTC',
        price: Decimal.parse('0.1'),
        volume: Decimal.parse('1.5'),
        max: false,
        cancelPrevious: true,
        minVolume: Decimal.parse('0.01'),
        baseConfs: 1,
        baseNota: true,
        relConfs: 2,
        relNota: false,
        saveInHistory: true,
        rpcPass: 'pass123',
      );

      final expectedJson = {
        'method': 'setprice',
        'rpc_pass': 'pass123',
        'userpass': 'pass123',
        'base': 'KMD',
        'rel': 'BTC',
        'price': {'numer': '1', 'denom': '10'},
        'volume': {'numer': '3', 'denom': '2'},
        'max': false,
        'cancel_previous': true,
        'min_volume': {'numer': '1', 'denom': '100'},
        'base_confs': 1,
        'base_nota': true,
        'rel_confs': 2,
        'rel_nota': false,
        'save_in_history': true,
      };

      expect(request.toJson(), expectedJson);
    });
  });
}

