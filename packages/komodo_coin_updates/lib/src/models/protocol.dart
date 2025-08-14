import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_coin_updates/src/models/protocol_data.dart';

part 'protocol.freezed.dart';
part 'protocol.g.dart';

@freezed
abstract class Protocol with _$Protocol {
  const factory Protocol({
    String? type,
    ProtocolData? protocolData,
    String? bip44,
  }) = _Protocol;

  factory Protocol.fromJson(Map<String, dynamic> json) =>
      _$ProtocolFromJson(json);
}
