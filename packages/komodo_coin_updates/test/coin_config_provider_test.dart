import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:komodo_coin_updates/src/data/coin_config_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
    registerFallbackValue(<String, String>{});
  });

  group('CoinConfigProvider', () {
    late _MockHttpClient client;
    late CoinConfigProvider provider;

    setUp(() {
      client = _MockHttpClient();
      provider = CoinConfigProvider(httpClient: client);
    });

    test('getLatestCommit returns sha on 200', () async {
      final uri = Uri.parse(
        '${provider.coinsGithubApiUrl}/branches/${provider.branch}',
      );
      when(() => client.get(uri, headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'commit': {'sha': 'abc123'},
          }),
          200,
        ),
      );

      final sha = await provider.getLatestCommit();
      expect(sha, 'abc123');
    });

    test('getLatestAssets parses list of Asset from config map', () async {
      final uri = Uri.parse(
        '${provider.coinsGithubContentUrl}/${provider.branch}/${provider.coinsConfigPath}',
      );

      when(() => client.get(uri)).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'KMD': {
              'coin': 'KMD',
              'decimals': 8,
              'type': 'UTXO',
              'protocol': {'type': 'UTXO'},
              'fname': 'Komodo',
              'chain_id': 0,
            },
          }),
          200,
        ),
      );

      final assets = await provider.getLatestAssets();
      expect(assets, isNotEmpty);
      expect(assets.first.id.id, 'KMD');
    });

    // CoinConfig retrieval removed; configs can be derived from Asset if needed.
  });
}
