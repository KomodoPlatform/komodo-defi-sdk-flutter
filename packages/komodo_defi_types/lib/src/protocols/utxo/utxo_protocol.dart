import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class UtxoProtocol extends ProtocolClass {
  UtxoProtocol._({
    required super.subClass,
    required super.config,
  });

  factory UtxoProtocol.fromJson(JsonMap json) {
    _validateUtxoConfig(json);
    return UtxoProtocol._(
      subClass: CoinSubClass.parse(json.value('type')),
      config: json,
    );
  }

  UtxoActivationParams defaultActivationParams() {
    return UtxoActivationParams.fromJsonConfig(config);
  }

  static void _validateUtxoConfig(JsonMap json) {
    if (json.value<bool>('is_testnet') == true) {
      return;
    }

    final requiredFields = {
      'pubtype': 'Public key type',
      'p2shtype': 'P2SH type',
      'wiftype': 'WIF type',
      'txfee': 'Transaction fee',
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
  bool get overwintered => config.valueOrNull<bool>('overwintered') ?? false;

  @override
  List<String> get requiredServers =>
      config.value<List<dynamic>>('electrum').cast<String>();
}
