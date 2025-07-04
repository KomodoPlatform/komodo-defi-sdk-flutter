import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart'
    show ConfirmAddressDetails, PubkeyInfo;

part 'new_address_state.freezed.dart';

@freezed
abstract class NewAddressState with _$NewAddressState {
  const factory NewAddressState({
    required NewAddressStatus status,
    String? message,
    int? taskId,
    PubkeyInfo? address,
    String? expectedAddress,
    String? error,
  }) = _NewAddressState;

  const NewAddressState._();

  /// Create a success state containing the generated address

  factory NewAddressState.completed(PubkeyInfo address) =>
      NewAddressState(status: NewAddressStatus.completed, address: address);

  factory NewAddressState.error(String error) =>
      NewAddressState(status: NewAddressStatus.error, error: error);

  /// Map in-progress descriptions to the appropriate state
  factory NewAddressState.fromInProgressDescription(
    Object? description,
    int taskId,
  ) {
    if (description is ConfirmAddressDetails) {
      return NewAddressState(
        status: NewAddressStatus.confirmAddress,
        expectedAddress: description.expectedAddress,
        taskId: taskId,
      );
    }

    final desc = description?.toString();

    if (desc == null) {
      return NewAddressState(
        status: NewAddressStatus.initializing,
        message: 'Generating new address...',
        taskId: taskId,
      );
    }

    final lower = desc.toLowerCase();

    if (lower.contains('waiting') && lower.contains('connect')) {
      return NewAddressState(
        status: NewAddressStatus.waitingForDevice,
        message: 'Waiting for device connection',
        taskId: taskId,
      );
    }

    if (lower.contains('follow') && lower.contains('instructions')) {
      return NewAddressState(
        status: NewAddressStatus.waitingForDeviceConfirmation,
        message: 'Follow the instructions on your device',
        taskId: taskId,
      );
    }

    if (lower.contains('pin')) {
      return NewAddressState(
        status: NewAddressStatus.pinRequired,
        message: 'Please enter your device PIN',
        taskId: taskId,
      );
    }

    if (lower.contains('passphrase')) {
      return NewAddressState(
        status: NewAddressStatus.passphraseRequired,
        message: 'Please enter your device passphrase',
        taskId: taskId,
      );
    }

    return NewAddressState(
      status: NewAddressStatus.processing,
      message: desc,
      taskId: taskId,
    );
  }
}

enum NewAddressStatus {
  /// Generation process started
  initializing,

  /// Waiting for the hardware wallet to be connected
  waitingForDevice,

  /// Waiting for user confirmation on the device
  waitingForDeviceConfirmation,

  /// The device requires a PIN entry
  pinRequired,

  /// The device requires a passphrase entry
  passphraseRequired,

  /// User must confirm the generated address on device
  confirmAddress,

  /// Address generation is processing
  processing,

  /// Address generation completed successfully
  completed,

  /// An error occurred during generation
  error,

  /// The operation was cancelled
  cancelled,
}
