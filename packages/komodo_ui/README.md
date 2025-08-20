# Komodo UI

Reusable Flutter widgets for DeFi apps built on the Komodo DeFi SDK and Framework. Focused, production‑ready components that pair naturally with the SDK’s managers.

[![License: MIT][license_badge]][license_link]

## Install

```sh
flutter pub add komodo_ui
```

## Highlights

- Core inputs and displays: address fields, fee info, transaction formatting
- DeFi flows: withdraw form primitives, asset cards, trend text, icons
- Utilities: debouncer, formatters, QR code scanner

## Usage

Widgets are framework‑agnostic and can be used directly. When used with the SDK, adapter widgets are available from `komodo_defi_sdk` to bind to SDK streams, e.g.:

```dart
// From komodo_defi_sdk: live balance text bound to BalanceManager
AssetBalanceText(assetId)
```

Withdraw UI example scaffolding is provided:

```dart
// Example only, see source for a complete form demo
WithdrawalFormExample(asset: asset)
```

## Formatting helpers

Utilities to format addresses, assets, fees and transaction details are available under `src/utils/formatters`.

## License

MIT

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
