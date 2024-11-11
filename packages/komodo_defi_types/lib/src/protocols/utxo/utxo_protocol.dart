import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class UtxoProtocol extends ProtocolClass {
  UtxoProtocol._({
    required super.subClass,
    required super.config,
    super.supportedProtocols,
  });

  factory UtxoProtocol.fromJson(
    JsonMap json, {
    List<CoinSubClass> supportedProtocols = const [],
  }) {
    _validateUtxoConfig(json);
    return UtxoProtocol._(
      subClass: CoinSubClass.parse(json.value('type')),
      config: json,
      supportedProtocols: supportedProtocols,
    );
  }

  @override
  UtxoActivationParams defaultActivationParams() {
    return UtxoActivationParams.fromJson(config);
  }

  @override
  bool get supportsMultipleAddresses => true;

  @override
  bool get requiresHdWallet => false;

  static void _validateUtxoConfig(JsonMap json) {
    if (json.value<bool>('is_testnet') == true) {
      return;
    }

    final requiredFields = <String, String>{
      // The validation below has been commented out as there are a few valid
      // coins that don't have these fields. Consider removing these checks or
      // adding the missing fields to the coins config.
      // 'pubtype': 'Public key type',
      // 'p2shtype': 'P2SH type',
      // 'wiftype': 'WIF type',
      // 'txfee': 'Transaction fee',
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

  int? get pubtype => config.valueOrNull<int>('pubtype');
  int? get p2shtype => config.valueOrNull<int>('p2shtype');
  int? get wiftype => config.valueOrNull<int>('wiftype');
  int? get txVersion => config.valueOrNull<int>('txversion');
  int? get txFee => config.valueOrNull<int>('txfee');
  bool get overwintered => config.valueOrNull<bool>('overwintered') ?? false;
}
