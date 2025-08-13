import 'dart:async';

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Handles polling-based watching for swap progress, with de-dup and replay.
class SwapWatchService {
  SwapWatchService(this._client);

  final ApiClient _client;
  static const Duration _statusPollInterval = Duration(seconds: 5);

  final Map<String, StreamController<SwapProgress>> _controllers = {};
  final Map<String, StreamSubscription<dynamic>> _watchers = {};
  final Map<String, SwapProgress> _lastProgress = {};
  final Map<String, String> _lastSignature = {};

  Stream<SwapProgress> watch(String uuid) {
    final controller = _controllers.putIfAbsent(
      uuid,
      () =>
          StreamController<SwapProgress>.broadcast(onCancel: () => _stop(uuid)),
    );

    _start(uuid);

    return Stream<SwapProgress>.multi((emitter) {
      final last = _lastProgress[uuid];
      if (last != null) emitter.add(last);
      final sub = controller.stream.listen(
        emitter.add,
        onError: emitter.addError,
        onDone: emitter.close,
        cancelOnError: false,
      );
      emitter.onCancel = () => sub.cancel();
    });
  }

  Future<void> _start(String uuid) async {
    await _watchers[uuid]?.cancel();

    // Emit current status immediately
    try {
      final status = await _client.rpc.trading.swapStatus(uuid: uuid);
      final info = status.swapInfo;
      final sig = _signatureForSwapInfo(info);
      if (_lastSignature[uuid] != sig) {
        _lastSignature[uuid] = sig;
      }
      final ev = _toProgress(uuid, info);
      _lastProgress[uuid] = ev;
      final controller = _controllers[uuid];
      if (controller != null && !controller.isClosed) controller.add(ev);
    } catch (_) {}

    final periodic = Stream<void>.periodic(_statusPollInterval);
    _watchers[uuid] = periodic.listen((_) async {
      final controller = _controllers[uuid];
      if (controller == null || controller.isClosed) return;
      try {
        final status = await _client.rpc.trading.swapStatus(uuid: uuid);
        final info = status.swapInfo;
        final sig = _signatureForSwapInfo(info);
        if (_lastSignature[uuid] == sig) return;
        _lastSignature[uuid] = sig;
        final ev = _toProgress(uuid, info);
        _lastProgress[uuid] = ev;
        controller.add(ev);
        if (info.isComplete) {
          await controller.close();
          await _watchers[uuid]?.cancel();
          _watchers.remove(uuid);
          _controllers.remove(uuid);
        }
      } catch (_) {}
    });
  }

  void _stop(String uuid) {
    _watchers[uuid]?.cancel();
    _watchers.remove(uuid);
  }

  SwapProgress _toProgress(String uuid, SwapInfo info) {
    if (info.isComplete) {
      return SwapProgress(
        status: info.isSuccessful ? SwapStatus.completed : SwapStatus.failed,
        message:
            info.isSuccessful
                ? 'Swap completed'
                : (info.errorEvents.isNotEmpty
                    ? 'Swap failed: ${info.errorEvents.last}'
                    : 'Swap failed'),
        swapUuid: uuid,
        details: info.toJson(),
      );
    }
    final last = info.successEvents.isNotEmpty ? info.successEvents.last : null;
    return SwapProgress(
      status: SwapStatus.inProgress,
      message: last ?? 'In progress',
      swapUuid: uuid,
      details: info.toJson(),
    );
  }

  String _signatureForSwapInfo(SwapInfo info) {
    final lastSuccess =
        info.successEvents.isNotEmpty ? info.successEvents.last : '';
    final lastError = info.errorEvents.isNotEmpty ? info.errorEvents.last : '';
    return '${info.startedAt ?? 0}:${info.finishedAt ?? 0}:${info.type}:S${info.successEvents.length}:E${info.errorEvents.length}:LS$lastSuccess:LE$lastError';
  }

  Future<void> dispose() async {
    for (final sub in _watchers.values) {
      await sub.cancel();
    }
    _watchers.clear();
    for (final c in _controllers.values) {
      await c.close();
    }
    _controllers.clear();
    _lastProgress.clear();
    _lastSignature.clear();
  }
}
