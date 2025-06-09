import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

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

  /// Factory constructor that maps API status response to domain state
  factory TrezorInitializationState.fromStatusResponse(
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
        return TrezorInitializationState.fromInProgressDescription(
          description,
          taskId,
        );

      case 'UserActionRequired':
        final description = response.progressDescription;
        return TrezorInitializationState.fromUserActionRequired(
          description,
          taskId,
        );

      default:
        return TrezorInitializationState(
          status: TrezorInitializationStatus.error,
          error: 'Unknown status: ${response.status}',
          taskId: taskId,
        );
    }
  }

  /// Factory constructor that maps in-progress descriptions to appropriate states
  factory TrezorInitializationState.fromInProgressDescription(
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

  /// Factory constructor that maps user action requirements to appropriate states
  factory TrezorInitializationState.fromUserActionRequired(
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
