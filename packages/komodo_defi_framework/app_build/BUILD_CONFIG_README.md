# Build Config Guide

This directory contains the artifact configuration used by `komodo_wallet_build_transformer` to fetch KDF binaries/WASM and coin assets at build time.

## Files

- `build_config.json` – canonical configuration used by the transformer
- `build_config.yaml` – reference YAML form (not currently consumed by the tool)

## Key fields (JSON)

- `api.api_commit_hash` – commit hash of the KDF artifacts to fetch
- `api.source_urls` – list of base URLs to download from (GitHub API, CDN)
- `api.platforms.*.matching_pattern` – regex to match artifact names per platform
- `api.platforms.*.valid_zip_sha256_checksums` – allow-list of artifact checksums
- `api.platforms.*.path` – destination relative to artifact output package
- `coins.bundled_coins_repo_commit` – commit of Komodo coins registry
- `coins.mapped_files` – mapping of output paths to source files in coins repo
- `coins.mapped_folders` – mapping of output dirs to repo folders (e.g. icons)

## Where artifacts are stored

Artifacts are downloaded into the package specified by the transformer flag:

```
--artifact_output_package=komodo_defi_framework
```

Paths in the config are relative to that package directory.

## Updating artifacts

1. Update `api_commit_hash` and (optionally) checksums
2. Run the build transformer (via Flutter asset transformers or CLI)
3. Commit the updated artifacts if your workflow requires vendoring

## Tips

- Set `GITHUB_API_PUBLIC_READONLY_TOKEN` to increase GitHub API rate limits
- Use `--concurrent` for faster downloads in development
- Override behavior per build via env `OVERRIDE_DEFI_API_DOWNLOAD=true|false`

## Troubleshooting

- Missing files: verify `config_output_path` points to this folder and the file exists
- Checksum mismatch: update checksums to match newly published artifacts
- Web CORS: ensure WASM bundle and bootstrap JS are present under `web/kdf/bin`
