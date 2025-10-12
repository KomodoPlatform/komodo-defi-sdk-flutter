import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_chain_data/src/models/chain_info.dart';

part 'evm_chain_info.freezed.dart';
part 'evm_chain_info.g.dart';

/// Native currency information for EVM chains.
@freezed
abstract class NativeCurrency with _$NativeCurrency {
  const factory NativeCurrency({
    required String name,
    required String symbol,
    required int decimals,
  }) = _NativeCurrency;

  factory NativeCurrency.fromJson(Map<String, dynamic> json) =>
      _$NativeCurrencyFromJson(json);
}

/// EVM-specific chain information from chainid.network.
@freezed
abstract class EvmChainInfo with _$EvmChainInfo implements ChainInfo {
  @JsonSerializable(explicitToJson: true)
  const factory EvmChainInfo({
    required String name,
    required int chainId,
    required String shortName,
    required int networkId,
    required NativeCurrency nativeCurrency,
    required List<String> rpc,
    required List<String> faucets,
    @JsonKey(name: 'infoURL') required String infoURL,
  }) = _EvmChainInfo;

  const EvmChainInfo._();

  /// Creates an EvmChainInfo from a JSON map (chainid.network format).
  factory EvmChainInfo.fromJson(Map<String, dynamic> json) =>
      _$EvmChainInfoFromJson(json);

  /// Factory constructor for Ethereum mainnet.
  factory EvmChainInfo.ethereum() => const EvmChainInfo(
    chainId: 1,
    name: 'Ethereum Mainnet',
    networkId: 1,
    shortName: 'eth',
    rpc: ['https://mainnet.infura.io/v3/'],
    nativeCurrency: NativeCurrency(name: 'Ether', symbol: 'ETH', decimals: 18),
    faucets: [],
    infoURL: 'https://ethereum.org',
  );

  /// Factory constructor for Polygon mainnet.
  factory EvmChainInfo.polygon() => const EvmChainInfo(
    chainId: 137,
    name: 'Polygon Mainnet',
    networkId: 137,
    shortName: 'matic',
    rpc: ['https://polygon-rpc.com/'],
    nativeCurrency: NativeCurrency(
      name: 'MATIC',
      symbol: 'MATIC',
      decimals: 18,
    ),
    faucets: [],
    infoURL: 'https://polygon.technology',
  );

  /// Factory constructor for BNB Smart Chain mainnet.
  factory EvmChainInfo.bnbSmartChain() => const EvmChainInfo(
    chainId: 56,
    name: 'BNB Smart Chain Mainnet',
    networkId: 56,
    shortName: 'bnb',
    rpc: ['https://bsc-dataseed1.binance.org/'],
    nativeCurrency: NativeCurrency(
      name: 'BNB Chain Native Token',
      symbol: 'BNB',
      decimals: 18,
    ),
    faucets: [],
    infoURL: 'https://www.bnbchain.org/en',
  );

  /// Factory constructor for Avalanche C-Chain mainnet.
  factory EvmChainInfo.avalanche() => const EvmChainInfo(
    chainId: 43114,
    name: 'Avalanche C-Chain',
    networkId: 43114,
    shortName: 'avax',
    rpc: ['https://api.avax.network/ext/bc/C/rpc'],
    nativeCurrency: NativeCurrency(
      name: 'Avalanche',
      symbol: 'AVAX',
      decimals: 18,
    ),
    faucets: [],
    infoURL: 'https://www.avax.network',
  );

  /// Factory constructor for Fantom Opera mainnet.
  factory EvmChainInfo.fantom() => const EvmChainInfo(
    chainId: 250,
    name: 'Fantom Opera',
    networkId: 250,
    shortName: 'ftm',
    rpc: ['https://rpc.ftm.tools/'],
    nativeCurrency: NativeCurrency(name: 'Fantom', symbol: 'FTM', decimals: 18),
    faucets: [],
    infoURL: 'https://fantom.foundation',
  );

  /// Returns the WalletConnect format chain ID (eip155:chainId).
  @override
  String get walletConnectChainId => 'eip155:$chainId';

  /// Returns true if this is a testnet chain.
  @override
  bool get isTestnet {
    final lowerName = name.toLowerCase();
    return lowerName.contains('test') ||
        lowerName.contains('goerli') ||
        lowerName.contains('sepolia') ||
        lowerName.contains('rinkeby') ||
        lowerName.contains('kovan') ||
        lowerName.contains('ropsten');
  }

  /// Returns true if this is a mainnet chain.
  @override
  bool get isMainnet => !isTestnet;

  /// Returns the primary RPC endpoint if available.
  String? get primaryRpcEndpoint => rpc.isNotEmpty ? rpc.first : null;

  /// Returns the native currency symbol.
  String get nativeCurrencySymbol => nativeCurrency.symbol;
}
