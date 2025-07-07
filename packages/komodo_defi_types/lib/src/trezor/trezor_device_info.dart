import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

// ignore_for_file: non_abstract_class_inherits_abstract_member

part 'trezor_device_info.freezed.dart';
part 'trezor_device_info.g.dart';

/// Information about a connected Trezor device.
@freezed
abstract class TrezorDeviceInfo with _$TrezorDeviceInfo {
  /// Create a new [TrezorDeviceInfo].
  const factory TrezorDeviceInfo({
    String? type,
    String? model,
    @JsonKey(name: 'device_name') String? deviceName,
    @JsonKey(name: 'device_id') required String deviceId,
    @JsonKey(name: 'device_pubkey') required String devicePubkey,
  }) = _TrezorDeviceInfo;

  /// Construct a [TrezorDeviceInfo] from json.
  factory TrezorDeviceInfo.fromJson(JsonMap json) =>
      _$TrezorDeviceInfoFromJson(json);
}
