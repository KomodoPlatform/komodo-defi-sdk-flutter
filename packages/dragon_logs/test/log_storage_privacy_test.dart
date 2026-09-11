@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dragon_logs/dragon_logs.dart';
import 'package:dragon_logs/src/storage/file_log_storage.dart';
import 'package:dragon_logs/src/storage/queue_mixin.dart';
import 'package:dragon_logs/src/storage/storage_lifecycle.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:test/test.dart';

import 'mock_path_provider_platform.dart';

const _epoch = 'gleec_diagnostics_test_v1';
const _sentinel = 'SYNTHETIC_LEGACY_SECRET_DO_NOT_EXPORT';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  late Directory documents;
  late FileLogStorage storage;

  setUp(() async {
    documents = await Directory.systemTemp.createTemp('dragon-privacy-');
    storage = FileLogStorage.forDirectory(documents);
  });

  tearDown(() async {
    await storage.dispose();
    await DragonLogs.dispose();
    if (await documents.exists()) await documents.delete(recursive: true);
  });

  Future<void> init() =>
      storage.init(storageNamespace: _epoch, purgeLegacy: true);

  test(
    'purges arbitrary legacy files and cached exports before accepting records',
    () async {
      final legacy = await Directory(
        '${documents.path}/dragon_logs/log_export',
      ).create(recursive: true);
      await File('${legacy.path}/export.txt').writeAsString(_sentinel);
      await File(
        '${documents.path}/dragon_logs/not-a-date.bin',
      ).writeAsString(_sentinel);
      final wallet = await File(
        '${documents.path}/wallet.db',
      ).writeAsString('unrelated-wallet-data');

      final ready = init();
      final pendingWrite = storage.appendLog(
        DateTime.now(),
        '{"event":"ready"}',
      );
      await Future.wait([ready, pendingWrite]);
      expect(
        await Directory('${documents.path}/dragon_logs').exists(),
        isFalse,
      );
      expect(await wallet.readAsString(), 'unrelated-wallet-data');
      expect(await storage.exportLogsStream().join(), '{"event":"ready"}\n');
    },
  );

  test(
    'failed migration is closed to exports and writes, and retries successfully',
    () async {
      final legacy = await Directory('${documents.path}/dragon_logs').create();
      await File('${legacy.path}/old.log').writeAsString(_sentinel);
      final blockedLock = await Directory(
        '${documents.path}/.dragon_logs_storage.lock',
      ).create();
      await expectLater(
        init(),
        throwsA(isA<LogStorageInitializationException>()),
      );
      expect(await Directory('${documents.path}/$_epoch').exists(), isFalse);
      await expectLater(storage.exportLogsStream().join(), throwsStateError);
      await expectLater(
        storage.appendLog(DateTime.now(), _sentinel),
        throwsStateError,
      );

      await blockedLock.delete();
      await init();
      expect(await legacy.exists(), isFalse);
      expect(await storage.exportLogsStream().join(), isEmpty);
    },
  );

  test(
    'migration does not follow a replacement epoch symlink',
    () async {
      final target = await Directory('${documents.path}/unsafe').create();
      await File(
        '${target.path}/APP-LOGS_2026-09-09.log',
      ).writeAsString(_sentinel);
      final link = await Link('${documents.path}/$_epoch').create(target.path);
      await expectLater(
        init(),
        throwsA(isA<LogStorageInitializationException>()),
      );
      await expectLater(storage.exportLogsStream().join(), throwsStateError);
      expect(
        await File('${target.path}/APP-LOGS_2026-09-09.log').readAsString(),
        _sentinel,
      );
      await link.delete();
    },
    skip: Platform.isWindows,
  );

  test(
    'one-time epoch preserves safe logs and excludes legacy recreated by an old client',
    () async {
      await init();
      await storage.appendLog(DateTime.now(), '{"event":"first"}');
      await storage.dispose();
      final legacy = await Directory('${documents.path}/dragon_logs').create();
      await File(
        '${legacy.path}/APP-LOGS_2026-09-09.log',
      ).writeAsString(_sentinel);
      await init();
      expect(await storage.exportLogsStream().join(), '{"event":"first"}\n');
      expect(await legacy.exists(), isTrue);
    },
  );

  test('concurrent instances migrate once and preserve every append', () async {
    final other = FileLogStorage.forDirectory(documents);
    addTearDown(other.dispose);
    await Future.wait([
      init(),
      other.init(storageNamespace: _epoch, purgeLegacy: true),
    ]);
    await Future.wait(
      List.generate(30, (index) async {
        final target = index.isEven ? storage : other;
        await target.appendLog(DateTime.now(), '{"index":$index}');
        await target.flushQueue();
      }),
    );
    final records = const LineSplitter().convert(
      await storage.exportLogsStream().join(),
    );
    expect(records, hasLength(30));
    expect(
      records.map((record) => (jsonDecode(record) as Map)['index']).toSet(),
      Set<int>.from(List.generate(30, (index) => index)),
    );
  });

  test(
    'export flushes pending records and clear cannot resurrect them',
    () async {
      await init();
      await storage.appendLog(DateTime.now(), '{"event":"pending"}');
      expect(await storage.exportLogsStream().join(), contains('pending'));
      await storage.appendLog(DateTime.now(), '{"event":"also-pending"}');
      await storage.deleteOldLogs(0);
      await storage.flushQueue();
      expect(await storage.exportLogsStream().join(), isEmpty);
    },
  );

  test(
    'failed write releases locks and retries without logging exception content',
    () async {
      await init();
      final blockedFile = await Directory(
        storage.getLogFile(DateTime.now()).path,
      ).create();
      await storage.appendLog(DateTime.now(), '{"event":"retained"}');
      await expectLater(
        storage.flushQueue(),
        throwsA(isA<FileSystemException>()),
      );
      await blockedFile.delete();
      expect(
        await storage.exportLogsStream().join().timeout(
          const Duration(seconds: 3),
        ),
        '{"event":"retained"}\n',
      );
    },
  );

  test(
    'namespace changes require disposal and never carry the old queue forward',
    () async {
      await storage.init();
      await storage.appendLog(DateTime.now(), _sentinel);
      expect(init, throwsStateError);
      await storage.dispose();
      await init();
      expect(await storage.exportLogsStream().join(), isEmpty);
    },
  );

  test('snapshot consumer does not retain a lock while paused', () async {
    await init();
    await storage.appendLog(DateTime.now(), '{"event":"snapshot"}');
    final received = Completer<void>();
    late StreamSubscription<String> subscription;
    subscription = storage.exportLogsStream().listen((_) {
      subscription.pause();
      received.complete();
    });
    await received.future;
    await storage.appendLog(DateTime.now(), '{"event":"later"}');
    await storage.flushQueue().timeout(const Duration(seconds: 3));
    subscription.resume();
    await subscription.cancel();
  });

  test('clearing exports spares artefacts a running export still owns', () async {
    await init();
    await storage.appendLog(DateTime.now(), '{"event":"retained"}');
    final cache = Directory('${documents.path}/$_epoch/log_export');
    final chunks = <String>[];
    final received = Completer<void>();
    late StreamSubscription<String> subscription;
    subscription = storage.exportLogsStream().listen((chunk) {
      chunks.add(chunk);
      subscription.pause();
      received.complete();
    });
    await received.future;
    final stale = File('${cache.path}/old-export.log');
    await stale.writeAsString(_sentinel);

    await storage.deleteExportedFiles().timeout(const Duration(seconds: 3));

    expect(await stale.exists(), isFalse);
    expect(await cache.list().toList(), hasLength(1));
    final done = subscription.asFuture<void>();
    subscription.resume();
    await done.timeout(const Duration(seconds: 3));
    expect(chunks.join(), contains('retained'));

    await storage.deleteExportedFiles().timeout(const Duration(seconds: 3));
    expect(await cache.exists(), isFalse);
  });

  test(
    'raw JSONL API escapes records without legacy metadata and gates pre-init writes',
    () async {
      await DragonLogs.dispose();
      PathProviderPlatform.instance = _DirectoryPathProvider(documents.path);
      await expectLater(
        DragonLogs.writeRecord('{"event":"before"}'),
        throwsStateError,
      );
      await DragonLogs.init(storageNamespace: _epoch, purgeLegacy: true);
      final record = jsonEncode({'event': 'safe', 'escaped': 'one\ntwo'});
      await DragonLogs.writeRecord(record);
      await expectLater(
        DragonLogs.writeRecord('{"bad":true}\n$_sentinel'),
        throwsArgumentError,
      );
      await expectLater(DragonLogs.writeRecord(_sentinel), throwsArgumentError);
      expect(await DragonLogs.exportLogsString(), '$record\n');
      final cache = await Directory(
        '${documents.path}/$_epoch/log_export',
      ).create();
      await File('${cache.path}/old-export.txt').writeAsString('safe');
      await DragonLogs.clearLogs();
      expect(await cache.exists(), isFalse);
      expect(await DragonLogs.exportLogsString(), isEmpty);
    },
  );

  test('queue serializes overlapping flushes and snapshot drain', () async {
    final queue = _BlockingQueue()..initQueueFlusher();
    addTearDown(queue.stopQueueFlusher);
    queue.enqueue('first');
    final first = queue.flushQueue();
    await queue.started.future;
    queue.enqueue('second');
    final second = queue.flushQueue();
    final snapshot = queue.withFlushedQueue(
      () async => List<String>.of(queue.records),
    );
    queue.release.complete();
    await Future.wait([first, second]);
    expect(await snapshot, ['first', 'second']);
    expect(queue.maximumConcurrent, 1);
  });

  test('background flush timer stops on lifecycle shutdown', () {
    fakeAsync((clock) {
      final queue = _ImmediateQueue()..initQueueFlusher();
      queue.enqueue('safe');
      clock.elapse(const Duration(seconds: 5));
      expect(queue.writes, 1);
      queue.stopQueueFlusher();
      expect(clock.periodicTimerCount, 0);
      expect(() => queue.enqueue(_sentinel), throwsStateError);
      clock.elapse(const Duration(seconds: 20));
      expect(queue.writes, 1);
    });
  });

  test(
    'large export uses bounded chunks and cancellation removes its snapshot',
    () async {
      await init();
      final record = 'x' * (1024 * 1024);
      await storage.appendLog(DateTime.now(), record);
      final iterator = StreamIterator(storage.exportLogsStream());
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current.length, lessThanOrEqualTo(64 * 1024));
      await iterator.cancel();
      final cache = Directory('${documents.path}/$_epoch/log_export');
      expect(await cache.list().toList(), isEmpty);
      expect(await storage.getLogFolderSize(), record.length + 1);
    },
  );
}

class _DirectoryPathProvider extends MockPathProviderPlatform {
  _DirectoryPathProvider(this.path);
  final String path;
  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

class _BlockingQueue with QueueMixin {
  final started = Completer<void>();
  final release = Completer<void>();
  final records = <String>[];
  var concurrent = 0;
  var maximumConcurrent = 0;
  @override
  Future<void> writeToTextFile(String logs) async {
    concurrent++;
    if (concurrent > maximumConcurrent) maximumConcurrent = concurrent;
    if (!started.isCompleted) {
      started.complete();
      await release.future;
    }
    records.add(logs);
    concurrent--;
  }
}

class _ImmediateQueue with QueueMixin {
  var writes = 0;
  @override
  Future<void> writeToTextFile(String logs) async {
    writes++;
  }
}
