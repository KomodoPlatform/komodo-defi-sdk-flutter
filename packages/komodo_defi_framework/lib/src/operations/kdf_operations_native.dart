import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_framework/src/native/komodo_defi_framework_bindings_generated.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_local_executable.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

typedef NativeLogCallback = ffi.Void Function(ffi.Pointer<ffi.Char>);

IKdfOperations createLocalKdfOperations({
  required void Function(String) logCallback,
  required LocalConfig config,
}) {
  try {
    return KdfOperationsNativeLibrary.create(
      logCallback: logCallback,
      config: config,
    );
  } catch (e) {
    final executable = KdfOperationsLocalExecutable.create(
      logCallback: logCallback,
      config: config,
    );

    // TODO: Refactor or consider a different approach that allows us to
    // determine if the executable is available before returning it using the
    // async `isAvailable` method.
    // scheduleMicrotask(() async {
    //   if (!await executable.isAvailable(config)) {
    //     throw Exception(
    //       'No valid KDF operations found. KdfOperationsLocalExecutable was '
    //       'returned but was not available.',
    //     );
    //   }
    // });

    return executable;
  }
}

class KdfOperationsNativeLibrary implements IKdfOperations {
  @override
  factory KdfOperationsNativeLibrary.create({
    required void Function(String)? logCallback,
    required LocalConfig config,
  }) {
    final nativeLogCallback = ffi.NativeCallable<NativeLogCallback>.listener(
      (ffi.Pointer<ffi.Char> messagePtr) {
        try {
          final message = utf8.decode(
            messagePtr
                .cast<ffi.Uint8>()
                .asTypedList(messagePtr[0].bitLength)
                .toList(),
            allowMalformed: true,
          );
          if (message.isNotEmpty) {
            (logCallback ?? print).call(message);
          } else {
            (logCallback ?? print).call(message);
          }
        } catch (e) {
          (logCallback ?? print).call('Failed to decode log message: $e');
        }
      },
    );

    return KdfOperationsNativeLibrary._(
      KomodoDefiFrameworkBindings(_library),
      nativeLogCallback,
      config,
      logCallback ?? print,
    );
  }

  KdfOperationsNativeLibrary._(
    this._bindings,
    this._logCallback,
    this._config,
    this._log,
  );

  void Function(String) _log;
  final KomodoDefiFrameworkBindings _bindings;
  final ffi.NativeCallable<NativeLogCallback> _logCallback;
  LocalConfig _config;

  @override
  String operationsName = 'Local Native Library';

  @override
  Future<bool> isAvailable(IKdfHostConfig hostConfig) async {
    // Check if the native dynamic library is available on the device.
    try {
      final dylib = _library;
      assert(
        dylib.providesSymbol('mm2_main'),
        'Symbol mm2_main not found in library',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<KdfStartupResult> kdfMain(JsonMap startParams, {int? logLevel}) async {
    final startParamsPtr =
        startParams.toJsonString().toNativeUtf8().cast<ffi.Char>();
    // TODO: Implement log level

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
  Future<MainStatus> kdfMainStatus() async {
    final status = _bindings.mm2_main_status();
    return MainStatus.fromDefaultInt(status);
  }

  @override
  Future<StopStatus> kdfStop() async {
    final result = await compute(_kdfStopIsolate, null);
    return StopStatus.fromDefaultInt(result);
  }

  @override
  Future<bool> isRunning() async =>
      (await kdfMainStatus()) == MainStatus.rpcIsUp;

  final Uri _url = Uri.parse('http://localhost:7783');
  final Client _client = Client();

  @override
  Future<Map<String, dynamic>> mm2Rpc(Map<String, dynamic> request) async {
    _log('mm2 config: ${_config.toJson()}');
    _log('mm2Rpc request (pre-process): $request');
    request['userpass'] = _config.rpcPassword;
    final response = await _client.post(
      _url,
      body: json.encode(request),
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<void> validateSetup() async {
    try {
      _bindings.mm2_main_status();
    } catch (e) {
      throw Exception('Failed to validate KDF setup: $e');
    }
  }

  @override
  Future<String?> version() async {
    try {
      final response = await mm2Rpc({'method': 'version'});
      return response['result'] as String?;
    } on Exception catch (e) {
      _log('Error getting KDF version: $e');
      return null;
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
    final logCallback =
        ffi.Pointer<ffi.NativeFunction<NativeLogCallback>>.fromAddress(
      params.logCallbackAddress,
    );
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

  void dispose() {
    _logCallback.close(); // Ensure the NativeCallable is properly closed
  }
}

class _KdfMainParams {
  _KdfMainParams(
    this.startParamsPtrAddress,
    this.logCallbackAddress,
  );
  final int startParamsPtrAddress;
  final int logCallbackAddress;
}

ffi.DynamicLibrary _loadLibrary() {
  final paths = _getLibraryPaths();
  for (final path in paths) {
    try {
      final lib = path == 'PROCESS'
          ? ffi.DynamicLibrary.process()
          : path == 'EXECUTABLE'
              ? ffi.DynamicLibrary.executable()
              : ffi.DynamicLibrary.open(path);
      if (lib.providesSymbol('mm2_main')) {
        print('Loaded library at path: $path');
        return lib;
      }
    } catch (_) {
      // Continue to the next path if this one fails
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
    return ['libkdflib.dylib'];
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

ffi.DynamicLibrary get _library => _loadLibrary();
