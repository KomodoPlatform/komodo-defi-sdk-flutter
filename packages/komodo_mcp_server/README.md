# Komodo MCP Server

An MCP (Model Context Protocol) server that exposes Komodo DeFi SDK functionality over stdio.

## Run

```
# Ensure Dart/Flutter SDKs are available in your environment
# Then from repo root:
melos bootstrap  # if melos is available
# Or just install deps inside the package using Flutter if needed
# flutter pub get -C packages/komodo_mcp_server
# Run
dart run packages/komodo_mcp_server/bin/komodo_mcp_server.dart
```

The server speaks MCP over stdio using Content-Length framing.

## MCP Client Configuration

Example client block:

```json
{
  "mcpServers": {
    "komodo": {
      "command": "dart",
      "args": [
        "run",
        "packages/komodo_mcp_server/bin/komodo_mcp_server.dart"
      ]
    }
  }
}
```

## Tools

- `sdk.call`: Call a raw KDF/mm2 RPC method. Input:
  - `method`: string
  - `params`: object (merged into the RPC request)
- `sdk.version`: Returns the KDF version string via RPC `version`.

## Notes

- Initialization boots the SDK with default local configuration.
- Extend `tools/list` and `tools/call` to expose higher-level SDK managers as needed.