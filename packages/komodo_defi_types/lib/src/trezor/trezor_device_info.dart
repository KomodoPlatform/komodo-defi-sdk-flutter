import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'trezor_device_info.freezed.dart';
part 'trezor_device_info.g.dart';

/// Information about a connected Trezor device.
@freezed
abstract class TrezorDeviceInfo with _$TrezorDeviceInfo {
  /// Create a new [TrezorDeviceInfo].
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TrezorDeviceInfo({
    required String deviceId,
    required String devicePubkey,
    String? type,
    String? model,
    String? deviceName,
  }) = _TrezorDeviceInfo;

  /// Construct a [TrezorDeviceInfo] from json.
  factory TrezorDeviceInfo.fromJson(JsonMap json) =>
      _$TrezorDeviceInfoFromJson(json);
}
