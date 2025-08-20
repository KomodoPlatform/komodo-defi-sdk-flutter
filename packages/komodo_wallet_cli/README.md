# Komodo Wallet CLI

Developer CLI wrapper for Komodo wallet tooling. Currently forwards to the build transformer to simplify local usage.

## Install

Run directly via Dart:

```sh
dart run packages/komodo_wallet_cli/bin/komodo_wallet_cli.dart --help
```

## Commands

- `get` – Run build transformer steps

Example:

```sh
dart run packages/komodo_wallet_cli/bin/komodo_wallet_cli.dart get \
  --all \
  --artifact_output_package=komodo_defi_framework \
  --config_output_path=app_build/build_config.json \
  -i /tmp/input_marker.txt -o /tmp/output_marker.txt
```

Use `-v/--verbose` for additional output.

## License

MIT