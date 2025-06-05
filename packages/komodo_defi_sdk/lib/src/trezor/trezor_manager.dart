import 'dart:async';

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Helper function for unawaited futures
void unawaited(Future<void> future) {
  // Intentionally ignore the future
}

/// Status of Trezor initialization process
enum TrezorInitializationStatus {
  /// Initialization is starting
  initializing,

  /// Waiting for Trezor device to be connected
  waitingForDevice,

  /// Waiting for user to follow instructions on device
  waitingForDeviceConfirmation,

  /// User needs to enter PIN
  pinRequired,

  /// User needs to enter passphrase
  passphraseRequired,

  /// Initialization completed successfully
  completed,

  /// Initialization failed with error
  error,

  /// Initialization was cancelled
  cancelled,
}

/// Represents the current state of Trezor initialization
class TrezorInitializationState {
  /// Creates a new initialization state
  const TrezorInitializationState({
    required this.status,
    this.message,
    this.deviceInfo,
    this.error,
    this.taskId,
  });

  /// Current status of the initialization process
  final TrezorInitializationStatus status;

  /// Human-readable message describing current state
  final String? message;

  /// Device information (available when initialization is complete)
  final TrezorDeviceInfo? deviceInfo;

  /// Error information (available when status is error)
  final String? error;

  /// Task ID for the current initialization process
  final int? taskId;

  /// Creates a copy of this state with optional parameter updates
  TrezorInitializationState copyWith({
    TrezorInitializationStatus? status,
    String? message,
    TrezorDeviceInfo? deviceInfo,
    String? error,
    int? taskId,
  }) {
    return TrezorInitializationState(
      status: status ?? this.status,
      message: message ?? this.message,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      error: error ?? this.error,
      taskId: taskId ?? this.taskId,
    );
  }

  @override
  String toString() {
    return 'TrezorInitializationState('
        'status: $status, '
        'message: $message, '
        'deviceInfo: ${deviceInfo?.deviceName}, '
        'error: $error, '
        'taskId: $taskId)';
  }
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

          final state = _mapStatusToState(statusResponse, taskId);

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

  /// Maps API status response to domain state
  TrezorInitializationState _mapStatusToState(
    TrezorStatusResponse response,
    int taskId,
  ) {
    switch (response.status) {
      case 'Ok':
        final deviceInfo = response.deviceInfo;
        if (deviceInfo != null) {
          return TrezorInitializationState(
            status: TrezorInitializationStatus.completed,
            message: 'Trezor device initialized successfully',
            deviceInfo: deviceInfo,
            taskId: taskId,
          );
        } else {
          return TrezorInitializationState(
            status: TrezorInitializationStatus.error,
            error: 'Invalid response: missing device info',
            taskId: taskId,
          );
        }

      case 'Error':
        final errorInfo = response.errorInfo;
        return TrezorInitializationState(
          status: TrezorInitializationStatus.error,
          error: errorInfo?.error ?? 'Unknown error occurred',
          taskId: taskId,
        );

      case 'InProgress':
        final description = response.progressDescription;
        return _mapInProgressDescription(description, taskId);

      case 'UserActionRequired':
        final description = response.progressDescription;
        return _mapUserActionRequired(description, taskId);

      default:
        return TrezorInitializationState(
          status: TrezorInitializationStatus.error,
          error: 'Unknown status: ${response.status}',
          taskId: taskId,
        );
    }
  }

  /// Maps in-progress descriptions to appropriate states
  TrezorInitializationState _mapInProgressDescription(
    String? description,
    int taskId,
  ) {
    if (description == null) {
      return TrezorInitializationState(
        status: TrezorInitializationStatus.initializing,
        message: 'Initializing Trezor device...',
        taskId: taskId,
      );
    }

    final descriptionLower = description.toLowerCase();

    if (descriptionLower.contains('waiting') &&
        descriptionLower.contains('connect')) {
      return TrezorInitializationState(
        status: TrezorInitializationStatus.waitingForDevice,
        message: 'Waiting for Trezor device to be connected',
        taskId: taskId,
      );
    }

    if (descriptionLower.contains('follow') &&
        descriptionLower.contains('instructions')) {
      return TrezorInitializationState(
        status: TrezorInitializationStatus.waitingForDeviceConfirmation,
        message: 'Please follow the instructions on your Trezor device',
        taskId: taskId,
      );
    }

    return TrezorInitializationState(
      status: TrezorInitializationStatus.initializing,
      message: description,
      taskId: taskId,
    );
  }

  /// Maps user action requirements to appropriate states
  TrezorInitializationState _mapUserActionRequired(
    String? description,
    int taskId,
  ) {
    if (description == null) {
      return TrezorInitializationState(
        status: TrezorInitializationStatus.initializing,
        message: 'User action required',
        taskId: taskId,
      );
    }

    if (description.contains('EnterTrezorPin')) {
      return TrezorInitializationState(
        status: TrezorInitializationStatus.pinRequired,
        message: 'Please enter your Trezor PIN',
        taskId: taskId,
      );
    }

    if (description.contains('EnterTrezorPassphrase')) {
      return TrezorInitializationState(
        status: TrezorInitializationStatus.passphraseRequired,
        message: 'Please enter your Trezor passphrase',
        taskId: taskId,
      );
    }

    return TrezorInitializationState(
      status: TrezorInitializationStatus.initializing,
      message: description,
      taskId: taskId,
    );
  }
}
