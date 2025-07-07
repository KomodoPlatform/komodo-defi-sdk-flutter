import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:komodo_defi_local_auth/src/trezor/trezor_connection_status.dart';
import 'package:komodo_defi_local_auth/src/trezor/trezor_repository.dart';
import 'package:logging/logging.dart';

/// Service responsible for monitoring Trezor device connection status
/// and providing callbacks for connection state changes.
class TrezorConnectionMonitor {
  TrezorConnectionMonitor(this._trezorRepository);

  static final _log = Logger('TrezorConnectionMonitor');

  final TrezorRepository _trezorRepository;
  StreamSubscription<TrezorConnectionStatus>? _connectionSubscription;
  TrezorConnectionStatus? _lastStatus;

  /// Start monitoring the Trezor connection status.
  ///
  /// [onConnectionLost] will be called when the device becomes disconnected
  /// or unreachable.
  /// [onConnectionRestored] will be called when the device becomes connected
  /// after being disconnected/unreachable.
  /// [onStatusChanged] will be called for any status change.
  void startMonitoring({
    String? devicePubkey,
    Duration pollInterval = const Duration(seconds: 1),
    VoidCallback? onConnectionLost,
    VoidCallback? onConnectionRestored,
    void Function(TrezorConnectionStatus)? onStatusChanged,
  }) {
    _log.info('Starting Trezor connection monitoring');

    stopMonitoring(); // Stop any existing monitoring

    _connectionSubscription = _trezorRepository
        .watchConnectionStatus(
          devicePubkey: devicePubkey,
          pollInterval: pollInterval,
        )
        .listen(
          (status) {
            _log.fine('Connection status changed: ${status.value}');

            final previousStatus = _lastStatus;
            _lastStatus = status;

            // Notify about any status change
            onStatusChanged?.call(status);

            // Handle connection lost events
            if (status.isUnavailable &&
                (previousStatus?.isAvailable ?? false)) {
              _log.warning('Trezor connection lost: ${status.value}');
              onConnectionLost?.call();
            }

            // Handle connection restored events
            if (status.isAvailable &&
                (previousStatus?.isUnavailable ?? false)) {
              _log.info('Trezor connection restored');
              onConnectionRestored?.call();
            }
          },
          onError: (Object error) {
            _log.severe('Error monitoring Trezor connection: $error');
            // Treat monitoring errors as connection lost
            onConnectionLost?.call();
          },
          onDone: () {
            _log.info('Trezor connection monitoring stopped');
          },
        );
  }

  /// Stop monitoring the Trezor connection status.
  void stopMonitoring() {
    if (_connectionSubscription != null) {
      _log.info('Stopping Trezor connection monitoring');
      _connectionSubscription?.cancel();
      _connectionSubscription = null;
      _lastStatus = null;
    }
  }

  /// Get the last known connection status.
  TrezorConnectionStatus? get lastKnownStatus => _lastStatus;

  /// Check if monitoring is currently active.
  bool get isMonitoring => _connectionSubscription != null;

  /// Dispose of the monitor and clean up resources.
  void dispose() {
    stopMonitoring();
  }
}
