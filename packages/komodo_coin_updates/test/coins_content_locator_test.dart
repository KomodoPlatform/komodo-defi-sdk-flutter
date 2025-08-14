import 'package:komodo_coin_updates/src/data/coins_content_locator.dart';
import 'package:test/test.dart';

void main() {
  group('CoinsContentLocator', () {
    test('uses CDN base when exact branch mirror exists', () {
      const locator = CoinsContentLocator(
        branch: 'master',
        coinsGithubContentUrl:
            'https://raw.githubusercontent.com/KomodoPlatform/coins',
        cdnBranchMirrors: {'master': 'https://komodoplatform.github.io/coins'},
      );
      final uri = locator.buildContentUri('utils/coins_config_unfiltered.json');
      expect(
        uri.toString(),
        'https://komodoplatform.github.io/coins/utils/coins_config_unfiltered.json',
      );
    });

    test('falls back to raw content when branch has no mirror', () {
      const locator = CoinsContentLocator(
        branch: 'dev',
        coinsGithubContentUrl:
            'https://raw.githubusercontent.com/KomodoPlatform/coins',
        cdnBranchMirrors: {'master': 'https://komodoplatform.github.io/coins'},
      );
      final uri = locator.buildContentUri('utils/coins_config_unfiltered.json');
      expect(
        uri.toString(),
        'https://raw.githubusercontent.com/KomodoPlatform/coins/dev/utils/coins_config_unfiltered.json',
      );
    });

    test('override uses matching CDN when available', () {
      const locator = CoinsContentLocator(
        branch: 'dev',
        coinsGithubContentUrl:
            'https://raw.githubusercontent.com/KomodoPlatform/coins',
        cdnBranchMirrors: {'master': 'https://komodoplatform.github.io/coins'},
      );
      final uri = locator.buildContentUri(
        'utils/coins_config_unfiltered.json',
        branchOrCommit: 'master',
      );
      expect(
        uri.toString(),
        'https://komodoplatform.github.io/coins/utils/coins_config_unfiltered.json',
      );
    });

    test('override falls back to raw when not mirrored', () {
      const locator = CoinsContentLocator(
        branch: 'master',
        coinsGithubContentUrl:
            'https://raw.githubusercontent.com/KomodoPlatform/coins',
        cdnBranchMirrors: {'master': 'https://komodoplatform.github.io/coins'},
      );
      final uri = locator.buildContentUri(
        'utils/coins_config_unfiltered.json',
        branchOrCommit: 'feature/example',
      );
      expect(
        uri.toString(),
        'https://raw.githubusercontent.com/KomodoPlatform/coins/feature/example/utils/coins_config_unfiltered.json',
      );
    });

    test('ignores empty CDN entry and falls back to raw', () {
      const locator = CoinsContentLocator(
        branch: 'dev',
        coinsGithubContentUrl:
            'https://raw.githubusercontent.com/KomodoPlatform/coins',
        cdnBranchMirrors: {'dev': ''},
      );
      final uri = locator.buildContentUri('utils/coins_config_unfiltered.json');
      expect(
        uri.toString(),
        'https://raw.githubusercontent.com/KomodoPlatform/coins/dev/utils/coins_config_unfiltered.json',
      );
    });

    test('handles null mirrors and falls back to raw', () {
      const locator = CoinsContentLocator(
        branch: 'master',
        coinsGithubContentUrl:
            'https://raw.githubusercontent.com/KomodoPlatform/coins',
      );
      final uri = locator.buildContentUri('utils/coins_config_unfiltered.json');
      expect(
        uri.toString(),
        'https://raw.githubusercontent.com/KomodoPlatform/coins/master/utils/coins_config_unfiltered.json',
      );
    });
  });
}
