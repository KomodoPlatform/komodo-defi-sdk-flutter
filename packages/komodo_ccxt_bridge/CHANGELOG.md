# 0.0.1

- feat: initial commit 🎉
- feat(serve): add KDF remote config flags: `--kdf-url`, `--kdf-pass`
- feat(serve): implement HTTP endpoints backed by KDF RPCs
  - GET `/health`
  - GET `/markets`
  - GET `/orderbook?base=...&rel=...`
  - GET `/balance?coin=...`
  - POST `/orders`
  - DELETE `/orders/<uuid>`
  - GET `/orders/open`
  - GET `/orders/<uuid>`
  - GET `/trades/my`
