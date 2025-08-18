## Merchant Invoices MVP for Komodo Wallet

### Objective

Enable merchants to generate one-time, per-invoice payment addresses, compute coin amounts from a fiat price, display a scannable QR, and automatically verify payment via transaction history—implemented primarily in the SDK with reusable UI widgets.

### Scope

- In-person payments MVP; verification is both visual and automatic via transaction streams.
- Logic lives in SDK; UI exposes composable widgets and thin BLoC wrappers.
- Merchant chooses accepted assets; only coins supporting multiple addresses are enabled.
- Price is locked at invoice creation (with refresh option by re-creating invoice).

---

## User Stories

- As a merchant, I can:
  - Select which coins I accept and a default fiat currency.
  - Enter a fiat amount, choose a coin, and generate an invoice with a fresh address and QR.
  - See live payment status (pending → confirming → paid; under/overpaid).
  - Verify payment without refreshing; reject expired invoices.

---

## Constraints

- Use existing SDK managers for activation, HD address generation, pricing, and transaction history.
- No new core RPCs; only light utilities in SDK and widgets in UI.
- EVM token QR support is limited; start with address+amount display and evolve.

---

## Existing Capabilities to Leverage

- HD address generation:
  - `packages/komodo_defi_sdk/lib/src/pubkeys/pubkey_manager.dart` → `createNewPubkey()`
  - RPC: `packages/komodo_defi_rpc_methods/lib/src/rpc_methods/hd_wallet/get_new_address.dart`
- Transaction history and streaming:
  - `packages/komodo_defi_sdk/lib/src/transaction_history/transaction_history_manager.dart` → `watchTransactions()` and `getTransactionHistory(...)`
  - Models: `packages/komodo_defi_types/lib/src/transactions/transaction.dart`, `balance_changes.dart`
- Fiat pricing:
  - `packages/komodo_defi_sdk/lib/src/market_data/market_data_manager.dart`
  - Quote currencies: `packages/komodo_cex_market_data/lib/src/models/quote_currency.dart`
- Activation:
  - `packages/komodo_defi_sdk/lib/src/activation/shared_activation_coordinator.dart`
  - `ActivationParams` tuning available if needed for HD scan behavior.

---

## SDK Design (new)

### Types (in `komodo_defi_types`)

- `lib/src/merchant/merchant_invoice.dart`
  - `MerchantInvoice { id, assetId, address, coinAmount: Decimal, fiatAmount: Decimal, fiat: QuoteCurrency, createdAt, expiresAt?, paymentUri, status, matchedTxIds: Set<String> }`
- `lib/src/merchant/invoice_status.dart`
  - `InvoiceStatus { pending, confirming(confirmations:int), paid, underpaid, overpaid, expired, cancelled }`
- `lib/src/merchant/invoice_events.dart`
  - `InvoiceUpdate { invoiceId, status, seenAt, txId?, confirmations? }`

### Managers & Utilities (in `komodo_defi_sdk`)

- `lib/src/merchant/merchant_invoices_manager.dart`
  - Depends on `MarketDataManager`, `PubkeyManager`, `TransactionHistoryManager`, `SharedActivationCoordinator`, `IAssetProvider`.
  - Responsibilities:
    - Ensure activation, create new HD address per invoice.
    - Compute coin amount from fiat using live price.
    - Build a payment URI.
    - Monitor history stream; aggregate multiple incoming txs for that address; manage confirmations; update status.
- `lib/src/merchant/invoice_storage.dart`
  - Pluggable storage interface with default in-memory implementation.
- `lib/src/utils/payment_uri_builder.dart`
  - Build standardized payment URIs for UTXO (BIP-21-like) and basic EVM (EIP-681) paths; safe fallbacks for tokens.

### SDK Public API

```dart
class MerchantInvoicesManager {
  Future<void> init();

  Future<MerchantInvoice> createInvoice({
    required Asset asset,
    required Decimal fiatAmount,
    required QuoteCurrency fiat,
    Duration? expiresIn, // default 15m
    int minConfirmations = 1,
    String? label,
    String? message,
  });

  Stream<InvoiceUpdate> watchInvoice(String invoiceId);

  Future<void> cancelInvoice(String invoiceId);
  Future<MerchantInvoice?> getInvoice(String invoiceId);
  Future<List<MerchantInvoice>> listInvoices({bool includeClosed = false});
}

abstract interface class InvoiceStorage {
  Future<void> upsert(MerchantInvoice invoice);
  Future<MerchantInvoice?> getById(String id);
  Future<List<MerchantInvoice>> list({bool includeClosed = false});
}
```

### Payment URI Builder

- UTXO (BIP-21-like): `<scheme>:<address>?amount=<coin>[&label=...&message=...]` (e.g., `bitcoin:...`, `litecoin:...`, `kmd:...` when applicable).
- EVM basic (EIP-681): `ethereum:<address>?value=<wei>`.
- Tokens: fallback to address string + explicit amount display; optionally emit EIP-681 transfer later.

```dart
class PaymentUriBuilder {
  static String forAsset({
    required Asset asset,
    required String address,
    required Decimal amount,
    String? label,
    String? message,
  });
}
```

### Monitoring & Matching Logic

- Subscribe to `TransactionHistoryManager.watchTransactions(asset)`.
- Match criteria:
  - `tx.isIncoming == true`
  - `tx.to.contains(invoice.address)`
- Aggregate `tx.balanceChanges.netChange` for the invoice address over time.
- Status:
  - `pending` until first match
  - `confirming(n)` after first match; advance with confirmations
  - `paid` when cumulative amount ≥ requested and confirmations ≥ `minConfirmations`
  - `underpaid` if cumulative < requested at expiry
  - `overpaid` if cumulative > requested (still paid, but flagged)
  - `expired` when `expiresAt` passes without full payment
- Defaults: expiry 15 minutes; min confirmations 1 (configurable).

### Amounts, Decimals, Activation

- Use `AssetId.chainId.decimals` to format/display; convert to wei for EVM as needed.
- Use `SharedActivationCoordinator` before `createNewPubkey`.
- HD gap limit handled by existing strategies; one new address per invoice is safe.

---

## UI Library Design (new)

### Reusable Widgets (in `komodo_ui`)

- `MerchantInvoiceQr`:
  - Renders QR for `paymentUri`; includes copy/share controls.
- `MerchantInvoiceStatusChip`:
  - Subscribes to `Stream<InvoiceUpdate>`; displays status transitions.
- `MerchantInvoiceDetailsCard`:
  - Shows address, coin and fiat amounts, created timestamp, actions.
- `MerchantInvoiceCreateForm`:
  - Fiat input, coin selector (filtered to assets supporting multiple addresses), “Generate” button.
- `MerchantSettingsPanel`:
  - Select accepted assets; default fiat; required confirmations.

Note: add `qr_flutter` to `komodo_ui` for QR rendering. Scanner already exists: `qr_code_scanner.dart`.

### BLoC (UI-thin, follows BLoC conventions)

- `MerchantSettingsBloc`:
  - State: accepted assets, default fiat, min confirmations.
- `InvoiceCreateBloc`:
  - Orchestrates form state; calls `MerchantInvoicesManager.createInvoice`.
- `InvoiceMonitorBloc`:
  - Subscribes to `watchInvoice`; maps `InvoiceUpdate` to UI statuses.

---

## Developer Experience (minimal integration)

```dart
// 1) Initialize managers once
await sdk.marketData.init();
final invoices = sdk.merchant.invoices; // resolves MerchantInvoicesManager

// 2) Create an invoice
final invoice = await invoices.createInvoice(
  asset: asset, // chosen from accepted assets
  fiatAmount: Decimal.parse('25.00'),
  fiat: FiatCurrency.usd,
  expiresIn: const Duration(minutes: 15),
  minConfirmations: 1,
);

// 3) Bind updates
final updates = invoices.watchInvoice(invoice.id);

// 4) Compose UI
MerchantInvoiceQr(data: invoice.paymentUri)
MerchantInvoiceStatusChip(stream: updates)
MerchantInvoiceDetailsCard(invoice: invoice, stream: updates)
```

---

## Acceptance Criteria

- Generate invoice with fresh address for supported assets.
- Compute coin amount from fiat and lock at creation; show price timestamp.
- Display QR with address+amount; allow copy/share.
- Live status transitions via streaming without manual refresh.
- Handle under/overpayments and expiry clearly.
- All core logic in SDK; app only wires widgets and calls manager APIs.

---

## Testing

- SDK unit tests:
  - URI builder (BIP-21/EIP-681 cases, decimals/wei conversions).
  - Invoice creation amount calculation; expiry and confirmation thresholds.
  - Matching logic: multiple partial payments; under/overpaid paths.
- UI tests:
  - Golden tests for QR/status widgets.
  - Bloc tests: create/monitor flows; price fetch failure; cancellation/expiry.
- Integration test:
  - Testnet coin end-to-end: create → send → confirm.

---

## Risks & Mitigations

- Price outages: use `maybeFiatPrice` and surface retry; display stale timestamp.
- EVM token QR ambiguity: start with address+amount text; add EIP-681 transfer later.
- Activation delays: await activation and present progress; retry policy in manager.

---

## Roadmap (post-MVP; still SDK-focused)

- Lightning invoices:
  - Use `client.rpc.lightning.generateInvoice(...)` for BOLT 11 paths; QR of encoded invoice string.
- Auto-conversion:
  - After `paid`, invoke DEX flows to convert to merchant’s preferred settlement asset.
- Webhook/server adapters:
  - Provide interfaces and example implementations for online merchants.

---

## Tasks Breakdown

- SDK
  - Add types: `merchant_invoice.dart`, `invoice_status.dart`, `invoice_events.dart`.
  - Implement `MerchantInvoicesManager` and `InvoiceStorage`.
  - Implement `PaymentUriBuilder`.
  - Unit tests for all above.
- UI
  - Widgets: QR, StatusChip, DetailsCard, CreateForm, SettingsPanel.
  - BLoC: `MerchantSettingsBloc`, `InvoiceCreateBloc`, `InvoiceMonitorBloc`.
  - Tests: golden and bloc tests.
- Wiring
  - Ensure proper lifecycle for `MarketDataManager`.
  - Ensure assets filter to multi-address-capable only.

---

## Timeline (estimate)

- SDK + tests: 5–8 days.
- UI widgets + BLoC + tests: 5–7 days.
- Stabilization/QA: 2–3 days.
- Optional Lightning path: +3–5 days.

---

## Dependencies

- New: `qr_flutter` (UI only).
- Existing: `komodo_cex_market_data`, `komodo_defi_rpc_methods`, `komodo_defi_sdk` managers already present.

---

## Open Questions

- Do we need per-merchant min confirmations overrides per asset?
- Should we support stablecoin quote selection mapped to fiat (e.g., display “$25 USDT” variants)?
- Do we want an optional “tips” mode that accepts overpayment within bounds?

---

### Short API Reference

```dart
// SDK: invoice creation
final invoice = await sdk.merchant.invoices.createInvoice(
  asset: asset,
  fiatAmount: Decimal.parse('9.99'),
  fiat: FiatCurrency.eur,
);

// SDK: status stream
final stream = sdk.merchant.invoices.watchInvoice(invoice.id);

// UI: widgets
MerchantInvoiceQr(data: invoice.paymentUri);
MerchantInvoiceStatusChip(stream: stream);
MerchantInvoiceDetailsCard(invoice: invoice, stream: stream);
```

- All business logic stays in the SDK; apps compose with UI widgets and thin BLoCs.

- Delivered a consolidated design doc detailing SDK types/managers/utilities, UI widgets/BLoCs, monitoring logic, APIs, testing, risks, and roadmap with code examples and file placement suggestions.
