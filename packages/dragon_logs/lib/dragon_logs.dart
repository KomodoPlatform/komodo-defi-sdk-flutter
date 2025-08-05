/// A Flutter-compatible logging package with support for Web Wasm.
/// 
/// This package provides flexible logging capabilities across all Flutter platforms,
/// with special support for Web Wasm compatibility by avoiding deprecated 
/// dart:html and file_system_access_api dependencies.
library dragon_logs;

export 'src/log_level.dart';
export 'src/log_entry.dart';
export 'src/logger.dart';
export 'src/log_writer.dart';
export 'src/storage/log_storage.dart';
export 'src/storage/memory_log_storage.dart';
export 'src/storage/file_log_storage.dart';
export 'src/storage/web_log_storage.dart';
export 'src/formatters/log_formatter.dart';
export 'src/formatters/simple_log_formatter.dart';
export 'src/formatters/json_log_formatter.dart';
export 'src/dragon_logs_config.dart';