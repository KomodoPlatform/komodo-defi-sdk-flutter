import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

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
            status: AuthenticationStatus.completed,
            message: 'Trezor device initialized successfully',
            deviceInfo: deviceInfo,
            taskId: taskId,
          );
        } else {
          return TrezorInitializationState(
            status: AuthenticationStatus.error,
            error: 'Invalid response: missing device info',
            taskId: taskId,
          );
        }

      case 'Error':
        final errorInfo = response.errorInfo;
        return TrezorInitializationState(
          status: AuthenticationStatus.error,
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
          status: AuthenticationStatus.error,
          error: 'Unknown status: ${response.status}',
          taskId: taskId,
        );
    }
  }

  /// Factory constructor that maps in-progress descriptions
  /// to appropriate states
  factory TrezorInitializationState.fromInProgressDescription(
    String? description,
    int taskId,
  ) {
    if (description == null) {
      return TrezorInitializationState(
        status: AuthenticationStatus.initializing,
        message: 'Initializing Trezor device...',
        taskId: taskId,
      );
    }

    final descriptionLower = description.toLowerCase();

    if (descriptionLower.contains('waiting') &&
        descriptionLower.contains('connect')) {
      return TrezorInitializationState(
        status: AuthenticationStatus.waitingForDevice,
        message: 'Waiting for Trezor device to be connected',
        taskId: taskId,
      );
    }

    if (descriptionLower.contains('follow') &&
        descriptionLower.contains('instructions')) {
      return TrezorInitializationState(
        status: AuthenticationStatus.waitingForDeviceConfirmation,
        message: 'Please follow the instructions on your Trezor device',
        taskId: taskId,
      );
    }

    return TrezorInitializationState(
      status: AuthenticationStatus.initializing,
      message: description,
      taskId: taskId,
    );
  }

  /// Factory constructor that maps user action requirements
  /// to appropriate states
  factory TrezorInitializationState.fromUserActionRequired(
    String? description,
    int taskId,
  ) {
    if (description == null) {
      return TrezorInitializationState(
        status: AuthenticationStatus.initializing,
        message: 'User action required',
        taskId: taskId,
      );
    }

    if (description == 'EnterTrezorPin') {
      return TrezorInitializationState(
        status: AuthenticationStatus.pinRequired,
        message: 'Please enter your Trezor PIN',
        taskId: taskId,
      );
    }

    if (description == 'EnterTrezorPassphrase') {
      return TrezorInitializationState(
        status: AuthenticationStatus.passphraseRequired,
        message: 'Please enter your Trezor passphrase',
        taskId: taskId,
      );
    }

    return TrezorInitializationState(
      status: AuthenticationStatus.initializing,
      message: description,
      taskId: taskId,
    );
  }

  /// Current status of the initialization process
  final AuthenticationStatus status;

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
    AuthenticationStatus? status,
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

  AuthenticationState toAuthenticationState() {
    return AuthenticationState(
      status: status,
      message: message,
      taskId: taskId,
      error: error,
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
