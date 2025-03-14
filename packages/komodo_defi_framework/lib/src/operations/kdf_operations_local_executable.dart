import 'dart:async';
import 'dart:io';

import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_framework/src/exceptions/kdf_exception.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_remote.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class KdfOperationsLocalExecutable implements IKdfOperations {
  KdfOperationsLocalExecutable._(
    this._logCallback,
    this._config,
    this._kdfRemote, {
    Duration startupTimeout = const Duration(seconds: 30),
  }) : _startupTimeout = startupTimeout;

  factory KdfOperationsLocalExecutable.create({
    required void Function(String) logCallback,
    required LocalConfig config,
    Duration startupTimeout = const Duration(seconds: 30),
  }) {
    return KdfOperationsLocalExecutable._(
      logCallback,
      config,
      KdfOperationsRemote.create(
        logCallback: logCallback,
        rpcUrl: _url,
        userpass: config.rpcPassword,
      ),
      startupTimeout: startupTimeout,
    );
  }

  final void Function(String) _logCallback;
  // ignore: unused_field
  final LocalConfig _config;

  Process? _process;
  final Duration _startupTimeout;
  late StreamSubscription<List<int>>? stdoutSub;
  late StreamSubscription<List<int>>? stderrSub;

  final KdfOperationsRemote _kdfRemote;

  @override
  String get operationsName => 'Local Executable';

  @override
  Future<bool> isAvailable(IKdfHostConfig hostConfig) async {
    try {
      return await _getExecutable() != null;
    } catch (e) {
      _logCallback('Error checking availability: $e');
      return false;
    }
  }

  static final Uri _url = Uri.parse('http://127.0.0.1:7783');

  Future<Process> _startKdf(JsonMap params) async {
    final executablePath = (await _getExecutable())?.absolute.path;
    if (executablePath == null) {
      throw KdfException(
        'KDF executable not found in any of the expected locations. '
        'Please ensure KDF is properly installed or included in your application bundle.',
        type: KdfExceptionType.executableNotFound,
      );
    }

    // specifically needed on linux, which currently resets the file permissions
    // on every build.
    await _tryGrantExecutablePermissions(executablePath);

    if (!params.containsKey('coins')) {
      throw ArgumentError.value(
        params['coins'],
        'params',
        'Missing coins list.',
      );
    }

    Directory? coinsTempDir;
    try {
      final coinsList = params.value<List<JsonMap>>('coins');
      final sensitiveArgs = JsonMap.of(params)..remove('coins');

      // Store the coins list in a temp file to avoid command line argument and
      // environment variable value size limits (varies from 4-128 KB).
      // Pass the config directly to the executable as an argument.
      final tempDir = await getTemporaryDirectory();
      coinsTempDir = await tempDir.createTemp('mm_coins_');
      final coinsConfigFile = File(p.join(coinsTempDir.path, 'kdf_coins.json'));
      await coinsConfigFile.writeAsString(
        coinsList.toJsonString(),
        flush: true,
      );

      final environment = Map<String, String>.of(Platform.environment)
        ..['MM_COINS_PATH'] = coinsConfigFile.path;

      final newProcess = await Process.start(
        executablePath,
        [sensitiveArgs.toJsonString()],
        environment: environment,
        runInShell: true,
      );

      _logCallback('Launched executable: $executablePath');
      _attachProcessListeners(newProcess, coinsTempDir);

      return newProcess;
    } catch (e, stackTrace) {
      // Clean up the temporary directory if an error occurs. Exceptions can
      // be thrown before process listeners are attached, so ensure that the
      // dangling resources are cleaned up.
      await coinsTempDir?.delete(recursive: true).catchError((Object error) {
        _logCallback('Failed to delete temporary directory: $error');
        return Directory(
            ''); // Return a dummy directory to satisfy the return type
      });
      if (e is KdfException) {
        rethrow;
      }
      throw KdfException(
        'Failed to start KDF: ${e.toString()}',
        type: KdfExceptionType.startupFailed,
        stackTrace: stackTrace,
      );
    }
  }

  /// check if the executable has executable permissions on linux/macos
  /// if not, run chmod +x on it
  Future<void> _tryGrantExecutablePermissions(String executablePath) async {
    if (Platform.isLinux || Platform.isMacOS) {
      final result = await Process.run('chmod', ['+x', executablePath]);
      if (result.exitCode != 0) {
        throw KdfException(
          'Failed to make executable executable: ${result.stderr}',
          type: KdfExceptionType.permissionError,
          stackTrace: StackTrace.current,
        );
      }
    }
  }

  void _attachProcessListeners(Process newProcess, Directory tempDir) {
    stdoutSub = newProcess.stdout.listen((event) {
      _logCallback('[INFO]: ${String.fromCharCodes(event)}');
    });

    stderrSub = newProcess.stderr.listen((event) {
      _logCallback('[ERROR]: ${String.fromCharCodes(event)}');
    });

    newProcess.exitCode
        .then((exitCode) async => _cleanUpOnProcessExit(exitCode, tempDir))
        .ignore();
  }

  Future<void> _cleanUpOnProcessExit(int exitCode, Directory tempDir) async {
    try {
      _logCallback('KDF process exited with code: $exitCode');
      await stdoutSub?.cancel();
      await stderrSub?.cancel();

      await tempDir.delete(recursive: true);
      _logCallback('Temporary directory deleted successfully.');
    } catch (error) {
      _logCallback('Failed to delete temporary directory: $error');
    } finally {
      _process = null;
    }
  }

  String linuxBuildKdfPath({bool isDebugBuild = false, bool isLib = false}) =>
      p.join(
        Directory.current.path,
        'build',
        'linux',
        'x64',
        isDebugBuild ? 'debug' : 'release',
        'bundle',
        'lib',
        isLib ? 'libkdf.so' : 'kdf',
      );

  String windowsBuildKdfPath({bool isDebugBuild = false, bool isLib = false}) =>
      p.join(
        Directory.current.path,
        'build',
        'windows',
        'x64',
        'runner',
        isDebugBuild ? 'Debug' : 'Release',
        isLib ? 'kdf.dll' : 'kdf.exe',
      );

  String macosBuildKdfPath({bool isDebugBuild = false, bool isLib = false}) =>
      p.join(
        Directory.current.path,
        'build',
        'macos',
        'Build',
        'Products',
        isDebugBuild ? 'Debug' : 'Release',
        'komodo_defi_framework',
        'kdf_resources.bundle',
        'Contents',
        'Resources',
        isLib ? 'libkdf.dylib' : 'kdf',
      );

  Future<File?> _getExecutable() async {
    final macosKdfResourcePath = p.joinAll([
      p.dirname(p.dirname(Platform.resolvedExecutable)),
      'Frameworks',
      'komodo_defi_framework.framework',
      'Resources',
      'kdf_resources.bundle',
      'Contents',
      'Resources',
      'kdf',
    ]);

    final files = [
      '/usr/local/bin/kdf',
      '/usr/bin/kdf',
      p.join(Directory.current.path, 'kdf'),
      p.join(Directory.current.path, 'kdf.exe'),
      p.join(Directory.current.path, 'lib/kdf'),
      p.join(Directory.current.path, 'lib/kdf.exe'),
      macosKdfResourcePath,

      // Paths specifically for running/debugging client applications like
      // Komodo Wallet. Looks inside of the build directory for the KDF
      // executable, since it won't be in the same directory as the IDE
      // execution context (usually the root directory of the project).
      windowsBuildKdfPath(isDebugBuild: true),
      windowsBuildKdfPath(),
      linuxBuildKdfPath(isDebugBuild: true),
      linuxBuildKdfPath(),
      macosBuildKdfPath(isDebugBuild: true),
      macosBuildKdfPath(),
    ].map((path) => File(p.normalize(path))).toList();

    for (final file in files) {
      if (file.existsSync()) {
        _logCallback('Found executable: ${file.path}');
        return file.absolute;
      }
    }

    _logCallback(
      'Executable not found in paths: ${files.map((e) => e.absolute.path).join('\n')}. '
      'If you are using the KDF Flutter SDK, open an issue on GitHub.',
    );

    return null;
  }

  @override
  Future<KdfStartupResult> kdfMain(JsonMap params, {int? logLevel}) async {
    if (_process != null && _process!.pid != 0) {
      return KdfStartupResult.alreadyRunning;
    }

    _logCallback('Starting KDF with parameters (Coins Removed): ${{
      ...params,
      'coins': <JsonMap>[],
      'log_level': logLevel ?? 3,
    }.censored().toJsonString()}');

    _process = await _startKdf(params);

    final timer = Stopwatch()..start();

    int? exitCode;
    unawaited(_process?.exitCode.then((code) => exitCode = code));

    while (timer.elapsed < _startupTimeout) {
      if (await isRunning()) {
        break;
      }

      if (exitCode != null) {
        throw KdfException(
          'Error starting KDF: Exit code: $exitCode',
          type: KdfExceptionType.startupFailed,
          details: {'exitCode': exitCode},
          stackTrace: StackTrace.current,
        );
      }

      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    if (await isRunning()) {
      return KdfStartupResult.ok;
    }

    throw KdfException(
      'Error starting KDF: Process not running after timeout.',
      type: KdfExceptionType.startupFailed,
      details: {'timeout': _startupTimeout.inSeconds},
      stackTrace: StackTrace.current,
    );
  }

  @override
  Future<MainStatus> kdfMainStatus() async {
    if (_process != null && _process!.pid > 0 && await _kdfRemote.isRunning()) {
      return MainStatus.rpcIsUp;
    }
    return MainStatus.notRunning;
  }

  @override
  Future<StopStatus> kdfStop() async {
    if (_process == null) {
      return StopStatus.notRunning;
    }

    final stopResult = await _kdfRemote.kdfStop();
    _process!.kill();

    return stopResult;
  }

  @override
  Future<bool> isRunning() async {
    return (await kdfMainStatus()) == MainStatus.rpcIsUp;
  }

  @override
  Future<String?> version() => _kdfRemote.version();

  @override
  Future<Map<String, dynamic>> mm2Rpc(Map<String, dynamic> request) =>
      _kdfRemote.mm2Rpc(request);

  @override
  Future<void> validateSetup() async {
    if (_process == null) {
      throw KdfException(
        'KDF executable is not running. Please start it first.',
        type: KdfExceptionType.notRunning,
      );
    }
  }

  void dispose() {
    _process?.kill();
    stdoutSub?.cancel();
    stderrSub?.cancel();
    _logCallback('Process killed and resources cleaned up.');
  }
}
