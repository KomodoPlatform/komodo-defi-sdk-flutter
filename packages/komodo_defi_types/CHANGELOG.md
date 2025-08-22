## 0.3.0+2

> Note: This release has breaking changes.

 - **REFACTOR**(tx history): Fix misrepresented fees field.
 - **REFACTOR**(types): Restructure type packages.
 - **PERF**: migrate packages to Dart workspace".
 - **PERF**: migrate packages to Dart workspace.
 - **FIX**(debugging): Avoid unnecessary exceptions.
 - **FIX**(deps): resolve deps error.
 - **FIX**(wasm-ops): fix example app login by improving JS call error handling (#185).
 - **FIX**(ui): resolve stale asset balance widget.
 - **FIX**(types): export missing RPC types.
 - **FIX**(activation): Fix eth activation parsing exception.
 - **FIX**(withdraw): revert temporary IBC channel type changes (#136).
 - **FIX**: SIA support.
 - **FIX**(pubkey-strategy): use new PrivateKeyPolicy constructors for checks (#97).
 - **FIX**(activation): eth PrivateKeyPolicy enum breaking changes (#96).
 - **FIX**: pub submission errors.
 - **FIX**: Add pubkey property needed for GUI.
 - **FIX**(trezor,activation): add PrivateKeyPolicy to AuthOptions (#75).
 - **FIX**: Fix breaking dependency upgrades.
 - **FIX**(fee-info): update tendermint, erc20, and qrc20 `fee_details` response format (#60).
 - **FIX**(rpc-password-generator): update password validation to match KDF password policy (#58).
 - **FIX**(withdrawal-manager): use legacy RPCs for tendermint withdrawals (#57).
 - **FIX**: breaking tendermint config changes and build transformer not using branch-specific content URL for non-master branches (#55).
 - **FIX**(native-auth-ops): remove exceptions from logs in KDF restart function (#45).
 - **FIX**(types): Fix Sub-class naming.
 - **FIX**(bug): Fix JSON list parsing.
 - **FIX**(local-exe-ops): local executable startup and registration (#33).
 - **FIX**(example): Fix registration form regression.
 - **FIX**(transaction-storage): transaction streaming errors and hanging due to storage error (#28).
 - **FIX**(types): Make types index private.
 - **FIX**(example): encrypted seed import (#16).
 - **FEAT**(sdk): add trezor support via RPC and SDK wrappers (#77).
 - **FEAT**(auth): Implement new exceptions for update password RPC.
 - **FEAT**(signing): Add message signing prefix to models.
 - **FEAT**(auth): poll trezor connection status and sign out when disconnected (#126).
 - **FEAT**(KDF): Make provision for HD mode signing.
 - **FEAT**(market-data): add support for multiple market data providers (#145).
 - **FEAT**: enhance balance and market data management in SDK.
 - **FEAT**(types): add new models and utility classes for reactive data handling.
 - **FEAT**(dev): Install `melos`.
 - **FEAT**(sdk): Balance manager WIP.
 - **FEAT**(rpc): trading-related RPCs/types (#191).
 - **FEAT**(withdrawals): Implement HD withdrawals.
 - **FEAT**: add configurable seed node system with remote fetching (#85).
 - **FEAT**(hd): HD withdrawal supporting widgets and (WIP) multi-instance example.
 - **FEAT**(seed): update seed node format (#87).
 - **FEAT**: custom token import (#22).
 - **FEAT**(pubkey): add streamed new address API with Trezor confirmations (#123).
 - **FEAT**(sdk): Implement remaining SDK withdrawal functionality.
 - **FEAT**(types): Iterate on withdrawal-related types.
 - **FEAT**(withdraw): add ibc source channel parameter (#63).
 - **FEAT**(ui): add helper constructors for AssetLogo from legacy ticker and AssetId (#109).
 - **FEAT**: offline private key export (#160).
 - **FEAT**(ui): adjust error display layout for narrow screens (#114).
 - **FEAT**(asset): add message signing support flag (#105).
 - **FEAT**(HD): Implement GUI utility for asset status.
 - **FEAT**(auth): allow weak password in auth options (#54).
 - **FEAT**(fees): integrate fee management (#152).
 - **BUG**(import): Fix incorrect encrypted seed parsing.
 - **BUG**: fix missing pubkey equality operators.
 - **BUG**(auth): Fix registration failing on Windows and Windows web builds  (#34).
 - **BREAKING** **FEAT**(sdk): Multi-SDK instance support.
 - **BREAKING** **FEAT**: add Flutter Web WASM support with OPFS interop extensions (#176).

## 0.3.0+0

- chore: add LICENSE, repository; add characters dep; loosen flutter bound
