import 'dart:async';

import 'package:collection/collection.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:vm_service/vm_service.dart';

import '../core/constants.dart';
import 'models/log_entry.dart';
import 'models/rpc_call.dart';
import 'models/rpc_method_metrics.dart';

class LogsStreamEvent {
  const LogsStreamEvent({required this.entries, this.isSnapshot = false});

  factory LogsStreamEvent.single(LogEntry entry) =>
      LogsStreamEvent(entries: [entry]);

  final List<LogEntry> entries;
  final bool isSnapshot;
}

class RpcStreamEvent {
  const RpcStreamEvent({
    required this.calls,
    this.isSnapshot = false,
    this.metrics,
  });

  factory RpcStreamEvent.single(RpcCall call) => RpcStreamEvent(calls: [call]);

  final List<RpcCall> calls;
  final bool isSnapshot;
  final List<RpcMethodMetrics>? metrics;
}

class DevToolsDataBridge {
  DevToolsDataBridge() {
    _init();
  }

  final _logController = StreamController<LogsStreamEvent>.broadcast();
  final _rpcController = StreamController<RpcStreamEvent>.broadcast();
  final _rpcSummaryController = StreamController<RpcSummary>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  StreamSubscription<Event>? _extensionSubscription;
  VoidCallback? _connectionListener;

  Stream<LogsStreamEvent> get logStream => _logController.stream;
  Stream<RpcStreamEvent> get rpcStream => _rpcController.stream;
  Stream<RpcSummary> get rpcSummaryStream => _rpcSummaryController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  void _init() {
    _connectionListener = () {
      final connected = serviceManager.connectedState.value.connected;
      _connectionController.add(connected);
      if (connected) {
        unawaited(_attachToVmService());
      } else {
        _extensionSubscription?.cancel();
      }
    };

    serviceManager.connectedState.addListener(_connectionListener!);
    _connectionController.add(serviceManager.connectedState.value.connected);

    if (serviceManager.connectedState.value.connected) {
      unawaited(_attachToVmService());
    }
  }

  Future<void> _attachToVmService() async {
    final vmService = serviceManager.service;
    if (vmService == null) return;
    try {
      await vmService.streamListen(EventStreams.kExtension);
    } on RPCError catch (error) {
      // Ignore "already subscribed" errors.
      if (error.code != RPCErrorKind.kStreamAlreadySubscribed.code) {
        _logController.addError(error);
      }
    } catch (error) {
      _logController.addError(error);
    }

    await _extensionSubscription?.cancel();
    _extensionSubscription = vmService.onExtensionEvent.listen(
      _handleExtensionEvent,
      onError: (Object error, StackTrace stackTrace) {
        _logController.addError(error, stackTrace);
      },
    );
  }

  void _handleExtensionEvent(Event event) {
    final kind = event.extensionKind;
    final data = event.extensionData?.data ?? const <String, dynamic>{};

    switch (kind) {
      case DevToolsEventKinds.logEntry:
        final entry = LogEntry.fromExtensionData(_asMap(data));
        _logController.add(LogsStreamEvent.single(entry));
        break;
      case DevToolsEventKinds.logBatch:
        final batch = _asMapList(
          data['entries'] ?? data['logs'],
        ).map(LogEntry.fromExtensionData).toList();
        if (batch.isNotEmpty) {
          _logController.add(LogsStreamEvent(entries: batch));
        }
        break;
      case DevToolsEventKinds.rpcCall:
        final call = RpcCall.fromExtensionData(_asMap(data));
        _rpcController.add(RpcStreamEvent.single(call));
        break;
      case DevToolsEventKinds.rpcBatch:
        final calls = _asMapList(
          data['calls'] ?? data['entries'],
        ).map(RpcCall.fromExtensionData).toList();
        if (calls.isNotEmpty) {
          _rpcController.add(RpcStreamEvent(calls: calls));
        }
        break;
      case DevToolsEventKinds.rpcSummary:
        final summary = RpcSummary.fromExtensionData(_asMap(data));
        _rpcSummaryController.add(summary);
        break;
      case DevToolsEventKinds.rpcInsight:
        final calls = _asMapList(
          data['calls'],
        ).map(RpcCall.fromExtensionData).toList();
        final metrics = _buildMetricsForBatch(calls);
        _rpcController.add(
          RpcStreamEvent(calls: calls, metrics: metrics, isSnapshot: true),
        );
        break;
      default:
        // Ignore unknown extension events so we remain forward compatible.
        break;
    }
  }

  List<RpcMethodMetrics> _buildMetricsForBatch(List<RpcCall> calls) {
    final grouped = calls.groupListsBy((call) => call.method);
    return grouped.entries
        .map((entry) => RpcMethodMetrics.fromCalls(entry.key, entry.value))
        .sorted((a, b) => b.callCount.compareTo(a.callCount))
        .toList(growable: false);
  }

  Future<List<LogEntry>> fetchLogSnapshot() async {
    final response = await _invokeExtension(
      DevToolsServiceExtensions.fetchLogSnapshot,
    );
    final entries = _asMapList(
      response['entries'] ?? response['logs'],
    ).map(LogEntry.fromExtensionData).toList();
    if (entries.isNotEmpty) {
      _logController.add(LogsStreamEvent(entries: entries, isSnapshot: true));
    }
    return entries;
  }

  Future<List<RpcCall>> fetchRpcSnapshot() async {
    final response = await _invokeExtension(
      DevToolsServiceExtensions.fetchRpcSnapshot,
    );
    final calls = _asMapList(
      response['calls'] ?? response['entries'],
    ).map(RpcCall.fromExtensionData).toList();
    if (calls.isNotEmpty) {
      _rpcController.add(
        RpcStreamEvent(
          calls: calls,
          isSnapshot: true,
          metrics: _buildMetricsForBatch(calls),
        ),
      );
    }
    return calls;
  }

  Future<Map<String, dynamic>> _invokeExtension(
    String method, {
    Map<String, Object?> args = const {},
  }) async {
    final vmService = serviceManager.service;
    if (vmService == null) {
      throw StateError('VM service is not connected.');
    }
    final isolateId = await _resolveMainIsolateId();
    if (isolateId == null) {
      throw StateError('Unable to resolve main isolate ID.');
    }

    final response = await vmService
        .callServiceExtension(method, isolateId: isolateId, args: args)
        .timeout(KomodoDevToolsConstants.logSnapshotRequestTimeout);
    return Map<String, dynamic>.from(response.json ?? const {});
  }

  Future<String?> _resolveMainIsolateId() async {
    final existing = serviceManager.isolateManager.mainIsolate.value?.id;
    if (existing != null) {
      return existing;
    }
    final state = await serviceManager.isolateManager.waitForMainIsolateState();
    return state?.isolateRef.id;
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, dynamic v) => MapEntry(key.toString(), v));
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asMapList(Object? value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (map) => map.map((key, dynamic v) => MapEntry(key.toString(), v)),
          )
          .toList(growable: false);
    }
    if (value is Map<String, dynamic>) {
      return [value];
    }
    return const [];
  }

  Future<void> dispose() async {
    await _extensionSubscription?.cancel();
    if (_connectionListener != null) {
      serviceManager.connectedState.removeListener(_connectionListener!);
    }
    await Future.wait([
      _logController.close(),
      _rpcController.close(),
      _rpcSummaryController.close(),
      _connectionController.close(),
    ]);
  }

  Future<void> toggleRpcTracing(bool enable) async {
    await _invokeExtension(
      DevToolsServiceExtensions.toggleRpcTracing,
      args: {'enabled': enable},
    );
  }

  Future<void> requestRpcInsightRefresh() async {
    await _invokeExtension(DevToolsServiceExtensions.requestInsightRefresh);
  }
}
