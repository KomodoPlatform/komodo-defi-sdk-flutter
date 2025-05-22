import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../controller/remote_kdf_controller.dart';

/// Base command runner for the remote CLI.
class KdfRemoteCommandRunner extends CommandRunner<int> {
  KdfRemoteCommandRunner()
    : super('kdf_remote', 'Manage remote KDF instances') {
    addCommand(_StartCommand());
    addCommand(_StopCommand());
    addCommand(_StatusCommand());
  }
}

class _BaseCommand extends Command<int> {
  RemoteKdfController createController() {
    final host = argResults?['host'] as String? ?? 'localhost';
    final port = int.tryParse(argResults?['port'] as String? ?? '8000') ?? 8000;
    return RemoteKdfController(RemoteConnectionConfig(host: host, port: port));
  }

  @override
  String get description => '';
}

class _StartCommand extends _BaseCommand {
  _StartCommand() {
    argParser
      ..addOption('host', defaultsTo: 'localhost')
      ..addOption('port', defaultsTo: '8000');
  }

  @override
  String get name => 'start';

  @override
  Future<int> run() async {
    final controller = createController();
    await controller.startKdf();
    print('KDF start requested');
    return 0;
  }
}

class _StopCommand extends _BaseCommand {
  _StopCommand() {
    argParser
      ..addOption('host', defaultsTo: 'localhost')
      ..addOption('port', defaultsTo: '8000');
  }

  @override
  String get name => 'stop';

  @override
  Future<int> run() async {
    final controller = createController();
    await controller.stopKdf();
    print('KDF stop requested');
    return 0;
  }
}

class _StatusCommand extends _BaseCommand {
  _StatusCommand() {
    argParser
      ..addOption('host', defaultsTo: 'localhost')
      ..addOption('port', defaultsTo: '8000');
  }

  @override
  String get name => 'status';

  @override
  Future<int> run() async {
    final controller = createController();
    final status = await controller.status();
    print('Running: ${status.isRunning}');
    return 0;
  }
}
