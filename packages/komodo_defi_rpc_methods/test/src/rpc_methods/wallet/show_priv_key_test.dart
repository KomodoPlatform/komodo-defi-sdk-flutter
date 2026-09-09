import 'package:komodo_defi_rpc_methods/src/rpc_methods/wallet/show_priv_key.dart';
import 'package:test/test.dart';

void main() {
  const fixtureKey = 'synthetic-private-key';
  final request = ShowPrivKeyRequest(
    coin: 'TRX',
    rpcPass: 'synthetic-password',
  );

  test('uses the authenticated legacy envelope with a top-level coin', () {
    expect(request.mmrpc, isNull);
    expect(request.toJson(), {
      'method': 'show_priv_key',
      'rpc_pass': 'synthetic-password',
      'coin': 'TRX',
    });
  });

  test(
    'parses the activated owner key and preserves deliberate serialization',
    () {
      final json = <String, dynamic>{
        'result': {'coin': 'TRX', 'priv_key': fixtureKey},
      };

      final response = request.parseResponseJson(json);

      expect(response.coin, 'TRX');
      expect(response.privKey, fixtureKey);
      expect(response.mmrpc, isNull);
      expect(response.toJson(), json);
      expect(response.toString(), isNot(contains(fixtureKey)));
      expect(request.toString(), isNot(contains('synthetic-password')));
    },
  );

  test('rejects a response for a different activated coin', () {
    expect(
      () => request.parseResponseJson({
        'result': {'coin': 'USDT-TRC20', 'priv_key': fixtureKey},
      }),
      throwsFormatException,
    );
  });

  test(
    'rejects missing, mistyped, or empty fields without exposing key data',
    () {
      for (final json in <Map<String, dynamic>>[
        {},
        {'result': fixtureKey},
        {'result': <String, dynamic>{}},
        {
          'result': {'coin': 'TRX', 'priv_key': 12},
        },
        {
          'result': {'coin': 12, 'priv_key': fixtureKey},
        },
        {
          'result': {'coin': '', 'priv_key': fixtureKey},
        },
        {
          'result': {'coin': 'TRX', 'priv_key': ' '},
        },
        {
          'mmrpc': 2,
          'result': {'coin': 'TRX', 'priv_key': fixtureKey},
        },
      ]) {
        expect(
          () => ShowPrivKeyResponse.parse(json),
          throwsA(
            isA<FormatException>().having(
              (error) => error.toString(),
              'redacted parser diagnostics',
              isNot(contains(fixtureKey)),
            ),
          ),
        );
      }
    },
  );
}
