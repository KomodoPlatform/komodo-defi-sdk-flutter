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
  /// [maxDuration] sets the maximum time to monitor before timing out. If null,
  /// monitoring continues indefinitely until stopped or disconnected.
  void startMonitoring({
    String? devicePubkey,
    Duration pollInterval = const Duration(seconds: 1),
    Duration? maxDuration,
    VoidCallback? onConnectionLost,
    VoidCallback? onConnectionRestored,
    void Function(TrezorConnectionStatus)? onStatusChanged,
  }) {
    _log.info('Starting Trezor connection monitoring');

    // Stop any existing monitoring safely before starting a new one.
    final previousSubscription = _connectionSubscription;
    if (previousSubscription != null) {
      _log.info('Stopping previous Trezor connection monitoring');
      _connectionSubscription = null;
      _lastStatus = null;
      unawaited(previousSubscription.cancel());
    }

    _connectionSubscription = _trezorRepository
        .watchConnectionStatus(
          devicePubkey: devicePubkey,
          pollInterval: pollInterval,
          maxDuration: maxDuration,
        )
        .listen(
          (status) {
            _log.fine('Connection status changed: ${status.value}');

            final previousStatus = _lastStatus;
            _lastStatus = status;

            onStatusChanged?.call(status);

            final previouslyAvailable = previousStatus?.isAvailable ?? true;
            if (status.isUnavailable && previouslyAvailable) {
              _log.warning('Trezor connection lost: ${status.value}');
              onConnectionLost?.call();
            }

            final previouslyUnavailable =
                previousStatus?.isUnavailable ?? false;
            if (status.isAvailable && previouslyUnavailable) {
              _log.info('Trezor connection restored');
              onConnectionRestored?.call();
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            _log.severe(
              'Error monitoring Trezor connection: $error',
              error,
              stackTrace,
            );
            // Only call onConnectionLost if this is a real connection error,
            // not a disposal
            if (_connectionSubscription != null) {
              onConnectionLost?.call();
            }
          },
          onDone: () {
            _log.info('Trezor connection monitoring stopped');
            // Underlying stream ended; mark as not monitoring while keeping
            // the last known status for inspection.
            _connectionSubscription = null;
          },
        );
  }

  /// Stop monitoring the Trezor connection status.
  Future<void> stopMonitoring() async {
    if (_connectionSubscription != null) {
      _log.info('Stopping Trezor connection monitoring');
      await _connectionSubscription?.cancel();
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
    // Make monitoring appear stopped synchronously.
    final previousSubscription = _connectionSubscription;
    _connectionSubscription = null;
    _lastStatus = null;
    if (previousSubscription != null) {
      unawaited(previousSubscription.cancel());
    }
  }
}
