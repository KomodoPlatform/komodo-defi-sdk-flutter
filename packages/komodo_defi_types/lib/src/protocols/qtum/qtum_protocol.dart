import 'package:komodo_defi_types/komodo_defi_types.dart';

class QtumProtocol extends ProtocolClass {
  QtumProtocol._({
    required super.subClass,
    required super.config,
  });

  factory QtumProtocol.fromJson(JsonMap json) {
    _validateQtumConfig(json);
    return QtumProtocol._(
      subClass: CoinSubClass.parse(json.value('type')),
      config: json,
    );
  }

  static void _validateQtumConfig(JsonMap json) {
    final requiredFields = {
      'pubtype': 'Public key type',
      'p2shtype': 'P2SH type',
      'wiftype': 'WIF type',
      'txfee': 'Transaction fee',
      'electrum': 'Electrum servers',
    };

    for (final field in requiredFields.entries) {
      if (!json.containsKey(field.key)) {
        throw MissingProtocolFieldException(
          field.value,
          field.key,
        );
      }
    }
  }

  int get pubtype => config.value<int>('pubtype');
  int get p2shtype => config.value<int>('p2shtype');
  int get wiftype => config.value<int>('wiftype');
  int get txVersion => config.value<int>('txversion');
  int get txFee => config.value<int>('txfee');

  @override
  List<String> get requiredServers =>
      config.value<List<dynamic>>('electrum').cast<String>();
}
