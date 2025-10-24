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

## Rate Limit Handling

The package includes intelligent rate limit handling to prevent API quota exhaustion and service disruption:

### Automatic 429 Detection

When a repository returns a 429 (Too Many Requests) response, it is immediately marked as unhealthy and excluded from requests for 5 minutes. The system detects rate limiting errors by checking for:

- HTTP status code 429 in exception messages
- Text patterns like "too many requests" or "rate limit"

### Fallback Behavior

```dart
// If CoinGecko hits rate limit, automatically falls back to Binance
final price = await manager.fiatPrice(assetId);
// No manual intervention required - fallback is transparent
```

### Repository Health Recovery

Rate-limited repositories automatically recover after the backoff period:

```dart
// After 5 minutes, CoinGecko becomes available again
// Next request will include it in the selection pool
final newPrice = await manager.fiatPrice(assetId);
```

### Monitoring Rate Limits

You can check repository health status (mainly useful for testing):

```dart
// Check if a repository is healthy (not rate-limited)
final isHealthy = manager.isRepositoryHealthyForTest(repository);
```

## License

MIT
