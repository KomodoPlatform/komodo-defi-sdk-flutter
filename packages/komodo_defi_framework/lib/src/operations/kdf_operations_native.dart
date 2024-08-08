import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:komodo_defi_framework/src/extensions/map_extension.dart';
import 'package:komodo_defi_framework/src/native/komodo_defi_framework_bindings_generated.dart';
import 'package:komodo_defi_framework/src/startup_config_manager.dart';

import '../logger/logger.dart';
import 'kdf_operations_interface.dart';

ILogger? _logger; // Declare logger as a nullable global variable

IKdfOperations createKdfOperations({
  required ILogger logger,
  required IConfigManager configManager,
}) {
  _logger = logger;
  return KdfOperationsNativeLibrary.create(
    logger: logger,
    configManager: configManager,
  );
}

class KdfOperationsNativeLibrary implements IKdfOperations {
  KdfOperationsNativeLibrary._(
    this._configManager,
    this._bindings,
    this._logCallback,
  );

  final IConfigManager _configManager;
  final KomodoDefiFrameworkBindings _bindings;
  final ffi.NativeCallable<ffi.Void Function(ffi.Pointer<ffi.Char>)>
      _logCallback;

  @override
  factory KdfOperationsNativeLibrary.create({
    required ILogger logger,
    required IConfigManager configManager,
  }) {
    return KdfOperationsNativeLibrary._(
      configManager,
      KomodoDefiFrameworkBindings(_library),
      ffi.NativeCallable<ffi.Void Function(ffi.Pointer<ffi.Char>)>.listener(
        logCallback,
      ),
    );
  }

  @override
  Future<KdfStartupResult> kdfMain(String passphrase) async {
    final startParams =
        await _configManager.generateStartParamsFromDefault(passphrase);
    final startParamsPtr =
        startParams.toJsonString().toNativeUtf8().cast<ffi.Char>();

    try {
      final result = await compute(
        _kdfMainIsolate,
        _KdfMainParams(
          startParamsPtr.address,
          _logCallback.nativeFunction.address,
        ),
      );
      return KdfStartupResult.fromDefaultInt(result);
    } finally {
      calloc.free(startParamsPtr);
    }
  }

  @override
  MainStatus kdfMainStatus() {
    final status = _bindings.mm2_main_status();
    return MainStatus.fromDefaultInt(status);
  }

  @override
  Future<StopStatus> kdfStop() async {
    final result = await compute(_kdfStopIsolate, null);
    return StopStatus.fromDefaultInt(result);
  }

  @override
  bool isRunning() => kdfMainStatus() == MainStatus.rpcIsUp;

  // TODO: Remote RPC calls as a mixin? E.g. for localhost native calls and
  // for remote server calls.
  final Uri _url = Uri.parse('http://localhost:7783');
  final Client _client = Client();

  @override
  Future<JsonMap> mm2Rpc(JsonMap request) async {
    final response = await _client.post(
      _url,
      body: json.encode(request),
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(response.body);
  }

  @override
  Future<void> validateSetup() async {
    try {
      _bindings.mm2_main_status();
    } catch (e) {
      throw Exception('Failed to validate KDF setup: $e');
    }
  }

  static int _kdfMainIsolate(_KdfMainParams params) {
    final dylib = _library;
    assert(
      dylib.providesSymbol('mm2_main'),
      'Symbol mm2_main not found in library',
    );
    final bindings = KomodoDefiFrameworkBindings(dylib);
    final startParamsPtr =
        ffi.Pointer<ffi.Char>.fromAddress(params.startParamsPtrAddress);
    final logCallback = ffi.Pointer<
        ffi.NativeFunction<
            ffi.Void Function(
              ffi.Pointer<ffi.Char>,
            )>>.fromAddress(params.logCallbackAddress);
    return bindings.mm2_main(startParamsPtr, logCallback);
  }

  static int _kdfStopIsolate(_) {
    final dylib = _library;
    assert(
      dylib.providesSymbol('mm2_stop'),
      'Symbol mm2_stop not found in library',
    );
    final bindings = KomodoDefiFrameworkBindings(dylib);
    return bindings.mm2_stop();
  }
}

String _extractValidString(ffi.Pointer<ffi.Char> ptr, int errorOffset) {
  // Create a copy of the data to ensure it's not modified or freed
  final bytes = ptr.cast<ffi.Uint8>().asTypedList(errorOffset).toList();
  return utf8.decode(bytes, allowMalformed: true);
}

// Define the logCallback function as a top-level function
void logCallback(ffi.Pointer<ffi.Char> messagePtr) {
  String? message;
  try {
    // First, try to decode the entire string
    message = messagePtr.cast<Utf8>().toDartString();
  } on FormatException catch (e) {
    if (e.offset != null) {
      message = _extractValidString(messagePtr, e.offset!);
    } else {
      rethrow;
    }
  }

  _logger?.log(message);
}

class _KdfMainParams {
  final int startParamsPtrAddress;
  final int logCallbackAddress;

  _KdfMainParams(
    this.startParamsPtrAddress,
    this.logCallbackAddress,
  );
}

ffi.DynamicLibrary _loadLibrary() {
  List<String> paths = _getLibraryPaths();
  for (String path in paths) {
    try {
      final lib = path == 'PROCESS'
          ? ffi.DynamicLibrary.process()
          : path == 'EXECUTABLE'
              ? ffi.DynamicLibrary.executable()
              : ffi.DynamicLibrary.open(path);
      if (lib.providesSymbol('mm2_main')) {
        _logger?.log('Loaded library at path: $path');
        return lib;
      }
    } catch (_) {
      // Continue to the next path if this one fails
      // _logger?.log('Failed to load library at path: $path');
    }
  }
  throw UnsupportedError('No valid library path found');
}

List<String> _getLibraryPaths() {
  if (Platform.isMacOS) {
    return [
      'kdf',
      'mm2',
      'Frameworks/libkdflib.a',
      'komodo_defi_framework/Frameworks/libkdflib.a',
      'libkdflib.dylib',
      'libkdflib.a',
      'PROCESS',
      'EXECUTABLE',
    ];
  } else if (Platform.isIOS) {
    return ['libkdflib.dylib']; // Assuming similar library name for iOS
  } else if (Platform.isAndroid) {
    return ['libkdflib.so', 'libkdflib_static.so'];
  } else if (Platform.isWindows) {
    return ['kdflib.dll', 'kdflib_static.dll'];
  } else if (Platform.isLinux) {
    return ['libkdflib.so', 'libkdflib_static.so'];
  } else {
    throw UnsupportedError('Unsupported platform or KDF library not found');
  }
}

// Memoized static getter for the library
final ffi.DynamicLibrary _library = _loadLibrary();