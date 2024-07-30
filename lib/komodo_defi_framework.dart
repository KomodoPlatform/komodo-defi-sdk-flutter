import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';
import 'package:komodo_defi_framework/komodo_defi_framework_bindings_generated.dart';

import 'src/coins_config_manager.dart';

typedef LoggerCallback = void Function(String logMessage);

class KomodoDefiFramework {
  final IKdfOperations _kdfOperations;
  final ILogger _logger;

  KomodoDefiFramework._({
    required IKdfOperations kdfOperations,
    required ILogger logger,
  })  : _kdfOperations = kdfOperations,
        _logger = logger;

  factory KomodoDefiFramework({void Function(String)? logger}) {
    final dynamicLibrary = ffi.DynamicLibrary.process();
    // final dynamicLibrary =  ffi.DynamicLibrary.open('komodo_defi_framework/komodo_defi_framework');

    final loggerInstance = Logger(externalLogger: logger);
    final configManager = CoinsConfigManager();
    final kdfOperations =
        KdfOperations(dynamicLibrary, loggerInstance, configManager);

    return KomodoDefiFramework._(
      kdfOperations: kdfOperations,
      logger: loggerInstance,
    );
  }

  Future<KdfStarupResult> kdfMain() => _kdfOperations.kdfMain();
  MainStatus kdfMainStatus() => _kdfOperations.kdfMainStatus();
  bool isRunning() => _kdfOperations.isRunning();
  Stream<String> get logStream => _logger.logStream;

  Future<StopStatus> kdfStop() => _kdfOperations.kdfStop();

  Future<void> dispose() async {
    if (_kdfOperations.isRunning()) {
      await _kdfOperations.kdfStop();
    }
    _logger.dispose();
  }
}

// Updated enums
enum MainStatus { notRunning, noContext, noRpc, rpcIsUp }

enum KdfStarupResult {
  ok,
  alreadyRunning,
  confIsNull,
  confNotUtf8,
  cantThread,
  unknown
}

enum StopStatus { ok, notRunning, errorStopping, stoppingAlready }

// Interfaces
abstract class IKdfOperations {
  Future<KdfStarupResult> kdfMain();
  MainStatus kdfMainStatus();
  Future<StopStatus> kdfStop();
  bool isRunning();
}

abstract class ILogger {
  void log(String message);
  Stream<String> get logStream;
  ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>>
      get logNative;
  void dispose();
}

class Logger implements ILogger {
  final StreamController<String> _logStreamController =
      StreamController<String>.broadcast();
  final void Function(String)? _externalLogger;
  late final ffi.NativeCallable<ffi.Void Function(ffi.Pointer<ffi.Char>)>
      _nativeCallable;
  late final StreamSubscription<String> _logSubscription;

  Logger({void Function(String)? externalLogger})
      : _externalLogger = externalLogger {
    _nativeCallable =
        ffi.NativeCallable<ffi.Void Function(ffi.Pointer<ffi.Char>)>.listener(
      _logCallback,
    );
    _logSubscription = _logStreamController.stream.listen(_handleLog);
  }

  void _handleLog(String message) {
    (_externalLogger ?? print).call(message);
  }

  @override
  void log(String message) {
    _logStreamController.add(message);
  }

  @override
  Stream<String> get logStream => _logStreamController.stream;

  @override
  ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>>
      get logNative => _nativeCallable.nativeFunction;

  void _logCallback(ffi.Pointer<ffi.Char> linePtr) {
    try {
      // First, try to decode the entire string
      final line = linePtr.cast<Utf8>().toDartString();
      log(line);
    } catch (e) {
      if (e is FormatException && e.offset != null) {
        // If there's a specific offset where the error occurred
        try {
          final validPart = _extractValidString(linePtr, e.offset!);
          final errorMsg =
              'UTF-8 decoding error at offset ${e.offset}. Valid part of the message: "$validPart"';
          log(errorMsg);
        } catch (innerError) {
          // If even extracting the valid part fails
          log('Error extracting valid part of the message: $innerError');
        }
      } else {
        // For any other type of error
        log('Error processing log message: $e');
      }
    }
  }

  String _extractValidString(ffi.Pointer<ffi.Char> ptr, int errorOffset) {
    // Create a copy of the data to ensure it's not modified or freed
    final bytes = ptr.cast<ffi.Uint8>().asTypedList(errorOffset).toList();
    return utf8.decode(bytes, allowMalformed: true);
  }

  @override
  void dispose() {
    _logSubscription.cancel();
    _logStreamController.close();
    _nativeCallable.close();
  }
}

class KdfOperations implements IKdfOperations {
  final ffi.DynamicLibrary _dynamicLibrary;
  final ILogger _logger;
  final IConfigManager _configManager;

  KdfOperations(this._dynamicLibrary, this._logger, this._configManager);

  late final _bindings = KomodoDefiFrameworkBindings(_dynamicLibrary);

  @override
  Future<KdfStarupResult> kdfMain() async {
    final startParams = await _configManager.generateStartParamsFromDefault();
    final startParamsPtr = startParams.toNativeUtf8().cast<ffi.Char>();

    try {
      final result = _bindings.mm2_main(startParamsPtr, _logger.logNative);
      return _intToKdfError(result);
    } finally {
      calloc.free(startParamsPtr);
    }
  }

  @override
  MainStatus kdfMainStatus() {
    final status = _bindings.mm2_main_status();
    return _intToMainStatus(status);
  }

  @override
  bool isRunning() => kdfMainStatus() == MainStatus.rpcIsUp;

  @override
  Future<StopStatus> kdfStop() async {
    final stopWatch = Stopwatch()..start();
    final result = _bindings.mm2_stop();
    _logger.log('KDF stop result: $result');

    final stopStatus = _intToStopStatus(result);
    if (stopStatus == StopStatus.ok) {
      bool isShutdown = false;
      final shutdownCompleter = Completer<void>();

      // Listen for the shutdown message
      final subscription = _logger.logStream.listen((message) {
        if (message.contains("MmCtx") && message.contains("has been dropped")) {
          shutdownCompleter.complete();
        }
      });

      // Poll for status change
      final timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (kdfMainStatus() == MainStatus.notRunning) {
          shutdownCompleter.complete();
        }
      });

      // Wait for shutdown or timeout
      try {
        await shutdownCompleter.future.timeout(const Duration(seconds: 30));
        isShutdown = true;
        timer.cancel();
        stopWatch.stop();
      } on TimeoutException {
        _logger.log('KDF shutdown timed out after 30 seconds');
      } finally {
        subscription.cancel();
      }

      _logger
          .log('KDF shutdown completed in ${stopWatch.elapsedMilliseconds}ms');
      _logger.log('Final KDF status: ${kdfMainStatus()}');

      return isShutdown ? StopStatus.ok : StopStatus.errorStopping;
    }

    return stopStatus;
  }
}

KdfStarupResult _intToKdfError(int errorCode) {
  switch (errorCode) {
    case 0:
      return KdfStarupResult.ok;
    case 1:
      return KdfStarupResult.alreadyRunning;
    case 2:
      return KdfStarupResult.confIsNull;
    case 3:
      return KdfStarupResult.confNotUtf8;
    case 5:
      return KdfStarupResult.cantThread;
    default:
      return KdfStarupResult.unknown;
  }
}

MainStatus _intToMainStatus(int statusCode) {
  switch (statusCode) {
    case 0:
      return MainStatus.notRunning;
    case 1:
      return MainStatus.noContext;
    case 2:
      return MainStatus.noRpc;
    case 3:
      return MainStatus.rpcIsUp;
    default:
      throw ArgumentError('Unknown MainStatus code: $statusCode');
  }
}

StopStatus _intToStopStatus(int statusCode) {
  switch (statusCode) {
    case 0:
      return StopStatus.ok;
    case 1:
      return StopStatus.notRunning;
    case 2:
      return StopStatus.errorStopping;
    case 3:
      return StopStatus.stoppingAlready;
    default:
      throw ArgumentError('Unknown StopStatus code: $statusCode');
  }
}

void main() async {
  final framework = KomodoDefiFramework(
    logger: (String logMessage) => print('KDF Message: $logMessage'),
  );

  print('Starting KDF...');
  final result = await framework.kdfMain();
  print('KDF start result: $result');

  while (!framework.isRunning()) {
    await Future.delayed(const Duration(seconds: 1));
  }

  print('Stopping KDF...');
  final stopResult = await framework.kdfStop();
  print('KDF stop result: $stopResult');

  await framework.dispose();
}
