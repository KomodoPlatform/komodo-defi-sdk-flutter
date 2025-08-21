# Komodo DeFi Local Auth

Authentication and wallet management on top of the Komodo DeFi Framework. This package powers the `KomodoDefiSdk.auth` surface and can be used directly for custom flows.

[![License: MIT][license_badge]][license_link]

## Install

```sh
dart pub add komodo_defi_local_auth
```

## Getting started

```dart
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';

final framework = KomodoDefiFramework.create(
  hostConfig: LocalConfig(https: false, rpcPassword: 'your-secure-password'),
);

final auth = KomodoDefiLocalAuth(
  kdf: framework,
  hostConfig: LocalConfig(https: false, rpcPassword: 'your-secure-password'),
);
await auth.ensureInitialized();

// Register or sign in (HD wallet by default)
await auth.register(walletName: 'my_wallet', password: 'strong-pass');
```

## API highlights

- `signIn` / `register` (+ `signInStream` / `registerStream` for progress and HW flows)
- `authStateChanges` and `watchCurrentUser()`
- `currentUser`, `getUsers()`, `signOut()`
- Mnemonic management: `getMnemonicEncrypted()`, `getMnemonicPlainText()`, `updatePassword()`
- Wallet admin: `deleteWallet(...)`
- Trezor flows (PIN entry etc.) via streaming API

HD is enabled by default via `AuthOptions(derivationMethod: DerivationMethod.hdWallet)`. Override if you need legacy (Iguana) mode.

## With the SDK

Prefer using `KomodoDefiSdk` which wires and scopes auth, assets, balances, and the rest for you:

```dart
final sdk = KomodoDefiSdk();
await sdk.initialize();
await sdk.auth.signIn(walletName: 'my_wallet', password: 'pass');
```

## License

MIT

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
