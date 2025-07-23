import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class TendermintProtocol extends ProtocolClass {
  TendermintProtocol._({
    required super.subClass,
    required super.config,
    super.supportedProtocols,
  });

  factory TendermintProtocol.fromJson(
    JsonMap json, {
    List<CoinSubClass> supportedProtocols = const [],
  }) {
    _validateTendermintConfig(json);
    return TendermintProtocol._(
      subClass: CoinSubClass.parse(json.value('type')),
      config: json,
      supportedProtocols: supportedProtocols,
    );
  }

  static void _validateTendermintConfig(JsonMap json) {
    final requiredFields = {
      'rpc_urls': 'RPC URLs',
      // 'account_prefix': 'Account prefix',
      // 'chain_id': 'Chain ID',
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

  JsonList get rpcUrlsMap => config.value<JsonList>('rpc_urls');

  String? get accountPrefix => config.valueOrNull<String>('account_prefix');

  String? get chainId =>
      config.valueOrNull<String>('protocol', 'protocol_data', 'chain_id');

  @override
  bool get supportsMultipleAddresses => true;

  @override
  bool get requiresHdWallet => false;
}
