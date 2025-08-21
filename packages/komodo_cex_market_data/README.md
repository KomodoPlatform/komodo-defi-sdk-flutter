# Komodo CEX Market Data

Composable repositories and strategies to fetch cryptocurrency prices from multiple sources with fallbacks and health-aware selection.

Sources supported:

- Komodo price service
- Binance
- CoinGecko

## Install

```sh
dart pub add komodo_cex_market_data
```

## Concepts

- Repositories implement a common interface to fetch prices and lists
- A selection strategy chooses the best repository per request
- Failures trigger temporary backoff; callers transparently fall back

## Quick start (standalone)

```dart
import 'package:get_it/get_it.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';

final di = GetIt.asNewInstance();

// Configure providers/repos/strategy
await MarketDataBootstrap.register(di, config: const MarketDataConfig());

final repos = await MarketDataBootstrap.buildRepositoryList(
  di,
  const MarketDataConfig(),
);

final manager = CexMarketDataManager(
  priceRepositories: repos,
  selectionStrategy: di<RepositorySelectionStrategy>(),
);
await manager.init();

// Fetch current price (see komodo_defi_types AssetId for details)
// In practice, you will receive an AssetId from the SDK or coins package
final price = await manager.fiatPrice(
  AssetId.parse({
    'coin': 'KMD',
    'protocol': {'type': 'UTXO'},
  }),
  quoteCurrency: Stablecoin.usdt,
);
```

## With the SDK

`KomodoDefiSdk` wires this package for you. Use `sdk.marketData`:

```dart
final price = await sdk.marketData.fiatPrice(asset.id);
final change24h = await sdk.marketData.priceChange24h(asset.id);
```

## Customization

```dart
const cfg = MarketDataConfig(
  enableKomodoPrice: true,
  enableBinance: true,
  enableCoinGecko: true,
  repositoryPriority: [
    RepositoryType.komodoPrice,
    RepositoryType.binance,
    RepositoryType.coinGecko,
  ],
  customRepositories: [],
);
```

## License

MIT
