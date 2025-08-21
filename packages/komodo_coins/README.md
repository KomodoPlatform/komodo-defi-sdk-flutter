# Komodo Coins

Fetch and transform the Komodo coins registry for use across Komodo SDK packages and apps. Provides filtering strategies and helpers to work with coin/asset metadata.

## Install

```sh
flutter pub add komodo_coins
```

## Quick start

```dart
import 'package:komodo_coins/komodo_coins.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

final coins = KomodoCoins();
await coins.init();

// All assets, keyed by AssetId
final all = coins.all;

// Find a specific ticker variant
final btcVariants = coins.findVariantsOfCoin('BTC');

// Get child assets for a platform id (e.g. tokens on a chain)
final erc20 = coins.findChildAssets(
  AssetId.parse({'coin': 'ETH', 'protocol': {'type': 'ETH'}}),
);
```

## Filtering strategies

Use strategies to filter the visible set of assets for a given context (e.g., hardware wallet support):

```dart
final filtered = coins.filteredAssets(const TrezorAssetFilterStrategy());
```

Included strategies:
- `NoAssetFilterStrategy` (default)
- `TrezorAssetFilterStrategy`
- `UtxoAssetFilterStrategy`
- `EvmAssetFilterStrategy`

## With the SDK

`KomodoDefiSdk` uses this package under the hood for asset discovery, ordering, and historical/custom tokens.

## License

MIT