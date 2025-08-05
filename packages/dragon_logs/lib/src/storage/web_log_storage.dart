// Direct export pattern with conditional imports
// This provides a clean, unified API while using platform-specific implementations
export 'web_log_storage_stub.dart'
    if (dart.library.js_interop) 'web_log_storage_web.dart';
