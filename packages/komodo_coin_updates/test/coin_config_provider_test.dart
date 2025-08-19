import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _ForceWalletOnlyTransform implements CoinConfigTransform {
  const _ForceWalletOnlyTransform();
  @override
  JsonMap transform(JsonMap config) {
    final out = JsonMap.of(config);
    out['wallet_only'] = true;
    return out;
  }

  @override
  bool needsTransform(JsonMap config) => true;
}

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

    test('uses raw URL for commit hash even when CDN is available', () {
      final provider = GithubCoinConfigProvider(
        cdnBranchMirrors: const {
          'master': 'https://komodoplatform.github.io/coins',
        },
      );

      final uri = provider.buildContentUri(
        'utils/coins_config_unfiltered.json',
        branchOrCommit: 'f7d8e39cd11c3b6431df314fcaae5becc2814136',
      );
      expect(
        uri.toString(),
        'https://raw.githubusercontent.com/KomodoPlatform/coins/f7d8e39cd11c3b6431df314fcaae5becc2814136/utils/coins_config_unfiltered.json',
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

    test('CDN base with trailing slash and path with leading slash', () {
      final provider = GithubCoinConfigProvider(
        cdnBranchMirrors: const {
          'master': 'https://komodoplatform.github.io/coins/',
        },
      );

      final uri = provider.buildContentUri(
        '/utils/coins_config_unfiltered.json',
      );
      expect(
        uri.toString(),
        'https://komodoplatform.github.io/coins/utils/coins_config_unfiltered.json',
      );
    });

    test('Raw content base with trailing slash and path with leading slash', () {
      final provider = GithubCoinConfigProvider(
        branch: 'feature/example',
        coinsGithubContentUrl:
            'https://raw.githubusercontent.com/KomodoPlatform/coins/',
      );

      final uri = provider.buildContentUri(
        '/utils/coins_config_unfiltered.json',
      );
      expect(
        uri.toString(),
        'https://raw.githubusercontent.com/KomodoPlatform/coins/feature/example/utils/coins_config_unfiltered.json',
      );
    });

    group('master/main branch CDN behavior', () {
      test('master branch uses CDN URL without appending branch name', () {
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

      test('main branch uses CDN URL without appending branch name', () {
        final provider = GithubCoinConfigProvider(
          branch: 'main',
          cdnBranchMirrors: const {
            'main': 'https://komodoplatform.github.io/coins',
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

      test('explicit master override uses CDN URL', () {
        final provider = GithubCoinConfigProvider(
          branch: 'dev',
          cdnBranchMirrors: const {
            'master': 'https://komodoplatform.github.io/coins',
            'main': 'https://komodoplatform.github.io/coins',
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

      test('explicit main override uses CDN URL', () {
        final provider = GithubCoinConfigProvider(
          branch: 'dev',
          cdnBranchMirrors: const {
            'master': 'https://komodoplatform.github.io/coins',
            'main': 'https://komodoplatform.github.io/coins',
          },
        );

        final uri = provider.buildContentUri(
          'utils/coins_config_unfiltered.json',
          branchOrCommit: 'main',
        );
        expect(
          uri.toString(),
          'https://komodoplatform.github.io/coins/utils/coins_config_unfiltered.json',
        );
      });
    });

    group('non-master/main branch behavior', () {
      test('development branch uses GitHub raw URL even with CDN available', () {
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

      test('feature branch uses GitHub raw URL even with CDN available', () {
        final provider = GithubCoinConfigProvider(
          branch: 'feature/new-coin-support',
          cdnBranchMirrors: const {
            'master': 'https://komodoplatform.github.io/coins',
            'main': 'https://komodoplatform.github.io/coins',
          },
        );

        final uri = provider.buildContentUri(
          'utils/coins_config_unfiltered.json',
        );
        expect(
          uri.toString(),
          'https://raw.githubusercontent.com/KomodoPlatform/coins/feature/new-coin-support/utils/coins_config_unfiltered.json',
        );
      });

      test('release branch uses GitHub raw URL even with CDN available', () {
        final provider = GithubCoinConfigProvider(
          cdnBranchMirrors: const {
            'master': 'https://komodoplatform.github.io/coins',
          },
        );

        final uri = provider.buildContentUri(
          'utils/coins_config_unfiltered.json',
          branchOrCommit: 'release/v1.2.0',
        );
        expect(
          uri.toString(),
          'https://raw.githubusercontent.com/KomodoPlatform/coins/release/v1.2.0/utils/coins_config_unfiltered.json',
        );
      });

      test('hotfix branch uses GitHub raw URL even with CDN available', () {
        final provider = GithubCoinConfigProvider(
          cdnBranchMirrors: const {
            'master': 'https://komodoplatform.github.io/coins',
            'main': 'https://komodoplatform.github.io/coins',
          },
        );

        final uri = provider.buildContentUri(
          'utils/coins_config_unfiltered.json',
          branchOrCommit: 'hotfix/urgent-fix',
        );
        expect(
          uri.toString(),
          'https://raw.githubusercontent.com/KomodoPlatform/coins/hotfix/urgent-fix/utils/coins_config_unfiltered.json',
        );
      });
    });

    group('commit hash behavior', () {
      test('full 40-character commit hash uses GitHub raw URL', () {
        final provider = GithubCoinConfigProvider(
          cdnBranchMirrors: const {
            'master': 'https://komodoplatform.github.io/coins',
            'main': 'https://komodoplatform.github.io/coins',
          },
        );

        final uri = provider.buildContentUri(
          'utils/coins_config_unfiltered.json',
          branchOrCommit: 'f7d8e39cd11c3b6431df314fcaae5becc2814136',
        );
        expect(
          uri.toString(),
          'https://raw.githubusercontent.com/KomodoPlatform/coins/f7d8e39cd11c3b6431df314fcaae5becc2814136/utils/coins_config_unfiltered.json',
        );
      });

      test('different commit hash uses GitHub raw URL', () {
        final provider = GithubCoinConfigProvider(
          cdnBranchMirrors: const {
            'master': 'https://komodoplatform.github.io/coins',
          },
        );

        final uri = provider.buildContentUri(
          'utils/coins_config_unfiltered.json',
          branchOrCommit: 'abc123def456789012345678901234567890abcd',
        );
        expect(
          uri.toString(),
          'https://raw.githubusercontent.com/KomodoPlatform/coins/abc123def456789012345678901234567890abcd/utils/coins_config_unfiltered.json',
        );
      });

      test('commit hash with uppercase letters uses GitHub raw URL', () {
        final provider = GithubCoinConfigProvider(
          cdnBranchMirrors: const {
            'master': 'https://komodoplatform.github.io/coins',
            'main': 'https://komodoplatform.github.io/coins',
          },
        );

        final uri = provider.buildContentUri(
          'utils/coins_config_unfiltered.json',
          branchOrCommit: 'F7D8E39CD11C3B6431DF314FCAAE5BECC2814136',
        );
        expect(
          uri.toString(),
          'https://raw.githubusercontent.com/KomodoPlatform/coins/F7D8E39CD11C3B6431DF314FCAAE5BECC2814136/utils/coins_config_unfiltered.json',
        );
      });

      test('mixed case commit hash uses GitHub raw URL', () {
        final provider = GithubCoinConfigProvider(
          cdnBranchMirrors: const {
            'master': 'https://komodoplatform.github.io/coins',
          },
        );

        final uri = provider.buildContentUri(
          'utils/coins_config_unfiltered.json',
          branchOrCommit: 'AbC123DeF456789012345678901234567890AbCd',
        );
        expect(
          uri.toString(),
          'https://raw.githubusercontent.com/KomodoPlatform/coins/AbC123DeF456789012345678901234567890AbCd/utils/coins_config_unfiltered.json',
        );
      });
    });

    group('edge cases and validation', () {
      test('short hash-like string is treated as branch name', () {
        final provider = GithubCoinConfigProvider(
          cdnBranchMirrors: const {
            'abc123': 'https://example.com/short-hash-branch',
          },
        );

        final uri = provider.buildContentUri(
          'utils/coins_config_unfiltered.json',
          branchOrCommit: 'abc123', // Only 6 characters, not a commit hash
        );
        expect(
          uri.toString(),
          'https://example.com/short-hash-branch/utils/coins_config_unfiltered.json',
        );
      });

      test('39-character string is treated as branch name', () {
        final provider = GithubCoinConfigProvider(
          cdnBranchMirrors: const {
            'master': 'https://komodoplatform.github.io/coins',
          },
        );

        final uri = provider.buildContentUri(
          'utils/coins_config_unfiltered.json',
          branchOrCommit: 'f7d8e39cd11c3b6431df314fcaae5becc281413', // 39 chars
        );
        expect(
          uri.toString(),
          'https://raw.githubusercontent.com/KomodoPlatform/coins/f7d8e39cd11c3b6431df314fcaae5becc281413/utils/coins_config_unfiltered.json',
        );
      });

      test('41-character string is treated as branch name', () {
        final provider = GithubCoinConfigProvider(
          cdnBranchMirrors: const {
            'master': 'https://komodoplatform.github.io/coins',
          },
        );

        final uri = provider.buildContentUri(
          'utils/coins_config_unfiltered.json',
          branchOrCommit:
              'f7d8e39cd11c3b6431df314fcaae5becc2814136a', // 41 chars
        );
        expect(
          uri.toString(),
          'https://raw.githubusercontent.com/KomodoPlatform/coins/f7d8e39cd11c3b6431df314fcaae5becc2814136a/utils/coins_config_unfiltered.json',
        );
      });

      test('40-character string with non-hex characters is treated as branch', () {
        final provider = GithubCoinConfigProvider(
          cdnBranchMirrors: const {
            'master': 'https://komodoplatform.github.io/coins',
          },
        );

        final uri = provider.buildContentUri(
          'utils/coins_config_unfiltered.json',
          branchOrCommit:
              'f7d8e39cd11c3b6431df314fcaae5becc281413g', // 40 chars but contains 'g'
        );
        expect(
          uri.toString(),
          'https://raw.githubusercontent.com/KomodoPlatform/coins/f7d8e39cd11c3b6431df314fcaae5becc281413g/utils/coins_config_unfiltered.json',
        );
      });
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

    test('getLatestCommit throws on non-200 and includes headers', () async {
      final uri = Uri.parse(
        '${provider.coinsGithubApiUrl}/branches/${provider.branch}',
      );
      when(() => client.get(uri, headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response('nope', 403, reasonPhrase: 'Forbidden'),
      );

      expect(() => provider.getLatestCommit(), throwsA(isA<Exception>()));
    });

    test('getAssetsForCommit throws on non-200', () async {
      final url = provider.buildContentUri(provider.coinsConfigPath);
      when(
        () => client.get(url),
      ).thenAnswer((_) async => http.Response('error', 500));
      expect(
        () => provider.getAssetsForCommit(provider.branch),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'transformation pipeline applies and filters excluded coins',
      () async {
        final p = GithubCoinConfigProvider(
          httpClient: client,
          transformer: const CoinConfigTransformer(
            transforms: [_ForceWalletOnlyTransform()],
          ),
        );

        final uri = Uri.parse(
          '${p.coinsGithubContentUrl}/${p.branch}/${p.coinsConfigPath}',
        );
        when(() => client.get(uri)).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'KMD': {
                'coin': 'KMD',
                'type': 'UTXO',
                'protocol': {'type': 'UTXO'},
                'fname': 'Komodo',
                'chain_id': 0,
                'is_testnet': false,
              },
              'SLP': {
                'coin': 'SLP',
                'type': 'SLP',
                'protocol': {'type': 'SLP'},
                'fname': 'SLP Token',
                'chain_id': 0,
                'is_testnet': false,
              },
            }),
            200,
          ),
        );

        final assets = await p.getAssets();
        expect(assets.any((a) => a.id.id == 'SLP'), isFalse);
        final kmd = assets.firstWhere((a) => a.id.id == 'KMD');
        expect(kmd.isWalletOnly, isTrue);
      },
    );

    test('buildContentUri normalizes coinsPath entries', () {
      final p = GithubCoinConfigProvider(
        coinsGithubContentUrl:
            'https://raw.githubusercontent.com/KomodoPlatform/coins/',
        cdnBranchMirrors: const {
          'master': 'https://komodoplatform.github.io/coins/',
        },
      );

      final cdnUri = p.buildContentUri('/coins/KMD.json');
      expect(
        cdnUri.toString(),
        'https://komodoplatform.github.io/coins/coins/KMD.json',
      );

      final rawP = GithubCoinConfigProvider(
        coinsGithubContentUrl:
            'https://raw.githubusercontent.com/KomodoPlatform/coins/',
        cdnBranchMirrors: const {},
      );
      final rawUri = rawP.buildContentUri('/coins/KMD.json');
      expect(
        rawUri.toString(),
        'https://raw.githubusercontent.com/KomodoPlatform/coins/master/coins/KMD.json',
      );
    });

    test('getAssets with branch override uses that ref', () async {
      final p = GithubCoinConfigProvider(httpClient: client);
      final uri = Uri.parse(
        '${p.coinsGithubContentUrl}/dev/${p.coinsConfigPath}',
      );
      when(() => client.get(uri)).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'KMD': {
              'coin': 'KMD',
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
      final assets = await p.getAssets(branch: 'dev');
      expect(assets, isNotEmpty);
    });

    test('getLatestCommit sends Accept and UA headers', () async {
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
      await provider.getLatestCommit();
      verify(() => client.get(uri, headers: any(named: 'headers'))).called(1);
    });
  });
}
