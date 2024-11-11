import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class Erc20Protocol extends ProtocolClass {
  Erc20Protocol._({
    required super.subClass,
    required super.config,
  });

  factory Erc20Protocol.fromJson(JsonMap json) {
    _validateErc20Config(json);
    return Erc20Protocol._(
      subClass: CoinSubClass.parse(json.value('type')),
      config: json,
    );
  }

  @override
  bool get supportsMultipleAddresses => true;

  @override
  bool get requiresHdWallet => false;

  @override
  ActivationParams defaultActivationParams([List<Asset>? childTokens]) {
    return childTokens == null
        ? Erc20ActivationParams.fromJsonConfig(super.config)
        : EthWithTokensActivationParams.fromJson(config).copyWith(
            erc20Tokens: childTokens
                .map((token) => TokensRequest(ticker: token.id.id))
                .toList(),
          );
  }

  static void _validateErc20Config(JsonMap json) {
    final requiredFields = {
      'chain_id': 'Chain ID',
      'nodes': 'RPC nodes',
      'swap_contract_address': 'Swap contract',
      'fallback_swap_contract': 'Fallback swap contract',
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

  int get chainId => config.value<int>('chain_id');

  List<EvmNode> get nodes =>
      config.value<JsonList>('nodes').map(EvmNode.fromJson).toList();

  String get swapContractAddress =>
      config.value<String>('swap_contract_address');

  String get fallbackSwapContract =>
      config.value<String>('fallback_swap_contract');
}
