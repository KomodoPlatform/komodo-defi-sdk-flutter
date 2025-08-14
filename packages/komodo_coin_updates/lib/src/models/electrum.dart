import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_coin_updates/src/models/contact.dart';

part 'electrum.freezed.dart';
part 'electrum.g.dart';

@freezed
abstract class Electrum with _$Electrum {
  const factory Electrum({
    String? url,
    String? wsUrl,
    String? protocol,
    List<Contact>? contact,
  }) = _Electrum;

  factory Electrum.fromJson(Map<String, dynamic> json) =>
      _$ElectrumFromJson(json);
}
