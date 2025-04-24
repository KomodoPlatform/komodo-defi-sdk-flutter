# Komodo Wallet CLI

A comprehensive command-line utility for managing Komodo SDK projects, build processes, and development workflows.

## Installation

You can install the CLI package globally to use it from anywhere:

```bash
# From the komodo_defi_framework repository
dart pub global activate --source=path packages/komodo_wallet_cli

# To upgrade the CLI package, first delete the cached package:
# macOS/Linux:
flutter clean && rm -rf ~/.pub-cache/global_packages/komodo_wallet_cli
# Windows:
# flutter clean && rd /s /q %USERPROFILE%\.pub-cache\global_packages\komodo_wallet_cli

# Then re-activate the package
dart pub global activate --source=path packages/komodo_wallet_cli
```

## Available Commands

### 1. Upgrade SDK Packages

The `upgrade-sdk` command helps you recursively upgrade all SDK packages across your projects. It automatically finds all pubspec.yaml files in your workspace and updates SDK dependencies to their latest versions.

```bash
# As a globally installed command:
upgrade-sdk [options]

# Using the CLI directly:
dart run packages/komodo_wallet_cli/bin/komodo_wallet_cli.dart upgrade-sdk [options]

# Running the script directly:
dart run packages/komodo_wallet_cli/bin/upgrade_sdk_packages.dart [options]
```

#### Options

- `--workspace-dir` - Root workspace directory (default: current directory)
- `--verbose`, `-v` - Enable verbose output
- `--dry-run` - Print changes without applying them
- `--help`, `-h` - Show usage information

#### Examples

```bash
# Upgrade all SDK packages in the current workspace
upgrade-sdk

# See what would be upgraded without making changes
upgrade-sdk --dry-run

# Upgrade packages in a specific directory with verbose output
upgrade-sdk --workspace-dir=/path/to/project --verbose
```

### 2. Flutter Upgrade Nested

The `flutter-upgrade-nested` command recursively finds and upgrades Flutter projects in a directory tree. It identifies Flutter projects by their pubspec.yaml files and runs `flutter pub upgrade` on each one.

```bash
# As a globally installed command:
flutter-upgrade-nested [options]

# Using the CLI directly:
dart run packages/komodo_wallet_cli/bin/komodo_wallet_cli.dart flutter-upgrade-nested [options]

# Running the script directly:
dart run packages/komodo_wallet_cli/bin/flutter_upgrade_nested.dart [options]
```

#### Options

- `--directory`, `-d` - Specify the directory to search for Flutter projects (default: current directory)
- `--major-versions` - Allow upgrading to major versions (breaking changes)
- `--unlock-transitive` - Allow upgrading transitive dependencies
- `--help`, `-h` - Show usage information

#### Examples

```bash
# Regular upgrade in current directory
flutter-upgrade-nested

# Regular upgrade in specific directory
flutter-upgrade-nested -d /path/to/projects

# Allow major version upgrades
flutter-upgrade-nested --major-versions

# Combine multiple upgrade options
flutter-upgrade-nested --major-versions --unlock-transitive
```

### 3. Update API Config

The `update-api-config` command updates the KDF version in the build config. It fetches the latest commit for a specified branch, retrieves the URLs and checksums for binaries, and updates the build configuration accordingly.

```bash
# As a globally installed command:
update-api-config [options]

# Using the CLI directly:
dart run packages/komodo_wallet_cli/bin/komodo_wallet_cli.dart update-api-config [options]

# Running the script directly:
dart run packages/komodo_wallet_cli/bin/update_api_config.dart [options]
```

#### Options

- `--branch` - The branch to use for fetching commits (e.g., 'dev', 'main')
- `--config` - Path to the build config JSON file to update
- `--output-dir` - Directory for temporary downloads
- `--source` - Source to use for downloads ('github' or 'mirror')
- `--verbose` - Enable verbose output
- `--help` - Show usage information

#### Examples

```bash
# Update KDF version using 'dev' branch and mirror source
update-api-config \
  --branch dev \
  --config packages/komodo_defi_framework/app_build/build_config.json \
  --output-dir temp_downloads \
  --source mirror \
  --verbose

# Update KDF version using 'main' branch and GitHub source
update-api-config \
  --branch main \
  --config packages/komodo_defi_framework/app_build/build_config.json \
  --output-dir temp_downloads \
  --source github
```

## SDK Packages Covered

The upgrade-sdk command targets these packages:

- komodo_defi_framework
- komodo_cex_market_data
- komodo_coin_updates
- komodo_defi_local_auth
- komodo_coins
- komodo_defi_types
- komodo_defi_sdk
- komodo_defi_rpc_methods
- komodo_defi_workers
- komodo_symbol_converter
- komodo_ui
- komodo_wallet_build_transformer

## Using Multiple Commands Together

You can combine these commands for common development workflows:

```bash
# Roll KDF version and update all dependent packages
update-api-config --branch dev --config packages/komodo_defi_framework/app_build/build_config.json --output-dir temp_downloads --source mirror
upgrade-sdk

# Complete upgrade of all projects in a workspace
flutter-upgrade-nested --major-versions
upgrade-sdk
```

## Development

To add new commands to the CLI:

1. Create a new script in the `bin/` directory
2. Add it as an executable in `pubspec.yaml`
3. Integrate it with the main CLI interface in `komodo_wallet_cli.dart`
