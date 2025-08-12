import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

// ignore_for_file: non_abstract_class_inherits_abstract_member

part 'trezor_user_action_data.freezed.dart';
part 'trezor_user_action_data.g.dart';

/// Type of user action required by the Trezor device.
@JsonEnum(valueField: 'value')
enum TrezorUserActionType {
  trezorPin('TrezorPin'),
  trezorPassphrase('TrezorPassphrase');

  const TrezorUserActionType(this.value);
  final String value;
}

/// Data sent to the API when providing a PIN or passphrase to a Trezor device.
@freezed
abstract class TrezorUserActionData with _$TrezorUserActionData {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TrezorUserActionData({
    required TrezorUserActionType actionType,
    String? pin,
    String? passphrase,
  }) = _TrezorUserActionData;

  /// Convenience factory for PIN actions with strong validation.
  factory TrezorUserActionData.pin(String pin) {
    if (pin.isEmpty || !_pinRegex.hasMatch(pin)) {
      throw ArgumentError('PIN must contain only digits and cannot be empty.');
    }
    return TrezorUserActionData(
      actionType: TrezorUserActionType.trezorPin,
      pin: pin,
    );
  }

  /// Convenience factory for passphrase actions with strong validation.
  factory TrezorUserActionData.passphrase(String passphrase) {
    // Empty passphrase is allowed to access default wallet
    return TrezorUserActionData(
      actionType: TrezorUserActionType.trezorPassphrase,
      passphrase: passphrase,
    );
  }

  factory TrezorUserActionData.fromJson(JsonMap json) =>
      _$TrezorUserActionDataFromJson(json);

  static final RegExp _pinRegex = RegExp(r'^\d+$');
}
