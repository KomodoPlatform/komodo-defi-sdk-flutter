import 'dart:async';
import 'dart:io';

import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_remote.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class KdfOperationsLocalExecutable implements IKdfOperations {
  KdfOperationsLocalExecutable._(
    this._logCallback,
    this._config,
    this._kdfRemote,
  );

  factory KdfOperationsLocalExecutable.create({
    required void Function(String) logCallback,
    required LocalConfig config,
  }) {
    return KdfOperationsLocalExecutable._(
      logCallback,
      config,
      KdfOperationsRemote.create(
        logCallback: logCallback,
        rpcUrl: _url,
        userpass: config.rpcPassword,
      ),
    );
  }

  final void Function(String) _logCallback;
  // ignore: unused_field
  final LocalConfig _config;

  Process? _process;
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

  Future<Process> _startKdf(List<String> args) async {
    final executablePath = (await _getExecutable())?.absolute.path;

    if (executablePath == null) {
      throw Exception('No executable found.');
    }

    try {
      // Store the config in a temp file to avoid command line argument and
      // environment variable value size limits (varies from 4-128 KB).
      final tempDir = await Directory.systemTemp.createTemp('mm_coins_');
      final configFile = File(p.join(tempDir.path, 'kdf_config.json'));
      await configFile.writeAsString(args.join());

      final environment = Map<String, String>.from(Platform.environment)
        ..['MM_CONF_PATH'] = configFile.path;

      final newProcess = await Process.start(
        executablePath,
        [],
        environment: environment,
        runInShell: true,
      );
      await newProcess.exitCode.then((_) async {
        await tempDir.delete(recursive: true);
      });

      _logCallback('Launched executable: $executablePath');
      _attachProcessListeners(newProcess);

      return newProcess;
    } catch (e) {
      throw Exception('Failed to start executable: $e');
    }
  }

  void _attachProcessListeners(Process newProcess) {
    stdoutSub = newProcess.stdout.listen((event) {
      _logCallback('[INFO]: ${String.fromCharCodes(event)}');
    });

    stderrSub = newProcess.stderr.listen((event) {
      _logCallback('[ERROR]: ${String.fromCharCodes(event)}');
    });

    newProcess.exitCode.then((exitCode) async {
      await stdoutSub?.cancel();
      await stderrSub?.cancel();
      _logCallback('Process exited with code: $exitCode');
    }).ignore();
  }

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

    final appSupportDir = await getApplicationSupportDirectory();
    final appSupportParentDir = Directory(p.dirname(appSupportDir.path));
    final appSupportGrandParentDir =
        Directory(p.dirname(appSupportParentDir.path));
    final homeDir = Platform.environment['HOME'] ?? '';

    final files = [
      '/usr/local/bin/kdf',
      '/usr/bin/kdf',
      '$homeDir/.local/bin/kdf',
      '$homeDir/bin/kdf',
      p.join(Directory.current.path, 'kdf'),
      p.join(Directory.current.path, 'kdf.exe'),
      p.join(Directory.current.path, 'lib/kdf'),
      p.join(Directory.current.path, 'lib/kdf.exe'),
      p.join(appSupportDir.path, 'kdf'),
      p.join(appSupportDir.path, 'kdf.exe'),
      p.join(appSupportParentDir.path, 'KomodoPlatform', 'kdf'),
      p.join(appSupportParentDir.path, 'KomodoPlatform', 'kdf.exe'),
      p.join(appSupportGrandParentDir.path, 'KomodoPlatform', 'kdf'),
      p.join(appSupportGrandParentDir.path, 'KomodoPlatform', 'kdf.exe'),
      macosKdfResourcePath,
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

    _process = await _startKdf([params.toJsonString()]);

    final timer = Stopwatch()..start();

    int? exitCode;
    unawaited(_process?.exitCode.then((code) => exitCode = code));

    while (timer.elapsed.inSeconds < 30) {
      if (await isRunning() || exitCode != null) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    if (exitCode != null && exitCode != 0) {
      throw Exception('Error starting KDF: Exit code: $exitCode');
    }

    if (await isRunning()) {
      return KdfStartupResult.ok;
    }

    throw Exception('Error starting KDF: Process not running.');
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
      throw Exception('Executable is not running. Please start it first.');
    }
  }

  void dispose() {
    _process?.kill();
    stdoutSub?.cancel();
    stderrSub?.cancel();
    _logCallback('Process killed and resources cleaned up.');
  }
}
