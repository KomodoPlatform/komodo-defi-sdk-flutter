# Komodo Coins

Fetch and transform the Komodo coins registry for use across Komodo SDK packages and apps. Provides filtering strategies and helpers to work with coin/asset metadata.

## Installation

Preferred (adds latest version to your pubspec):

```sh
dart pub add komodo_coins
```

## Quick start (standalone usage)

If you just need to parse the bundled coins configuration without the full SDK orchestration:

```dart
import 'package:komodo_coins/komodo_coins.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

Future<void> main() async {
  final coins = KomodoCoins();
  await coins.init(); // Parses bundled config assets

  // All assets, keyed by AssetId
  final all = coins.all;

  // Find variants of an asset ticker
  final btcVariants = coins.findVariantsOfCoin('BTC');

  // Get child assets (e.g. ERC‑20 tokens on Ethereum)
  final erc20 = coins.findChildAssets(
    Asset.fromJson({'coin': 'ETH', 'protocol': {'type': 'ETH'}}).id,
  );

  print('Loaded ${all.length} assets; BTC variants: ${btcVariants.length}; ERC20 children: ${erc20.length}');
}
```

## Recommended: Use via the SDK Assets module

Most applications should rely on the higher-level SDK which wires `komodo_coins` together with runtime updates (`komodo_coin_updates`), caching, filtering, and ordering.

```dart
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

Future<void> main() async {
  // This single call internally initializes komodo_coins and komodo_coin_updates (when enabled)
  final sdk = await KomodoDefiSdk.init();

  // Access the curated assets view
  final assets = sdk.assets; // or sdk.assetsRepository / sdk.coins depending on exposed API

  // Filtered examples (depends on actual SDK API names)
  final trezorSupported = assets.filteredAssets(const TrezorAssetFilterStrategy());
  print('Trezor supported assets: ${trezorSupported.length}');
}
```

Using the SDK ensures:

- Automatic initialization ordering
- Runtime configuration & update checks (via `komodo_coin_updates`)
- Unified caching and persistence strategy
- Consistent filtering utilities

If you only import `komodo_coins` directly you are responsible for calling `init()` before accessing data and for handling runtime updates (if desired) yourself.

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

`KomodoDefiSdk.init()` automatically:

1. Initializes Hive / storage (if required by higher-level features)
2. Initializes `komodo_coins` (parses bundled configuration)
3. Optionally initializes `komodo_coin_updates` (if runtime updates are enabled in your SDK configuration)
4. Exposes a cohesive assets-facing interface (naming subject to the SDK export surface)

Check the SDK README for the latest assets API surface. If an interface referenced here (e.g. `assets.filteredAssets`) differs, prefer the SDK documentation; this README focuses on the standalone library concepts.

## License

MIT
