import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:komodo_coin_updates/src/data/coin_config_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  group('GithubCoinConfigProvider CDN mirrors', () {
    test('uses CDN base when exact branch mirror exists', () {
      final provider = GithubCoinConfigProvider(
        cdnBranchMirrors: const {
          'master': 'https://komodoplatform.github.io/coins',
        },
      );

      final uri = provider.buildContentUri(
        'utils/coins_config_unfiltered.json',
      );
      expect(
        uri.toString(),
        'https://komodoplatform.github.io/coins/utils/coins_config_unfiltered.json',
      );
    });

    test('falls back to raw content when branch has no mirror', () {
      final provider = GithubCoinConfigProvider(
        branch: 'dev',
        cdnBranchMirrors: const {
          'master': 'https://komodoplatform.github.io/coins',
        },
      );

      final uri = provider.buildContentUri(
        'utils/coins_config_unfiltered.json',
      );
      expect(
        uri.toString(),
        'https://raw.githubusercontent.com/KomodoPlatform/coins/dev/utils/coins_config_unfiltered.json',
      );
    });

    test('branchOrCommit override uses matching CDN when available', () {
      final provider = GithubCoinConfigProvider(
        branch: 'dev',
        cdnBranchMirrors: const {
          'master': 'https://komodoplatform.github.io/coins',
        },
      );

      final uri = provider.buildContentUri(
        'utils/coins_config_unfiltered.json',
        branchOrCommit: 'master',
      );
      expect(
        uri.toString(),
        'https://komodoplatform.github.io/coins/utils/coins_config_unfiltered.json',
      );
    });

    test('branchOrCommit override falls back to raw when not mirrored', () {
      final provider = GithubCoinConfigProvider(
        cdnBranchMirrors: const {
          'master': 'https://komodoplatform.github.io/coins',
        },
      );

      final uri = provider.buildContentUri(
        'utils/coins_config_unfiltered.json',
        branchOrCommit: 'feature/example',
      );
      expect(
        uri.toString(),
        'https://raw.githubusercontent.com/KomodoPlatform/coins/feature/example/utils/coins_config_unfiltered.json',
      );
    });

    test('ignores empty CDN entry and falls back to raw', () {
      final provider = GithubCoinConfigProvider(
        branch: 'dev',
        cdnBranchMirrors: const {'dev': ''},
      );

      final uri = provider.buildContentUri(
        'utils/coins_config_unfiltered.json',
      );
      expect(
        uri.toString(),
        'https://raw.githubusercontent.com/KomodoPlatform/coins/dev/utils/coins_config_unfiltered.json',
      );
    });

    test('handles null mirrors and falls back to raw', () {
      final provider = GithubCoinConfigProvider();

      final uri = provider.buildContentUri(
        'utils/coins_config_unfiltered.json',
      );
      expect(
        uri.toString(),
        'https://raw.githubusercontent.com/KomodoPlatform/coins/master/utils/coins_config_unfiltered.json',
      );
    });
  });
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
    registerFallbackValue(<String, String>{});
  });

  group('GithubCoinConfigProvider', () {
    late _MockHttpClient client;
    late GithubCoinConfigProvider provider;

    setUp(() {
      client = _MockHttpClient();
      provider = GithubCoinConfigProvider(httpClient: client);
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
              'is_testnet': false,
            },
          }),
          200,
        ),
      );

      final assets = await provider.getAssets();
      expect(assets, isNotEmpty);
      expect(assets.first.id.id, 'KMD');
    });

    // CoinConfig retrieval removed; configs can be derived from Asset if needed.
  });
}
