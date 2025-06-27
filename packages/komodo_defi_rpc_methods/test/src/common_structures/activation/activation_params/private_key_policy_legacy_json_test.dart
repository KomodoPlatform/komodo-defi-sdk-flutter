import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:test/test.dart';

void main() {
  group('PrivateKeyPolicy.fromLegacyJson - Core Legacy Support', () {
    group('Legacy String Format', () {
      test('handles "ContextPrivKey" (PascalCase legacy)', () {
        final result = PrivateKeyPolicy.fromLegacyJson('ContextPrivKey');
        expect(result, const PrivateKeyPolicy.contextPrivKey());
        expect(result.toJson()['type'], 'context_priv_key');
      });

      test('handles "context_priv_key" (snake_case)', () {
        final result = PrivateKeyPolicy.fromLegacyJson('context_priv_key');
        expect(result, const PrivateKeyPolicy.contextPrivKey());
        expect(result.toJson()['type'], 'context_priv_key');
      });

      test('handles "Trezor" (PascalCase legacy)', () {
        final result = PrivateKeyPolicy.fromLegacyJson('Trezor');
        expect(result, const PrivateKeyPolicy.trezor());
        expect(result.toJson()['type'], 'trezor');
      });

      test('handles "trezor" (snake_case)', () {
        final result = PrivateKeyPolicy.fromLegacyJson('trezor');
        expect(result, const PrivateKeyPolicy.trezor());
        expect(result.toJson()['type'], 'trezor');
      });

      test('handles "WalletConnect" (PascalCase legacy)', () {
        final result = PrivateKeyPolicy.fromLegacyJson('WalletConnect');
        expect(result.toString(), contains('walletConnect'));
        expect(result.toJson()['type'], 'wallet_connect');
        expect(result.toJson()['session_topic'], '');
      });
    });

    group('Modern JSON Format', () {
      test('handles modern JSON with context_priv_key', () {
        final json = {'type': 'context_priv_key'};
        final result = PrivateKeyPolicy.fromLegacyJson(json);
        expect(result, const PrivateKeyPolicy.contextPrivKey());
      });

      test('handles modern JSON with wallet_connect and session_topic', () {
        final json = {
          'type': 'wallet_connect',
          'session_topic': 'my_session_123',
        };
        final result = PrivateKeyPolicy.fromLegacyJson(json);
        expect(result.toJson()['type'], 'wallet_connect');
        expect(result.toJson()['session_topic'], 'my_session_123');
      });
    });

    group('Default and Error Cases', () {
      test('returns contextPrivKey for null input', () {
        final result = PrivateKeyPolicy.fromLegacyJson(null);
        expect(result, const PrivateKeyPolicy.contextPrivKey());
      });

      test('throws for unknown string types', () {
        expect(
          () => PrivateKeyPolicy.fromLegacyJson('UnknownType'),
          throwsArgumentError,
        );
      });

      test('throws for invalid input types', () {
        expect(() => PrivateKeyPolicy.fromLegacyJson(123), throwsArgumentError);
      });
    });

    group('Backward Compatibility Matrix', () {
      final testCases = [
        // Legacy string format -> Expected modern type
        {'input': 'ContextPrivKey', 'expectedType': 'context_priv_key'},
        {'input': 'context_priv_key', 'expectedType': 'context_priv_key'},
        {'input': 'Trezor', 'expectedType': 'trezor'},
        {'input': 'trezor', 'expectedType': 'trezor'},
        {'input': 'Metamask', 'expectedType': 'metamask'},
        {'input': 'metamask', 'expectedType': 'metamask'},
        {'input': 'WalletConnect', 'expectedType': 'wallet_connect'},
        {'input': 'wallet_connect', 'expectedType': 'wallet_connect'},
      ];

      for (final testCase in testCases) {
        test(
          'converts "${testCase['input']}" to "${testCase['expectedType']}"',
          () {
            final result = PrivateKeyPolicy.fromLegacyJson(testCase['input']);
            expect(result.toJson()['type'], testCase['expectedType']);
          },
        );
      }
    });

    group('JSON Roundtrip Compatibility', () {
      test('legacy string -> modern JSON -> same result', () {
        final legacyResult = PrivateKeyPolicy.fromLegacyJson('Trezor');
        final modernJson = legacyResult.toJson();
        final modernResult = PrivateKeyPolicy.fromLegacyJson(modernJson);

        expect(legacyResult.toJson(), equals(modernResult.toJson()));
        expect(legacyResult, equals(modernResult));
      });

      test('modern JSON -> legacy equivalent produces same result', () {
        final modernJson = {'type': 'context_priv_key'};
        final modernResult = PrivateKeyPolicy.fromLegacyJson(modernJson);
        final legacyResult = PrivateKeyPolicy.fromLegacyJson('ContextPrivKey');

        expect(modernResult, equals(legacyResult));
      });
    });

    group('PascalCase Name Integration', () {
      test('pascalCaseName matches legacy string format', () {
        final testCases = [
          {'legacy': 'ContextPrivKey', 'pascal': 'ContextPrivKey'},
          {'legacy': 'Trezor', 'pascal': 'Trezor'},
          {'legacy': 'Metamask', 'pascal': 'Metamask'},
          {'legacy': 'WalletConnect', 'pascal': 'WalletConnect'},
        ];

        for (final testCase in testCases) {
          final policy = PrivateKeyPolicy.fromLegacyJson(testCase['legacy']);
          expect(policy.pascalCaseName, testCase['pascal']);
        }
      });

      test(
        'pascalCaseName is consistent between legacy and modern formats',
        () {
          final legacyPolicy = PrivateKeyPolicy.fromLegacyJson('Trezor');
          final modernPolicy = PrivateKeyPolicy.fromLegacyJson({
            'type': 'trezor',
          });

          expect(legacyPolicy.pascalCaseName, modernPolicy.pascalCaseName);
          expect(legacyPolicy.pascalCaseName, 'Trezor');
        },
      );

      test('pascalCaseName provides clean type identification', () {
        final policies = [
          PrivateKeyPolicy.fromLegacyJson('ContextPrivKey'),
          PrivateKeyPolicy.fromLegacyJson('context_priv_key'),
          PrivateKeyPolicy.fromLegacyJson({'type': 'context_priv_key'}),
        ];

        for (final policy in policies) {
          expect(policy.pascalCaseName, 'ContextPrivKey');
        }
      });
    });
  });
}
