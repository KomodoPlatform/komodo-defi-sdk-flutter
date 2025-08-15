# Run GitHub Actions locally with act

This guide shows how to run the Flutter test workflow locally using act, filter to a single package, and re-run failed jobs on GitHub.

## Prerequisites

- Docker (required by act)
  - Windows: [Install Docker Desktop on Windows](https://docs.docker.com/desktop/install/windows-install/)
  - macOS: [Install Docker Desktop on Mac](https://docs.docker.com/desktop/install/mac-install/)
  - Ubuntu: [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

- act
  - macOS (Homebrew):

    ```bash
    brew install act
    ```

  - Other platforms: download a binary from [nektos/act releases](https://github.com/nektos/act/releases) and put it on your PATH
  - Repo/docs: [nektos/act](https://github.com/nektos/act)

- (Optional) GitHub CLI (to re-run failed jobs on GitHub):
  - Install: [GitHub CLI](https://cli.github.com/)

## Notes for Apple Silicon (M-series) Macs

- act may need to run containers as amd64:
  - Add: `--container-architecture linux/amd64`
  - Map `ubuntu-latest` to an image: `-P ubuntu-latest=catthehacker/ubuntu:act-latest`

## Common commands

- List jobs in this workflow:

  ```bash
  act -l -W .github/workflows/flutter-tests.yml
  ```

- Run the test job for all packages (verbose):

  ```bash
  act -j test --verbose \
    -W .github/workflows/flutter-tests.yml \
    -P ubuntu-latest=catthehacker/ubuntu:act-latest \
    --container-architecture linux/amd64
  ```

- Run only a single package (e.g., packages/komodo_coin_updates) via workflow_dispatch input (verbose):

  ```bash
  act workflow_dispatch -j test --verbose \
    -W .github/workflows/flutter-tests.yml \
    -P ubuntu-latest=catthehacker/ubuntu:act-latest \
    --container-architecture linux/amd64 \
    --input package=komodo_coin_updates
  ```

- Filter packages by regex (matches paths under `packages/*`):

  ```bash
  act workflow_dispatch -j test --verbose \
    -W .github/workflows/flutter-tests.yml \
    -P ubuntu-latest=catthehacker/ubuntu:act-latest \
    --container-architecture linux/amd64 \
    --input package_regex='komodo_coin_updates'
  ```

## Re-run only failed jobs on GitHub

- GitHub UI: Actions → select the failed run → Re-run jobs → Re-run failed jobs
- GitHub CLI:

  ```bash
  gh run rerun <run-id> --failed
  ```

## Verify installation

- Docker:

  ```bash
  docker --version
  docker run hello-world
  ```

- act:

  ```bash
  act --version
  ```
