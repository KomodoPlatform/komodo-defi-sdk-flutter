## Plan: Automated pub.dev publishing from GitHub Actions (monorepo with Melos)

This document outlines the end-to-end plan to implement automated publishing of packages in this monorepo to pub.dev using GitHub Actions with OIDC, following guidance in `docs/automated-publishing.md` and `docs/melos-gh-action.md`.

The plan covers:

- Tag-based publishing via GitHub Actions OIDC (no long-lived secrets)
- Monorepo-friendly versioning, tagging and release flows via Melos
- Per-package tag patterns and publish triggers
- Security hardening (environments, tag protection, reviewers)
- Exact repository changes (files to add/update), example workflow YAML, and rollout steps

References:

- `docs/automated-publishing.md` (pub.dev + GitHub OIDC requirements)
- `docs/melos-gh-action.md` (Melos Action for versioning, tagging, and orchestrating releases)

### Goals and constraints

- Publish each public package in `packages/` to pub.dev automatically when a corresponding tag is pushed.
- Avoid long-lived secrets by using OIDC (GitHub-issued ID token) per `docs/automated-publishing.md`.
- Fit monorepo workflows using Melos for versioning and for creating per-package tags.
- Harden publishing with GitHub Environments and tag protection.

### Target packages

Publishable packages are those in `packages/` that are intended for pub.dev (i.e., they do not have `publish_to: "none"`). Examples include:

- `packages/dragon_charts_flutter`
- `packages/dragon_logs`
- `packages/komodo_cex_market_data`
- `packages/komodo_coin_updates`
- `packages/komodo_coins`
- `packages/komodo_defi_framework`
- `packages/komodo_defi_local_auth`
- `packages/komodo_defi_rpc_methods`
- `packages/komodo_defi_sdk`
- `packages/komodo_defi_types`
- `packages/komodo_ui`
- `packages/komodo_symbol_converter`
- `packages/komodo_wallet_cli`
- `packages/komodo_wallet_build_transformer`

Note: Final set = all packages in `packages/**` intended for publishing.

## High-level approach

1. For each publishable package on pub.dev, enable “Automated publishing from GitHub Actions” (Admin tab) and configure a unique tag pattern per package.
2. In the repo, use Melos to version and generate tags per package.
3. A single GitHub Actions workflow listens for pushed tags matching `<package>-vX.Y.Z`, resolves package path, and publishes only that package using OIDC.
4. Secure publishing via a dedicated GitHub Environment (for example: `pub.dev`) with required reviewers; add tag protection for `<package>-v*` patterns.

## Tag naming strategy (monorepo)

- Per pub.dev guidance in `docs/automated-publishing.md`, multi-package repos need a package-specific tag pattern.
- Recommended pattern: `<package>-v{{version}}` (example: `komodo_defi_sdk-v1.2.3`).
- Regex used in workflows: `<package>-v[0-9]+\.[0-9]+\.[0-9]+` (extend if using build/RC metadata).

Why: The package name is encoded in the tag so the publish workflow can route to the correct directory.

## Changes to repository

### 1) Add a package map for publish routing

Create a mapping used by the publish workflow to translate `<package>` (from tag) to its directory.

Add `tool/pub/package_map.json` (example content):

```json
{
  "dragon_charts_flutter": "packages/dragon_charts_flutter",
  "dragon_logs": "packages/dragon_logs",
  "komodo_cex_market_data": "packages/komodo_cex_market_data",
  "komodo_coin_updates": "packages/komodo_coin_updates",
  "komodo_coins": "packages/komodo_coins",
  "komodo_defi_framework": "packages/komodo_defi_framework",
  "komodo_defi_local_auth": "packages/komodo_defi_local_auth",
  "komodo_defi_rpc_methods": "packages/komodo_defi_rpc_methods",
  "komodo_defi_sdk": "packages/komodo_defi_sdk",
  "komodo_defi_types": "packages/komodo_defi_types",
  "komodo_ui": "packages/komodo_ui",
  "komodo_symbol_converter": "packages/komodo_symbol_converter",
  "komodo_wallet_cli": "packages/komodo_wallet_cli",
  "komodo_wallet_build_transformer": "packages/komodo_wallet_build_transformer"
}
```

Notes:

- Include only packages intended to publish to pub.dev.
- Keep this file as single source of truth for the publish workflow.

### 2) Add GitHub Actions workflows

Add the following workflows in `.github/workflows/`:

2.1) Versioning + release PR (manual or on merges) using Melos Action

- Purpose: run `melos version`, update `CHANGELOG.md` and `pubspec.yaml` across changed packages, optionally dry-run publish checks, and open a release PR.

Create `.github/workflows/release-prepare.yml`:

```yaml
name: Release - Prepare (Melos)

on:
  workflow_dispatch:
    inputs:
      prerelease:
        description: "Version as prerelease"
        type: boolean
        required: false
        default: false

jobs:
  prepare:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - uses: bluefireteam/melos-action@v3
        with:
          run-bootstrap: true
          run-versioning: true
          run-versioning-prerelease: ${{ inputs.prerelease }}
          publish-dry-run: true
          include-private: false
          create-pr: true
          tag: false
```

2.2) Tag creation after release PR merge

- Purpose: when the release PR is merged to the default branch, create tags for each changed package in the format `<package>-vX.Y.Z`.

Create `.github/workflows/release-tag.yml`:

```yaml
name: Release - Create Tags (Melos)

on:
  push:
    branches:
      - main
  workflow_dispatch: {}

jobs:
  tag:
    if: github.event_name == 'workflow_dispatch' || (github.event_name == 'push' && contains(github.event.head_commit.message, 'chore(release)'))
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - uses: bluefireteam/melos-action@v3
        with:
          run-bootstrap: true
          run-versioning: false
          tag: true
```

Notes:

- The condition on commit message assumes Melos commit message contains `chore(release)`; adjust if different.
- You can instead trigger this via `workflow_dispatch` when you explicitly want to cut tags.

  2.3) Publish on tag push (OIDC, single workflow for all packages)

- Purpose: publish a single package when its tag `<package>-vX.Y.Z` is pushed.
- Uses custom steps so we can dynamically resolve the package directory from the tag. (Reusable workflows via `jobs.<id>.uses` cannot consume step outputs in the same job.)

Create `.github/workflows/publish-on-tag.yml`:

```yaml
name: Publish to pub.dev on tag

on:
  push:
    tags:
      - "*-v[0-9]+.[0-9]+.[0-9]+"

jobs:
  publish:
    permissions:
      id-token: write # required for OIDC
      contents: read
    environment: pub.dev
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1

      - name: Extract package from tag
        id: tag
        run: |
          REF_NAME="${GITHUB_REF_NAME}"
          PKG="${REF_NAME%%-v*}"
          echo "package=${PKG}" >> "$GITHUB_OUTPUT"

      - name: Resolve package path
        id: resolve
        run: |
          sudo apt-get update && sudo apt-get install -y jq
          PKG="${{ steps.tag.outputs.package }}"
          PATH_JSON=$(cat tool/pub/package_map.json)
          MATCH=$(echo "$PATH_JSON" | jq -r --arg k "$PKG" '.[$k] // empty')
          if [ -z "$MATCH" ]; then
            echo "Package $PKG not found in tool/pub/package_map.json" >&2
            exit 1
          fi
          echo "dir=$MATCH" >> "$GITHUB_OUTPUT"

      - name: Publish package
        run: |
          cd "${{ steps.resolve.outputs.dir }}"
          dart pub get
          dart pub publish --force
```

Notes:

- Ensure the GitHub Environment named `pub.dev` exists (see Security section) and is required in pub.dev automated publishing settings.
- The tag pattern is generic for all packages; the workflow resolves the correct directory via `tool/pub/package_map.json`.
- If you prefer using the reusable workflow `dart-lang/setup-dart/.github/workflows/publish.yml@v1`, create per-package workflows with static `working-directory` (see Alternative section) since `working-directory` cannot be set from step outputs in the same job.

### 3) Melos configuration

Ensure Melos is configured at the repo root (file `melos.yaml`). Confirm `packages:` glob includes `packages/**`. Optionally configure versioning/tagging defaults. Example (illustrative):

```yaml
name: komodo_monorepo
packages:
  - packages/**

command:
  version:
    message: "chore(release): publish"
    # Note: actual tag format is handled by Melos Action; keep message consistent
```

If you prefer Melos itself to create specific tag formats, consult Melos docs and ensure the workflow that creates tags aligns with the `<package>-v{{version}}` pattern configured on pub.dev.

### 4) Per-package pub.dev configuration

For each publishable package, on pub.dev (Admin tab):

- Enable automated publishing from GitHub Actions.
- Set repository to your GitHub repository (for example: `owner/repo`).
- Set tag pattern to `<package>-v{{version}}` (example: `komodo_defi_sdk-v{{version}}`).
- If using GitHub Environments, mark the required environment name (for example: `pub.dev`).

### 5) Security hardening (recommended)

Per `docs/automated-publishing.md`:

- Create GitHub Environment `pub.dev` and require it in the publish job (`environment: pub.dev`). Add required reviewers to gate runs.
- Add tag protection rules for patterns like `*-v*` so only authorized users or automation can create matching tags.
- Pin actions to tags/SHAs (already using `@v1`, `@v2`, `@v3`, etc.), keep them updated.
- Prefer checking in generated code needed for publishing to avoid build-time supply-chain risks.

### 6) Package hygiene checklist

Before enabling automated publish for each package:

- `pubspec.yaml` has a valid `version`, correct `environment` constraints, proper `homepage`, `repository`, `issue_tracker`, and a `LICENSE` file.
- No `publish_to: "none"` for public packages.
- `CHANGELOG.md` exists and is updated by versioning flow.
- All generated code committed (or ensure the custom publish step generates required files).
- `dart pub publish --dry-run` passes locally (and in CI via the prepare workflow).

## Rollout plan (step-by-step)

1. Decide the list of packages to publish (audit `packages/**`). Remove or keep `publish_to: "none"` accordingly.
2. Create `tool/pub/package_map.json` listing `<packageName>` → directory (only for publishable packages).
3. Add the three workflows under `.github/workflows/` described above.
4. Ensure Melos is configured (`melos.yaml`), and that CI machines have Flutter/Dart as needed.
5. In GitHub:
   - Create environment `pub.dev`, add required reviewers.
   - Add tag protection for `*-v*`.
6. On pub.dev for each package:
   - Enable automated publishing from GitHub Actions.
   - Set repository to `owner/repo`.
   - Set tag pattern to `<package>-v{{version}}`.
   - Require environment `pub.dev` (must match workflow).
7. Dry run:
   - Trigger `Release - Prepare (Melos)` via `workflow_dispatch` (optionally with `prerelease=true`).
   - Review and merge the release PR.
   - Trigger `Release - Create Tags (Melos)` (auto on merge if configured, or manual dispatch).
   - Verify tags are created correctly.
8. Observe `Publish to pub.dev on tag` runs for each tag. Confirm success on pub.dev (audit log links back to GH run).

## Operational notes

- Fallback/manual publish: you can still run `dart pub publish --force` locally if needed.
- If a tag is created incorrectly, delete the tag and re-create with the correct format.
- If build-time code generation is required for a package, switch the publish step to the "Option B" custom steps and add generation before `dart pub publish`.

## Alternative: per-package publish workflows (static mapping)

If you prefer not to keep `tool/pub/package_map.json`, create one workflow per package with static `working-directory` and a tag filter specific to that package, e.g. for `komodo_defi_sdk`:

```yaml
name: Publish komodo_defi_sdk

on:
  push:
    tags:
      - "komodo_defi_sdk-v[0-9]+.[0-9]+.[0-9]+"

jobs:
  publish:
    permissions:
      id-token: write
    environment: pub.dev
    uses: dart-lang/setup-dart/.github/workflows/publish.yml@v1
    with:
      working-directory: packages/komodo_defi_sdk
```

Pros: no mapping file; Cons: N workflows to maintain.

## Testing and verification

- Prepare workflow should pass `publish --dry-run` across changed packages.
- After tags are created, verify the publish workflow triggers only once per tag and runs in the correct directory.
- Confirm pub.dev audit log shows the GitHub Action run link and that versions match `pubspec.yaml`.

## Summary of repo changes to make (no code behavior change beyond CI)

- Add `tool/pub/package_map.json`.
- Add three workflows under `.github/workflows/`:
  - `release-prepare.yml` (Melos versioning + PR)
  - `release-tag.yml` (create `<package>-vX.Y.Z` tags)
  - `publish-on-tag.yml` (publish via OIDC on tag)
- Verify/update `melos.yaml` as needed.
- Update pub.dev Admin settings per package with repository + tag pattern, and require `pub.dev` environment.

---

This plan adheres to pub.dev automated publishing requirements and leverages Melos for a monorepo-friendly release flow. See `docs/automated-publishing.md` and `docs/melos-gh-action.md` for underlying rationale and options.
