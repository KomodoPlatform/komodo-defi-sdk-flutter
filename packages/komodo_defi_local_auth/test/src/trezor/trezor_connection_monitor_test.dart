import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class _DummyApiClient implements ApiClient {
  @override
  FutureOr<JsonMap> executeRpc(JsonMap request) => <String, dynamic>{};
}

class _TestTrezorRepository extends TrezorRepository {
  _TestTrezorRepository() : super(_DummyApiClient());

  StreamController<TrezorConnectionStatus>? lastController;
  String? lastDevicePubkey;
  Duration? lastPollInterval;
  Duration? lastMaxDuration;

  @override
  Stream<TrezorConnectionStatus> watchConnectionStatus({
    String? devicePubkey,
    Duration pollInterval = const Duration(seconds: 1),
    Duration? maxDuration,
  }) {
    lastDevicePubkey = devicePubkey;
    lastPollInterval = pollInterval;
    lastMaxDuration = maxDuration;

    final controller = StreamController<TrezorConnectionStatus>();
    lastController = controller;
    return controller.stream;
  }

  void emit(TrezorConnectionStatus status) {
    lastController?.add(status);
  }

  void emitError(Object error) {
    lastController?.addError(error);
  }

  Future<void> close() async {
    await lastController?.close();
  }

  void complete() {
    lastController?.close();
  }
}

void main() {
  group('TrezorConnectionMonitor', () {
    test('emits onStatusChanged and updates lastKnownStatus', () async {
      final repo = _TestTrezorRepository();
      final monitor = TrezorConnectionMonitor(repo);

      final statuses = <TrezorConnectionStatus>[];

      monitor.startMonitoring(onStatusChanged: statuses.add);

      // Emit a sequence of statuses
      repo
        ..emit(TrezorConnectionStatus.connected)
        ..emit(TrezorConnectionStatus.busy)
        ..emit(TrezorConnectionStatus.unreachable)
        ..emit(TrezorConnectionStatus.connected)
        ..emit(TrezorConnectionStatus.disconnected);

      // Allow events to flow
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(statuses, isNotEmpty);
      expect(monitor.lastKnownStatus, TrezorConnectionStatus.disconnected);
      expect(monitor.isMonitoring, isTrue);

      await monitor.stopMonitoring();
      expect(monitor.isMonitoring, isFalse);
      expect(monitor.lastKnownStatus, isNull);
      await repo.close();
    });

    test(
      'calls onConnectionLost only on available -> unavailable transitions',
      () async {
        final repo = _TestTrezorRepository();
        final monitor = TrezorConnectionMonitor(repo);

        var lostCount = 0;
        var restoredCount = 0;

        monitor.startMonitoring(
          onConnectionLost: () => lostCount++,
          onConnectionRestored: () => restoredCount++,
        );

        // Initial unavailable should NOT trigger lost (no previous status)
        repo
          ..emit(TrezorConnectionStatus.unreachable)
          // Transition to available -> should trigger restored
          ..emit(TrezorConnectionStatus.connected)
          // Available -> unavailable -> lost
          ..emit(TrezorConnectionStatus.busy)
          // Unavailable -> available -> restored
          ..emit(TrezorConnectionStatus.connected)
          // Available -> unavailable -> lost
          ..emit(TrezorConnectionStatus.unreachable)
          // Unavailable -> unavailable (no change) -> no callbacks
          ..emit(TrezorConnectionStatus.disconnected);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(lostCount, 2);
        expect(restoredCount, 2);

        await monitor.stopMonitoring();
        await repo.close();
      },
    );

    test(
      'onConnectionRestored only when transitioning from unavailable to available',
      () async {
        final repo = _TestTrezorRepository();
        final monitor = TrezorConnectionMonitor(repo);

        var restoredCount = 0;
        monitor.startMonitoring(onConnectionRestored: () => restoredCount++);

        // Initial available should NOT trigger restored
        repo
          ..emit(TrezorConnectionStatus.connected)
          // available -> available, still no restored
          ..emit(TrezorConnectionStatus.connected)
          // unavailable -> available -> restored once
          ..emit(TrezorConnectionStatus.busy)
          ..emit(TrezorConnectionStatus.connected);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(restoredCount, 1);

        await monitor.stopMonitoring();
        await repo.close();
      },
    );

    test('forwards parameters to repository', () async {
      final repo = _TestTrezorRepository();
      final monitor = TrezorConnectionMonitor(repo);

      const pubkey = 'pub-xyz';
      const poll = Duration(milliseconds: 250);
      const max = Duration(seconds: 3);

      monitor.startMonitoring(
        devicePubkey: pubkey,
        pollInterval: poll,
        maxDuration: max,
      );

      // Allow the start to invoke repo.watchConnectionStatus
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(repo.lastDevicePubkey, pubkey);
      expect(repo.lastPollInterval, poll);
      expect(repo.lastMaxDuration, max);

      await monitor.stopMonitoring();
      await repo.close();
    });

    test(
      'stopMonitoring cancels subscription and ignores further events',
      () async {
        final repo = _TestTrezorRepository();
        final monitor = TrezorConnectionMonitor(repo);

        final statuses = <TrezorConnectionStatus>[];
        monitor.startMonitoring(onStatusChanged: statuses.add);

        repo.emit(TrezorConnectionStatus.connected);
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await monitor.stopMonitoring();

        // After stop, lastKnown should be cleared and events ignored
        expect(monitor.lastKnownStatus, isNull);
        repo.emit(TrezorConnectionStatus.busy);
        await Future<void>.delayed(const Duration(milliseconds: 5));

        // Only the first event should be recorded
        expect(statuses, [TrezorConnectionStatus.connected]);
        await repo.close();
      },
    );

    test('onError triggers onConnectionLost while monitoring', () async {
      final repo = _TestTrezorRepository();
      final monitor = TrezorConnectionMonitor(repo);

      var lost = 0;
      monitor.startMonitoring(onConnectionLost: () => lost++);

      // Emit any status to set previousStatus
      repo.emit(TrezorConnectionStatus.connected);
      await Future<void>.delayed(const Duration(milliseconds: 5));

      // Now emit error from repository stream
      repo.emitError(Exception('stream failure'));
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(lost, 1);

      await monitor.stopMonitoring();
      await repo.close();
    });

    test('startMonitoring replaces previous monitoring session', () async {
      final repo = _TestTrezorRepository();
      final monitor = TrezorConnectionMonitor(repo);

      final statuses = <TrezorConnectionStatus>[];

      monitor.startMonitoring(onStatusChanged: statuses.add);
      repo.emit(TrezorConnectionStatus.connected);
      await Future<void>.delayed(const Duration(milliseconds: 5));

      // Start a new session; should cancel the previous
      monitor.startMonitoring(onStatusChanged: statuses.add);
      // Emit from the new stream
      repo.emit(TrezorConnectionStatus.busy);
      await Future<void>.delayed(const Duration(milliseconds: 5));

      // We should have seen both events, and isMonitoring should be true
      expect(statuses, [
        TrezorConnectionStatus.connected,
        TrezorConnectionStatus.busy,
      ]);
      expect(monitor.isMonitoring, isTrue);

      await monitor.stopMonitoring();
      await repo.close();
    });

    test('dispose stops monitoring', () async {
      final repo = _TestTrezorRepository();
      final monitor = TrezorConnectionMonitor(repo);

      monitor.startMonitoring();
      expect(monitor.isMonitoring, isTrue);
      monitor.dispose();
      expect(monitor.isMonitoring, isFalse);
      expect(monitor.lastKnownStatus, isNull);
      await repo.close();
    });

    test(
      'isMonitoring becomes false when underlying stream completes',
      () async {
        final repo = _TestTrezorRepository();
        final monitor = TrezorConnectionMonitor(repo);

        monitor.startMonitoring();
        expect(monitor.isMonitoring, isTrue);

        // Complete the repository stream
        repo
          ..emit(TrezorConnectionStatus.connected)
          ..complete();

        await Future<void>.delayed(const Duration(milliseconds: 5));

        // Monitor should reflect completion
        expect(monitor.isMonitoring, isFalse);
        // Last status should remain available for inspection
        expect(monitor.lastKnownStatus, TrezorConnectionStatus.connected);

        await repo.close();
      },
    );

    test('errors after stopMonitoring are ignored', () async {
      final repo = _TestTrezorRepository();
      final monitor = TrezorConnectionMonitor(repo);

      var lost = 0;
      monitor.startMonitoring(onConnectionLost: () => lost++);

      repo.emit(TrezorConnectionStatus.connected);
      await Future<void>.delayed(const Duration(milliseconds: 5));

      await monitor.stopMonitoring();
      repo.emitError(Exception('late error'));
      await Future<void>.delayed(const Duration(milliseconds: 5));

      // No new lost invocations after stop
      expect(lost, 0);

      await repo.close();
    });

    test(
      'startMonitoring without events then stopMonitoring remains quiet',
      () async {
        final repo = _TestTrezorRepository();
        final monitor = TrezorConnectionMonitor(repo);

        var lost = 0;
        var restored = 0;
        final statuses = <TrezorConnectionStatus>[];

        monitor.startMonitoring(
          onStatusChanged: statuses.add,
          onConnectionLost: () => lost++,
          onConnectionRestored: () => restored++,
        );

        // No emissions; then stop
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await monitor.stopMonitoring();
        await Future<void>.delayed(const Duration(milliseconds: 5));

        expect(statuses, isEmpty);
        expect(lost, 0);
        expect(restored, 0);

        await repo.close();
      },
    );
  });
}
