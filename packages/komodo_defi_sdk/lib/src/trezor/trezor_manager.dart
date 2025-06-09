import 'dart:async';

import 'package:komodo_defi_sdk/src/trezor/trezor_initialization_state.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Helper function for unawaited futures
void unawaited(Future<void> future) {
  // Intentionally ignore the future
}

/// Exception thrown when Trezor operations fail
class TrezorException implements Exception {
  /// Creates a new TrezorException with the given message and optional details
  const TrezorException(this.message, [this.details]);

  /// Human-readable error message
  final String message;

  /// Optional additional error details
  final String? details;

  @override
  String toString() =>
      'TrezorException: $message${details != null ? ' ($details)' : ''}';
}

/// Manages Trezor hardware wallet initialization and operations
class TrezorManager {
  /// Creates a new TrezorManager instance with the provided API client
  TrezorManager(this._client);

  /// The API client for making RPC calls
  final ApiClient _client;

  /// Track active initialization streams
  final Map<int, StreamController<TrezorInitializationState>>
  _activeInitializations = {};

  /// Initialize a Trezor device for use with Komodo DeFi Framework
  ///
  /// Returns a stream that emits [TrezorInitializationState] updates throughout
  /// the initialization process. The caller should listen to this stream and
  /// respond to user input requirements (PIN/passphrase) by calling the
  /// appropriate methods ([providePin] or [providePassphrase]).
  ///
  /// Example usage:
  /// ```dart
  /// await for (final state in trezorManager.initializeDevice()) {
  ///   switch (state.status) {
  ///     case TrezorInitializationStatus.pinRequired:
  ///       final pin = await getUserPin();
  ///       await trezorManager.providePin(state.taskId!, pin);
  ///       break;
  ///     case TrezorInitializationStatus.passphraseRequired:
  ///       final passphrase = await getUserPassphrase();
  ///       await trezorManager.providePassphrase(state.taskId!, passphrase);
  ///       break;
  ///     case TrezorInitializationStatus.completed:
  ///       print('Device initialized: ${state.deviceInfo}');
  ///       break;
  ///   }
  /// }
  /// ```
  Stream<TrezorInitializationState> initializeDevice({
    String? devicePubkey,
    Duration pollingInterval = const Duration(seconds: 1),
  }) async* {
    int? taskId;
    StreamController<TrezorInitializationState>? controller;

    try {
      // Start initialization
      yield const TrezorInitializationState(
        status: TrezorInitializationStatus.initializing,
        message: 'Starting Trezor initialization...',
      );

      final initResponse = await _client.rpc.trezor.init(
        devicePubkey: devicePubkey,
      );

      taskId = initResponse.taskId;
      controller = StreamController<TrezorInitializationState>();
      _activeInitializations[taskId] = controller;

      yield TrezorInitializationState(
        status: TrezorInitializationStatus.initializing,
        message: 'Initialization started, checking status...',
        taskId: taskId,
      );

      // Poll for status updates
      Timer? statusTimer;
      var isComplete = false;

      Future<void> pollStatus() async {
        if (isComplete || taskId == null) return;

        try {
          final statusResponse = await _client.rpc.trezor.status(
            taskId: taskId,
            forgetIfFinished: false,
          );

          final state = TrezorInitializationState.fromStatusResponse(
            statusResponse,
            taskId,
          );

          if (!controller!.isClosed) {
            controller.add(state);
          }

          // Check if we should stop polling
          if (state.status == TrezorInitializationStatus.completed ||
              state.status == TrezorInitializationStatus.error ||
              state.status == TrezorInitializationStatus.cancelled) {
            isComplete = true;
            statusTimer?.cancel();
            if (!controller.isClosed) {
              unawaited(controller.close());
            }
          }
        } catch (e) {
          if (!controller!.isClosed) {
            controller.addError(
              TrezorException('Status check failed', e.toString()),
            );
            await controller.close();
          }

          isComplete = true;
          statusTimer?.cancel();
        }
      }

      // Start polling
      statusTimer = Timer.periodic(
        pollingInterval,
        (_) => unawaited(pollStatus()),
      );

      yield* controller.stream;
    } catch (e) {
      yield TrezorInitializationState(
        status: TrezorInitializationStatus.error,
        error: 'Initialization failed: $e',
        taskId: taskId,
      );

      throw TrezorException('Failed to initialize Trezor device', e.toString());
    } finally {
      if (taskId != null) {
        _activeInitializations.remove(taskId);
        if (controller != null && !controller.isClosed) {
          unawaited(controller.close());
        }
      }
    }
  }

  /// Provide PIN when the device requests it
  ///
  /// The [pin] should be entered as it appears on your keyboard numpad,
  /// mapped according to the grid shown on the Trezor device.
  Future<void> providePin(int taskId, String pin) async {
    try {
      await _client.rpc.trezor.providePin(taskId: taskId, pin: pin);
    } catch (e) {
      throw TrezorException('Failed to provide PIN', e.toString());
    }
  }

  /// Provide passphrase when the device requests it
  ///
  /// The [passphrase] acts like an additional word in your recovery seed.
  /// Use an empty string to access the default wallet without passphrase.
  Future<void> providePassphrase(int taskId, String passphrase) async {
    try {
      await _client.rpc.trezor.providePassphrase(
        taskId: taskId,
        passphrase: passphrase,
      );
    } catch (e) {
      throw TrezorException('Failed to provide passphrase', e.toString());
    }
  }

  /// Cancel an ongoing Trezor initialization
  Future<bool> cancelInitialization(int taskId) async {
    try {
      final response = await _client.rpc.trezor.cancel(taskId: taskId);

      // Close and remove the controller
      final controller = _activeInitializations.remove(taskId);
      if (controller != null && !controller.isClosed) {
        controller.add(
          TrezorInitializationState(
            status: TrezorInitializationStatus.cancelled,
            message: 'Initialization cancelled by user',
            taskId: taskId,
          ),
        );
        unawaited(controller.close());
      }

      return response.result == 'success';
    } catch (e) {
      throw TrezorException('Failed to cancel initialization', e.toString());
    }
  }

  /// Cancel all active initializations and clean up resources
  Future<void> dispose() async {
    final activeTaskIds = _activeInitializations.keys.toList();

    for (final taskId in activeTaskIds) {
      try {
        await cancelInitialization(taskId);
      } catch (e) {
        // Log error but continue cleanup
        // Log error but continue cleanup - could use proper logging here
        // ignore: avoid_print
        print('Error cancelling Trezor task $taskId: $e');
      }
    }

    _activeInitializations.clear();
  }
}
