import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Confirmation settings for order
class OrderConfirmationSettings {
  OrderConfirmationSettings({
    this.baseConfs,
    this.baseNota,
    this.relConfs,
    this.relNota,
  });

  factory OrderConfirmationSettings.fromJson(Map<String, dynamic> json) {
    return OrderConfirmationSettings(
      baseConfs: json.valueOrNull<int>('base_confs'),
      baseNota: json.valueOrNull<bool>('base_nota'),
      relConfs: json.valueOrNull<int>('rel_confs'),
      relNota: json.valueOrNull<bool>('rel_nota'),
    );
  }

  final int? baseConfs;
  final bool? baseNota;
  final int? relConfs;
  final bool? relNota;

  Map<String, dynamic> toJson() => {
    if (baseConfs != null) 'base_confs': baseConfs,
    if (baseNota != null) 'base_nota': baseNota,
    if (relConfs != null) 'rel_confs': relConfs,
    if (relNota != null) 'rel_nota': relNota,
  };
}
