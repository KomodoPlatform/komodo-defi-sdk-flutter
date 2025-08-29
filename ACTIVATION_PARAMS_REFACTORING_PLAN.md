## Activation Parameters Architecture Refactoring Plan

### Goals

- Fix SRP violations by removing protocol-specific fields from the base `ActivationParams`.
- Establish a consistent, extensible serialization model across protocols while adapting to KDF API differences.
- Introduce a user configuration framework (request, validate, persist, reuse) that is extensible per protocol.
- Add state management for “awaiting user input” with a 60s timeout and graceful handling.
- Integrate cleanly with `KomodoDefiSdk` using type-safe models (`freezed`), `AssetId`, and existing JSON utilities.

### Non-Goals

- Backward compatibility with the old `ActivationParams` shape. We will provide a clean vNext design and adapters for KDF RPC formats where needed.

---

## 1) Architecture Design

### 1.1 Class hierarchy (clean, SRP-compliant)

- `abstract class ActivationParams implements RpcRequestParams`

  - Common, protocol-agnostic fields only:
    - `requiredConfirmations: int?`
    - `requiresNotarization: bool`
    - `privKeyPolicy: PrivateKeyPolicy` (canonical object form internally)
    - `mode: ActivationMode?` (shared concept, but not all protocols require it)
  - API:
    - `JsonMap toCanonicalJson()` → canonical SDK-wide JSON (uniform across protocols)
    - `JsonMap toRpcParams(KdfRpcParamsEncoder encoder)` → converts canonical JSON to KDF-specific RPC params using an encoder strategy

- Protocol-specific subclasses (each contains only its own concerns):
  - `UtxoActivationParams extends ActivationParams`
    - `txHistory, txVersion, txFee, dustAmount, pubtype, p2shtype, wiftype, overwintered, ...`
  - `ZhtlcActivationParams extends ActivationParams`
    - `zcashParamsPath, scanBlocksPerIteration (default 1000), scanIntervalMs (default 0)`, and any ZHTLC sync params via `ActivationMode.rpcData.syncParams`
  - `EthActivationParams extends ActivationParams` (and optionally `Erc20ActivationParams`)
    - ETH/ERC specifics (e.g., fee policy, chainId if applicable)

Notes:

- Base class no longer contains any ZHTLC- or UTXO-specific fields.
- All subclasses expose `toCanonicalJson()` that returns stable, uniform key names. The KDF shape differences are handled in an encoder (Strategy pattern).

### 1.2 Serialization: uniform canonical form + Strategy encoder

- Canonical form (internal SDK) is consistent across protocols:
  - Example keys: `required_confirmations`, `requires_notarization`, `priv_key_policy: { "type": "ContextPrivKey" | ... }`, `mode`, protocol-specific keys.
- `abstract class KdfRpcParamsEncoder` (Strategy):
  - `JsonMap encode(JsonMap canonical, {required AssetId assetId, required ActivationProtocol protocol});`
  - Concrete encoders per protocol handle KDF-specific differences:
    - `UtxoRpcParamsEncoder` → may set/rename fields, ensure PascalCase string for `priv_key_policy` if KDF requires it.
    - `ZhtlcRpcParamsEncoder` → includes `zcash_params_path`, `scan_blocks_per_iteration`, `scan_interval_ms` in the output.
    - `EthRpcParamsEncoder` → uses JSON object for `priv_key_policy` (as today), ETH-specific aspects.

This provides a single internal representation and a well-defined translation to the RPC-facing shape per protocol.

### 1.3 Builder + Factory for params

- `ActivationParamsBuilder` (Builder pattern) composes:

  - coin metadata (from `AssetId`),
  - user configuration (persisted or default),
  - and programmatic overrides,
    to produce a concrete `ActivationParams` subtype.

- `ActivationParamsFactory` (Factory Method) resolves which subtype to create based on `AssetId`’s protocol and provided inputs.

### 1.4 User configuration framework

- Type-safe configuration models (freezed):

  - `sealed class ActivationUserConfig` with protocol variants:
    - `ZhtlcActivationUserConfig { String zcashParamsPath; int scanBlocksPerIteration; int scanIntervalMs; }`
    - `UtxoActivationUserConfig { ... }` (initially optional/no-op)
    - `EthActivationUserConfig { ... }` (initially optional/no-op)
  - Validations included in factory constructors.

- Field specs for dynamic UI generation:

  - `class ConfigFieldSpec { String id; String label; ConfigFieldType type; bool required; dynamic defaultValue; String? hint; String? Function(dynamic value)? validator; }`
  - `enum ConfigFieldType { text, number, path }`

- `extension AssetIdActivation on AssetId`:
  - `ActivationProtocol get activationProtocol;`
  - `List<ConfigFieldSpec> get configurationFields;` → per protocol definition (ZHTLC returns the 3 fields; others empty for now)

### 1.5 Persistence layer

- `abstract class ActivationConfigRepository`:

  - `Future<ActivationUserConfig?> load(AssetId assetId);`
  - `Future<void> save(AssetId assetId, ActivationUserConfig config);`
  - `Future<void> delete(AssetId assetId);`
  - Keys are namespaced by `assetId.canonical`.

- Default implementations:
  - `SharedPreferencesActivationConfigRepository` (Flutter/mobile/web).
  - `FileActivationConfigRepository` (CLI/desktop), or `InMemoryActivationConfigRepository` fallback.

Storage format: JSON-encoded canonical `ActivationUserConfig` using `toJson()`/`fromJson()` via freezed.

### 1.6 State management (BLoC)

- BLoC to orchestrate “awaiting user input” with 60s timeout:

  - Events:
    - `ActivationConfigRequested(AssetId)`
    - `ActivationConfigSubmitted(AssetId, ActivationUserConfig)`
    - `ActivationConfigTimedOut(AssetId)`
  - States:
    - `ActivationConfigInitial`
    - `ActivationConfigLoading(AssetId)`
    - `ActivationConfigAwaitingUser(AssetId, List<ConfigFieldSpec>, int remainingSeconds)`
    - `ActivationConfigSaving(AssetId)`
    - `ActivationConfigReady(AssetId, ActivationUserConfig)`
    - `ActivationConfigTimeout(AssetId)`
    - `ActivationConfigFailure(AssetId, Object error)`

- Timeout policy:
  - Default: fail with `ActivationConfigTimeout` (recommended for safety).
  - SDK option to choose “use defaults on timeout” per asset/protocol.

### 1.7 SDK integration points

- `KomodoDefiSdk` adds an activation coordination flow:

  - `Future<ActivationParams> resolveActivationParams(AssetId assetId, {ActivationUserConfig? override, Duration timeout = const Duration(seconds: 60), TimeoutPolicy timeoutPolicy = TimeoutPolicy.fail,})`
    1. Load persisted config; if present → build params.
    2. If absent → emit UI request via BLoC; await up to `timeout`.
    3. On submit → persist and build params.
    4. On timeout → apply configured policy (fail or defaults).

- The returned `ActivationParams` are encoded via the appropriate `KdfRpcParamsEncoder` before RPC call.

---

## 2) Implementation Details

### 2.1 Core models with freezed

```dart
// packages/komodo_defi_rpc_methods/lib/src/common_structures/activation/activation_params/base.dart
@freezed
class BaseActivationParams with _$BaseActivationParams {
  const factory BaseActivationParams({
    int? requiredConfirmations,
    @Default(false) bool requiresNotarization,
    @Default(PrivateKeyPolicy.contextPrivKey()) PrivateKeyPolicy privKeyPolicy,
    ActivationMode? mode,
  }) = _BaseActivationParams;

  factory BaseActivationParams.fromJson(JsonMap json) =>
      _$BaseActivationParamsFromJson(json);
}

abstract class ActivationParams implements RpcRequestParams {
  BaseActivationParams get base;

  // Canonical, protocol-agnostic shape
  JsonMap toCanonicalJson();

  // RPC-ready shape for KDF API
  @override
  JsonMap toRpcParams(KdfRpcParamsEncoder encoder) =>
      encoder.encode(toCanonicalJson(), assetId: assetId, protocol: protocol);

  AssetId get assetId;
  ActivationProtocol get protocol;
}
```

```dart
// ZHTLC params
@freezed
class ZhtlcActivationParams with _$ZhtlcActivationParams implements ActivationParams {
  const factory ZhtlcActivationParams({
    required AssetId assetId,
    required ActivationProtocol protocol,
    required BaseActivationParams base,
    String? zcashParamsPath,
    @Default(1000) int scanBlocksPerIteration,
    @Default(0) int scanIntervalMs,
  }) = _ZhtlcActivationParams;

  factory ZhtlcActivationParams.fromJson(JsonMap json) =>
      _$ZhtlcActivationParamsFromJson(json);

  @override
  JsonMap toCanonicalJson() => {
    ...base.toJson(),
    'zcash_params_path': zcashParamsPath,
    'scan_blocks_per_iteration': scanBlocksPerIteration,
    'scan_interval_ms': scanIntervalMs,
  }..removeWhere((_, v) => v == null);
}
```

```dart
// UTXO params (example, trimmed)
@freezed
class UtxoActivationParams with _$UtxoActivationParams implements ActivationParams {
  const factory UtxoActivationParams({
    required AssetId assetId,
    required ActivationProtocol protocol,
    required BaseActivationParams base,
    bool? txHistory,
    int? txVersion,
    int? txFee,
    int? dustAmount,
    int? pubtype,
    int? p2shtype,
    int? wiftype,
    int? overwintered,
  }) = _UtxoActivationParams;

  factory UtxoActivationParams.fromJson(JsonMap json) =>
      _$UtxoActivationParamsFromJson(json);

  @override
  JsonMap toCanonicalJson() => {
    ...base.toJson(),
    if (txHistory != null) 'tx_history': txHistory,
    if (txVersion != null) 'txversion': txVersion,
    if (txFee != null) 'txfee': txFee,
    if (dustAmount != null) 'dust_amount': dustAmount,
    if (pubtype != null) 'pubtype': pubtype,
    if (p2shtype != null) 'p2shtype': p2shtype,
    if (wiftype != null) 'wiftype': wiftype,
    if (overwintered != null) 'overwintered': overwintered,
  };
}
```

### 2.2 Encoder strategy

```dart
abstract class KdfRpcParamsEncoder {
  JsonMap encode(
    JsonMap canonical, {
    required AssetId assetId,
    required ActivationProtocol protocol,
  });
}

class ZhtlcRpcParamsEncoder implements KdfRpcParamsEncoder {
  @override
  JsonMap encode(JsonMap canonical, {required AssetId assetId, required ActivationProtocol protocol}) {
    // ZHTLC keeps keys; ensure types using json utils
    final base = convertToJsonMap(canonical);
    return base;
  }
}

class UtxoRpcParamsEncoder implements KdfRpcParamsEncoder {
  @override
  JsonMap encode(JsonMap canonical, {required AssetId assetId, required ActivationProtocol protocol}) {
    final base = convertToJsonMap(canonical);
    // KDF expects PascalCase string for priv_key_policy for UTXO
    final policy = PrivateKeyPolicy.fromLegacyJson(base['priv_key_policy']).pascalCaseName;
    return base.deepMerge({'priv_key_policy': policy, 'max_connected': 1});
  }
}

class EthRpcParamsEncoder implements KdfRpcParamsEncoder {
  @override
  JsonMap encode(JsonMap canonical, {required AssetId assetId, required ActivationProtocol protocol}) {
    // ETH uses object for priv_key_policy (canonical already is object)
    return convertToJsonMap(canonical);
  }
}
```

### 2.3 User configuration models and repository

```dart
@freezed
class ZhtlcActivationUserConfig with _$ZhtlcActivationUserConfig implements ActivationUserConfig {
  const factory ZhtlcActivationUserConfig({
    required String zcashParamsPath,
    @Default(1000) int scanBlocksPerIteration,
    @Default(0) int scanIntervalMs,
  }) = _ZhtlcActivationUserConfig;

  factory ZhtlcActivationUserConfig.fromJson(JsonMap json) =>
      _$ZhtlcActivationUserConfigFromJson(json);
}

sealed class ActivationUserConfig {
  JsonMap toJson();
}

abstract class ActivationConfigRepository {
  Future<ActivationUserConfig?> load(AssetId assetId);
  Future<void> save(AssetId assetId, ActivationUserConfig config);
  Future<void> delete(AssetId assetId);
}
```

### 2.4 BLoC state management (naming per BLoC conventions)

```dart
// Events
sealed class ActivationConfigEvent {}
class ActivationConfigRequested extends ActivationConfigEvent { ActivationConfigRequested(this.assetId); final AssetId assetId; }
class ActivationConfigSubmitted extends ActivationConfigEvent { ActivationConfigSubmitted(this.assetId, this.config); final AssetId assetId; final ActivationUserConfig config; }
class ActivationConfigTimedOut extends ActivationConfigEvent { ActivationConfigTimedOut(this.assetId); final AssetId assetId; }

// States
sealed class ActivationConfigState {}
class ActivationConfigInitial extends ActivationConfigState {}
class ActivationConfigLoading extends ActivationConfigState { ActivationConfigLoading(this.assetId); final AssetId assetId; }
class ActivationConfigAwaitingUser extends ActivationConfigState {
  ActivationConfigAwaitingUser(this.assetId, this.fields, this.remainingSeconds);
  final AssetId assetId; final List<ConfigFieldSpec> fields; final int remainingSeconds;
}
class ActivationConfigSaving extends ActivationConfigState { ActivationConfigSaving(this.assetId); final AssetId assetId; }
class ActivationConfigReady extends ActivationConfigState { ActivationConfigReady(this.assetId, this.config); final AssetId assetId; final ActivationUserConfig config; }
class ActivationConfigTimeout extends ActivationConfigState { ActivationConfigTimeout(this.assetId); final AssetId assetId; }
class ActivationConfigFailure extends ActivationConfigState { ActivationConfigFailure(this.assetId, this.error); final AssetId assetId; final Object error; }
```

### 2.5 Activation builder and factory

```dart
class ActivationParamsFactory {
  ActivationParams create({
    required AssetId assetId,
    required BaseActivationParams base,
    ActivationUserConfig? userConfig,
  }) {
    switch (assetId.activationProtocol) {
      case ActivationProtocol.zhtlc:
        final cfg = userConfig as ZhtlcActivationUserConfig?;
        return ZhtlcActivationParams(
          assetId: assetId,
          protocol: ActivationProtocol.zhtlc,
          base: base,
          zcashParamsPath: cfg?.zcashParamsPath,
          scanBlocksPerIteration: cfg?.scanBlocksPerIteration ?? 1000,
          scanIntervalMs: cfg?.scanIntervalMs ?? 0,
        );
      case ActivationProtocol.utxo:
        return UtxoActivationParams(assetId: assetId, protocol: ActivationProtocol.utxo, base: base);
      case ActivationProtocol.eth:
        return EthActivationParams(...);
    }
  }
}
```

### 2.6 JSON utilities usage

- Use `convertToJsonMap`, `deepMerge`, and `valueOrNull` from `json_type_utils.dart` to:
  - sanitize maps before encoding,
  - safely merge base and protocol-specific params,
  - validate and parse incoming JSON.

---

## 3) SDK Integration

### 3.1 `KomodoDefiSdk` API

```dart
enum TimeoutPolicy { fail, useDefaults }

extension AssetIdActivation on AssetId {
  ActivationProtocol get activationProtocol { /* map from coin metadata */ }
  List<ConfigFieldSpec> get configurationFields {
    switch (activationProtocol) {
      case ActivationProtocol.zhtlc:
        return [
          ConfigFieldSpec(id: 'zcash_params_path', label: 'Zcash Params Path', type: ConfigFieldType.path, required: true, defaultValue: null),
          ConfigFieldSpec(id: 'scan_blocks_per_iteration', label: 'Blocks per iteration', type: ConfigFieldType.number, required: false, defaultValue: 1000),
          ConfigFieldSpec(id: 'scan_interval_ms', label: 'Scan interval (ms)', type: ConfigFieldType.number, required: false, defaultValue: 0),
        ];
      default:
        return const [];
    }
  }
}

class KomodoDefiSdk {
  KomodoDefiSdk({required this.configRepository, required this.encoders});

  final ActivationConfigRepository configRepository;
  final Map<ActivationProtocol, KdfRpcParamsEncoder> encoders;

  Future<ActivationParams> resolveActivationParams(
    AssetId assetId, {
    ActivationUserConfig? override,
    Duration timeout = const Duration(seconds: 60),
    TimeoutPolicy timeoutPolicy = TimeoutPolicy.fail,
  }) async {
    final stored = override ?? await configRepository.load(assetId);
    final config = stored ?? await _requestConfigWithTimeout(assetId, timeout, timeoutPolicy);

    final base = BaseActivationParams();
    final params = ActivationParamsFactory().create(
      assetId: assetId,
      base: base,
      userConfig: config,
    );
    return params;
  }

  Future<ActivationUserConfig?> _requestConfigWithTimeout(
    AssetId assetId,
    Duration timeout,
    TimeoutPolicy policy,
  ) async {
    // Wire up to BLoC/UI; if not available or times out, honor policy
    // For plan brevity: return null to trigger policy handling
    return null;
  }
}
```

### 3.2 Example usage (Flutter)

```dart
final sdk = KomodoDefiSdk(
  configRepository: SharedPreferencesActivationConfigRepository(),
  encoders: {
    ActivationProtocol.zhtlc: ZhtlcRpcParamsEncoder(),
    ActivationProtocol.utxo: UtxoRpcParamsEncoder(),
    ActivationProtocol.eth: EthRpcParamsEncoder(),
  },
);

final assetId = AssetId.parse('KMD');
final params = await sdk.resolveActivationParams(assetId);
final rpcParams = params.toRpcParams(sdk.encoders[assetId.activationProtocol]!);
// Pass rpcParams to KDF activation call
```

### 3.3 Example usage (programmatic config injection)

```dart
final zhtlcConfig = ZhtlcActivationUserConfig(
  zcashParamsPath: '/path/to/zcash-params',
  scanBlocksPerIteration: 2000,
  scanIntervalMs: 0,
);

await repo.save(assetId, zhtlcConfig);
final params = await sdk.resolveActivationParams(assetId);
```

---

## 4) Migration Strategy (no backward compatibility required)

1. Create new canonical models

   - Introduce `BaseActivationParams`, protocol-specific `ActivationParams` (ZHTLC/UTXO/ETH), and `KdfRpcParamsEncoder`.
   - Keep old classes side-by-side temporarily.

2. Extract ZHTLC-specific fields from base

   - Remove `zcashParamsPath`, `scanBlocksPerIteration`, `scanIntervalMs` from base.
   - Add them to `ZhtlcActivationParams` only.

3. Implement encoders

   - `UtxoRpcParamsEncoder`: convert `priv_key_policy` to PascalCase string; add `max_connected: 1`.
   - `ZhtlcRpcParamsEncoder`: pass through canonical keys; ensure JSON sanitation.
   - `EthRpcParamsEncoder`: pass canonical object policy unchanged.

4. Introduce user configuration layer

   - `ActivationUserConfig` (freezed) and `ActivationConfigRepository`.
   - Default repository based on `shared_preferences` and in-memory fallback.

5. Add BLoC for configuration request

   - Implement events/states, 60s timeout behavior, and UI scaffolding example.

6. Integrate with `KomodoDefiSdk`

   - Add `resolveActivationParams` and wire encoder lookup by protocol.
   - Use `AssetId` extension to surface `configurationFields` to UI.

7. Replace usages

   - Update activation flows and strategies (e.g., ZHTLC/Tendermint strategies) to use new params and encoders.

8. Testing

   - Unit tests for:
     - `toCanonicalJson()` per protocol
     - Encoder outputs vs KDF API expectations
     - Repository save/load roundtrip
     - BLoC timeout and submission paths

9. Documentation and examples

   - Update README and examples to show configuring ZHTLC.
   - Document `AssetId` extension methods.

10. Cleanup

- Remove old `ActivationParams` fields and deprecated constructors.
- Update `CHANGELOG.md` with breaking changes and follow Conventional Commits.

---

## 5) Notes on JSON utilities

- Always sanitize before RPC: `convertToJsonMap(canonical)`.
- Merge protocol overlays using `deepMerge` from `JsonMapDeepMerge`.
- Use `valueOrNull` and `tryParse` helpers when reading configuration.

---

## 6) Commit and package hygiene

- Use Conventional Commits for all changes (e.g., `feat(rpc-activation): add ZHTLC encoder and config repo`).
- Add analyzer/linter coverage to enforce `freezed` and serialization contracts.
- Ensure code generation (`build_runner`) scripts are updated in package READMEs.

---

## 7) Deliverables Checklist

- Base + protocol-specific `ActivationParams` (freezed)
- `KdfRpcParamsEncoder` implementations for UTXO, ZHTLC, ETH
- `ActivationParamsFactory` and builder wiring
- `ActivationUserConfig` models (ZHTLC required fields)
- `ActivationConfigRepository` with default impl
- BLoC: events/states with 60s timeout
- `KomodoDefiSdk.resolveActivationParams` and `AssetId` extension
- Unit tests and example usage
