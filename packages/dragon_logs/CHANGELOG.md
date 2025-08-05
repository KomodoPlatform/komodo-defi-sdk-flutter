# Changelog

All notable changes to the Dragon Logs package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Dragon Logs package
- Wasm-compatible logging system using `package:web`
- Multiple storage backends:
  - `WebLogStorage` for browser localStorage
  - `FileLogStorage` for mobile and desktop file systems
  - `MemoryLogStorage` for in-memory temporary storage
- Flexible log formatting:
  - `SimpleLogFormatter` for human-readable text output
  - `JsonLogFormatter` for structured JSON output
- Comprehensive logger functionality:
  - Multiple log levels (trace, debug, info, warn, error, fatal)
  - Structured logging with extra data
  - Error and stack trace support
- Cross-platform compatibility:
  - Android, iOS, Web (JS and Wasm), Windows, macOS, Linux
- Configuration system:
  - Global log level management
  - Platform-aware storage selection
  - Customizable writers and formatters
- Log writers:
  - `ConsoleLogWriter` for console output
  - `BufferedLogWriter` for batched operations
  - `MultiLogWriter` for multiple destinations
  - `StorageLogWriter` for persistent storage
- Comprehensive test coverage
- Example application demonstrating usage
- Complete documentation and API reference

### Features
- **Wasm Compatibility**: Designed specifically for Flutter Web Wasm support
- **Migration Path**: Easy migration from `file_system_access_api`
- **Platform Detection**: Automatic platform capability detection
- **Error Resilience**: Graceful degradation when storage is unavailable
- **Performance Optimized**: Async operations and batching support
- **Developer Friendly**: Rich debugging information and platform insights

### Technical Details
- Uses `package:web` instead of deprecated `dart:html`
- Avoids `file_system_access_api` for Wasm compatibility
- Implements modern Dart patterns with null safety
- Supports conditional compilation for platform-specific features
- Uses `dart:js_interop` compatible APIs for web functionality