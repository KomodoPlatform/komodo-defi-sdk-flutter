## Tech Debt Report: Activation and ZHTLC

### Context and scope

- New components introduced: `ActivationConfigService`, `HiveActivationConfigRepository`, `ZhtlcActivationStrategy`, `SharedActivationCoordinator`, wiring in `bootstrap.dart`, UI prompts in example.
- Primary concerns: activation orchestration, ZHTLC activation/config, persistence, concurrency, and UI flow.

### Design pattern alignment (good)

- Strategy: protocol-specific activation strategies (e.g., `ZhtlcActivationStrategy`) selected via `ActivationStrategyFactory`.
- Factory: `ActivationStrategyFactory` composes per-protocol activators.
- Repository: `ActivationConfigRepository` and `HiveActivationConfigRepository`.
- Mediator/Coordinator: `SharedActivationCoordinator` synchronizes activation across managers.
- Observer: activation progress streams, failed/pending streams.
- Mutex: `ActivationManager`’s `Mutex` for critical sections.

### Tech-debt inventory

- Architecture and flow

  - Primary/child grouping bug in `ActivationManager`

    - Risk: child asset may be treated as group primary, confusing strategy selection and completion bookkeeping.
    - Reference: `packages/komodo_defi_sdk/lib/src/activation/activation_manager.dart` (`_groupByPrimary`).
    - Refactoring: Ensure true primary resolution for group key and members.

  - Duplication of activation orchestration

    - Both `ActivationManager` and `SharedActivationCoordinator` track activation state and deduplication.
    - Refactoring: Make Coordinator the single entrypoint (Facade); slim `ActivationManager` to strategy runner.

  - Flutter-only dependency in SDK bootstrap
    - `Hive.initFlutter()` in SDK couples core to Flutter.
    - Refactoring: Inject `ActivationConfigRepository` via DI; provide Flutter Hive impl at app layer.

- API/serialization consistency

  - `priv_key_policy` serialization not centralized

    - Base emits PascalCase string; EVM needs JSON object.
    - Refactoring: Use `PrivKeyPolicySerializer` consistently in base or subclasses; add tests.

  - ZHTLC parameter extraction
    - `ZhtlcActivationParams` correctly owns `zcash_params_path` and scan tuning (good).

- Config, persistence, and UI flow

  - Service/UI coupling without a formal BLoC

    - Example pre-prompts and saves config; strategy also awaits service completer.
    - Refactoring: Introduce `ActivationConfigBloc`; UI uses descriptors; strategies pull via service only.

  - Activation settings descriptors unused in UI

    - Add dynamic form generation using `AssetId.activationSettings()`.

  - Repository granularity

    - Single map per wallet entry can cause coarse updates.
    - Consider per-asset keys or transactional update helper.

  - Zcash params path UX
    - Provide platform helpers or discovery to reduce user friction.

- Concurrency and timing

  - Coin availability backoff short and hard-coded

    - Make policy configurable; add metrics.

  - No public cancellation API
    - Add `cancelActivation(assetId)` on Coordinator; propagate.

- Naming and API

  - Legacy RPC method name for ZHTLC is acceptable but document it clearly.

- Code quality
  - `ActivationProgressDetails.toJson` optional-field serialization bug; fix with conditional inserts.
  - Outdated TODO in `ZhtlcActivationStrategy` re: sync mode; update.

### Recommendations

- Unify activation orchestration in `SharedActivationCoordinator`; treat it as Facade/Mediator.
- Fix `_groupByPrimary` to always use true primary; add tests.
- Normalize `priv_key_policy` serialization using `PrivKeyPolicySerializer`; add per-protocol tests.
- Decouple persistence from SDK; inject `ActivationConfigRepository` and remove direct `Hive.initFlutter()` from core.
- Implement `ActivationConfigBloc` and adopt `ActivationSettingDescriptor` in UI.
- Expose `cancelActivation(assetId)` and configurable coin-availability wait.
- Add unit/integration tests and structured logs around activation timing.

### Prioritized action plan

1. Correctness: fix `toJson`, fix grouping, update ZHTLC TODO.
2. Architecture: coordinator as single entrypoint; cancellation + wait policy.
3. Serialization: apply serializer; tests.
4. Config/Persistence: BLoC + descriptors; DI for repository.
5. Tests/Docs: coverage + documentation.

### Suggested conventional commits

- fix(types): correct ActivationProgressDetails.toJson optional fields
- fix(activation): ensure \_groupByPrimary uses true primary asset
- refactor(activation): centralize orchestration in SharedActivationCoordinator
- feat(activation): add cancelActivation and configurable availability wait
- refactor(rpc): use PrivKeyPolicySerializer across protocols; add tests
- feat(config): add ActivationConfigBloc and adopt ActivationSettingDescriptor in example UI
- refactor(sdk): inject ActivationConfigRepository via bootstrap; remove direct Hive.initFlutter dependency
- docs: update ZHTLC activation docs and RPC naming notes
- test(activation): add ZHTLC activation flow tests

### Acceptance criteria

- Single activation Facade with deduplication and coin-availability guard.
- Correct grouping semantics; passing tests.
- Consistent `priv_key_policy` serialization per protocol; tests pass.
- ZHTLC config via BLoC; UI built from descriptors.
- SDK no longer depends on Flutter for persistence wiring.
- Cancellation and availability wait are configurable and documented.
