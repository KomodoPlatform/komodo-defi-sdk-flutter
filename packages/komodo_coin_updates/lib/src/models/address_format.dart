import 'package:freezed_annotation/freezed_annotation.dart';

part 'address_format.freezed.dart';
part 'address_format.g.dart';

@freezed
abstract class AddressFormat with _$AddressFormat {
  const factory AddressFormat({String? format, String? network}) =
      _AddressFormat;

  factory AddressFormat.fromJson(Map<String, dynamic> json) =>
      _$AddressFormatFromJson(json);
}
