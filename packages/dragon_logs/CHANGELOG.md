# Changelog

## 2.0.0

### Added

- **Flutter Web Wasm compatibility** by migrating from deprecated web APIs
- **Web storage using `package:web`** instead of `file_system_access_api`
- **Cross-platform storage backends**:
  - `WebLogStorage` using browser localStorage via `package:web`
  - `FileLogStorage` for mobile and desktop platforms using `path_provider`
  - `MemoryLogStorage` for in-memory temporary storage
- **Enhanced configuration system** with `DragonLogsConfig`
- **Multiple log formatters**: `SimpleLogFormatter` and `JsonLogFormatter`
- **Advanced log writers**: `BufferedLogWriter`, `MultiLogWriter`, `StorageLogWriter`
- **Platform detection utilities** for Wasm compatibility
- **Comprehensive test coverage** with cross-platform testing

### Changed

- **BREAKING**: Migrated from `dart:html` to `package:web` for Wasm compatibility
- **BREAKING**: Removed dependency on `file_system_access_api`
- **BREAKING**: Updated minimum Flutter version to 3.22.0 for Wasm support
- **BREAKING**: Updated minimum Dart SDK to 3.2.0
- Improved performance with async operations and buffered writing
- Enhanced error handling with graceful degradation

### Fixed

- Web platform compatibility issues with WebAssembly compilation
- Storage availability detection across different platforms
- Memory management with automatic log rotation

### Technical Details

- Uses `package:web` instead of deprecated `dart:html`
- Compatible with `dart:js_interop` requirements for Wasm
- Automatic platform detection using `dart.tool.dart2wasm` constant
- Graceful degradation when web APIs are unavailable

## 1.1.0

- Bump packages to latest versions.
- Apply new Dart format styling introduced in Dart `3.27`.

## 1.0.4

- Fix log message sorting bug. Thanks to @takenagain for their first contribution to this project.

## 1.0.2

- Bump `intl` dependency to latest version of `0.19.0`.

## 1.0.1

- Refactor to share more code with web and native platforms.
- Fix date parsing bug.
- Add public API to clear all logs.

Refactor to share more code between web and native platforms (focused mainly on file name and directory handling) and fix a bug where logs belonging to days with a single digit month or day could not be parsed.

## 1.0.0

- Stable release
- Tweak: Localisation initialisation no longer needs to be inialised before logs.

## 0.1.1-preview.1

- Memory improvement for log flushing.
- Bug fixes.

## 0.1.0-preview.1

- Bug fixes.

## 0.0.1-preview.1

- Initial preview version.
