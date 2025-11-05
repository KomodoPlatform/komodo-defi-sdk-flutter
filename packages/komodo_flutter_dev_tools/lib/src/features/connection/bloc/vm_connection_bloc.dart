import 'dart:async';

import 'package:devtools_app_shared/service.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/devtools_data_bridge.dart';

part 'vm_connection_event.dart';
part 'vm_connection_state.dart';

class VmConnectionBloc extends Bloc<VmConnectionEvent, VmConnectionState> {
  VmConnectionBloc(DevToolsDataBridge bridge)
    : _bridge = bridge,
      super(const VmConnectionState.disconnected()) {
    on<VmConnectionSubscriptionRequested>(_onSubscriptionRequested);
    on<_VmConnectionChanged>(_onConnectionChanged);
    on<_VmConnectionMetadataRequested>(_onMetadataRequested);
  }

  final DevToolsDataBridge _bridge;
  StreamSubscription<bool>? _connectionSubscription;

  Future<void> _onSubscriptionRequested(
    VmConnectionSubscriptionRequested event,
    Emitter<VmConnectionState> emit,
  ) async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = _bridge.connectionStream.listen((connected) {
      add(_VmConnectionChanged(connected: connected));
    });
  }

  Future<void> _onConnectionChanged(
    _VmConnectionChanged event,
    Emitter<VmConnectionState> emit,
  ) async {
    if (!event.connected) {
      emit(const VmConnectionState.disconnected());
      return;
    }

    emit(
      state.copyWith(
        status: ConnectionStatus.connecting,
        connectedAt: DateTime.now(),
        appDescription: null,
        error: null,
      ),
    );
    add(const _VmConnectionMetadataRequested());
  }

  Future<void> _onMetadataRequested(
    _VmConnectionMetadataRequested event,
    Emitter<VmConnectionState> emit,
  ) async {
    try {
      final connectedApp = serviceManager.connectedApp;
      if (connectedApp != null && !connectedApp.initialized.isCompleted) {
        await connectedApp.initializeValues();
      }

      final appSummary = _buildAppSummary(connectedApp);
      emit(
        state.copyWith(
          status: ConnectionStatus.connected,
          appDescription: appSummary,
          error: null,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: ConnectionStatus.connected,
          appDescription: state.appDescription,
          error: error.toString(),
        ),
      );
      // Surface error to DevTools notification system for visibility.
      extensionManager.showNotification('Failed to load app metadata: $error');
      addError(error, stackTrace);
    }
  }

  String? _buildAppSummary(ConnectedApp? app) {
    if (app == null || !app.connectedAppInitialized) {
      return null;
    }

    final buffer = StringBuffer();
    if (app.isFlutterAppNow == true) {
      buffer.write('Flutter');
      if (app.isDartWebAppNow == true) {
        buffer.write(' Web');
      }
    } else {
      buffer.write('Dart VM');
    }

    final os = app.operatingSystem;
    if (os != ConnectedApp.unknownOS) {
      buffer.write(' · $os');
    }

    if (app.flutterVersionNow != null && !app.flutterVersionNow!.unknown) {
      buffer.write(' · ${app.flutterVersionNow!.version}');
    }

    return buffer.toString();
  }

  @override
  Future<void> close() async {
    await _connectionSubscription?.cancel();
    return super.close();
  }
}
