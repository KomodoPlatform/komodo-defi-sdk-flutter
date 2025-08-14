# Komodo Coin Updates

Utilities for retrieving, storing, and updating the Komodo coins configuration at runtime.

This package fetches the unified coins configuration JSON from the `KomodoPlatform/coins` repository (`utils/coins_config_unfiltered.json` by default), converts entries into `Asset` models (from `komodo_defi_types`), persists them to Hive, and tracks the source commit so you can decide when to refresh.

## Features

- Fetch latest commit from the `KomodoPlatform/coins` repo
- Retrieve the latest coins_config JSON and parse to strongly-typed `Asset` models
- Persist assets in Hive (`assets` lazy box) and store current commit in `coins_settings`
- Check whether the stored commit is up to date and update when needed
- Configurable repo URLs, branch/commit, CDN mirrors, and optional GitHub token
- Initialize in the main isolate or a background isolate

## Installation

Add the dependency and import the library:

```yaml
dependencies:
  komodo_coin_updates: ^1.0.0
```

```dart
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
```

## Quick start

1. Initialize Hive storage for the package (once on app start):

```dart
await KomodoCoinUpdater.ensureInitialized('/path/to/app/storage');
```

1. Provide your runtime update configuration (e.g., derived from your build config):

```dart
final config = RuntimeUpdateConfig(
  fetchAtBuildEnabled: false,
  updateCommitOnBuild: false,
  bundledCoinsRepoCommit: 'abcdef123456',
  coinsRepoApiUrl: 'https://api.github.com/repos/KomodoPlatform/coins',
  coinsRepoContentUrl: 'https://raw.githubusercontent.com/KomodoPlatform/coins',
  coinsRepoBranch: 'master',
  runtimeUpdatesEnabled: true,
  mappedFiles: {
    // App asset → Repo path (used to locate coins_config in the repo)
    'assets/config/coins_config.json': 'utils/coins_config_unfiltered.json',
    'assets/config/coins.json': 'coins',
  },
  mappedFolders: {},
  concurrentDownloadsEnabled: true,
  cdnBranchMirrors: {},
);
```

1. Create a repository with sensible defaults and use it to load/update data:

```dart
final repo = CoinConfigRepository.withDefaults(
  config,
  githubToken: String.fromEnvironment('GITHUB_TOKEN', defaultValue: ''),
);

// First-run or app start logic
if (await repo.coinConfigExists()) {
  final isUpToDate = await repo.isLatestCommit();
  if (!isUpToDate) {
    await repo.updateCoinConfig();
  }
} else {
  await repo.updateCoinConfig();
}

final assets = await repo.getAssets();
```

## Provider-only usage

If you only need to fetch from the repo without persistence:

```dart
final provider = CoinConfigProvider.fromConfig(config);
final latestCommit = await provider.getLatestCommit();
final latestAssets = await provider.getLatestAssets();
```

## Notes

- The package reads from `utils/coins_config_unfiltered.json` by default. You can override this via `RuntimeUpdateConfig.mappedFiles['assets/config/coins_config.json']`.
- Assets are stored in a Hive lazy box named `assets`; the current commit hash is stored in a box named `coins_settings` with key `coins_commit`.
- Provide a GitHub token to reduce the likelihood of rate limiting when calling the GitHub API for commit information.

## License

See the repository's license for details.
