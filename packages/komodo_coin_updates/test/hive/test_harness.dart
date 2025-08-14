import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:komodo_coin_updates/hive/hive_registrar.g.dart';

/// Lightweight Hive test harness inspired by hive_ce's integration tests.
class HiveTestEnv {
  Directory? _tempDir;
  static bool _adaptersRegistered = false;

  String get path => _tempDir!.path;

  Future<void> _initHive() async {
    Hive.init(_tempDir!.path);
    if (!_adaptersRegistered) {
      Hive.registerAdapters();
      _adaptersRegistered = true;
    }
  }

  Future<void> setup() async {
    _tempDir ??= await Directory.systemTemp.createTemp('hive_test_');
    await _initHive();
  }

  Future<void> restart() async {
    await Hive.close();
    await _initHive();
  }

  Future<void> dispose() async {
    try {
      await Hive.close();
    } catch (_) {}
    try {
      if (_tempDir != null && _tempDir!.existsSync()) {
        await _tempDir!.delete(recursive: true);
      }
    } catch (_) {}
    _tempDir = null;
  }
}
