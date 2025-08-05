import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart';

/// JavaScript async iterator result type
@JS()
@anonymous
extension type JSIteratorResult._(JSObject _) implements JSObject {
  external bool get done;
  external JSAny? get value;
}

/// JavaScript async iterator type
@JS()
@anonymous
extension type JSAsyncIterator._(JSObject _) implements JSObject {
  external JSPromise<JSIteratorResult> next();
}

/// Extensions for FileSystemDirectoryHandle to provide missing async iterator methods
/// that are available in the JavaScript File System API but not exposed in Flutter's web package.
@JS()
extension FileSystemDirectoryHandleExtension on FileSystemDirectoryHandle {
  /// Returns an async iterator for the values (handles) in this directory.
  /// Equivalent to calling `directoryHandle.values()` in JavaScript.
  external JSAsyncIterator values();

  /// Returns an async iterator for the keys (names) in this directory.
  /// Equivalent to calling `directoryHandle.keys()` in JavaScript.
  external JSAsyncIterator keys();

  /// Returns an async iterator for the entries (name-handle pairs) in this directory.
  /// Equivalent to calling `directoryHandle.entries()` in JavaScript.
  external JSAsyncIterator entries();
}

/// Helper extensions to convert JavaScript async iterators to Dart async iterables
extension JSAsyncIteratorExtension on JSAsyncIterator {
  /// Converts a JavaScript async iterator to a Dart Stream
  Stream<JSAny?> asStream() async* {
    while (true) {
      final result = await next().toDart;
      if (result.done) break;
      yield result.value;
    }
  }
}

/// Extension to provide async iteration capabilities for FileSystemDirectoryHandle values
extension FileSystemDirectoryHandleValuesIterable on FileSystemDirectoryHandle {
  /// Returns a Stream of FileSystemHandle objects for async iteration over directory contents
  Stream<FileSystemHandle> valuesStream() {
    return values().asStream().map((jsValue) => jsValue as FileSystemHandle);
  }

  /// Returns a Stream of file/directory names for async iteration over directory contents
  Stream<String> keysStream() {
    return keys().asStream().map((jsValue) => (jsValue as JSString).toDart);
  }

  /// Returns a Stream of [name, handle] pairs for async iteration over directory contents
  Stream<(String, FileSystemHandle)> entriesStream() {
    return entries().asStream().map((jsValue) {
      // The entries() iterator returns [name, handle] arrays
      // We need to use js_interop_unsafe to access array elements
      final jsObject = jsValue as JSObject;
      final name = (jsObject['0']! as JSString).toDart;
      final handle = jsObject['1']! as FileSystemHandle;
      return (name, handle);
    });
  }
}
