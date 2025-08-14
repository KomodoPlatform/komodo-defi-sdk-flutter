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

    test('getLatestCoins parses list of Coin', () async {
      final uri = Uri.parse(
        '${provider.coinsGithubContentUrl}/${provider.branch}/${provider.coinsPath}',
      );

      when(() => client.get(uri)).thenAnswer(
        (_) async => http.Response(
          jsonEncode([
            {'coin': 'KMD', 'decimals': 8},
          ]),
          200,
        ),
      );

      final coins = await provider.getLatestCoins();
      expect(coins, isNotEmpty);
      expect(coins.first.coin, 'KMD');
    });

    test('getLatestCoinConfigs parses map', () async {
      final uri = Uri.parse(
        '${provider.coinsGithubContentUrl}/${provider.branch}/${provider.coinsConfigPath}',
      );

      when(() => client.get(uri)).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'KMD': {'coin': 'KMD', 'decimals': 8},
          }),
          200,
        ),
      );

      final configs = await provider.getLatestCoinConfigs();
      expect(configs, contains('KMD'));
      expect(configs['KMD']!.coin, 'KMD');
    });
  });
}
