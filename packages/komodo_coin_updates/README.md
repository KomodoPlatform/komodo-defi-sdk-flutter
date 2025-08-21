# Komodo Coin Updates

Runtime updater for the Komodo coins list, coin configs, and seed nodes with local persistence. Useful for apps that need to refresh coin metadata without shipping a new app build.

## Install

```sh
dart pub add komodo_coin_updates
```

## Initialize

```dart
import 'package:flutter/widgets.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KomodoCoinUpdater.ensureInitialized('/path/to/app/data');
}
```

## Provider (fetch from GitHub)

```dart
final provider = const CoinConfigProvider();
final coins = await provider.getLatestCoins();
final coinConfigs = await provider.getLatestCoinConfigs();
```

## Repository (manage + persist)

```dart
final repo = CoinConfigRepository(
  api: const CoinConfigProvider(),
  storageProvider: CoinConfigStorageProvider.withDefaults(),
);

if (await repo.coinConfigExists()) {
  if (await repo.isLatestCommit()) {
    await repo.loadCoinConfigs();
  } else {
    await repo.updateCoinConfig();
  }
} else {
  await repo.updateCoinConfig();
}
```

## License

MIT
