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
- WalletConnect authentication with QR code generation and session management

HD is enabled by default via `AuthOptions(derivationMethod: DerivationMethod.hdWallet)`. Override if you need legacy (Iguana) mode.

## WalletConnect Authentication

WalletConnect allows users to authenticate using their mobile wallets by scanning QR codes:

```dart
// Sign in with WalletConnect
final authStream = auth.signInStream(
  options: AuthOptions(
    privateKeyPolicy: PrivateKeyPolicy.walletConnect(),
    derivationMethod: DerivationMethod.hdWallet,
  ),
  walletName: 'my_wallet',
  password: 'strong-pass',
);

await for (final state in authStream) {
  switch (state.status) {
    case AuthenticationStatus.generatingQrCode:
      print('Generating QR code...');
      break;
    case AuthenticationStatus.waitingForConnection:
      final qrData = state.data as QRCodeData;
      print('Scan QR code: ${qrData.uri}');
      // Display QR code to user
      break;
    case AuthenticationStatus.walletConnected:
      print('Mobile wallet connected!');
      break;
    case AuthenticationStatus.completed:
      print('Authentication completed: ${state.user?.walletName}');
      break;
    case AuthenticationStatus.error:
      print('Error: ${state.error}');
      break;
  }
}

// Session management
final sessions = await auth.walletConnect.getSessions();
final session = await auth.walletConnect.getSession('session_topic');
await auth.walletConnect.pingSession('session_topic');
await auth.walletConnect.deleteSession('session_topic');
```

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
