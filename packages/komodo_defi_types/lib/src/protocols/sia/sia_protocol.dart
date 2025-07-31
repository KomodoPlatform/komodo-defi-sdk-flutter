// TODO!
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class SiaProtocol extends ProtocolClass {
  SiaProtocol._({
    required super.subClass,
    required super.config,
    super.supportedProtocols,
  });

  factory SiaProtocol.fromJson(
    JsonMap json, {
    List<CoinSubClass> supportedProtocols = const [],
  }) {
    _validateSiaConfig(json);
    return SiaProtocol._(
      subClass: CoinSubClass.parse(json.value('type')),
      config: json,
      supportedProtocols: supportedProtocols,
    );
  }

  static void _validateSiaConfig(JsonMap json) {
    final requiredFields = {
      'nodes': 'RPC URLs',
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

  String get chainId =>
      config.value<String>('protocol', 'protocol_data', 'chain_id');

  @override
  bool get supportsMultipleAddresses => false;

  @override
  bool get requiresHdWallet => false;

  @override
  bool get isMemoSupported => false;

  @override
  Uri? explorerTxUrl(String txHash) {
    // SIA uses address-based event URLs instead of transaction hashes
    return null;
  }

  @override
  Uri? explorerAddressUrl(String address) {
    // SIA has a special address events URL format
    return explorerPattern.buildUrl(
      'addresses/{ADDRESS}/events/',
      {'ADDRESS': address},
    );
  }
}
