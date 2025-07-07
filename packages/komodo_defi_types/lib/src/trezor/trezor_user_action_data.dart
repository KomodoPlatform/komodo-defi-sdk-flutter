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
  @Assert(
    '((actionType == TrezorUserActionType.trezorPin && pin != null) || '
        '(actionType == TrezorUserActionType.trezorPassphrase && passphrase != null))',
    'PIN must be provided for TrezorPin action, passphrase for TrezorPassphrase action',
  )
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TrezorUserActionData({
    required TrezorUserActionType actionType,
    String? pin,
    String? passphrase,
  }) = _TrezorUserActionData;

  factory TrezorUserActionData.fromJson(JsonMap json) =>
      _$TrezorUserActionDataFromJson(json);
}
