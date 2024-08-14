class CoinProtocol {
  CoinProtocol({
    required this.type,
    required this.protocolData,
  });
  final CoinType type;
  final CoinProtocolData protocolData;

  Map<String, dynamic> toJson() => {
        'type': type.toJson(),
        'protocol_data': protocolData.toJson(),
      };
}

class CoinProtocolData {
  CoinProtocolData({
    required this.platform,
    required this.network,
    required this.confirmationTargets,
  });
  final String platform;
  final String network;
  final ConfirmationTargets confirmationTargets;

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'network': network,
        'confirmation_targets': confirmationTargets.toJson(),
      };
}

enum CoinType {
  UTXO,
  ETH,
  LIGHTNING,
  ZHTLC,
  // Add other coin types as needed
}

extension CoinTypeExtension on CoinType {
  String toJson() => toString().split('.').last;
}

class ConfirmationTargets {
  ConfirmationTargets({
    required this.background,
    required this.normal,
    required this.highPriority,
  });
  final int background;
  final int normal;
  final int highPriority;

  Map<String, dynamic> toJson() => {
        'background': background,
        'normal': normal,
        'high_priority': highPriority,
      };
}
