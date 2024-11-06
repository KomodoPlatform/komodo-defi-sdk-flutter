import 'package:komodo_defi_types/komodo_defi_types.dart';

class LightningChannelAmount {
  LightningChannelAmount({
    required this.type,
    this.value,
  });

  factory LightningChannelAmount.fromJson(Map<String, dynamic> json) {
    return LightningChannelAmount(
      type: json.value<String>('type'),
      value: json.valueOrNull<double?>('value'),
    );
  }
  final String type;
  final double? value;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type};
    if (value != null) json['value'] = value;
    return json;
  }
}
