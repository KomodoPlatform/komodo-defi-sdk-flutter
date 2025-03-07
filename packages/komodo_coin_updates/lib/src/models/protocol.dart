import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'protocol_data.dart';

part 'adapters/protocol_adapter.dart';

class Protocol extends Equatable {
  const Protocol({
    this.type,
    this.protocolData,
    this.bip44,
  });

  factory Protocol.fromJson(Map<String, dynamic> json) {
    return Protocol(
      type: json['type'] as String?,
      protocolData: (json['protocol_data'] != null)
          ? ProtocolData.fromJson(json['protocol_data'] as Map<String, dynamic>)
          : null,
      bip44: json['bip44'] as String?,
    );
  }

  final String? type;
  final ProtocolData? protocolData;
  final String? bip44;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'protocol_data': protocolData?.toJson(),
      'bip44': bip44,
    };
  }

  @override
  List<Object?> get props => <Object?>[type, protocolData, bip44];
}
