# Komodo DeFi Types

Lightweight, shared domain types used across the Komodo DeFi SDK and Framework. These types are UI‑ and storage‑agnostic by design.

## Install

```sh
dart pub add komodo_defi_types
```

## What’s inside

Exports (selection):

- API: `ApiClient` (+ `client.rpc` extension)
- Assets: `Asset`, `AssetId`, `AssetPubkeys`, `AssetValidation`
- Public keys: `BalanceStrategy`, `PubkeyInfo`
- Auth: `KdfUser`, `AuthOptions`
- Fees: `FeeInfo`, `WithdrawalFeeOptions`
- Trading/Swaps: common high‑level types
- Transactions: `Transaction`, pagination helpers

These types are consumed by higher‑level managers in `komodo_defi_sdk`.

## Example

```dart
import 'package:komodo_defi_types/komodo_defi_types.dart';

// Create an AssetId (normally parsed/built by coins package/SDK)
final id = AssetId.parse({'coin': 'KMD', 'protocol': {'type': 'UTXO'}});

// Work with typed RPC via ApiClient extension
Future<void> printBalance(ApiClient client) async {
  final resp = await client.rpc.wallet.myBalance(coin: id.id);
  print(resp.balance);
}
```

## Guidance

- Keep these types free of presentation or persistence logic
- Prefer explicit, well‑named fields and immutability

## License

MIT
